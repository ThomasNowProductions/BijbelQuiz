import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import '../services/logger.dart';
import '../models/quiz_question.dart';
import '../providers/game_stats_provider.dart';
import '../providers/lesson_progress_provider.dart';
import '../providers/settings_provider.dart';
import '../services/question_cache_service.dart';

/// Service for running a local HTTP API server
class ApiService {
  static const String _defaultBindAddress = '0.0.0.0';
  HttpServer? _server;
  bool _isRunning = false;

  /// Whether the API server is currently running
   bool get isRunning => _isRunning;

   /// Gets the current server port if running
   int? get currentPort => _server?.port;

   /// Gets the server address if running
   String? get serverAddress => _server?.address.host;

  /// Starts the API server on the specified port with authentication
   Future<void> startServer({
     required int port,
     required String apiKey,
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
         ..get('/health', _handleHealth)
         ..get('/questions', _handleGetQuestions(questionCacheService))
         ..get('/questions/<category>', _handleGetQuestionsByCategory(questionCacheService))
         ..get('/progress', _handleGetProgress(lessonProgressProvider))
         ..get('/stats', _handleGetStats(gameStatsProvider))
         ..get('/settings', _handleGetSettings(settingsProvider));

       final handler = const Pipeline()
           .addMiddleware(_createPublicEndpointMiddleware(apiKey))
           .addMiddleware(_createCorsMiddleware())
           .addMiddleware(logRequests())
           .addHandler(app);

       _server = await shelf_io.serve(handler, _defaultBindAddress, port);
       _isRunning = true;

       AppLogger.info('API server started successfully on ${_server!.address.host}:${_server!.port}');
       AppLogger.info('API server is accessible at http://localhost:$port and http://${_server!.address.host}:$port');
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
       await _server!.close(force: true); // Force close to ensure cleanup
       _isRunning = false;
       _server = null;
       AppLogger.info('API server stopped successfully');
     } catch (e) {
       AppLogger.error('Failed to stop API server: $e');
       _isRunning = false;
       _server = null;
       // Don't throw exception on stop failure to avoid crashes during app shutdown
       AppLogger.warning('API server stopped with errors but continuing');
     }
   }

  /// Middleware for API key authentication (allows public access to /health)
  Middleware _createPublicEndpointMiddleware(String expectedApiKey) {
    return (Handler innerHandler) {
      return (Request request) async {
        // Allow public access to health endpoint
        if (request.url.path == 'health') {
          return await innerHandler(request);
        }

        // Require authentication for all other endpoints
        final authHeader = request.headers['authorization'];
        final apiKeyHeader = request.headers['x-api-key'];

        String? providedKey;

        if (authHeader != null && authHeader.startsWith('Bearer ')) {
          providedKey = authHeader.substring(7);
        } else if (apiKeyHeader != null) {
          providedKey = apiKeyHeader;
        }

        if (providedKey == null || providedKey != expectedApiKey) {
          return Response.forbidden(json.encode({
            'error': 'Invalid or missing API key',
            'message': 'Please provide a valid API key via Authorization header (Bearer token) or X-API-Key header'
          }));
        }

        return await innerHandler(request);
      };
    };
  }

  /// Middleware for CORS support
  Middleware _createCorsMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        final response = await innerHandler(request);

        return response.change(headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-API-Key',
          'Access-Control-Max-Age': '86400', // 24 hours
        });
      };
    };
  }

  /// Health check endpoint
  Future<Response> _handleHealth(Request request) async {
    return Response.ok(json.encode({
      'status': 'healthy',
      'timestamp': DateTime.now().toIso8601String(),
      'service': 'BijbelQuiz API',
    }), headers: {'Content-Type': 'application/json'});
  }

  /// Get questions endpoint
   Future<Response> Function(Request) _handleGetQuestions(QuestionCacheService questionCacheService) {
     return (Request request) async {
       try {
         final category = request.url.queryParameters['category'];
         final limitParam = request.url.queryParameters['limit'] ?? '10';
         final difficulty = request.url.queryParameters['difficulty'];

         // Validate and parse limit parameter
         final limit = int.tryParse(limitParam);
         if (limit == null || limit < 1 || limit > 50) {
           return Response.badRequest(body: json.encode({
             'error': 'Invalid limit parameter',
             'message': 'Limit must be a number between 1 and 50',
           }), headers: {'Content-Type': 'application/json'});
         }

         List<QuizQuestion> questions;

         if (category != null && category.isNotEmpty) {
           questions = await questionCacheService.getQuestionsByCategory('nl', category, count: limit);
         } else {
           questions = await questionCacheService.getQuestions('nl', count: limit);
         }

         // Filter by difficulty if specified
         if (difficulty != null && difficulty.isNotEmpty) {
           questions = questions.where((q) => q.difficulty.toLowerCase() == difficulty.toLowerCase()).toList();
         }

         final questionsData = questions.map((q) => {
           'question': q.question,
           'correctAnswer': q.correctAnswer,
           'incorrectAnswers': q.incorrectAnswers,
           'difficulty': q.difficulty,
           'type': q.type.name,
           'categories': q.categories,
           'biblicalReference': q.biblicalReference,
           'allOptions': q.allOptions,
           'correctAnswerIndex': q.correctAnswerIndex,
         }).toList();

         return Response.ok(json.encode({
           'questions': questionsData,
           'count': questions.length,
           'category': category,
           'difficulty': difficulty,
         }), headers: {'Content-Type': 'application/json'});
       } catch (e) {
         AppLogger.error('Error in questions endpoint: $e');
         return Response.internalServerError(body: json.encode({
           'error': 'Failed to load questions',
           'message': 'An internal error occurred while processing your request',
         }), headers: {'Content-Type': 'application/json'});
       }
     };
   }

  /// Get questions by category endpoint
   Future<Response> Function(Request) _handleGetQuestionsByCategory(QuestionCacheService questionCacheService) {
     return (Request request) async {
       try {
         final category = request.params['category'];
         if (category == null || category.isEmpty) {
           return Response.badRequest(body: json.encode({
             'error': 'Missing category parameter',
             'message': 'Category parameter is required in the URL path',
           }), headers: {'Content-Type': 'application/json'});
         }

         final limitParam = request.url.queryParameters['limit'] ?? '10';
         final difficulty = request.url.queryParameters['difficulty'];

         // Validate and parse limit parameter
         final limit = int.tryParse(limitParam);
         if (limit == null || limit < 1 || limit > 50) {
           return Response.badRequest(body: json.encode({
             'error': 'Invalid limit parameter',
             'message': 'Limit must be a number between 1 and 50',
           }), headers: {'Content-Type': 'application/json'});
         }

         final questions = await questionCacheService.getQuestionsByCategory('nl', category, count: limit);

         // Filter by difficulty if specified
         final filteredQuestions = difficulty != null && difficulty.isNotEmpty
             ? questions.where((q) => q.difficulty.toLowerCase() == difficulty.toLowerCase()).toList()
             : questions;

         final questionsData = filteredQuestions.map((q) => {
           'question': q.question,
           'correctAnswer': q.correctAnswer,
           'incorrectAnswers': q.incorrectAnswers,
           'difficulty': q.difficulty,
           'type': q.type.name,
           'categories': q.categories,
           'biblicalReference': q.biblicalReference,
           'allOptions': q.allOptions,
           'correctAnswerIndex': q.correctAnswerIndex,
         }).toList();

         return Response.ok(json.encode({
           'questions': questionsData,
           'count': filteredQuestions.length,
           'category': category,
           'difficulty': difficulty,
         }), headers: {'Content-Type': 'application/json'});
       } catch (e) {
         AppLogger.error('Error in questions by category endpoint: $e');
         return Response.internalServerError(body: json.encode({
           'error': 'Failed to load questions for category',
           'message': 'An internal error occurred while processing your request',
         }), headers: {'Content-Type': 'application/json'});
       }
     };
   }

  /// Get user progress endpoint
   Future<Response> Function(Request) _handleGetProgress(LessonProgressProvider progressProvider) {
     return (Request request) async {
       try {
         final progressData = {
           'unlockedCount': progressProvider.unlockedCount,
           'bestStarsByLesson': progressProvider.getExportData()['bestStarsByLesson'],
         };

         return Response.ok(json.encode(progressData), headers: {'Content-Type': 'application/json'});
       } catch (e) {
         AppLogger.error('Error in progress endpoint: $e');
         return Response.internalServerError(body: json.encode({
           'error': 'Failed to get progress data',
           'message': 'An internal error occurred while retrieving progress data',
         }), headers: {'Content-Type': 'application/json'});
       }
     };
   }

  /// Get game stats endpoint
   Future<Response> Function(Request) _handleGetStats(GameStatsProvider statsProvider) {
     return (Request request) async {
       try {
         final statsData = {
           'score': statsProvider.score,
           'currentStreak': statsProvider.currentStreak,
           'longestStreak': statsProvider.longestStreak,
           'incorrectAnswers': statsProvider.incorrectAnswers,
         };

         return Response.ok(json.encode(statsData), headers: {'Content-Type': 'application/json'});
       } catch (e) {
         AppLogger.error('Error in stats endpoint: $e');
         return Response.internalServerError(body: json.encode({
           'error': 'Failed to get stats data',
           'message': 'An internal error occurred while retrieving statistics',
         }), headers: {'Content-Type': 'application/json'});
       }
     };
   }

   /// Get settings endpoint
   Future<Response> Function(Request) _handleGetSettings(SettingsProvider settingsProvider) {
     return (Request request) async {
       try {
         final settingsData = {
           'themeMode': settingsProvider.themeMode.name,
           'gameSpeed': settingsProvider.gameSpeed,
           'mute': settingsProvider.mute,
           'analyticsEnabled': settingsProvider.analyticsEnabled,
           'notificationEnabled': settingsProvider.notificationEnabled,
         };

         return Response.ok(json.encode(settingsData), headers: {'Content-Type': 'application/json'});
       } catch (e) {
         AppLogger.error('Error in settings endpoint: $e');
         return Response.internalServerError(body: json.encode({
           'error': 'Failed to get settings data',
           'message': 'An internal error occurred while retrieving settings',
         }), headers: {'Content-Type': 'application/json'});
       }
     };
   }
}