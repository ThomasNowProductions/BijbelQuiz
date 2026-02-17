import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show Random;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/game_stats_provider.dart';
import '../providers/lesson_progress_provider.dart';
import '../providers/settings_provider.dart';
import '../models/quiz_question.dart';
import 'question_cache_service.dart';
import 'logger.dart';

class ApiKey {
  final String id;
  final String key;
  final String name;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final bool isEnabled;
  final int requestCount;

  ApiKey({
    required this.id,
    required this.key,
    required this.name,
    required this.createdAt,
    this.lastUsedAt,
    this.isEnabled = true,
    this.requestCount = 0,
  });

  factory ApiKey.generate({String? name}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final key =
        'bq_${List.generate(16, (_) => Random.secure().nextInt(36).toRadixString(36)).join()}';
    return ApiKey(
      id: id,
      key: key,
      name: name ?? 'API Key',
      createdAt: DateTime.now(),
    );
  }

  ApiKey copyWith({
    String? id,
    String? key,
    String? name,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    bool? isEnabled,
    int? requestCount,
  }) {
    return ApiKey(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      isEnabled: isEnabled ?? this.isEnabled,
      requestCount: requestCount ?? this.requestCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'lastUsedAt': lastUsedAt?.toIso8601String(),
        'isEnabled': isEnabled,
        'requestCount': requestCount,
      };

  factory ApiKey.fromJson(Map<String, dynamic> json) {
    return ApiKey(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'] as String)
          : null,
      isEnabled: json['isEnabled'] as bool? ?? true,
      requestCount: json['requestCount'] as int? ?? 0,
    );
  }
}

class LocalApiService {
  static final LocalApiService _instance = LocalApiService._internal();
  factory LocalApiService() => _instance;
  LocalApiService._internal();

  static LocalApiService get instance => _instance;

  HttpServer? _server;
  List<ApiKey> _apiKeys = [];
  int _port = 7777;
  bool _isEnabled = false;

  GameStatsProvider? _gameStatsProvider;
  LessonProgressProvider? _lessonProgressProvider;
  SettingsProvider? _settingsProvider;
  QuestionCacheService? _questionCacheService;

  final Map<String, _RateLimitEntry> _rateLimitMap = {};
  Timer? _rateLimitCleanupTimer;

  static const String _apiKeysStorageKey = 'local_api_keys_v2';
  static const String _apiEnabledKey = 'local_api_enabled';
  static const String _apiPortKey = 'local_api_port';

  bool get isEnabled => _isEnabled;
  bool get isRunning => _server != null;
  int get port => _port;
  List<ApiKey> get apiKeys => List.unmodifiable(_apiKeys);
  int get activeKeyCount => _apiKeys.where((k) => k.isEnabled).length;

  void initialize({
    required GameStatsProvider gameStatsProvider,
    required LessonProgressProvider lessonProgressProvider,
    required SettingsProvider settingsProvider,
    required QuestionCacheService questionCacheService,
  }) {
    _gameStatsProvider = gameStatsProvider;
    _lessonProgressProvider = lessonProgressProvider;
    _settingsProvider = settingsProvider;
    _questionCacheService = questionCacheService;
    AppLogger.info('LocalApiService initialized with providers');
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_apiEnabledKey) ?? false;
      _port = prefs.getInt(_apiPortKey) ?? 7777;

      final keysJson = prefs.getString(_apiKeysStorageKey);
      if (keysJson != null && keysJson.isNotEmpty) {
        final List<dynamic> keysList = json.decode(keysJson);
        _apiKeys = keysList
            .map((j) => ApiKey.fromJson(j as Map<String, dynamic>))
            .toList();
      } else {
        _apiKeys = [];
      }

      AppLogger.info(
          'LocalApiService settings loaded: enabled=$_isEnabled, port=$_port, keyCount=${_apiKeys.length}');
    } catch (e) {
      AppLogger.error('Failed to load LocalApiService settings', e);
      _apiKeys = [];
    }
  }

  Future<void> _saveApiKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysJson = json.encode(_apiKeys.map((k) => k.toJson()).toList());
      await prefs.setString(_apiKeysStorageKey, keysJson);
    } catch (e) {
      AppLogger.error('Failed to save API keys', e);
    }
  }

  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_apiEnabledKey, enabled);

    if (enabled && !isRunning) {
      await startServer();
    } else if (!enabled && isRunning) {
      await stopServer();
    }

    AppLogger.info('Local API enabled: $enabled');
  }

  Future<void> setPort(int port) async {
    if (port < 1024 || port > 65535) {
      throw ArgumentError('Port must be between 1024 and 65535');
    }

    _port = port;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_apiPortKey, port);

    if (isRunning) {
      await stopServer();
      if (_isEnabled) {
        await startServer();
      }
    }

    AppLogger.info('Local API port changed to: $port');
  }

  Future<ApiKey> createApiKey({String? name}) async {
    final apiKey = ApiKey.generate(name: name);
    _apiKeys.add(apiKey);
    await _saveApiKeys();
    AppLogger.info('Created new API key: ${apiKey.name}');
    return apiKey;
  }

  Future<void> updateApiKey(String id, {String? name, bool? isEnabled}) async {
    final index = _apiKeys.indexWhere((k) => k.id == id);
    if (index == -1) return;

    _apiKeys[index] = _apiKeys[index].copyWith(
      name: name,
      isEnabled: isEnabled,
    );
    await _saveApiKeys();
    AppLogger.info('Updated API key: $id');
  }

  Future<void> deleteApiKey(String id) async {
    _apiKeys.removeWhere((k) => k.id == id);
    await _saveApiKeys();
    AppLogger.info('Deleted API key: $id');
  }

  Future<void> regenerateKey(String id) async {
    final index = _apiKeys.indexWhere((k) => k.id == id);
    if (index == -1) return;

    final newKey =
        'bq_${List.generate(16, (_) => Random.secure().nextInt(36).toRadixString(36)).join()}';
    _apiKeys[index] = _apiKeys[index].copyWith(
      key: newKey,
      requestCount: 0,
      lastUsedAt: null,
    );
    await _saveApiKeys();
    AppLogger.info('Regenerated API key: $id');
  }

  Future<void> _recordKeyUsage(String key) async {
    final index = _apiKeys.indexWhere((k) => k.key == key);
    if (index == -1) return;

    _apiKeys[index] = _apiKeys[index].copyWith(
      lastUsedAt: DateTime.now(),
      requestCount: _apiKeys[index].requestCount + 1,
    );
    await _saveApiKeys();
  }

  Future<void> startServer() async {
    if (kIsWeb) {
      AppLogger.warning('Local API server not supported on web platform');
      return;
    }

    if (isRunning) {
      AppLogger.warning('Local API server already running');
      return;
    }

    if (_apiKeys.isEmpty || _apiKeys.every((k) => !k.isEnabled)) {
      AppLogger.warning('No enabled API keys, creating default key');
      await createApiKey(name: 'Default Key');
    }

    try {
      final router = _createRouter();
      final handler = const shelf.Pipeline()
          .addMiddleware(_corsMiddleware())
          .addMiddleware(_rateLimitMiddleware())
          .addHandler(router.call);

      _server = await HttpServer.bind(InternetAddress.anyIPv4, _port);

      _startRateLimitCleanup();

      _server!.listen((request) async {
        try {
          final shelfRequest = await _convertRequest(request);
          final shelfResponse = await handler(shelfRequest);
          await _writeResponse(request.response, shelfResponse);
        } catch (e) {
          AppLogger.error('Error handling request', e);
          request.response.statusCode = 500;
          await request.response.close();
        }
      });

      AppLogger.info('Local API server started on port $_port');
    } catch (e) {
      AppLogger.error('Failed to start Local API server', e);
      rethrow;
    }
  }

  Future<void> stopServer() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
      _rateLimitCleanupTimer?.cancel();
      _rateLimitCleanupTimer = null;
      AppLogger.info('Local API server stopped');
    }
  }

  Router _createRouter() {
    final router = Router();

    router.get('/v1/health', _handleHealth);
    router.get('/v1/questions', _handleGetQuestions);
    router.get('/v1/progress', _handleGetProgress);
    router.get('/v1/stats', _handleGetStats);
    router.get('/v1/stars/balance', _handleGetStarsBalance);
    router.post('/v1/stars/add', _handleAddStars);
    router.post('/v1/stars/spend', _handleSpendStars);

    return router;
  }

  shelf.Middleware _corsMiddleware() {
    return (shelf.Handler innerHandler) {
      return (shelf.Request request) async {
        if (request.method == 'OPTIONS') {
          return shelf.Response.ok('', headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers':
                'Authorization, X-API-Key, Content-Type',
          });
        }

        final response = await innerHandler(request);
        return response.change(headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers':
              'Authorization, X-API-Key, Content-Type',
        });
      };
    };
  }

  shelf.Middleware _rateLimitMiddleware() {
    return (shelf.Handler innerHandler) {
      return (shelf.Request request) async {
        final ip = request.ip ?? 'unknown';
        final now = DateTime.now();
        final entry = _rateLimitMap[ip];

        if (entry != null) {
          final requestsInWindow = entry.timestamps
              .where((t) => now.difference(t).inSeconds < 60)
              .toList();

          if (requestsInWindow.length >= 100) {
            return shelf.Response(429,
                body: json.encode({
                  'error': 'Rate limit exceeded',
                  'message': 'Maximum 100 requests per minute per IP'
                }),
                headers: {'Content-Type': 'application/json'});
          }

          entry.timestamps = requestsInWindow;
        }

        _rateLimitMap[ip] = _RateLimitEntry([...?(entry?.timestamps), now]);

        return innerHandler(request);
      };
    };
  }

  void _startRateLimitCleanup() {
    _rateLimitCleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      final now = DateTime.now();
      _rateLimitMap.removeWhere((_, entry) {
        entry.timestamps.removeWhere((t) => now.difference(t).inMinutes >= 5);
        return entry.timestamps.isEmpty;
      });
    });
  }

  bool _validateApiKey(shelf.Request request) {
    final authHeader = request.headers['Authorization'];
    String? providedKey;

    if (authHeader != null && authHeader.startsWith('Bearer ')) {
      providedKey = authHeader.substring(7);
    } else {
      providedKey = request.headers['X-API-Key'];
    }

    if (providedKey == null) return false;

    final apiKey = _apiKeys.firstWhere(
      (k) => k.key == providedKey && k.isEnabled,
      orElse: () =>
          ApiKey(id: '', key: '', name: '', createdAt: DateTime.now()),
    );

    if (apiKey.id.isNotEmpty) {
      _recordKeyUsage(apiKey.key);
      return true;
    }

    return false;
  }

  Future<shelf.Response> _handleHealth(shelf.Request request) async {
    return shelf.Response.ok(
        json.encode({
          'status': 'healthy',
          'timestamp': DateTime.now().toIso8601String(),
          'activeKeys': activeKeyCount,
        }),
        headers: {'Content-Type': 'application/json'});
  }

  Future<shelf.Response> _handleGetQuestions(shelf.Request request) async {
    if (!_validateApiKey(request)) {
      return shelf.Response(401,
          body: json.encode({'error': 'Unauthorized'}),
          headers: {'Content-Type': 'application/json'});
    }

    try {
      final params = request.url.queryParameters;
      final language = _settingsProvider?.language ?? 'nl';
      final category = params['category'];
      final difficulty = params['difficulty'];
      final limitParam = params['limit'];
      final limit = limitParam != null ? int.tryParse(limitParam) ?? 10 : 10;

      List<QuizQuestion> questions;

      if (category != null && _questionCacheService != null) {
        questions = await _questionCacheService!.getQuestionsByCategory(
          language,
          category,
          count: limit,
        );
      } else if (_questionCacheService != null) {
        questions =
            await _questionCacheService!.getQuestions(language, count: limit);
      } else {
        questions = [];
      }

      if (difficulty != null) {
        final diffInt = int.tryParse(difficulty);
        if (diffInt != null) {
          questions = questions
              .where((q) => int.tryParse(q.difficulty) == diffInt)
              .toList();
        }
      }

      final questionsJson = questions
          .map((q) => {
                'id': q.id,
                'question': q.question,
                'correctAnswer': q.correctAnswer,
                'incorrectAnswers': q.incorrectAnswers,
                'difficulty': q.difficulty,
                'type': q.type.name,
                'categories': q.categories,
                'biblicalReference': q.biblicalReference,
              })
          .toList();

      return shelf.Response.ok(
          json.encode({
            'count': questionsJson.length,
            'questions': questionsJson,
          }),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      AppLogger.error('Error getting questions', e);
      return shelf.Response(500,
          body: json.encode({'error': 'Internal server error'}),
          headers: {'Content-Type': 'application/json'});
    }
  }

  Future<shelf.Response> _handleGetProgress(shelf.Request request) async {
    if (!_validateApiKey(request)) {
      return shelf.Response(401,
          body: json.encode({'error': 'Unauthorized'}),
          headers: {'Content-Type': 'application/json'});
    }

    try {
      final progress = _lessonProgressProvider?.getExportData() ?? {};
      return shelf.Response.ok(json.encode(progress),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      AppLogger.error('Error getting progress', e);
      return shelf.Response(500,
          body: json.encode({'error': 'Internal server error'}),
          headers: {'Content-Type': 'application/json'});
    }
  }

  Future<shelf.Response> _handleGetStats(shelf.Request request) async {
    if (!_validateApiKey(request)) {
      return shelf.Response(401,
          body: json.encode({'error': 'Unauthorized'}),
          headers: {'Content-Type': 'application/json'});
    }

    try {
      final stats = _gameStatsProvider?.getExportData() ?? {};
      return shelf.Response.ok(json.encode(stats),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      AppLogger.error('Error getting stats', e);
      return shelf.Response(500,
          body: json.encode({'error': 'Internal server error'}),
          headers: {'Content-Type': 'application/json'});
    }
  }

  Future<shelf.Response> _handleGetStarsBalance(shelf.Request request) async {
    if (!_validateApiKey(request)) {
      return shelf.Response(401,
          body: json.encode({'error': 'Unauthorized'}),
          headers: {'Content-Type': 'application/json'});
    }

    try {
      final balance = _gameStatsProvider?.score ?? 0;
      return shelf.Response.ok(json.encode({'balance': balance}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      AppLogger.error('Error getting stars balance', e);
      return shelf.Response(500,
          body: json.encode({'error': 'Internal server error'}),
          headers: {'Content-Type': 'application/json'});
    }
  }

  Future<shelf.Response> _handleAddStars(shelf.Request request) async {
    if (!_validateApiKey(request)) {
      return shelf.Response(401,
          body: json.encode({'error': 'Unauthorized'}),
          headers: {'Content-Type': 'application/json'});
    }

    try {
      final body = await request.readAsString();
      final data = json.decode(body) as Map<String, dynamic>;
      final amount = data['amount'] as int?;

      if (amount == null || amount <= 0) {
        return shelf.Response(400,
            body: json
                .encode({'error': 'Invalid amount, must be positive integer'}),
            headers: {'Content-Type': 'application/json'});
      }

      final success = await _gameStatsProvider?.addStars(amount) ?? false;

      if (success) {
        return shelf.Response.ok(
            json.encode({
              'success': true,
              'newBalance': _gameStatsProvider?.score ?? 0,
            }),
            headers: {'Content-Type': 'application/json'});
      } else {
        return shelf.Response(500,
            body: json.encode({'error': 'Failed to add stars'}),
            headers: {'Content-Type': 'application/json'});
      }
    } catch (e) {
      AppLogger.error('Error adding stars', e);
      return shelf.Response(500,
          body: json.encode({'error': 'Internal server error'}),
          headers: {'Content-Type': 'application/json'});
    }
  }

  Future<shelf.Response> _handleSpendStars(shelf.Request request) async {
    if (!_validateApiKey(request)) {
      return shelf.Response(401,
          body: json.encode({'error': 'Unauthorized'}),
          headers: {'Content-Type': 'application/json'});
    }

    try {
      final body = await request.readAsString();
      final data = json.decode(body) as Map<String, dynamic>;
      final amount = data['amount'] as int?;

      if (amount == null || amount <= 0) {
        return shelf.Response(400,
            body: json
                .encode({'error': 'Invalid amount, must be positive integer'}),
            headers: {'Content-Type': 'application/json'});
      }

      final success = await _gameStatsProvider?.spendStars(amount) ?? false;

      if (success) {
        return shelf.Response.ok(
            json.encode({
              'success': true,
              'newBalance': _gameStatsProvider?.score ?? 0,
            }),
            headers: {'Content-Type': 'application/json'});
      } else {
        return shelf.Response(400,
            body: json.encode({'error': 'Insufficient balance'}),
            headers: {'Content-Type': 'application/json'});
      }
    } catch (e) {
      AppLogger.error('Error spending stars', e);
      return shelf.Response(500,
          body: json.encode({'error': 'Internal server error'}),
          headers: {'Content-Type': 'application/json'});
    }
  }

  Future<shelf.Request> _convertRequest(HttpRequest httpRequest) async {
    final headers = <String, String>{};
    httpRequest.headers.forEach((name, values) {
      headers[name] = values.join(',');
    });

    final body = await utf8.decoder.bind(httpRequest).join();

    return shelf.Request(
      httpRequest.method,
      httpRequest.requestedUri,
      headers: headers,
      body: body,
    );
  }

  Future<void> _writeResponse(
      HttpResponse httpResponse, shelf.Response shelfResponse) async {
    httpResponse.statusCode = shelfResponse.statusCode;

    shelfResponse.headers.forEach((name, value) {
      httpResponse.headers.set(name, value);
    });

    await shelfResponse.read().pipe(httpResponse);
  }

  void dispose() {
    stopServer();
    _rateLimitMap.clear();
  }
}

class _RateLimitEntry {
  List<DateTime> timestamps;
  _RateLimitEntry(this.timestamps);
}

extension on shelf.Request {
  String? get ip {
    final forwarded = headers['X-Forwarded-For'];
    if (forwarded != null) {
      return forwarded.split(',').first.trim();
    }
    return null;
  }
}
