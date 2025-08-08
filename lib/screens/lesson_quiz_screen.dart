import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lesson.dart';
import '../models/quiz_question.dart';
import '../providers/lesson_progress_provider.dart';
import '../providers/settings_provider.dart';
import '../services/logger.dart';
import '../services/question_cache_service.dart';
import '../widgets/question_card.dart';
import 'lesson_complete_screen.dart';

class LessonQuizScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonQuizScreen({super.key, required this.lesson});

  @override
  State<LessonQuizScreen> createState() => _LessonQuizScreenState();
}

class _LessonQuizScreenState extends State<LessonQuizScreen> {
  final QuestionCacheService _questionCacheService = QuestionCacheService();

  bool _loading = true;
  String? _error;

  List<QuizQuestion> _questions = const [];
  int _currentIndex = 0;

  // Per-question UI state
  int? _selectedAnswerIndex;
  bool _isAnswering = false;
  bool _isTransitioning = false;

  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
        _currentIndex = 0;
        _correctCount = 0;
        _selectedAnswerIndex = null;
        _isAnswering = false;
        _isTransitioning = false;
      });

      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final language = settings.language;

      // Pull all questions for the lesson category (or as many as available)
      final allQuestions = await _questionCacheService.getQuestions(
        language,
      );
      if (allQuestions.isEmpty) {
        throw Exception('Geen vragen beschikbaar');
      }
      // Shuffle and take up to maxQuestions
      final rng = Random();
      final shuffled = List<QuizQuestion>.from(allQuestions)..shuffle(rng);
      final capped = shuffled.take(widget.lesson.maxQuestions).toList();

      setState(() {
        _questions = capped;
      });
    } catch (e) {
      AppLogger.error('Failed to load lesson questions', e);
      if (!mounted) return;
      setState(() {
        _error = 'Kon lesvragen niet laden';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _onAnswer(int index) async {
    if (_isAnswering || _isTransitioning) return;

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswering = true;
    });

    final question = _questions[_currentIndex];
    final options = question.allOptions;
    int correctIndex;
if (question.type == QuestionType.tf) {
  // Map fixed TF UI options: index 0 => 'true', index 1 => 'false'
  correctIndex = (question.correctAnswer.toLowerCase() == 'goed') ? 0 : 1;
} else {
  correctIndex = options.indexOf(question.correctAnswer);
}

    final isCorrect = index == correctIndex;
    if (isCorrect) _correctCount++;

    // brief feedback pause
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // Transition
    setState(() {
      _isTransitioning = true;
    });
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    if (_currentIndex + 1 >= _questions.length) {
      // Completed lesson
      await _completeLesson();
      return;
    }

    // Next question
    setState(() {
      _currentIndex++;
      _selectedAnswerIndex = null;
      _isAnswering = false;
      _isTransitioning = false;
    });
  }

  Future<void> _completeLesson() async {
    // Persist stars
    final progress = Provider.of<LessonProgressProvider>(context, listen: false);
    await progress.markCompleted(
      lesson: widget.lesson,
      correct: _correctCount,
      total: _questions.length,
    );

    if (!mounted) return;

    final stars = _computeStars(_correctCount, _questions.length);
    final quizContext = context;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => LessonCompleteScreen(
          lesson: widget.lesson,
          stars: stars,
          correct: _correctCount,
          total: _questions.length,
          bestStreak: 0, // Not tracked in this screen
          onRetry: () {
            // Pop completion screen, restart lesson
            Navigator.of(ctx).pop();
            _loadQuestions();
          },
          onExit: () {
            // Pop completion screen and then go back to lesson select
            Navigator.of(ctx).pop();
            Navigator.of(quizContext).pop();
          },
        ),
      ),
    );
  }

  int _computeStars(int correct, int total) {
    if (total <= 0) return 0;
    final pct = correct / total;
    if (pct >= 0.9) return 3;
    if (pct >= 0.7) return 2;
    if (pct >= 0.5) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: (!_loading && _questions.isNotEmpty)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(20),
                child: _LessonLinearProgress(
                  current: _currentIndex + (_selectedAnswerIndex != null ? 1 : 0),
                  total: _questions.length,
                ),
              )
            : null,
        actions: [
          if (!_loading && _questions.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: _ProgressBadge(
                  current: _currentIndex + 1,
                  total: _questions.length,
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const _LessonQuizSkeleton()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: TextStyle(color: colorScheme.error)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadQuestions,
                        child: const Text('Opnieuw proberen'),
                      ),
                    ],
                  ),
                )
              : _questions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Geen vragen gevonden voor deze les'),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Terug'),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // Stars preview (based on current progress)
                          _StarsPreview(
                            correct: _correctCount,
                            totalAnswered: _currentIndex + (_selectedAnswerIndex != null ? 1 : 0),
                            total: _questions.length,
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Center(
                              child: QuestionCard(
                                question: _questions[_currentIndex],
                                selectedAnswerIndex: _selectedAnswerIndex,
                                isAnswering: _isAnswering,
                                isTransitioning: _isTransitioning,
                                onAnswerSelected: _onAnswer,
                                language: settings.language,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressBadge({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text('$current / $total', style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _LessonLinearProgress extends StatelessWidget {
  final int current;
  final int total;

  const _LessonLinearProgress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final value = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: value,
          minHeight: 8,
          backgroundColor: cs.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
        ),
      ),
    );
  }
}

class _StarsPreview extends StatelessWidget {
  final int correct;
  final int totalAnswered;
  final int total;

  const _StarsPreview({
    required this.correct,
    required this.totalAnswered,
    required this.total,
  });

  int _computePreviewStars() {
    if (total == 0 || totalAnswered == 0) return 0;
    final pct = correct / total; // optimistic preview based on final denominator
    if (pct >= 0.9) return 3;
    if (pct >= 0.7) return 2;
    if (pct >= 0.5) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stars = _computePreviewStars();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Padding(
          padding: EdgeInsets.only(right: i == 2 ? 0 : 6),
          child: Icon(
            Icons.star_rounded,
            size: 22,
            color: filled ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        );
      }),
    );
  }
}

class _LessonQuizSkeleton extends StatelessWidget {
  const _LessonQuizSkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            height: 18,
            width: 120,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}