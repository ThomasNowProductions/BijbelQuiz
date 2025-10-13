import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/user_stats.dart';
import '../services/logger.dart';

/// Service for synchronizing game statistics with the server
class StatsSyncService {
  static final StatsSyncService _instance = StatsSyncService._internal();
  factory StatsSyncService() => _instance;
  StatsSyncService._internal();

  static const String _baseUrl = 'https://api.bijbelquiz.app';
  late final Dio _dio;

  /// Initialize the stats sync service
  Future<void> initialize(String? accessToken) async {
    try {
      _dio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      ));

      // Add request interceptor to include auth token
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            AppLogger.warning('Stats sync failed: Unauthorized');
          }
          handler.next(error);
        },
      ));

      AppLogger.info('StatsSyncService initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize StatsSyncService', e);
      rethrow;
    }
  }

  /// Update access token
  void updateAccessToken(String? accessToken) {
    if (accessToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  /// Get user stats from server
  Future<UserStats?> getUserStats() async {
    try {
      final response = await _dio.get('/api/stats/me');
      if (response.statusCode == 200) {
        return UserStats.fromJson(response.data['stats']);
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get user stats', e);
      return null;
    }
  }

  /// Update user stats on server
  Future<bool> updateUserStats(UserStats stats) async {
    try {
      final response = await _dio.put('/api/stats/me', data: {
        'score': stats.score,
        'currentStreak': stats.currentStreak,
        'longestStreak': stats.longestStreak,
        'incorrectAnswers': stats.incorrectAnswers,
        'totalQuestionsAnswered': stats.totalQuestionsAnswered,
        'totalCorrectAnswers': stats.totalCorrectAnswers,
        'totalTimeSpent': stats.totalTimeSpent,
        'level': stats.level,
        'experiencePoints': stats.experiencePoints,
      });

      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Failed to update user stats', e);
      return false;
    }
  }

  /// Sync local stats with server (server takes precedence for critical values)
  Future<UserStats?> syncStats(UserStats localStats) async {
    try {
      final response = await _dio.post('/api/stats/sync', data: {
        'localStats': localStats.toJson(),
      });

      if (response.statusCode == 200) {
        return UserStats.fromJson(response.data['stats']);
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to sync stats', e);
      return null;
    }
  }

  /// Get user stats by username
  Future<UserStats?> getUserStatsByUsername(String username) async {
    try {
      final response = await _dio.get('/api/stats/user/$username');
      if (response.statusCode == 200) {
        return UserStats.fromJson(response.data['stats']);
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get user stats by username', e);
      return null;
    }
  }

  /// Get leaderboard
  Future<List<LeaderboardEntry>?> getLeaderboard({
    String type = 'score',
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get('/api/stats/leaderboard', queryParameters: {
        'type': type,
        'limit': limit,
      });

      if (response.statusCode == 200) {
        final List<dynamic> leaderboardData = response.data['leaderboard'];
        return leaderboardData.map((entry) => LeaderboardEntry.fromJson(entry)).toList();
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get leaderboard', e);
      return null;
    }
  }

  /// Reset user stats
  Future<bool> resetStats() async {
    try {
      final response = await _dio.post('/api/stats/me/reset');
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Failed to reset stats', e);
      return false;
    }
  }

  /// Update activity timestamp
  Future<bool> updateActivity() async {
    try {
      final response = await _dio.post('/api/users/me/activity');
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Failed to update activity', e);
      return false;
    }
  }
}

/// Represents a leaderboard entry
class LeaderboardEntry {
  final int rank;
  final int value;
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;

  const LeaderboardEntry({
    required this.rank,
    required this.value,
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      value: json['value'] as int,
      userId: json['user']['id'] as String,
      username: json['user']['username'] as String,
      displayName: json['user']['displayName'] as String,
      avatarUrl: json['user']['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'value': value,
      'user': {
        'id': userId,
        'username': username,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
      },
    };
  }
}