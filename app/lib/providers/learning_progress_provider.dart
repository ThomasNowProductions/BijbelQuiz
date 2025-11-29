import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_module.dart';
import '../services/logger.dart';
import '../services/sync_service.dart';

/// Tracks progress through the beginner learning path.
/// Manages module completion, achievements earned, and learning streak.
class LearningProgressProvider extends ChangeNotifier {
  static const String _storageKey = 'learning_progress_v1';
  static const String _achievementsKey = 'learning_achievements_v1';

  SharedPreferences? _prefs;
  bool _isLoading = true;
  String? _error;

  /// Set of completed module IDs
  final Set<String> _completedModules = {};

  /// Map: moduleId -> quiz score (percentage 0-100)
  final Map<String, int> _moduleQuizScores = {};

  /// Set of earned achievement IDs
  final Set<String> _earnedAchievements = {};

  /// Current learning streak (consecutive days)
  int _learningStreak = 0;

  /// Last date user completed a learning module
  DateTime? _lastLearningDate;

  late SyncService syncService;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get learningStreak => _learningStreak;
  int get completedModuleCount => _completedModules.length;
  Set<String> get completedModules => Set.unmodifiable(_completedModules);
  Set<String> get earnedAchievements => Set.unmodifiable(_earnedAchievements);

  LearningProgressProvider() {
    syncService = SyncService();
    _initializeSyncService();
    _load();
  }

  Future<void> _initializeSyncService() async {
    await syncService.initialize();
    syncService.setCallbacks(
      onSyncError: (key, error) {
        if (key == 'learning_progress') {
          _error = 'Synchronisatie mislukt: $error';
          notifyListeners();
        }
      },
      onSyncSuccess: (key) {
        if (key == 'learning_progress') {
          AppLogger.debug('Learning progress sync successful');
        }
      },
    );

    // Listen for auth changes
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session?.user != null) {
        AppLogger.info(
            'User signed in (LearningProgressProvider), reloading data...');
        Future.delayed(const Duration(milliseconds: 500), () {
          _load();
          setupSyncListener();
        });
      }
    });
  }

  Future<void> _load() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _prefs = await SharedPreferences.getInstance();

      // Load completed modules and quiz scores
      final raw = _prefs?.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final Map data = json.decode(raw) as Map;
        _completedModules.clear();
        _completedModules.addAll(
            (data['completedModules'] as List<dynamic>?)?.cast<String>() ?? []);

        _moduleQuizScores.clear();
        final scores = data['moduleQuizScores'] as Map<String, dynamic>?;
        scores?.forEach((k, v) {
          _moduleQuizScores[k] = (v is int) ? v : int.tryParse(v.toString()) ?? 0;
        });

        _learningStreak = data['learningStreak'] ?? 0;
        final lastDateMs = data['lastLearningDate'];
        _lastLearningDate = lastDateMs != null
            ? DateTime.fromMillisecondsSinceEpoch(lastDateMs)
            : null;
      }

      // Load achievements
      final achievementsRaw = _prefs?.getString(_achievementsKey);
      if (achievementsRaw != null && achievementsRaw.isNotEmpty) {
        final List<dynamic> achievementsList = json.decode(achievementsRaw);
        _earnedAchievements.clear();
        _earnedAchievements.addAll(achievementsList.cast<String>());
      }

      // Check for synced data
      if (syncService.isAuthenticated) {
        AppLogger.info('User authenticated, fetching synced learning progress');
        final allData = await syncService.fetchAllData();

        if (allData != null && allData.containsKey('learning_progress')) {
          final syncedData = allData['learning_progress'];
          AppLogger.info('Found synced learning progress, merging');

          if (syncedData != null) {
            // Merge completed modules
            final syncedCompleted =
                (syncedData['completedModules'] as List<dynamic>?)
                        ?.cast<String>() ??
                    [];
            _completedModules.addAll(syncedCompleted);

            // Merge quiz scores (take higher)
            final syncedScores =
                syncedData['moduleQuizScores'] as Map<String, dynamic>?;
            syncedScores?.forEach((k, v) {
              final score = (v is int) ? v : int.tryParse(v.toString()) ?? 0;
              final currentScore = _moduleQuizScores[k] ?? 0;
              if (score > currentScore) {
                _moduleQuizScores[k] = score;
              }
            });

            // Take higher streak
            final syncedStreak = syncedData['learningStreak'] ?? 0;
            if (syncedStreak > _learningStreak) {
              _learningStreak = syncedStreak;
            }

            // Merge achievements
            final syncedAchievements =
                (syncedData['earnedAchievements'] as List<dynamic>?)
                        ?.cast<String>() ??
                    [];
            _earnedAchievements.addAll(syncedAchievements);

            await _persist();
            AppLogger.info(
                'Merged learning progress: ${_completedModules.length} modules completed');
          }
        }
      }
    } catch (e) {
      _error = 'Failed to load learning progress: $e';
      AppLogger.error(_error!, e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    try {
      final data = {
        'completedModules': _completedModules.toList(),
        'moduleQuizScores': _moduleQuizScores,
        'learningStreak': _learningStreak,
        'lastLearningDate': _lastLearningDate?.millisecondsSinceEpoch,
      };
      await _prefs?.setString(_storageKey, json.encode(data));
      await _prefs?.setString(
          _achievementsKey, json.encode(_earnedAchievements.toList()));
    } catch (e) {
      AppLogger.error('Failed to save learning progress', e);
    }
  }

  /// Checks if a module is completed
  bool isModuleCompleted(String moduleId) => _completedModules.contains(moduleId);

  /// Gets the quiz score for a module (0-100, or null if not attempted)
  int? getModuleQuizScore(String moduleId) => _moduleQuizScores[moduleId];

  /// Checks if an achievement is earned
  bool hasAchievement(String achievementId) =>
      _earnedAchievements.contains(achievementId);

  /// Marks a module as completed with optional quiz score
  Future<void> markModuleCompleted({
    required LearningModule module,
    int? quizScore,
  }) async {
    _completedModules.add(module.id);

    if (quizScore != null) {
      final currentScore = _moduleQuizScores[module.id] ?? 0;
      if (quizScore > currentScore) {
        _moduleQuizScores[module.id] = quizScore.clamp(0, 100);
      }
    }

    // Update streak
    _updateStreak();

    await _persist();
    notifyListeners();
  }

  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastLearningDate == null) {
      _learningStreak = 1;
    } else {
      final lastDate = DateTime(
          _lastLearningDate!.year, _lastLearningDate!.month, _lastLearningDate!.day);
      final difference = today.difference(lastDate).inDays;

      if (difference == 0) {
        // Same day, streak unchanged
      } else if (difference == 1) {
        // Consecutive day
        _learningStreak++;
      } else {
        // Streak broken
        _learningStreak = 1;
      }
    }

    _lastLearningDate = now;
  }

  /// Grants an achievement
  Future<void> grantAchievement(String achievementId) async {
    if (!_earnedAchievements.contains(achievementId)) {
      _earnedAchievements.add(achievementId);
      await _persist();
      notifyListeners();
    }
  }

  /// Resets all learning progress
  Future<void> resetAll() async {
    _completedModules.clear();
    _moduleQuizScores.clear();
    _earnedAchievements.clear();
    _learningStreak = 0;
    _lastLearningDate = null;
    await _persist();
    notifyListeners();
  }

  /// Gets all data for export/sync
  Map<String, dynamic> getExportData() {
    return {
      'completedModules': _completedModules.toList(),
      'moduleQuizScores': _moduleQuizScores,
      'earnedAchievements': _earnedAchievements.toList(),
      'learningStreak': _learningStreak,
      'lastLearningDate': _lastLearningDate?.millisecondsSinceEpoch,
    };
  }

  /// Loads data from import
  Future<void> loadImportData(Map<String, dynamic> data) async {
    _completedModules.clear();
    _completedModules.addAll(
        (data['completedModules'] as List<dynamic>?)?.cast<String>() ?? []);

    _moduleQuizScores.clear();
    final scores = data['moduleQuizScores'] as Map<String, dynamic>?;
    scores?.forEach((k, v) {
      _moduleQuizScores[k] = (v is int) ? v : int.tryParse(v.toString()) ?? 0;
    });

    _earnedAchievements.clear();
    _earnedAchievements.addAll(
        (data['earnedAchievements'] as List<dynamic>?)?.cast<String>() ?? []);

    _learningStreak = data['learningStreak'] ?? 0;
    final lastDateMs = data['lastLearningDate'];
    _lastLearningDate = lastDateMs != null
        ? DateTime.fromMillisecondsSinceEpoch(lastDateMs)
        : null;

    await _persist();
    notifyListeners();
    AppLogger.info(
        'Loaded synced learning progress: ${_completedModules.length} modules');
  }

  /// Sets up sync listener
  void setupSyncListener() {
    AppLogger.info('Setting up learning progress sync listener');
    syncService.addListener('learning_progress', (data) {
      AppLogger.info('Received synced learning progress update');
      loadImportData(data);
    });
  }

  /// Triggers immediate sync
  Future<void> triggerSync() async {
    if (!syncService.isAuthenticated) {
      AppLogger.debug('Skipping learning progress sync: user not authenticated');
      return;
    }

    if (!syncService.isConnected) {
      AppLogger.debug('Skipping learning progress sync: device is offline');
      return;
    }

    AppLogger.info('Triggering learning progress sync');
    await syncService.syncDataImmediate('learning_progress', getExportData());
  }

  @override
  void dispose() {
    syncService.removeListener('learning_progress');
    AppLogger.debug('LearningProgressProvider disposed');
    super.dispose();
  }
}
