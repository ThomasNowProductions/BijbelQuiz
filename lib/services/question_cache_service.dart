import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_question.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'logger.dart';

/// A service for caching and lazy loading quiz questions to improve performance
/// on low-end devices and poor internet connections.
class QuestionCacheService {
  static const String _cacheKey = 'cached_questions';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const Duration _cacheExpiry = Duration(days: 7);
  static const int _maxCacheSize = 100; // Maximum number of questions per language
  static const String _appVersionKey = 'app_version';
  
  final Map<String, List<QuizQuestion>> _memoryCache = {};
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  /// Initialize the cache service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      await _clearCacheOnAppUpdate();
      AppLogger.info('QuestionCacheService initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize QuestionCacheService', e);
      // Continue without persistent cache if SharedPreferences fails
    }
  }

  /// Clear cache if app version has changed
  Future<void> _clearCacheOnAppUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final savedVersion = _prefs.getString(_appVersionKey);
      if (savedVersion == null || savedVersion != currentVersion) {
        await clearCache();
        await _prefs.setString(_appVersionKey, currentVersion);
        AppLogger.info('Cache cleared on app update: $currentVersion');
      }
    } catch (e) {
      AppLogger.error('Error checking app version for cache clear', e);
      // Ignore version check errors
    }
  }

  /// Get questions for a specific language with lazy loading
  Future<List<QuizQuestion>> getQuestions(String language) async {
    await initialize();
    
    // Check memory cache first
    if (_memoryCache.containsKey(language)) {
      return _memoryCache[language]!;
    }
    
    // Check persistent cache
    final cachedQuestions = await _getCachedQuestions(language);
    if (cachedQuestions.isNotEmpty) {
      _memoryCache[language] = cachedQuestions;
      return cachedQuestions;
    }
    
    // Load from assets and cache
    final questions = await _loadQuestionsFromAssets(language);
    await _cacheQuestions(language, questions);
    _memoryCache[language] = questions;
    
    return questions;
  }

  /// Get a batch of questions for a specific language with lazy loading
  Future<List<QuizQuestion>> getQuestionBatch(String language, int batchSize, int offset) async {
    await initialize();

    // Try to get the full list from memory cache (if already loaded)
    if (_memoryCache.containsKey(language)) {
      final allQuestions = _memoryCache[language]!;
      final end = (offset + batchSize) > allQuestions.length ? allQuestions.length : (offset + batchSize);
      return allQuestions.sublist(offset, end);
    }

    // Try to get from persistent cache (if available)
    final cachedQuestions = await _getCachedQuestions(language);
    if (cachedQuestions.isNotEmpty) {
      _memoryCache[language] = cachedQuestions;
      final end = (offset + batchSize) > cachedQuestions.length ? cachedQuestions.length : (offset + batchSize);
      return cachedQuestions.sublist(offset, end);
    }

    // Load from assets (but only keep in memory the batch)
    final allQuestions = await _loadQuestionsFromAssets(language);
    await _cacheQuestions(language, allQuestions);
    _memoryCache[language] = allQuestions;
    final end = (offset + batchSize) > allQuestions.length ? allQuestions.length : (offset + batchSize);
    return allQuestions.sublist(offset, end);
  }

  /// Load questions from assets with error handling
  Future<List<QuizQuestion>> _loadQuestionsFromAssets(String language) async {
    try {
      final String response = await rootBundle.loadString('assets/questions-nl-sv.json');
      
      final List<dynamic> data = json.decode(response);
      if (data.isEmpty) {
        throw Exception('Question file is empty');
      }
      
      final questions = data.map((json) {
        try {
          return QuizQuestion.fromJson(json);
        } catch (e) {
          throw Exception('Invalid question format: $e');
        }
      }).toList();
      
      if (questions.isEmpty) {
        throw Exception('No valid questions found');
      }
      
      // Sort questions by difficulty for better performance
      questions.sort((a, b) {
        final difficultyOrder = {'MAKKELIJK': 0, 'GEMIDDELD': 1, 'MOEILIJK': 2};
        return (difficultyOrder[a.difficulty] ?? 0).compareTo(difficultyOrder[b.difficulty] ?? 0);
      });
      
      return questions;
    } catch (e) {
      throw Exception('Failed to load questions: $e');
    }
  }

  /// Get cached questions from persistent storage
  Future<List<QuizQuestion>> _getCachedQuestions(String language) async {
    if (!_isInitialized) return [];
    
    try {
      final cacheKey = '${_cacheKey}_$language';
      final timestampKey = '${_cacheTimestampKey}_$language';
      
      final cachedData = _prefs.getString(cacheKey);
      final timestamp = _prefs.getInt(timestampKey);
      
      if (cachedData == null || timestamp == null) {
        return [];
      }
      
      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
        return [];
      }
      
      final List<dynamic> data = json.decode(cachedData);
      return data.map((json) => QuizQuestion.fromJson(json)).toList();
    } catch (e) {
      // Return empty list if cache is corrupted
      return [];
    }
  }

  /// Cache questions to persistent storage
  Future<void> _cacheQuestions(String language, List<QuizQuestion> questions) async {
    if (!_isInitialized) return;
    try {
      // Limit cache size
      List<QuizQuestion> limitedQuestions = questions;
      if (questions.length > _maxCacheSize) {
        limitedQuestions = questions.sublist(0, _maxCacheSize);
      }
      final cacheKey = '${_cacheKey}_$language';
      final timestampKey = '${_cacheTimestampKey}_$language';
      final data = limitedQuestions.map((q) => q.toJson()).toList();
      final jsonData = json.encode(data);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await _prefs.setString(cacheKey, jsonData);
      await _prefs.setInt(timestampKey, timestamp);
    } catch (e) {
      // Continue without caching if storage fails
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await initialize();
    try {
      final keys = _prefs.getKeys().where((key) => 
        key.startsWith(_cacheKey) || key.startsWith(_cacheTimestampKey)
      );
      for (final key in keys) {
        await _prefs.remove(key);
      }
      _memoryCache.clear();
      AppLogger.info('Cache cleared successfully');
    } catch (e) {
      AppLogger.error('Failed to clear cache', e);
      // Continue if clearing fails
    }
  }

  /// Get memory usage information
  Map<String, dynamic> getMemoryUsage() {
    return {
      'memoryCacheSize': _memoryCache.length,
      'cachedLanguages': _memoryCache.keys.toList(),
    };
  }
} 