import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/follow.dart';
import '../models/user.dart';
import '../services/logger.dart';

/// Service for social features like following, followers, and feeds
class SocialService {
  static final SocialService _instance = SocialService._internal();
  factory SocialService() => _instance;
  SocialService._internal();

  static const String _baseUrl = 'https://api.bijbelquiz.app';
  late final Dio _dio;

  /// Initialize the social service
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
            AppLogger.warning('Social service failed: Unauthorized');
          }
          handler.next(error);
        },
      ));

      AppLogger.info('SocialService initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize SocialService', e);
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

  /// Follow a user
  Future<bool> followUser(String username) async {
    try {
      final response = await _dio.post('/api/social/follow', data: {
        'username': username,
      });

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      AppLogger.error('Failed to follow user', e);
      return false;
    }
  }

  /// Unfollow a user
  Future<bool> unfollowUser(String username) async {
    try {
      final response = await _dio.delete('/api/social/follow/$username');
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Failed to unfollow user', e);
      return false;
    }
  }

  /// Check if following a user
  Future<bool> isFollowingUser(String username) async {
    try {
      final response = await _dio.get('/api/social/following/$username');
      if (response.statusCode == 200) {
        return response.data['isFollowing'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      AppLogger.error('Failed to check follow status', e);
      return false;
    }
  }

  /// Get following list
  Future<List<UserWithFollow>?> getFollowing({int limit = 50, int offset = 0}) async {
    try {
      final response = await _dio.get('/api/social/following', queryParameters: {
        'limit': limit,
        'offset': offset,
      });

      if (response.statusCode == 200) {
        final List<dynamic> followingData = response.data['following'];
        return followingData.map((item) => UserWithFollow.fromJson(item)).toList();
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get following list', e);
      return null;
    }
  }

  /// Get followers list
  Future<List<UserWithFollow>?> getFollowers({int limit = 50, int offset = 0}) async {
    try {
      final response = await _dio.get('/api/social/followers', queryParameters: {
        'limit': limit,
        'offset': offset,
      });

      if (response.statusCode == 200) {
        final List<dynamic> followersData = response.data['followers'];
        return followersData.map((item) => UserWithFollow.fromJson(item)).toList();
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get followers list', e);
      return null;
    }
  }

  /// Get activity feed
  Future<List<FeedItem>?> getFeed({int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get('/api/social/feed', queryParameters: {
        'limit': limit,
        'offset': offset,
      });

      if (response.statusCode == 200) {
        final List<dynamic> feedData = response.data['feed'];
        return feedData.map((item) => FeedItem.fromJson(item)).toList();
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get activity feed', e);
      return null;
    }
  }

  /// Search users
  Future<List<User>?> searchUsers(String query, {int limit = 10}) async {
    try {
      final response = await _dio.get('/api/users/search', queryParameters: {
        'q': query,
        'limit': limit,
      });

      if (response.statusCode == 200) {
        final List<dynamic> usersData = response.data['users'];
        return usersData.map((user) => User.fromJson(user)).toList();
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to search users', e);
      return null;
    }
  }

  /// Get user profile by username
  Future<User?> getUserProfile(String username) async {
    try {
      final response = await _dio.get('/api/users/profile/$username');
      if (response.statusCode == 200) {
        return User.fromJson(response.data['user']);
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get user profile', e);
      return null;
    }
  }

  /// Get user social stats
  Future<SocialStats?> getUserSocialStats(String username) async {
    try {
      final response = await _dio.get('/api/social/stats/$username');
      if (response.statusCode == 200) {
        return SocialStats.fromJson(response.data['socialStats']);
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get user social stats', e);
      return null;
    }
  }

  /// Get user profile with stats
  Future<UserProfileWithStats?> getUserProfileWithStats(String username) async {
    try {
      final response = await _dio.get('/api/social/stats/$username');
      if (response.statusCode == 200) {
        return UserProfileWithStats.fromJson(response.data);
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get user profile with stats', e);
      return null;
    }
  }
}

/// Represents a user profile with social and game stats
class UserProfileWithStats {
  final User user;
  final SocialStats socialStats;
  final UserStats gameStats;

  const UserProfileWithStats({
    required this.user,
    required this.socialStats,
    required this.gameStats,
  });

  factory UserProfileWithStats.fromJson(Map<String, dynamic> json) {
    return UserProfileWithStats(
      user: User.fromJson(json['user']),
      socialStats: SocialStats.fromJson(json['socialStats']),
      gameStats: UserStats.fromJson(json['gameStats']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'socialStats': socialStats.toJson(),
      'gameStats': gameStats.toJson(),
    };
  }
}