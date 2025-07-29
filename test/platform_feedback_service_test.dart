import 'package:flutter_test/flutter_test.dart';
import 'package:bijbelquiz/services/platform_feedback_service.dart';

void main() {
  group('PlatformFeedbackService', () {
    late PlatformFeedbackService service;

    setUp(() async {
      service = PlatformFeedbackService();
      await service.initialize();
    });

    test('should initialize successfully', () async {
      expect(service, isNotNull);
    });

    test('should provide standardized feedback duration', () {
      final normalDuration = service.getStandardizedFeedbackDuration();
      final slowModeDuration = service.getStandardizedFeedbackDuration(slowMode: true);
      
      expect(normalDuration.inMilliseconds, greaterThan(0));
      expect(slowModeDuration.inMilliseconds, greaterThan(normalDuration.inMilliseconds));
    });

    test('should provide transition pause duration', () {
      final transitionDuration = service.getTransitionPauseDuration();
      expect(transitionDuration.inMilliseconds, greaterThan(0));
    });

    test('should provide platform info', () {
      final info = service.getPlatformInfo();
      expect(info, containsPair('platform', isA<String>()));
      expect(info, containsPair('multiplier', isA<double>()));
      expect(info, containsPair('standardDuration', isA<int>()));
      expect(info, containsPair('slowModeDuration', isA<int>()));
    });

    test('should have consistent timing across calls', () {
      final duration1 = service.getStandardizedFeedbackDuration();
      final duration2 = service.getStandardizedFeedbackDuration();
      
      expect(duration1.inMilliseconds, equals(duration2.inMilliseconds));
    });

    test('should apply platform-specific adjustments', () {
      final info = service.getPlatformInfo();
      final multiplier = info['multiplier'] as double;
      
      // Multiplier should be positive and reasonable
      expect(multiplier, greaterThan(0.0));
      expect(multiplier, lessThanOrEqualTo(2.0));
    });
  });
}