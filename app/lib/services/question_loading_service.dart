import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/question_cache_service.dart';
import '../services/logger.dart';
import 'dart:math';

/// Shared service for loading questions in background
class QuestionLoadingService {
  final QuestionCacheService _questionCacheService;

  QuestionLoadingService(this._questionCacheService);

  /// Load more questions in background (simple version for quiz screen)
  Future<void> loadMoreQuestionsInBackground({
    required BuildContext context,
    required bool lessonMode,
    required List questions,
    required void Function(void Function()) setState,
  }) async {
    if (lessonMode) return; // Don't load more in lesson mode

    try {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final language = settings.effectiveLanguage;

      // Load next batch of questions
      final nextBatchStartIndex = questions.length;
      const int batchSize = 50; // Load 50 more questions

      final newQuestions = await _questionCacheService.getQuestions(
        language,
        startIndex: nextBatchStartIndex,
        count: batchSize
      );

      if (newQuestions.isNotEmpty) {
        setState(() {
          // Add new questions and shuffle the combined list
          questions.addAll(newQuestions);
          questions.shuffle(Random());
          AppLogger.info('Loaded additional questions, total now: ${questions.length}');
        });
      }
    } catch (e) {
      AppLogger.error('Failed to load more questions in background', e);
    }
  }

  /// Enhanced background loading with predictive loading and adaptive batching
  Future<void> loadMoreQuestionsAdvanced({
    required BuildContext context,
    required List questions,
    required void Function(void Function()) setState,
    required bool mounted,
  }) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final language = settings.language;

    try {
      // First, load predictive candidates if available
      final predictiveCandidates = _questionCacheService.getPredictiveLoadCandidates();
      if (predictiveCandidates.isNotEmpty) {
        await _loadPredictiveCandidates(language, questions, setState, predictiveCandidates);
      }

      // Then load next sequential batch
      final nextBatchStartIndex = questions.length;
      final adaptiveBatchSize = _calculateAdaptiveBatchSize();

      final newQuestions = await _questionCacheService.getQuestions(
        language,
        startIndex: nextBatchStartIndex,
        count: adaptiveBatchSize
      );

      if (newQuestions.isNotEmpty) {
        setState(() {
          // Add new questions and shuffle the combined list
          questions.addAll(newQuestions);
          questions.shuffle(Random());
          AppLogger.info('Loaded additional questions, total now: ${questions.length}');
        });
      }

      // Continue loading in background if we still have room
      if (questions.length < 200 && mounted) { // Keep at least 200 questions loaded
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            // Skip recursive call to avoid context issues across async gaps
            // The loading service should be called from the widget when needed
          }
        });
      }
    } catch (e) {
      AppLogger.error('Failed to load more questions in background', e);
    }
  }

  /// Load predictive candidates identified by the cache service
  Future<void> _loadPredictiveCandidates(
    String language,
    List questions,
    void Function(void Function()) setState,
    List<String> candidates
  ) async {
    try {
      final indicesToLoad = <int>[];

      for (final candidate in candidates) {
        // Parse cache key to get language and index
        final parts = candidate.split('_');
        if (parts.length == 2 && parts[0] == language) {
          final index = int.tryParse(parts[1]);
          if (index != null && !_isQuestionLoaded(questions, index)) {
            indicesToLoad.add(index);
          }
        }
      }

      if (indicesToLoad.isNotEmpty) {
        final predictiveQuestions = await _questionCacheService.loadQuestionsByIndices(language, indicesToLoad);
        if (predictiveQuestions.isNotEmpty) {
          setState(() {
            questions.addAll(predictiveQuestions);
            AppLogger.info('Loaded ${predictiveQuestions.length} predictive questions');
          });
        }
      }
    } catch (e) {
      AppLogger.error('Failed to load predictive candidates', e);
    }
  }

  /// Calculate adaptive batch size based on current performance and memory usage
  int _calculateAdaptiveBatchSize() {
    const baseBatchSize = 30;

    // Get memory usage info
    final memoryInfo = _questionCacheService.getMemoryUsage();
    final cacheUtilization = double.tryParse(memoryInfo['memoryCache']['cacheUtilizationPercent'] as String) ?? 0.0;

    // Reduce batch size if memory usage is high
    if (cacheUtilization > 80.0) {
      return (baseBatchSize * 0.5).round(); // 50% reduction
    } else if (cacheUtilization > 60.0) {
      return (baseBatchSize * 0.75).round(); // 25% reduction
    }

    // Increase batch size if memory usage is low
    if (cacheUtilization < 30.0) {
      return (baseBatchSize * 1.5).round(); // 50% increase
    }

    return baseBatchSize;
  }

  /// Check if a question index is already loaded
  bool _isQuestionLoaded(List questions, int index) {
    // This is a simplified check - in practice we'd need to track loaded indices
    // For now, we'll use a basic heuristic
    return questions.length > index;
  }
}