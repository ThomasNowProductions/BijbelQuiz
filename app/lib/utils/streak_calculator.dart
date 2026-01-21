/// Represents the state of a day in the streak tracker
enum DayState {
  success, // Day with activity
  fail, // Day without activity
  freeze, // Frozen day (e.g. Sunday)
  future, // Future day
}

/// Represents a day with its date and state in the streak tracker
class DayIndicator {
  final DateTime date;
  final DayState state;

  const DayIndicator({
    required this.date,
    required this.state,
  });
}

/// Utility class for calculating and managing daily activity streaks
class StreakCalculator {
  /// Formats a date as 'yyyy-MM-dd'
  static String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Checks if the given date is a Sunday
  static bool isSunday(DateTime date) => date.weekday == DateTime.sunday;

  /// Calculates the current streak count based on active days
  /// A streak is a sequence of consecutive days with activity (excluding Sundays)
  static int calculateCurrentStreak(Set<String> activeDays) {
    int streak = 0;
    DateTime now = DateTime.now();
    DateTime cursor = DateTime(now.year, now.month, now.day);

    while (true) {
      if (isSunday(cursor)) {
        // Sunday is a free day, does not break or add to streak
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }

      final dayStr = formatDate(cursor);
      if (activeDays.contains(dayStr)) {
        streak += 1;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Gets a five-day window centered around today showing streak status
  static List<DayIndicator> getFiveDayWindow(Set<String> activeDays) {
    final List<DayIndicator> out = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int offset = -2; offset <= 2; offset++) {
      final day = today.add(Duration(days: offset));
      final isFuture = day.isAfter(today);
      final dayStr = formatDate(day);

      DayState state;
      if (isFuture) {
        state = DayState.future;
      } else if (isSunday(day)) {
        // Sunday streak freeze only applies to non-future days
        state = DayState.freeze;
      } else if (activeDays.contains(dayStr)) {
        state = DayState.success;
      } else {
        // For the current day, show fail state only after the day is completely over
        if (day.isAtSameMomentAs(today)) {
          // Current day not done yet, use fail state for now (this will be handled in the UI with orange)
          state = DayState.fail;
        } else {
          // Past day without activity
          state = DayState.fail;
        }
      }

      out.add(DayIndicator(date: day, state: state));
    }

    return out;
  }
}
