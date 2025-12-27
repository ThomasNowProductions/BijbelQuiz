import '../models/lesson.dart';
import '../services/logger.dart';
import '../utils/automatic_error_reporter.dart';

/// Builds Duolingo-like lessons not tied to categories.
/// Lessons are generic, numbered, and each pulls a capped set of random questions.
class LessonService {
  LessonService();

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
      final lessons = <Lesson>[];

      for (int i = 0; i < maxLessons; i++) {
        final id = 'lesson_${i.toString().padLeft(4, '0')}';
        final lessonNumber = i + 1;

        // All lessons are now regular lessons
        final category = 'Algemeen';
        final title = 'Les $lessonNumber';
        final description = 'Beantwoord $maxQuestionsPerLesson vragen';
        final special = false;

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
