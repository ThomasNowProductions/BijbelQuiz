import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/lesson.dart';
import '../services/logger.dart';
import '../utils/automatic_error_reporter.dart';

/// Builds Duolingo-like lessons not tied to categories.
/// Lessons are generic, numbered, and each pulls a capped set of random questions.
class LessonService {
  LessonService();

  List<String>? _categories;

  Future<List<String>> _loadCategories() async {
    if (_categories != null) return _categories!;
    try {
      final jsonString = await rootBundle.loadString('assets/categories.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _categories = jsonList.map((e) => e.toString()).toList();
      return _categories!;
    } catch (e) {
      AppLogger.error('Failed to load categories', e);
      
      // Report error to automatic error tracking system
      await AutomaticErrorReporter.reportStorageError(
        message: 'Failed to load lesson categories from assets',
        operation: 'load_categories',
        filePath: 'assets/categories.json',
        additionalInfo: {
          'error': e.toString(),
          'operation_type': 'asset_loading',
          'fallback_used': true,
        },
      );
      
      return ['Genesis', 'Exodus', 'Matteüs', 'Johannes']; // Fallback
    }
  }

  /// Generates a sequential list of generic lessons (Les 1, Les 2, ...).
  ///
  /// - [language]: question language (currently forced to 'nl' in settings)
  /// - [maxLessons]: number of lessons to expose in the track
  /// - [maxQuestionsPerLesson]: cap of questions per lesson
  Future<List<Lesson>> generateLessons(
    String language, {
    int maxLessons = 30,
    int maxQuestionsPerLesson = 10,
  }) async {
    try {
      final categories = await _loadCategories();
      final lessons = <Lesson>[];

      for (int i = 0; i < maxLessons; i++) {
        final id = 'lesson_${i.toString().padLeft(4, '0')}';
        final lessonNumber = i + 1;

        // Check if this should be a special lesson (every 7-10 lessons)
        final isSpecial = lessonNumber > 1 && (lessonNumber - 1) % (7 + (i % 4)) == 0;

        String category;
        String title;
        String description;
        bool special = false;

        if (isSpecial) {
          // Special lesson: pick a random category from categories.json
          category = categories[i % categories.length];
          title = 'Speciale Les $lessonNumber - $category';
          description = 'Beantwoord $maxQuestionsPerLesson vragen uit $category';
          special = true;
        } else {
          // Regular lesson
          category = 'Algemeen';
          title = 'Les $lessonNumber';
          description = 'Beantwoord $maxQuestionsPerLesson vragen';
        }

        lessons.add(Lesson(
          id: id,
          title: title,
          category: category,
          maxQuestions: maxQuestionsPerLesson,
          index: i,
          description: description,
          iconHint: _iconForIndex(i),
          isSpecial: special,
        ));
      }

      if (lessons.isEmpty) {
        return [
          Lesson(
            id: 'lesson_0000',
            title: 'Les 1',
            category: 'Algemeen',
            maxQuestions: maxQuestionsPerLesson,
            index: 0,
            description: 'Beantwoord $maxQuestionsPerLesson vragen',
            iconHint: 'menu_book',
            isSpecial: false,
          ),
        ];
      }

      return lessons;
    } catch (e) {
      AppLogger.error('Failed to generate lessons', e);
      
      // Report error to automatic error tracking system
      await AutomaticErrorReporter.reportQuestionError(
        message: 'Failed to generate lessons',
        questionId: 'lesson_generation_error',
        additionalInfo: {
          'language': language,
          'max_lessons': maxLessons,
          'max_questions_per_lesson': maxQuestionsPerLesson,
          'error': e.toString(),
          'operation_type': 'lesson_generation',
          'fallback_used': true,
        },
      );
      
      // Minimal fallback to keep UI functional
      return [
        Lesson(
          id: 'lesson_0000',
          title: 'Les 1',
          category: 'Algemeen',
          maxQuestions: maxQuestionsPerLesson,
          index: 0,
          description: 'Beantwoord $maxQuestionsPerLesson vragen',
          iconHint: 'menu_book',
          isSpecial: false,
        ),
      ];
    }
  }

  String _iconForIndex(int i) {
    const icons = [
      'menu_book',
      'stars',
      'auto_awesome',
      'emoji_objects',
      'record_voice_over',
      'forum',
      'church',
      'music_note',
      'mail',
      'castle',
    ];
    return icons[i % icons.length];
  }
}
