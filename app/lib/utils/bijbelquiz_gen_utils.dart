/// Utility class for checking if we're in the BijbelQuiz Gen period (December 10 - December 31)
class BijbelQuizGenPeriod {
  /// Check if the current date falls within the BijbelQuiz Gen period (December 10 - December 31)
  static bool isGenPeriod([DateTime? date]) {
    final now = date ?? DateTime.now();

    // Define the start and end of the Gen period
    // December 10 - December 31

    // Check if current date is between December 10 and December 31
    if (now.month == 12 && now.day >= 10 && now.day <= 31) {
      return true;
    }

    return false;
  }

  /// Get the start date of the current Gen period
  static DateTime getGenStartDate([DateTime? date]) {
    final now = date ?? DateTime.now();
    return DateTime(now.year, 12, 10);
  }

  /// Get the end date of the current Gen period
  static DateTime getGenEndDate([DateTime? date]) {
    final now = date ?? DateTime.now();
    return DateTime(now.year, 12, 31);
  }

  /// Get the year for which the stats are being calculated
  static int getStatsYear([DateTime? date]) {
    final now = date ?? DateTime.now();
    return now.year;
  }
}
