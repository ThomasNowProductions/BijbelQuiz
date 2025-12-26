import '../logger.dart';

/// Interface for conflict resolution strategies
abstract class ConflictResolver {
  /// Resolves a conflict between existing data and incoming data
  /// Returns the merged data
  Map<String, dynamic> resolve(
    Map<String, dynamic> existing,
    Map<String, dynamic> incoming,
  );
}

/// Resolves conflicts based on timestamp (last write wins)
class TimestampConflictResolver implements ConflictResolver {
  @override
  Map<String, dynamic> resolve(
    Map<String, dynamic> existing,
    Map<String, dynamic> incoming,
  ) {
    // For simple data, we assume the incoming data is newer or preferred
    // if we've reached the conflict resolution stage.
    // However, if we had timestamps inside the data payload, we could compare them.
    // Here we default to incoming (last write wins logic handled by caller usually, but explicit here)
    return incoming;
  }
}

/// Resolves conflicts for game statistics
class GameStatsConflictResolver implements ConflictResolver {
  @override
  Map<String, dynamic> resolve(
    Map<String, dynamic> existing,
    Map<String, dynamic> incoming,
  ) {
    if (!_isValidGameStatsData(existing) || !_isValidGameStatsData(incoming)) {
      AppLogger.warning(
          'Invalid game stats data in merge, using incoming data as fallback');
      return incoming;
    }

    final existingScore = existing['score'] as int? ?? 0;
    final incomingScore = incoming['score'] as int? ?? 0;
    final existingCurrentStreak = existing['currentStreak'] as int? ?? 0;
    final incomingCurrentStreak = incoming['currentStreak'] as int? ?? 0;
    final existingLongestStreak = existing['longestStreak'] as int? ?? 0;
    final incomingLongestStreak = incoming['longestStreak'] as int? ?? 0;
    final existingIncorrect = existing['incorrectAnswers'] as int? ?? 0;
    final incomingIncorrect = incoming['incorrectAnswers'] as int? ?? 0;

    return {
      // Take maximum score
      'score': existingScore > incomingScore ? existingScore : incomingScore,
      // Take maximum current streak (but reset if incoming just started)
      'currentStreak': existingCurrentStreak > incomingCurrentStreak
          ? existingCurrentStreak
          : incomingCurrentStreak,
      // Take maximum longest streak
      'longestStreak': existingLongestStreak > incomingLongestStreak
          ? existingLongestStreak
          : incomingLongestStreak,
      // Sum incorrect answers to track total mistakes across devices
      'incorrectAnswers': existingIncorrect + incomingIncorrect,
    };
  }

  bool _isValidGameStatsData(Map<String, dynamic> data) {
    return data.containsKey('score') &&
        data.containsKey('currentStreak') &&
        data.containsKey('longestStreak') &&
        data.containsKey('incorrectAnswers') &&
        data['score'] is int &&
        data['currentStreak'] is int &&
        data['longestStreak'] is int &&
        data['incorrectAnswers'] is int;
  }
}

/// Resolves conflicts for settings
class SettingsConflictResolver implements ConflictResolver {
  @override
  Map<String, dynamic> resolve(
    Map<String, dynamic> existing,
    Map<String, dynamic> incoming,
  ) {
    // For settings, we generally want the latest values, but merge AI themes by combining
    final merged = Map<String, dynamic>.from(incoming);

    // For AI themes, merge by combining all themes
    if (existing.containsKey('aiThemes') && incoming.containsKey('aiThemes')) {
      final existingThemes =
          Map<String, dynamic>.from(existing['aiThemes'] ?? {});
      final incomingThemes =
          Map<String, dynamic>.from(incoming['aiThemes'] ?? {});
      final mergedThemes = Map<String, dynamic>.from(existingThemes);
      mergedThemes.addAll(incomingThemes); // Incoming themes override existing
      merged['aiThemes'] = mergedThemes;
    }

    return merged;
  }
}

/// Resolves conflicts for lesson progress
class LessonProgressConflictResolver implements ConflictResolver {
  @override
  Map<String, dynamic> resolve(
    Map<String, dynamic> existing,
    Map<String, dynamic> incoming,
  ) {
    final merged = Map<String, dynamic>.from(incoming);

    // Take the maximum unlocked count
    final existingUnlocked = existing['unlockedCount'] as int? ?? 1;
    final incomingUnlocked = incoming['unlockedCount'] as int? ?? 1;
    merged['unlockedCount'] = existingUnlocked > incomingUnlocked
        ? existingUnlocked
        : incomingUnlocked;

    // Merge best stars by taking maximum for each lesson
    final existingStars =
        Map<String, int>.from(existing['bestStarsByLesson'] ?? {});
    final incomingStars =
        Map<String, int>.from(incoming['bestStarsByLesson'] ?? {});
    final mergedStars = Map<String, int>.from(existingStars);

    incomingStars.forEach((lessonId, stars) {
      final currentStars = mergedStars[lessonId] ?? 0;
      if (stars > currentStars) {
        mergedStars[lessonId] = stars;
      }
    });

    merged['bestStarsByLesson'] = mergedStars;
    return merged;
  }
}

/// Factory to get the appropriate resolver for a key
class ConflictResolverFactory {
  static ConflictResolver getResolver(String key) {
    switch (key) {
      case 'game_stats':
        return GameStatsConflictResolver();
      case 'settings':
        return SettingsConflictResolver();
      case 'lesson_progress':
        return LessonProgressConflictResolver();
      default:
        return TimestampConflictResolver();
    }
  }
}
