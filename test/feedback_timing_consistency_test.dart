import 'package:flutter_test/flutter_test.dart';
import 'package:bijbelquiz/services/platform_feedback_service.dart';

void main() {
  group('Feedback Timing Consistency', () {
    late PlatformFeedbackService service;

    setUp(() async {
      service = PlatformFeedbackService();
      await service.initialize();
    });

    test('should provide identical timing for correct and incorrect feedback', () {
      // Get feedback duration multiple times to ensure consistency
      final duration1 = service.getStandardizedFeedbackDuration();
      final duration2 = service.getStandardizedFeedbackDuration();
      final duration3 = service.getStandardizedFeedbackDuration(slowMode: false);
      
      // All calls should return identical durations
      expect(duration1.inMilliseconds, equals(duration2.inMilliseconds));
      expect(duration2.inMilliseconds, equals(duration3.inMilliseconds));
    });

    test('should provide different timing for normal vs slow mode', () {
      final normalDuration = service.getStandardizedFeedbackDuration(slowMode: false);
      final slowDuration = service.getStandardizedFeedbackDuration(slowMode: true);
      
      // Slow mode should be longer than normal mode
      expect(slowDuration.inMilliseconds, greaterThan(normalDuration.inMilliseconds));
    });

    test('should provide reasonable timing values', () {
      final normalDuration = service.getStandardizedFeedbackDuration(slowMode: false);
      final slowDuration = service.getStandardizedFeedbackDuration(slowMode: true);
      
      // Normal mode should be between 400-800ms (reasonable for user feedback)
      expect(normalDuration.inMilliseconds, greaterThanOrEqualTo(400));
      expect(normalDuration.inMilliseconds, lessThanOrEqualTo(800));
      
      // Slow mode should be between 700-1200ms
      expect(slowDuration.inMilliseconds, greaterThanOrEqualTo(700));
      expect(slowDuration.inMilliseconds, lessThanOrEqualTo(1200));
    });

    test('should apply platform-specific adjustments correctly', () {
      final info = service.getPlatformInfo();
      final multiplier = info['multiplier'] as double;
      final standardDuration = info['standardDuration'] as int;
      
      // Verify that the multiplier is being applied
      if (multiplier != 1.0) {
        // If multiplier is not 1.0, the duration should be adjusted
        final expectedDuration = (650 * multiplier).round();
        expect(standardDuration, equals(expectedDuration));
      } else {
        // If multiplier is 1.0, duration should be the base value
        expect(standardDuration, equals(650));
      }
    });
  });
}