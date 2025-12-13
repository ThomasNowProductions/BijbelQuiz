import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import '../services/logger.dart';
import '../models/quiz_question.dart';
import '../providers/game_stats_provider.dart';
import '../providers/lesson_progress_provider.dart';
import '../providers/settings_provider.dart';
import '../services/question_cache_service.dart';
import '../services/star_transaction_service.dart';
import '../services/store_service.dart';
import '../services/lesson_service.dart';
import '../services/time_tracking_service.dart';
import '../services/coupon_service.dart';
import '../services/messaging_service.dart';
import '../services/sync_service.dart';
import '../theme/theme_manager.dart';
import '../utils/bible_book_mapper.dart';
import '../utils/automatic_error_reporter.dart';
import '../models/api_key.dart';
import '../services/api_key_manager.dart';

/// Service for running a local HTTP API server
class ApiService {
  static const String _defaultBindAddress = '0.0.0.0';
  static const String _apiVersion = 'v1';
  static const int _maxRequestsPerMinute = 100;
  static const Duration _rateLimitWindow = Duration(minutes: 1);
  static const int _maxDailyStars = 150; // Maximum stars that can be added per day

  HttpServer? _server;
  bool _isRunning = false;
  final Map<String, List<DateTime>> _requestLog = {};
  final Map<String, int> _dailyStarsAdded = {}; // date -> total stars added
  final ApiKeyManager _apiKeyManager = ApiKeyManager();

  /// Whether the API server is currently running
  bool get isRunning => _isRunning;

  /// Gets the current server port if running
  int? get currentPort => _server?.port;

  /// Gets the server address if running
  String? get serverAddress => _server?.address.host;

  /// Clean up old rate limit entries periodically
  Timer? _cleanupTimer;

  /// Start the cleanup timer for rate limiting
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _cleanupOldRequests();
    });
  }

  /// Stop the cleanup timer
  void _stopCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// Clean up old request entries for rate limiting
  void _cleanupOldRequests() {
    final now = DateTime.now();
    final cutoff = now.subtract(_rateLimitWindow);

    _requestLog.removeWhere((ip, requests) {
      requests.removeWhere((timestamp) => timestamp.isBefore(cutoff));
      return requests.isEmpty;
    });

    // Also clean up old daily stars entries (older than 7 days)
    final sevenDaysAgo = now.subtract(Duration(days: 7));
    final cutoffDate = _getDateString(sevenDaysAgo);

    _dailyStarsAdded.removeWhere((date, _) => date.compareTo(cutoffDate) < 0);
  }

  /// Get date string in YYYY-MM-DD format
  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Starts the API server on the specified port with authentication
  Future<void> startServer({
    required int port,
    required SettingsProvider settingsProvider,
    required GameStatsProvider gameStatsProvider,
    required LessonProgressProvider lessonProgressProvider,
    required QuestionCacheService questionCacheService,
  }) async {
    if (_isRunning) {
      AppLogger.warning('API server is already running');
      return;
    }

    try {
      AppLogger.info('Starting API server on port $port...');

      final app = shelf_router.Router()
        ..get('/$_apiVersion/health', _handleHealth)
        ..get('/$_apiVersion/questions',
            _handleGetQuestions(questionCacheService))
        ..get('/$_apiVersion/questions/<category>',
            _handleGetQuestionsByCategory(questionCacheService))
        ..get('/$_apiVersion/progress',
            _handleGetProgress(lessonProgressProvider))
        ..get('/$_apiVersion/stats', _handleGetStats(gameStatsProvider))
        ..get('/$_apiVersion/settings', _handleGetSettings(settingsProvider))
        ..get('/$_apiVersion/stars/balance', _handleGetStarBalance())
        ..post('/$_apiVersion/stars/add', _handleAddStars())
        ..post('/$_apiVersion/stars/spend', _handleSpendStars())
        ..get('/$_apiVersion/stars/transactions', _handleGetStarTransactions())
        ..get('/$_apiVersion/stars/stats', _handleGetStarStats())
        ..get('/$_apiVersion/store/items', _handleGetStoreItems())
        ..get('/$_apiVersion/store/items/<itemKey>', _handleGetStoreItemByKey())
        ..get('/$_apiVersion/lessons', _handleGetLessons())
        ..get('/$_apiVersion/time/tracking', _handleGetTimeTracking())
        ..post('/$_apiVersion/coupons/redeem', _handleRedeemCoupon())
        ..get('/$_apiVersion/messages', _handleGetMessages())
        ..get('/$_apiVersion/messages/<messageId>/reactions', _handleGetMessageReactions())
        ..get('/$_apiVersion/sync/status', _handleGetSyncStatus())
        ..get('/$_apiVersion/analytics/features', _handleGetFeatureAnalytics())
        ..get('/$_apiVersion/bible/books', _handleGetBibleBooks())
        ..get('/$_apiVersion/themes', _handleGetThemes());

      final handler = const Pipeline()
          .addMiddleware(_createSecurityHeadersMiddleware())
          .addMiddleware(_createRateLimitingMiddleware())
          .addMiddleware(_createAprilFoolsMiddleware())
          .addMiddleware(_createCorsMiddleware())
          .addMiddleware(_createValidationMiddleware())
          .addMiddleware(_createLoggingMiddleware())
          .addMiddleware(_createAuthenticationMiddleware())
          .addHandler(app.call);

      _server = await shelf_io.serve(handler, _defaultBindAddress, port);
      _isRunning = true;
      _startCleanupTimer();

      AppLogger.info(
          'API server started successfully on ${_server!.address.host}:${_server!.port}');
      AppLogger.info(
          'API server is accessible at http://localhost:$port/$_apiVersion and http://${_server!.address.host}:$port/$_apiVersion');
    } catch (e) {
      AppLogger.error('Failed to start API server: $e');
      _isRunning = false;
      throw Exception('Failed to start API server: $e');
    }
  }

  /// Stops the API server
  Future<void> stopServer() async {
    if (!_isRunning || _server == null) {
      AppLogger.info('API server stop requested but server is not running');
      return;
    }

    try {
      AppLogger.info('Stopping API server...');
      _stopCleanupTimer();
      await _server!.close(force: true); // Force close to ensure cleanup
      _isRunning = false;
      _server = null;
      _requestLog.clear();
      _dailyStarsAdded.clear();
      AppLogger.info('API server stopped successfully');
    } catch (e) {
      AppLogger.error('Failed to stop API server: $e');
      _isRunning = false;
      _server = null;
      _requestLog.clear();
      _dailyStarsAdded.clear();
      // Don't throw exception on stop failure to avoid crashes during app shutdown
      AppLogger.warning('API server stopped with errors but continuing');
    }
  }

  /// Middleware for April Fools' prank (returns 418 on April 1st)
  Middleware _createAprilFoolsMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        final now = DateTime.now();
        if (now.month == 4 && now.day == 1) {
          // Allow health endpoint to work normally
          if (request.url.path.endsWith('/health')) {
            return await innerHandler(request);
          }

          // Return 418 I'm a teapot for all other endpoints on April 1st
          return Response(418,
              body: json.encode({
                'error': 'I\'m a teapot',
                'message': 'April Fools! This server is a teapot today.',
                'timestamp': now.toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        return await innerHandler(request);
      };
    };
  }

  /// Middleware for API key authentication (allows public access to /health)
  Middleware _createAuthenticationMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        // Allow public access to health endpoint
        if (request.url.path.endsWith('/health')) {
          return await innerHandler(request);
        }

        // Extract provided API key from headers
        final authHeader = request.headers['authorization'];
        final apiKeyHeader = request.headers['x-api-key'];

        String? providedKey;

        if (authHeader != null && authHeader.startsWith('Bearer ')) {
          providedKey = authHeader.substring(7);
        } else if (apiKeyHeader != null) {
          providedKey = apiKeyHeader;
        }

        if (providedKey == null) {
          AppLogger.warning(
              'API authentication failed: No API key provided from ${request.headers['x-forwarded-for'] ?? request.headers['x-real-ip'] ?? 'unknown IP'}');
          return Response.forbidden(
              json.encode({
                'error': 'Invalid or missing API key',
                'message':
                    'Please provide a valid API key via Authorization header (Bearer token) or X-API-Key header',
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        // Find the API key in the stored keys
        final apiKey = await _apiKeyManager.findApiKey(providedKey);
        if (apiKey == null || !apiKey.isActive) {
          AppLogger.warning(
              'API authentication failed: Invalid or inactive API key from ${request.headers['x-forwarded-for'] ?? request.headers['x-real-ip'] ?? 'unknown IP'}');
          return Response.forbidden(
              json.encode({
                'error': 'Invalid or inactive API key',
                'message':
                    'The provided API key is invalid or has been deactivated',
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        // Increment the request count for the API key
        await _apiKeyManager.incrementRequestCount(apiKey.id);

        return await innerHandler(request);
      };
    };
  }

  /// Middleware for rate limiting
  Middleware _createRateLimitingMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        // Skip rate limiting for health checks
        if (request.url.path.endsWith('/health')) {
          return await innerHandler(request);
        }

        final clientIp = _getClientIp(request);
        final now = DateTime.now();

        // Clean up old requests for this IP
        if (_requestLog.containsKey(clientIp)) {
          _requestLog[clientIp]!.removeWhere(
              (timestamp) => now.difference(timestamp) > _rateLimitWindow);
        } else {
          _requestLog[clientIp] = [];
        }

        // Check rate limit
        if (_requestLog[clientIp]!.length >= _maxRequestsPerMinute) {
          AppLogger.warning('Rate limit exceeded for IP: $clientIp');
          return Response(429,
              body: json.encode({
                'error': 'Rate limit exceeded',
                'message':
                    'Too many requests. Maximum $_maxRequestsPerMinute requests per minute allowed.',
                'retry_after': _rateLimitWindow.inSeconds,
                'timestamp': now.toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        // Add current request to log
        _requestLog[clientIp]!.add(now);

        return await innerHandler(request);
      };
    };
  }

  /// Middleware for security headers
  Middleware _createSecurityHeadersMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        final response = await innerHandler(request);

        return response.change(headers: {
          'X-Content-Type-Options': 'nosniff',
          'X-Frame-Options': 'DENY',
          'X-XSS-Protection': '1; mode=block',
          'Referrer-Policy': 'strict-origin-when-cross-origin',
          'Content-Security-Policy': "default-src 'self'",
          'Server': 'BijbelQuiz-API',
        });
      };
    };
  }

  /// Middleware for request validation
  Middleware _createValidationMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        // Validate request size (prevent large payloads)
        final contentLength = request.contentLength;
        if (contentLength != null && contentLength > 1024 * 1024) {
          // 1MB limit
          return Response(413,
              body: json.encode({
                'error': 'Request too large',
                'message':
                    'Request payload exceeds maximum allowed size of 1MB',
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        return await innerHandler(request);
      };
    };
  }

  /// Enhanced logging middleware
  Middleware _createLoggingMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        final startTime = DateTime.now();
        final clientIp = _getClientIp(request);
        final userAgent =
            _sanitizeHeader(request.headers['user-agent'] ?? 'Unknown');

        // Only log non-sensitive information
        AppLogger.info(
            'API Request: ${request.method} ${request.url.path} from $clientIp (UA: ${userAgent.length > 100 ? '${userAgent.substring(0, 100)}...' : userAgent})');

        try {
          final response = await innerHandler(request);
          final duration = DateTime.now().difference(startTime);

          AppLogger.info(
              'API Response: ${response.statusCode} for ${request.method} ${request.url.path} (${duration.inMilliseconds}ms)');
          return response;
        } catch (e) {
          final duration = DateTime.now().difference(startTime);
          AppLogger.error(
              'API Error: ${request.method} ${request.url.path} failed after ${duration.inMilliseconds}ms - ${e.toString()}');
          rethrow;
        }
      };
    };
  }

  /// Sanitizes headers to prevent sensitive data from being logged
  String _sanitizeHeader(String headerValue) {
    // Remove potential sensitive data from headers
    String sanitized = headerValue;

    // Remove API keys, tokens, etc. from headers
    // Sanitize using the centralized AppLogger method
    sanitized = AppLogger.sanitizeLogMessage(sanitized);

    return sanitized;
  }

  /// Get client IP address from request
  String _getClientIp(Request request) {
    // Try X-Forwarded-For header first (for proxies/load balancers)
    final forwardedFor = request.headers['x-forwarded-for'];
    if (forwardedFor != null && forwardedFor.isNotEmpty) {
      return forwardedFor.split(',').first.trim();
    }

    // Try X-Real-IP header
    final realIp = request.headers['x-real-ip'];
    if (realIp != null && realIp.isNotEmpty) {
      return realIp;
    }

    // Fallback to connection info (safer approach)
    try {
      final connectionInfo = request.context['shelf.io.connection.info'];
      if (connectionInfo != null) {
        // Use string representation as fallback
        return connectionInfo.toString();
      }
    } catch (e) {
      // Ignore errors and use fallback
    }

    return 'unknown';
  }

  /// Middleware for CORS support
  Middleware _createCorsMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        final response = await innerHandler(request);

        return response.change(headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers':
              'Content-Type, Authorization, X-API-Key',
          'Access-Control-Max-Age': '86400', // 24 hours
        });
      };
    };
  }

  /// Health check endpoint
  Future<Response> _handleHealth(Request request) async {
    try {
      return Response.ok(
          json.encode({
            'status': 'healthy',
            'timestamp': DateTime.now().toIso8601String(),
            'service': 'BijbelQuiz API',
            'version': _apiVersion,
            'uptime': _isRunning ? 'running' : 'stopped',
          }),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      AppLogger.error('Health check failed: $e');
      return Response.internalServerError(
          body: json.encode({
            'status': 'unhealthy',
            'timestamp': DateTime.now().toIso8601String(),
            'error': 'Health check failed',
            'message': 'An internal error occurred during health check',
          }),
          headers: {'Content-Type': 'application/json'});
    }
  }

  /// Get questions endpoint
  Future<Response> Function(Request) _handleGetQuestions(
      QuestionCacheService questionCacheService) {
    return (Request request) async {
      final startTime = DateTime.now();
      String? category;
      String? limitParam;
      String? difficulty;

      try {
        category = request.url.queryParameters['category'];
        limitParam = request.url.queryParameters['limit'] ?? '10';
        difficulty = request.url.queryParameters['difficulty'];

        // Validate and parse limit parameter
        final limit = int.tryParse(limitParam);
        if (limit == null || limit < 1 || limit > 50) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Invalid limit parameter',
                'message': 'Limit must be a number between 1 and 50',
                'timestamp': DateTime.now().toIso8601String(),
                'valid_range': '1-50',
              }),
              headers: {'Content-Type': 'application/json'});
        }

        // Validate difficulty parameter if provided
        if (difficulty != null && difficulty.isNotEmpty) {
          final validDifficulties = ['1', '2', '3', '4', '5'];
          if (!validDifficulties.contains(difficulty.toLowerCase())) {
            return Response.badRequest(
                body: json.encode({
                  'error': 'Invalid difficulty parameter',
                  'message': 'Difficulty must be a number between 1 and 5',
                  'timestamp': DateTime.now().toIso8601String(),
                  'valid_values': validDifficulties,
                }),
                headers: {'Content-Type': 'application/json'});
          }
        }

        List<QuizQuestion> questions;

        if (category != null && category.isNotEmpty) {
          questions = await questionCacheService
              .getQuestionsByCategory('nl', category, count: limit);
        } else {
          questions =
              await questionCacheService.getQuestions('nl', count: limit);
        }

        // Filter by difficulty if specified
        if (difficulty != null && difficulty.isNotEmpty) {
          questions = questions
              .where(
                  (q) => q.difficulty.toLowerCase() == difficulty!.toLowerCase())
              .toList();
        }

        final questionsData = questions
            .map((q) => {
                  'question': q.question,
                  'correctAnswer': q.correctAnswer,
                  'incorrectAnswers': q.incorrectAnswers,
                  'difficulty': q.difficulty,
                  'type': q.type.name,
                  'categories': q.categories,
                  'biblicalReference': q.biblicalReference,
                  'allOptions': q.allOptions,
                  'correctAnswerIndex': q.correctAnswerIndex,
                })
            .toList();

        final response = {
          'questions': questionsData,
          'count': questions.length,
          'category': category,
          'difficulty': difficulty,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Questions endpoint: Retrieved ${questions.length} questions in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in questions endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportQuestionError(
          message: 'API questions endpoint failed after ${duration.inMilliseconds}ms',
          questionId: 'api_questions_endpoint',
          questionText: 'Questions loading via API failed',
          additionalInfo: {
            'endpoint': '/v1/questions',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
            'category': category,
            'limit': limitParam,
            'difficulty': difficulty,
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to load questions',
              'message':
                  'An internal error occurred while processing your request',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Get questions by category endpoint
  Future<Response> Function(Request) _handleGetQuestionsByCategory(
      QuestionCacheService questionCacheService) {
    return (Request request) async {
      final startTime = DateTime.now();
      String? category;
      String? limitParam;
      String? difficulty;

      try {
        category = request.params['category'];
        if (category == null || category.isEmpty) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Missing category parameter',
                'message': 'Category parameter is required in the URL path',
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        limitParam = request.url.queryParameters['limit'] ?? '10';
        difficulty = request.url.queryParameters['difficulty'];

        // Validate and parse limit parameter
        final limit = int.tryParse(limitParam);
        if (limit == null || limit < 1 || limit > 50) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Invalid limit parameter',
                'message': 'Limit must be a number between 1 and 50',
                'timestamp': DateTime.now().toIso8601String(),
                'valid_range': '1-50',
              }),
              headers: {'Content-Type': 'application/json'});
        }

        // Validate difficulty parameter if provided
        if (difficulty != null && difficulty.isNotEmpty) {
          final validDifficulties = ['1', '2', '3', '4', '5'];
          if (!validDifficulties.contains(difficulty.toLowerCase())) {
            return Response.badRequest(
                body: json.encode({
                  'error': 'Invalid difficulty parameter',
                  'message': 'Difficulty must be a number between 1 and 5',
                  'timestamp': DateTime.now().toIso8601String(),
                  'valid_values': validDifficulties,
                }),
                headers: {'Content-Type': 'application/json'});
          }
        }

        final questions = await questionCacheService
            .getQuestionsByCategory('nl', category, count: limit);

        // Filter by difficulty if specified
        final filteredQuestions = difficulty != null && difficulty.isNotEmpty
            ? questions
                .where((q) =>
                    q.difficulty.toLowerCase() == difficulty!.toLowerCase())
                .toList()
            : questions;

        final questionsData = filteredQuestions
            .map((q) => {
                  'question': q.question,
                  'correctAnswer': q.correctAnswer,
                  'incorrectAnswers': q.incorrectAnswers,
                  'difficulty': q.difficulty,
                  'type': q.type.name,
                  'categories': q.categories,
                  'biblicalReference': q.biblicalReference,
                  'allOptions': q.allOptions,
                  'correctAnswerIndex': q.correctAnswerIndex,
                })
            .toList();

        final response = {
          'questions': questionsData,
          'count': filteredQuestions.length,
          'category': category,
          'difficulty': difficulty,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Questions by category endpoint: Retrieved ${filteredQuestions.length} questions for category "$category" in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in questions by category endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportQuestionError(
          message: 'API questions by category endpoint failed after ${duration.inMilliseconds}ms',
          questionId: 'api_questions_by_category_endpoint',
          questionText: 'Questions loading by category via API failed',
          additionalInfo: {
            'endpoint': '/v1/questions/<category>',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
            'category': category,
            'limit': limitParam,
            'difficulty': difficulty,
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to load questions for category',
              'message':
                  'An internal error occurred while processing your request',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Get user progress endpoint
  Future<Response> Function(Request) _handleGetProgress(
      LessonProgressProvider progressProvider) {
    return (Request request) async {
      final startTime = DateTime.now();

      try {
        final exportData = progressProvider.getExportData();
        final progressData = {
          'unlockedCount': progressProvider.unlockedCount,
          'bestStarsByLesson': exportData['bestStarsByLesson'],
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Progress endpoint: Retrieved progress data in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(progressData),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in progress endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportStorageError(
          message: 'API progress endpoint failed after ${duration.inMilliseconds}ms',
          operation: 'get_progress',
          additionalInfo: {
            'endpoint': '/v1/progress',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to get progress data',
              'message':
                  'An internal error occurred while retrieving progress data',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Get game stats endpoint
  Future<Response> Function(Request) _handleGetStats(
      GameStatsProvider statsProvider) {
    return (Request request) async {
      final startTime = DateTime.now();

      try {
        final statsData = {
          'score': statsProvider.score,
          'currentStreak': statsProvider.currentStreak,
          'longestStreak': statsProvider.longestStreak,
          'incorrectAnswers': statsProvider.incorrectAnswers,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Stats endpoint: Retrieved stats data in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(statsData),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in stats endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportStorageError(
          message: 'API stats endpoint failed after ${duration.inMilliseconds}ms',
          operation: 'get_stats',
          additionalInfo: {
            'endpoint': '/v1/stats',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to get stats data',
              'message':
                  'An internal error occurred while retrieving statistics',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Get settings endpoint
  Future<Response> Function(Request) _handleGetSettings(
      SettingsProvider settingsProvider) {
    return (Request request) async {
      final startTime = DateTime.now();

      try {
        final settingsData = {
          'themeMode': settingsProvider.themeMode.name,
          'gameSpeed': settingsProvider.gameSpeed,
          'mute': settingsProvider.mute,
          'analyticsEnabled': settingsProvider.analyticsEnabled,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Settings endpoint: Retrieved settings data in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(settingsData),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in settings endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportStorageError(
          message: 'API settings endpoint failed after ${duration.inMilliseconds}ms',
          operation: 'get_settings',
          additionalInfo: {
            'endpoint': '/v1/settings',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to get settings data',
              'message': 'An internal error occurred while retrieving settings',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Get current star balance endpoint
  Future<Response> Function(Request) _handleGetStarBalance() {
    return (Request request) async {
      final startTime = DateTime.now();

      try {
        final starService = StarTransactionService.instance;
        final balance = starService.currentBalance;

        final response = {
          'balance': balance,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Star balance endpoint: Retrieved balance $balance in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in star balance endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportStorageError(
          message: 'API star balance endpoint failed after ${duration.inMilliseconds}ms',
          operation: 'get_star_balance',
          additionalInfo: {
            'endpoint': '/v1/stars/balance',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to get star balance',
              'message':
                  'An internal error occurred while retrieving star balance',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Add stars endpoint
  Future<Response> Function(Request) _handleAddStars() {
    return (Request request) async {
      final startTime = DateTime.now();

      try {
        final payload =
            json.decode(await request.readAsString()) as Map<String, dynamic>;
        final amount = payload['amount'] as int?;
        final reason = payload['reason'] as String?;
        final lessonId = payload['lessonId'] as String?;

        // Validate required fields
        if (amount == null || amount <= 0) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Invalid amount',
                'message': 'Amount must be a positive integer',
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        if (reason == null || reason.isEmpty) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Invalid reason',
                'message': 'Reason is required and cannot be empty',
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        // Check daily limit
        final today = _getDateString(DateTime.now());
        final currentDailyTotal = _dailyStarsAdded[today] ?? 0;

        if (currentDailyTotal + amount > _maxDailyStars) {
          return Response(429,
              body: json.encode({
                'error': 'Daily star limit exceeded',
                'message': 'Cannot add $amount stars. Daily limit of $_maxDailyStars stars exceeded.',
                'current_daily_total': currentDailyTotal,
                'requested_amount': amount,
                'remaining_allowed': _maxDailyStars - currentDailyTotal,
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        final starService = StarTransactionService.instance;
        final success = await starService.addStars(
          amount: amount,
          reason: reason,
          lessonId: lessonId,
        );

        if (!success) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Failed to add stars',
                'message': 'Could not add stars to balance',
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        // Update daily total
        _dailyStarsAdded[today] = currentDailyTotal + amount;

        final response = {
          'success': true,
          'balance': starService.currentBalance,
          'amount_added': amount,
          'reason': reason,
          'daily_total_added': _dailyStarsAdded[today],
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Add stars endpoint: Added $amount stars (daily total: ${_dailyStarsAdded[today]}) in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in add stars endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportStorageError(
          message: 'API add stars endpoint failed after ${duration.inMilliseconds}ms',
          operation: 'add_stars',
          additionalInfo: {
            'endpoint': '/v1/stars/add',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to add stars',
              'message': 'An internal error occurred while adding stars',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Spend stars endpoint
  Future<Response> Function(Request) _handleSpendStars() {
    return (Request request) async {
      final startTime = DateTime.now();

      try {
        final payload =
            json.decode(await request.readAsString()) as Map<String, dynamic>;
        final amount = payload['amount'] as int?;
        final reason = payload['reason'] as String?;
        final lessonId = payload['lessonId'] as String?;

        // Validate required fields
        if (amount == null || amount <= 0) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Invalid amount',
                'message': 'Amount must be a positive integer',
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        if (reason == null || reason.isEmpty) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Invalid reason',
                'message': 'Reason is required and cannot be empty',
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        final starService = StarTransactionService.instance;
        final success = await starService.spendStars(
          amount: amount,
          reason: reason,
          lessonId: lessonId,
        );

        if (!success) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Insufficient stars',
                'message': 'Not enough stars in balance for this transaction',
                'current_balance': starService.currentBalance,
                'requested_amount': amount,
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        final response = {
          'success': true,
          'balance': starService.currentBalance,
          'amount_spent': amount,
          'reason': reason,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Spend stars endpoint: Spent $amount stars in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in spend stars endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportStorageError(
          message: 'API spend stars endpoint failed after ${duration.inMilliseconds}ms',
          operation: 'spend_stars',
          additionalInfo: {
            'endpoint': '/v1/stars/spend',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to spend stars',
              'message': 'An internal error occurred while spending stars',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Get star transactions endpoint
  Future<Response> Function(Request) _handleGetStarTransactions() {
    return (Request request) async {
      final startTime = DateTime.now();
      String? capturedType;
      String? capturedLessonId;

      try {
        final limitParam = request.url.queryParameters['limit'] ?? '50';
        capturedType = request.url.queryParameters['type'];
        capturedLessonId = request.url.queryParameters['lessonId'];

        // Validate and parse limit parameter
        final limit = int.tryParse(limitParam);
        if (limit == null || limit < 1 || limit > 1000) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Invalid limit parameter',
                'message': 'Limit must be a number between 1 and 1000',
                'timestamp': DateTime.now().toIso8601String(),
                'valid_range': '1-1000',
              }),
              headers: {'Content-Type': 'application/json'});
        }

        final starService = StarTransactionService.instance;
        List<StarTransaction> transactions;

        if (capturedType != null && capturedType.isNotEmpty) {
          transactions =
              starService.getTransactionsByType(capturedType).take(limit).toList();
        } else if (capturedLessonId != null && capturedLessonId.isNotEmpty) {
          transactions = starService
              .getTransactionsForLesson(capturedLessonId)
              .take(limit)
              .toList();
        } else {
          transactions = starService.getRecentTransactions(count: limit);
        }

        final transactionsData = transactions.map((t) => t.toJson()).toList();

        final response = {
          'transactions': transactionsData,
          'count': transactions.length,
          'type_filter': capturedType,
          'lesson_filter': capturedLessonId,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Star transactions endpoint: Retrieved ${transactions.length} transactions in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in star transactions endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportStorageError(
          message: 'API star transactions endpoint failed after ${duration.inMilliseconds}ms',
          operation: 'get_star_transactions',
          additionalInfo: {
            'endpoint': '/v1/stars/transactions',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
            'type_filter': capturedType,
            'lesson_filter': capturedLessonId,
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to get star transactions',
              'message':
                  'An internal error occurred while retrieving star transactions',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Get star statistics endpoint
  Future<Response> Function(Request) _handleGetStarStats() {
    return (Request request) async {
      final startTime = DateTime.now();

      try {
        final starService = StarTransactionService.instance;
        final stats = starService.getTransactionStats();

        final response = {
          'stats': stats,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Star stats endpoint: Retrieved stats in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in star stats endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportStorageError(
          message: 'API star stats endpoint failed after ${duration.inMilliseconds}ms',
          operation: 'get_star_stats',
          additionalInfo: {
            'endpoint': '/v1/stars/stats',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to get star statistics',
              'message':
                  'An internal error occurred while retrieving star statistics',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Get store items endpoint
  Future<Response> Function(Request) _handleGetStoreItems() {
    return (Request request) async {
      final startTime = DateTime.now();
      String? category;
      String? limitParam;

      try {
        category = request.url.queryParameters['category'];
        limitParam = request.url.queryParameters['limit'] ?? '20';

        // Validate and parse limit parameter
        final limit = int.tryParse(limitParam);
        if (limit == null || limit < 1 || limit > 100) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Invalid limit parameter',
                'message': 'Limit must be a number between 1 and 100',
                'timestamp': DateTime.now().toIso8601String(),
                'valid_range': '1-100',
              }),
              headers: {'Content-Type': 'application/json'});
        }

        final storeService = StoreService();
        final items = await storeService.getStoreItems();

        // Filter by category if specified
        final filteredItems = category != null && category.isNotEmpty
            ? items.where((item) => item.category == category).toList()
            : items;

        // Apply limit
        final limitedItems = filteredItems.take(limit).toList();

        final itemsData = limitedItems.map((item) => {
          'itemKey': item.itemKey,
          'itemName': item.itemName,
          'description': item.itemDescription,
          'category': item.category,
          'basePrice': item.basePrice,
          'currentPrice': item.currentPrice,
          'isDiscounted': item.isDiscounted,
          'discountPercentage': item.discountPercentage,
          'isActive': item.isActive,
          'icon': item.icon,
        }).toList();

        final response = {
          'items': itemsData,
          'count': limitedItems.length,
          'category_filter': category,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Store items endpoint: Retrieved ${limitedItems.length} items in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in store items endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportStorageError(
          message: 'API store items endpoint failed after ${duration.inMilliseconds}ms',
          operation: 'get_store_items',
          additionalInfo: {
            'endpoint': '/v1/store/items',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
            'category': category,
            'limit': limitParam,
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to get store items',
              'message':
                  'An internal error occurred while retrieving store items',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Get specific store item endpoint
  Future<Response> Function(Request) _handleGetStoreItemByKey() {
    return (Request request) async {
      final startTime = DateTime.now();

      try {
        final itemKey = request.params['itemKey'];
        if (itemKey == null || itemKey.isEmpty) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Missing itemKey parameter',
                'message': 'Item key parameter is required in the URL path',
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        final storeService = StoreService();
        final item = await storeService.getStoreItemByKey(itemKey);

        if (item == null) {
          return Response(404,
              body: json.encode({
                'error': 'Item not found',
                'message': 'Store item with the specified key was not found',
                'itemKey': itemKey,
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        final response = {
          'itemKey': item.itemKey,
          'itemName': item.itemName,
          'description': item.itemDescription,
          'category': item.category,
          'basePrice': item.basePrice,
          'currentPrice': item.currentPrice,
          'isDiscounted': item.isDiscounted,
          'discountPercentage': item.discountPercentage,
          'isActive': item.isActive,
          'icon': item.icon,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Store item by key endpoint: Retrieved item $itemKey in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in store item by key endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportNetworkError(
          message: 'API store item by key endpoint failed after ${duration.inMilliseconds}ms',
          url: 'store_items table',
          additionalInfo: {
            'endpoint': '/v1/store/items/<itemKey>',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
            'item_key': request.params['itemKey'],
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to get store item',
              'message':
                  'An internal error occurred while retrieving store item',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Get lessons endpoint
  Future<Response> Function(Request) _handleGetLessons() {
    return (Request request) async {
      final startTime = DateTime.now();
      String? capturedLimitParam;
      String? capturedIncludeSpecialParam;

      try {
        capturedLimitParam = request.url.queryParameters['limit'] ?? '10';
        capturedIncludeSpecialParam = request.url.queryParameters['includeSpecial'] ?? 'true';

        // Validate and parse limit parameter
        final limit = int.tryParse(capturedLimitParam);
        if (limit == null || limit < 1 || limit > 50) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Invalid limit parameter',
                'message': 'Limit must be a number between 1 and 50',
                'timestamp': DateTime.now().toIso8601String(),
                'valid_range': '1-50',
              }),
              headers: {'Content-Type': 'application/json'});
        }

        final includeSpecial = capturedIncludeSpecialParam.toLowerCase() == 'true';

        final lessonService = LessonService();
        final lessons = await lessonService.generateLessons('nl',
            maxLessons: limit, maxQuestionsPerLesson: 10);

        // Filter special lessons if requested
        final filteredLessons = includeSpecial
            ? lessons
            : lessons.where((lesson) => !lesson.isSpecial).toList();

        final lessonsData = filteredLessons.map((lesson) => {
          'id': lesson.id,
          'title': lesson.title,
          'category': lesson.category,
          'maxQuestions': lesson.maxQuestions,
          'index': lesson.index,
          'description': lesson.description,
          'iconHint': lesson.iconHint,
          'isSpecial': lesson.isSpecial,
        }).toList();

        final response = {
          'lessons': lessonsData,
          'count': filteredLessons.length,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Lessons endpoint: Generated ${filteredLessons.length} lessons in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in lessons endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportQuestionError(
          message: 'API lessons endpoint failed after ${duration.inMilliseconds}ms',
          questionId: 'api_lessons_endpoint',
          questionText: 'Lessons generation via API failed',
          additionalInfo: {
            'endpoint': '/v1/lessons',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
            'limit': capturedLimitParam,
            'include_special': capturedIncludeSpecialParam,
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to generate lessons',
              'message':
                  'An internal error occurred while generating lessons',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Get time tracking endpoint
  Future<Response> Function(Request) _handleGetTimeTracking() {
    return (Request request) async {
      final startTime = DateTime.now();

      try {
        final timeTrackingService = TimeTrackingService.instance;
        await timeTrackingService.initialize();

        final response = {
          'totalTimeSpentSeconds': timeTrackingService.getTotalTimeSpent(),
          'totalTimeSpentFormatted': timeTrackingService.getTotalTimeSpentFormatted(),
          'totalTimeSpentInHours': timeTrackingService.getTotalTimeSpentInHours(),
          'totalTimeSpentInMinutes': timeTrackingService.getTotalTimeSpentInMinutes(),
          'hasOngoingSession': timeTrackingService.hasOngoingSession(),
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Time tracking endpoint: Retrieved time data in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in time tracking endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportStorageError(
          message: 'API time tracking endpoint failed after ${duration.inMilliseconds}ms',
          operation: 'get_time_tracking',
          additionalInfo: {
            'endpoint': '/v1/time/tracking',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to get time tracking data',
              'message':
                  'An internal error occurred while retrieving time tracking data',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Redeem coupon endpoint
  Future<Response> Function(Request) _handleRedeemCoupon() {
    return (Request request) async {
      final startTime = DateTime.now();

      try {
        final payload =
            json.decode(await request.readAsString()) as Map<String, dynamic>;
        final code = payload['code'] as String?;

        // Validate required fields
        if (code == null || code.isEmpty) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Invalid coupon code',
                'message': 'Coupon code is required and cannot be empty',
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        final couponService = CouponService();
        final reward = await couponService.redeemCoupon(code);

        final response = {
          'success': true,
          'rewardType': reward.type,
          'rewardValue': reward.value,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Coupon redemption endpoint: Redeemed coupon $code in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in coupon redemption endpoint after ${duration.inMilliseconds}ms: $e');

        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportStorageError(
          message: 'API coupon redemption endpoint failed after ${duration.inMilliseconds}ms',
          operation: 'redeem_coupon',
          additionalInfo: {
            'endpoint': '/v1/coupons/redeem',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
            'coupon_code': (json.decode(await request.readAsString()) as Map<String, dynamic>?)?['code'],
          },
        );

        // Handle specific coupon errors
        if (e.toString().contains('expired')) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Invalid coupon',
                'message': 'Coupon code has expired',
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        } else if (e.toString().contains('maximum uses')) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Invalid coupon',
                'message': 'Coupon code has reached maximum usage limit',
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        } else {
          return Response.badRequest(
              body: json.encode({
                'error': 'Invalid coupon',
                'message': 'Coupon code is invalid or has expired',
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }
      }
    };
  }

  /// Get messages endpoint
  Future<Response> Function(Request) _handleGetMessages() {
    return (Request request) async {
      final startTime = DateTime.now();
      String? capturedLimitParam;
      String? capturedIncludeExpiredParam;

      try {
        capturedLimitParam = request.url.queryParameters['limit'] ?? '20';
        capturedIncludeExpiredParam = request.url.queryParameters['includeExpired'] ?? 'false';

        // Validate and parse limit parameter
        final limit = int.tryParse(capturedLimitParam);
        if (limit == null || limit < 1 || limit > 100) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Invalid limit parameter',
                'message': 'Limit must be a number between 1 and 100',
                'timestamp': DateTime.now().toIso8601String(),
                'valid_range': '1-100',
              }),
              headers: {'Content-Type': 'application/json'});
        }

        final includeExpired = capturedIncludeExpiredParam.toLowerCase() == 'true';

        final messagingService = MessagingService();
        final messages = await messagingService.getActiveMessages();

        // Filter expired messages if requested
        final filteredMessages = includeExpired
            ? messages
            : messages.where((msg) => messagingService.isMessageActive(msg)).toList();

        // Apply limit
        final limitedMessages = filteredMessages.take(limit).toList();

        final messagesData = limitedMessages.map((msg) => {
          'id': msg.id,
          'title': msg.title,
          'content': msg.content,
          'expirationDate': msg.expirationDate?.toIso8601String(),
          'createdAt': msg.createdAt.toIso8601String(),
          'createdBy': msg.createdBy,
        }).toList();

        final response = {
          'messages': messagesData,
          'count': limitedMessages.length,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Messages endpoint: Retrieved ${limitedMessages.length} messages in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in messages endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportNetworkError(
          message: 'API messages endpoint failed after ${duration.inMilliseconds}ms',
          url: 'messages table',
          additionalInfo: {
            'endpoint': '/v1/messages',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
            'limit': capturedLimitParam,
            'include_expired': capturedIncludeExpiredParam,
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to get messages',
              'message':
                  'An internal error occurred while retrieving messages',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Get message reactions endpoint
  Future<Response> Function(Request) _handleGetMessageReactions() {
    return (Request request) async {
      final startTime = DateTime.now();

      try {
        final messageId = request.params['messageId'];
        if (messageId == null || messageId.isEmpty) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Missing messageId parameter',
                'message': 'Message ID parameter is required in the URL path',
                'timestamp': DateTime.now().toIso8601String(),
              }),
              headers: {'Content-Type': 'application/json'});
        }

        final messagingService = MessagingService();
        final reactionCounts = await messagingService.getMessageReactionCounts(messageId);

        final reactionsData = reactionCounts.map((rc) => {
          'emoji': rc.emoji,
          'count': rc.count,
        }).toList();

        final response = {
          'reactions': reactionsData,
          'totalReactions': reactionCounts.fold(0, (sum, rc) => sum + rc.count),
          'messageId': messageId,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Message reactions endpoint: Retrieved ${reactionCounts.length} reaction types for message $messageId in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in message reactions endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportNetworkError(
          message: 'API message reactions endpoint failed after ${duration.inMilliseconds}ms',
          url: 'messages table',
          additionalInfo: {
            'endpoint': '/v1/messages/<messageId>/reactions',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
            'message_id': request.params['messageId'],
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to get message reactions',
              'message':
                  'An internal error occurred while retrieving message reactions',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Get sync status endpoint
  Future<Response> Function(Request) _handleGetSyncStatus() {
    return (Request request) async {
      final startTime = DateTime.now();

      try {
        final syncService = SyncService.instance;
        await syncService.initialize();

        final response = {
          'isAuthenticated': syncService.isAuthenticated,
          'isConnected': syncService.isConnected,
          'isListening': false, // Placeholder - would need to be exposed from service
          'pendingSyncsCount': 0, // Placeholder - would need to be exposed from service
          'currentUserId': syncService.currentUserId,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Sync status endpoint: Retrieved sync status in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in sync status endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportNetworkError(
          message: 'API sync status endpoint failed after ${duration.inMilliseconds}ms',
          url: 'sync service',
          additionalInfo: {
            'endpoint': '/v1/sync/status',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to get sync status',
              'message':
                  'An internal error occurred while retrieving sync status',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Get feature analytics endpoint
  Future<Response> Function(Request) _handleGetFeatureAnalytics() {
    return (Request request) async {
      final startTime = DateTime.now();
      String? capturedFeature;
      String? capturedLimitParam;

      try {
        capturedFeature = request.url.queryParameters['feature'];
        capturedLimitParam = request.url.queryParameters['limit'] ?? '20';

        // Validate and parse limit parameter
        final limit = int.tryParse(capturedLimitParam);
        if (limit == null || limit < 1 || limit > 100) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Invalid limit parameter',
                'message': 'Limit must be a number between 1 and 100',
                'timestamp': DateTime.now().toIso8601String(),
                'valid_range': '1-100',
              }),
              headers: {'Content-Type': 'application/json'});
        }

        // Note: The AnalyticsService methods require a BuildContext, which we don't have in API context
        // For now, we'll return a simplified response. In a real implementation, we'd need to
        // either modify the service to work without context or provide a different approach.

        final featuresData = [
          {
            'feature': 'quiz_gameplay',
            'totalUsage': 42,
            'lastUsed': '2025-10-20T16:00:00.000Z',
            'firstUsed': '2025-10-15T10:00:00.000Z'
          }
        ];

        // Filter by feature if specified
        final filteredFeatures = capturedFeature != null && capturedFeature.isNotEmpty
            ? featuresData.where((f) => f['feature'] == capturedFeature).toList()
            : featuresData;

        // Apply limit
        final limitedFeatures = filteredFeatures.take(limit).toList();

        final response = {
          'features': limitedFeatures,
          'count': limitedFeatures.length,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Feature analytics endpoint: Retrieved ${limitedFeatures.length} features in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in feature analytics endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportStorageError(
          message: 'API feature analytics endpoint failed after ${duration.inMilliseconds}ms',
          operation: 'get_feature_analytics',
          additionalInfo: {
            'endpoint': '/v1/analytics/features',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
            'feature_filter': capturedFeature,
            'limit': capturedLimitParam,
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to get feature analytics',
              'message':
                  'An internal error occurred while retrieving feature analytics',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Get Bible books endpoint
  Future<Response> Function(Request) _handleGetBibleBooks() {
    return (Request request) async {
      final startTime = DateTime.now();

      try {
        final books = BibleBookMapper.getAllBookNames();

        final booksData = {for (final book in books) book: BibleBookMapper.getBookNumber(book) ?? 0};

        final response = {
          'books': booksData,
          'count': booksData.length,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Bible books endpoint: Retrieved ${booksData.length} books in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in Bible books endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportBiblicalReferenceError(
          message: 'API Bible books endpoint failed after ${duration.inMilliseconds}ms',
          reference: 'bible_books_list',
          additionalInfo: {
            'endpoint': '/v1/bible/books',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to get Bible books',
              'message':
                  'An internal error occurred while retrieving Bible books',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }

  /// Get themes endpoint
  Future<Response> Function(Request) _handleGetThemes() {
    return (Request request) async {
      final startTime = DateTime.now();
      String? capturedType;
      String? capturedLimitParam;

      try {
        capturedType = request.url.queryParameters['type']?.toLowerCase();
        capturedLimitParam = request.url.queryParameters['limit'] ?? '20';

        // Validate and parse limit parameter
        final limit = int.tryParse(capturedLimitParam);
        if (limit == null || limit < 1 || limit > 100) {
          return Response.badRequest(
              body: json.encode({
                'error': 'Invalid limit parameter',
                'message': 'Limit must be a number between 1 and 100',
                'timestamp': DateTime.now().toIso8601String(),
                'valid_range': '1-100',
              }),
              headers: {'Content-Type': 'application/json'});
        }

        final themeManager = ThemeManager();
        await themeManager.initialize();
        final themes = themeManager.getAvailableThemes();

        // Filter by type if specified
        final filteredThemes = capturedType != null && capturedType.isNotEmpty && capturedType != 'all'
            ? themes.values.where((theme) => theme.type == capturedType).toList()
            : themes.values.toList();

        // Apply limit
        final limitedThemes = filteredThemes.take(limit).toList();

        final themesData = limitedThemes.map((theme) => {
          'id': theme.id,
          'name': theme.name,
          'type': theme.type,
          'colors': {
            'primary': theme.colors['primary'] ?? '#FFFFFF',
            'secondary': theme.colors['secondary'] ?? '#CCCCCC',
            'background': theme.colors['background'] ?? '#FFFFFF',
          }
        }).toList();

        final response = {
          'themes': themesData,
          'count': limitedThemes.length,
          'timestamp': DateTime.now().toIso8601String(),
          'processing_time_ms':
              DateTime.now().difference(startTime).inMilliseconds,
        };

        AppLogger.info(
            'Themes endpoint: Retrieved ${limitedThemes.length} themes in ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return Response.ok(json.encode(response),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        AppLogger.error(
            'Error in themes endpoint after ${duration.inMilliseconds}ms: $e');
        
        // Report error to automatic error tracking system
        await AutomaticErrorReporter.reportStorageError(
          message: 'API themes endpoint failed after ${duration.inMilliseconds}ms',
          operation: 'get_themes',
          additionalInfo: {
            'endpoint': '/v1/themes',
            'duration_ms': duration.inMilliseconds,
            'error': e.toString(),
            'type_filter': capturedType,
            'limit': capturedLimitParam,
          },
        );
        
        return Response.internalServerError(
            body: json.encode({
              'error': 'Failed to get themes',
              'message':
                  'An internal error occurred while retrieving themes',
              'timestamp': DateTime.now().toIso8601String(),
              'processing_time_ms': duration.inMilliseconds,
            }),
            headers: {'Content-Type': 'application/json'});
      }
    };
  }
}
