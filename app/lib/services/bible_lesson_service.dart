import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/bible_lesson.dart';
import '../services/logger.dart';

/// Service for managing Bible learning lessons with educational content.
/// These lessons are designed for new users who know nothing about the Bible,
/// providing reading material before quizzes to teach fundamentals.
class BibleLessonService {
  /// Cached lessons data to avoid repeated asset loading
  static Map<String, List<BibleLesson>>? _cachedLessons;

  BibleLessonService();

  /// Loads lessons from the JSON asset file
  Future<Map<String, List<BibleLesson>>> _loadLessonsFromAsset() async {
    if (_cachedLessons != null) {
      return _cachedLessons!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/bible-lessons.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final Map<String, List<BibleLesson>> result = {};

      for (final entry in jsonData.entries) {
        final language = entry.key;
        final lessonsList = entry.value as List<dynamic>;
        result[language] = lessonsList
            .map((lessonJson) => BibleLesson.fromJson(lessonJson as Map<String, dynamic>))
            .toList();
      }

      _cachedLessons = result;
      return result;
    } catch (e) {
      AppLogger.error('Failed to load lessons from asset', e);
      return {};
    }
  }

  /// Generates the beginner Bible lessons for new users.
  /// These lessons cover fundamental topics from the Old and New Testament.
  ///
  /// - [language]: question language ('nl' for Dutch, 'en' for English)
  Future<List<BibleLesson>> getBeginnerLessons(String language) async {
    try {
      final lessonsMap = await _loadLessonsFromAsset();
      
      // Return lessons for the requested language, fall back to Dutch
      if (lessonsMap.containsKey(language)) {
        return lessonsMap[language]!;
      }
      return lessonsMap['nl'] ?? [];
    } catch (e) {
      AppLogger.error('Failed to load beginner lessons', e);
      return [];
    }
  }

  /// Get a specific lesson by ID
  Future<BibleLesson?> getLessonById(String id, String language) async {
    final lessons = await getBeginnerLessons(language);
    try {
      return lessons.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clears the cached lessons (useful for testing or language changes)
  static void clearCache() {
    _cachedLessons = null;
  }
}
