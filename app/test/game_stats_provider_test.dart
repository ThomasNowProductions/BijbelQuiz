import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bijbelquiz/providers/game_stats_provider.dart';

// Generate mocks
@GenerateMocks([SharedPreferences])
import 'game_stats_provider_test.mocks.dart';

void main() {
  late MockSharedPreferences mockPrefs;
  late GameStatsProvider provider;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    provider.dispose();
  });

  group('GameStatsProvider', () {
    test('should initialize with default values', () async {
      when(mockPrefs.getInt('game_score')).thenReturn(null);
      when(mockPrefs.getInt('game_current_streak')).thenReturn(null);
      when(mockPrefs.getInt('game_longest_streak')).thenReturn(null);
      when(mockPrefs.getInt('game_incorrect_answers')).thenReturn(null);

      provider = GameStatsProvider();

      // Wait for initialization
      await Future.delayed(Duration.zero);

      expect(provider.score, 0);
      expect(provider.currentStreak, 0);
      expect(provider.longestStreak, 0);
      expect(provider.incorrectAnswers, 0);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('should load stats from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'game_score': 150,
        'game_current_streak': 5,
        'game_longest_streak': 12,
        'game_incorrect_answers': 8,
      });

      provider = GameStatsProvider();

      // Wait for initialization
      await Future.delayed(Duration.zero);

      expect(provider.score, 150);
      expect(provider.currentStreak, 5);
      expect(provider.longestStreak, 12);
      expect(provider.incorrectAnswers, 8);
    });

    test('should update stats correctly for correct answer', () async {
      SharedPreferences.setMockInitialValues({});

      provider = GameStatsProvider();
      await Future.delayed(Duration.zero);

      await provider.updateStats(isCorrect: true);

      expect(provider.score, 6); // 1 base + 5 bonus for new longest streak
      expect(provider.currentStreak, 1);
      expect(provider.longestStreak, 1);
      expect(provider.incorrectAnswers, 0);
    });

    test('should update stats correctly for incorrect answer', () async {
      SharedPreferences.setMockInitialValues({});

      provider = GameStatsProvider();
      await Future.delayed(Duration.zero);

      await provider.updateStats(isCorrect: false);

      expect(provider.score, 0);
      expect(provider.currentStreak, 0);
      expect(provider.longestStreak, 0);
      expect(provider.incorrectAnswers, 1);
    });

    test('should update longest streak when current exceeds it', () async {
      SharedPreferences.setMockInitialValues({
        'game_score': 0,
        'game_current_streak': 4,
        'game_longest_streak': 4,
        'game_incorrect_answers': 0,
      });

      provider = GameStatsProvider();
      await Future.delayed(Duration.zero);

      await provider.updateStats(isCorrect: true);

      expect(provider.score, 6); // 1 + 5 bonus for new longest streak
      expect(provider.currentStreak, 5);
      expect(provider.longestStreak, 5);
    });

    test('should reset stats correctly', () async {
      SharedPreferences.setMockInitialValues({});

      provider = GameStatsProvider();
      await Future.delayed(Duration.zero);

      await provider.resetStats();

      expect(provider.score, 0);
      expect(provider.currentStreak, 0);
      expect(provider.longestStreak, 0);
      expect(provider.incorrectAnswers, 0);
    });

    test('should spend points for retry successfully', () async {
      SharedPreferences.setMockInitialValues({
        'game_score': 100,
      });

      provider = GameStatsProvider();
      await Future.delayed(Duration.zero);

      final result = await provider.spendPointsForRetry();

      expect(result, true);
      expect(provider.score, 50);
    });

    test('should fail to spend points for retry when insufficient', () async {
      SharedPreferences.setMockInitialValues({
        'game_score': 40,
      });

      provider = GameStatsProvider();
      await Future.delayed(Duration.zero);

      final result = await provider.spendPointsForRetry();

      expect(result, false);
      expect(provider.score, 40);
    });

    test('should spend stars successfully', () async {
      SharedPreferences.setMockInitialValues({
        'game_score': 100,
      });

      provider = GameStatsProvider();
      await Future.delayed(Duration.zero);

      final result = await provider.spendStars(25);

      expect(result, true);
      expect(provider.score, 75);
    });

    test('should fail to spend stars when insufficient', () async {
      SharedPreferences.setMockInitialValues({
        'game_score': 20,
      });

      provider = GameStatsProvider();
      await Future.delayed(Duration.zero);

      final result = await provider.spendStars(50);

      expect(result, false);
      expect(provider.score, 20);
    });

    test('should export data correctly', () async {
      SharedPreferences.setMockInitialValues({
        'game_score': 150,
        'game_current_streak': 5,
        'game_longest_streak': 12,
        'game_incorrect_answers': 8,
      });

      provider = GameStatsProvider();
      await Future.delayed(Duration.zero);

      final data = provider.getExportData();

      expect(data['score'], 150);
      expect(data['currentStreak'], 5);
      expect(data['longestStreak'], 12);
      expect(data['incorrectAnswers'], 8);
    });

    test('should load import data correctly', () async {
      SharedPreferences.setMockInitialValues({});

      provider = GameStatsProvider();
      await Future.delayed(Duration.zero);

      final importData = {
        'score': 200,
        'currentStreak': 8,
        'longestStreak': 15,
        'incorrectAnswers': 12,
      };

      await provider.loadImportData(importData);

      expect(provider.score, 200);
      expect(provider.currentStreak, 8);
      expect(provider.longestStreak, 15);
      expect(provider.incorrectAnswers, 12);
    });
  });

  group('Powerup functionality', () {
    test('should activate question-based powerup', () {
      provider = GameStatsProvider();

      provider.activatePowerup(multiplier: 2, questions: 5);

      expect(provider.activePowerup, isNotNull);
      expect(provider.powerupMultiplier, 2);
      expect(provider.powerupQuestionsLeft, 5);
      expect(provider.isPowerupActive, true);
    });

    test('should activate time-based powerup', () {
      provider = GameStatsProvider();

      provider.activatePowerup(multiplier: 3, time: Duration(minutes: 5));

      expect(provider.activePowerup, isNotNull);
      expect(provider.powerupMultiplier, 3);
      expect(provider.powerupTimeLeft, isNotNull);
      expect(provider.isPowerupActive, true);
    });

    test('should clear powerup', () {
      provider = GameStatsProvider();
      provider.activatePowerup(multiplier: 2, questions: 5);

      provider.clearPowerup();

      expect(provider.activePowerup, isNull);
      expect(provider.isPowerupActive, false);
    });

    test('should decrement question-based powerup', () async {
      SharedPreferences.setMockInitialValues({});

      provider = GameStatsProvider();
      await Future.delayed(Duration.zero);
      provider.activatePowerup(multiplier: 2, questions: 3);

      await provider.updateStats(isCorrect: true);

      expect(provider.powerupQuestionsLeft, 2);

      await provider.updateStats(isCorrect: true);
      await provider.updateStats(isCorrect: true);

      expect(provider.activePowerup, isNull);
    });

    test('should handle powerup multiplier in score calculation', () async {
      SharedPreferences.setMockInitialValues({});

      provider = GameStatsProvider();
      await Future.delayed(Duration.zero);

      provider.activatePowerup(multiplier: 3, questions: 2);

      await provider.updateStats(isCorrect: true);

      expect(provider.score, 8); // 3 (3*1) + 5 bonus for new longest streak
      expect(provider.powerupQuestionsLeft, 1);

      // Test decrement by answering another question
      await provider.updateStats(isCorrect: true);
      expect(provider.score, 16); // 8 + 3 (3*1) + 5 bonus for new longest streak
      expect(provider.activePowerup, isNull);  // Powerup should be null after 2 questions
    });
  });
}