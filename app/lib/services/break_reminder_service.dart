import '../services/logger.dart';

/// Service to track continuous foreground time and show break reminders
class BreakReminderService {
  static const Duration _breakReminderDuration = Duration(minutes: 30);

  static BreakReminderService? _instance;
  DateTime? _foregroundStartTime;
  bool _breakShownThisSession = false;

  BreakReminderService._privateConstructor();

  static BreakReminderService get instance {
    _instance ??= BreakReminderService._privateConstructor();
    return _instance!;
  }

  /// Start tracking when app comes to foreground
  void startForegroundTracking() {
    if (_foregroundStartTime == null) {
      _foregroundStartTime = DateTime.now();
      _breakShownThisSession = false;
      AppLogger.info('Break reminder tracking started');
    }
  }

  /// Stop tracking when app goes to background
  void stopForegroundTracking() {
    _foregroundStartTime = null;
    _breakShownThisSession = false;
    AppLogger.info('Break reminder tracking stopped');
  }

  /// Check if a break reminder should be shown
  bool shouldShowBreakReminder() {
    if (_foregroundStartTime == null || _breakShownThisSession) {
      return false;
    }

    final elapsedTime = DateTime.now().difference(_foregroundStartTime!);
    return elapsedTime >= _breakReminderDuration;
  }

  /// Mark that a break reminder has been shown for this session
  void markBreakShown() {
    _breakShownThisSession = true;
    AppLogger.info('Break reminder marked as shown');
  }

  /// Reset tracking (for testing or manual reset)
  void reset() {
    _foregroundStartTime = null;
    _breakShownThisSession = false;
    AppLogger.info('Break reminder tracking reset');
  }

  /// Get the remaining time until break reminder
  Duration? getRemainingTime() {
    if (_foregroundStartTime == null) {
      return null;
    }

    final elapsedTime = DateTime.now().difference(_foregroundStartTime!);
    if (elapsedTime >= _breakReminderDuration) {
      return Duration.zero;
    }

    return _breakReminderDuration - elapsedTime;
  }

  /// Get formatted remaining time
  String? getRemainingTimeFormatted() {
    final remaining = getRemainingTime();
    if (remaining == null) {
      return null;
    }

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
