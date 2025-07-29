import 'package:flutter_test/flutter_test.dart';
import 'package:bijbelquiz/models/quiz_question.dart';
import 'package:bijbelquiz/providers/game_stats_provider.dart';
import 'package:bijbelquiz/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  group('Question Repetition Tests', () {
    late List<QuizQuestion> testQuestions;
    late GameStatsProvider gameStatsProvider;
    late SettingsProvider settingsProvider;

    setUp(() {
      // Create test questions
      testQuestions = [
        QuizQuestion(
          question: "Test question 1",
          correctAnswer: "Answer 1",
          incorrectAnswers: ["Wrong 1", "Wrong 2", "Wrong 3"],
          difficulty: "MAKKELIJK",
          type: QuestionType.mc,
        ),
        QuizQuestion(
          question: "Test question 2",
          correctAnswer: "Answer 2",
          incorrectAnswers: ["Wrong 1", "Wrong 2", "Wrong 3"],
          difficulty: "GEMIDDELD",
          type: QuestionType.mc,
        ),
        QuizQuestion(
          question: "Test question 3",
          correctAnswer: "Answer 3",
          incorrectAnswers: ["Wrong 1", "Wrong 2", "Wrong 3"],
          difficulty: "MOEILIJK",
          type: QuestionType.mc,
        ),
        QuizQuestion(
          question: "Test question 4",
          correctAnswer: "Answer 4",
          incorrectAnswers: ["Wrong 1", "Wrong 2", "Wrong 3"],
          difficulty: "MAKKELIJK",
          type: QuestionType.mc,
        ),
        QuizQuestion(
          question: "Test question 5",
          correctAnswer: "Answer 5",
          incorrectAnswers: ["Wrong 1", "Wrong 2", "Wrong 3"],
          difficulty: "GEMIDDELD",
          type: QuestionType.mc,
        ),
      ];

      gameStatsProvider = GameStatsProvider();
      settingsProvider = SettingsProvider();
    });

    testWidgets('Questions should not repeat until all are used', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settingsProvider),
            ChangeNotifierProvider.value(value: gameStatsProvider),
          ],
          child: const MaterialApp(home: Scaffold()),
        ),
      );

      // Create a mock quiz screen state
      final quizState = _MockQuizScreenState();
      quizState._allQuestions = testQuestions;

      // Test that we get all questions without repetition
      final usedQuestions = <String>{};
      final selectedQuestions = <QuizQuestion>[];

      // Simulate selecting 5 questions (all available)
      for (int i = 0; i < 5; i++) {
        final question = quizState._getNextQuestion(0.0);
        selectedQuestions.add(question);
        usedQuestions.add(question.question);
        
        // Verify no repetition so far
        expect(usedQuestions.length, i + 1);
        expect(selectedQuestions.length, i + 1);
      }

      // Verify all questions were used
      expect(usedQuestions.length, 5);
      expect(usedQuestions.contains("Test question 1"), true);
      expect(usedQuestions.contains("Test question 2"), true);
      expect(usedQuestions.contains("Test question 3"), true);
      expect(usedQuestions.contains("Test question 4"), true);
      expect(usedQuestions.contains("Test question 5"), true);

      // Test that after all questions are used, the pool resets
      final question6 = quizState._getNextQuestion(0.0);
      expect(question6.question, isA<String>());
      // The question should be one of the original questions (pool reset)
      expect(testQuestions.map((q) => q.question).contains(question6.question), true);
    });

    testWidgets('Question pool should reset when all questions are used', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settingsProvider),
            ChangeNotifierProvider.value(value: gameStatsProvider),
          ],
          child: const MaterialApp(home: Scaffold()),
        ),
      );

      final quizState = _MockQuizScreenState();
      quizState._allQuestions = testQuestions;

      // Use all questions
      for (int i = 0; i < 5; i++) {
        quizState._getNextQuestion(0.0);
      }

      // After using all questions, the next call should reset the pool
      final questionAfterReset = quizState._getNextQuestion(0.0);
      
      // Verify that we can get a question after reset (pool was cleared)
      expect(questionAfterReset.question, isA<String>());
      expect(testQuestions.map((q) => q.question).contains(questionAfterReset.question), true);
      
      // Verify that the used questions set was cleared during the reset
      expect(quizState._usedQuestions.length, 1); // Only the last question is marked as used
    });
  });
}

// Mock class to test the question selection logic
class _MockQuizScreenState {
  final Set<String> _usedQuestions = {};
  List<QuizQuestion> _allQuestions = [];

  QuizQuestion _getNextQuestion(double currentDifficulty) {
    // Get available questions (not used yet)
    final availableQuestions = _allQuestions.where((q) => !_usedQuestions.contains(q.question)).toList();
    
    // If all questions have been used, reset the used questions set
    if (availableQuestions.isEmpty) {
      _usedQuestions.clear();
      return _getNextQuestion(currentDifficulty); // Recursive call with fresh pool
    }
    
    // Select a random question from available ones
    final random = Random();
    final selectedQuestion = availableQuestions[random.nextInt(availableQuestions.length)];
    
    // Mark the selected question as used
    _usedQuestions.add(selectedQuestion.question);
    
    return selectedQuestion;
  }
} 