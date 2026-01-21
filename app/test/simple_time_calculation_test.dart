import 'package:flutter_test/flutter_test.dart';
import 'package:bijbelquiz/services/logger.dart';

void main() {
  group('Simple Time Calculation Tests', () {
    test('Test time calculation with 2006 questions', () {
      // Test the calculation directly
      final totalQuestions = 2006;
      final totalSeconds = totalQuestions * 5;
      final hours = totalSeconds / 3600.0;

      AppLogger.info('Total seconds for 2006 questions: $totalSeconds');
      AppLogger.info('Total hours for 2006 questions: $hours');

      // Verify calculations: 2006 questions * 5 seconds = 10030 seconds = 2.786 hours
      expect(hours, closeTo(2.786, 0.01));

      // Test formatted time
      final formattedHours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
      final formattedMinutes =
          ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
      final formattedSeconds = (totalSeconds % 60).toString().padLeft(2, '0');
      final formattedTime =
          '$formattedHours:$formattedMinutes:$formattedSeconds';

      AppLogger.info('Formatted time: $formattedTime');
      expect(formattedTime,
          '02:47:10'); // 10030 seconds = 2 hours, 47 minutes, 10 seconds
    });

    test('Test time calculation with zero questions', () {
      final totalQuestions = 0;
      final totalSeconds = totalQuestions * 5;
      final hours = totalSeconds / 3600.0;

      expect(hours, 0.0);
      expect('$hours', '0.0');
    });

    test('Test time calculation with 100 questions', () {
      final totalQuestions = 100;
      final totalSeconds = totalQuestions * 5;
      final hours = totalSeconds / 3600.0;

      // 100 questions * 5 seconds = 500 seconds = 0.139 hours
      expect(hours, closeTo(0.139, 0.01));

      // Test formatted time
      final formattedHours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
      final formattedMinutes =
          ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
      final formattedSeconds = (totalSeconds % 60).toString().padLeft(2, '0');
      final formattedTime =
          '$formattedHours:$formattedMinutes:$formattedSeconds';

      expect(formattedTime, '00:08:20'); // 500 seconds = 8 minutes 20 seconds
    });

    test(
        'Verify user scenario: 2006 questions should show 2.786 hours not 716.6',
        () {
      final totalQuestions = 2006;
      final totalSeconds = totalQuestions * 5;
      final hours = totalSeconds / 3600.0;

      AppLogger.info('User scenario - 2006 questions:');
      AppLogger.info('Total hours: $hours');

      // Should be 2.786 hours, NOT 716.6 hours
      expect(hours, closeTo(2.786, 0.01));
      expect(hours, isNot(closeTo(716.6, 1.0)));
    });
  });
}
