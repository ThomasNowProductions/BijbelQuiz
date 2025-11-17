import '../models/quiz_state.dart';
import '../models/quiz_question.dart';
import '../services/performance_service.dart';
import '../providers/settings_provider.dart';

/// Manages UI state for the quiz screen
class QuizUiStateManager {
  QuizState? _quizState;
  bool _isLoading = true;
  String? _error;

  // Getters
  QuizState? get quizState => _quizState;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Update loading state
  void setLoading(bool loading) {
    _isLoading = loading;
  }

  /// Set error state
  void setError(String? error) {
    _error = error;
    _isLoading = false;
  }

  /// Initialize quiz state with first question
  void initializeQuizState({
    required QuizQuestion firstQuestion,
    required Duration timerDuration,
  }) {
    _quizState = QuizState(
      question: firstQuestion,
      timeRemaining: timerDuration.inSeconds,
      currentDifficulty: 0.0,
    );
    _isLoading = false;
    _error = null;
  }

  /// Update quiz state
  void updateQuizState(QuizState newState) {
    _quizState = newState;
  }

  /// Handle answer selection
  void selectAnswer(int? answerIndex) {
    if (_quizState != null) {
      _quizState = _quizState!.copyWith(selectedAnswerIndex: answerIndex);
    }
  }

  /// Start answering animation
  void startAnswering() {
    if (_quizState != null) {
      _quizState = _quizState!.copyWith(isAnswering: true);
    }
  }

  /// Start transition to next question
  void startTransition() {
    if (_quizState != null) {
      _quizState = _quizState!.copyWith(
        selectedAnswerIndex: null,
        isTransitioning: true,
      );
    }
  }

  /// Transition to next question
  void transitionToNextQuestion({
    required QuizQuestion nextQuestion,
    required SettingsProvider settings,
    required PerformanceService performanceService,
  }) {
    final optimalTimerDuration = performanceService.getOptimalTimerDuration(
      Duration(seconds: settings.gameSpeedTimerDuration),
    );

    _quizState = QuizState(
      question: nextQuestion,
      timeRemaining: optimalTimerDuration.inSeconds,
      currentDifficulty: _quizState?.currentDifficulty ?? 0.0,
    );
  }

  /// Update time remaining
  void updateTimeRemaining(int timeRemaining) {
    if (_quizState != null) {
      _quizState = _quizState!.copyWith(timeRemaining: timeRemaining);
    }
  }

  /// Update current difficulty
  void updateDifficulty(double difficulty) {
    if (_quizState != null) {
      _quizState = _quizState!.copyWith(currentDifficulty: difficulty);
    }
  }

  /// Reset for new game
  void resetForNewGame() {
    _quizState = null;
    _isLoading = true;
    _error = null;
  }
}