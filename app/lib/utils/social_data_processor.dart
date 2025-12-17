import '../services/logger.dart';

/// Utility class to process social data and handle complex data operations
class SocialDataProcessor {
  /// Gets followed users and their scores
  static Future<List<Map<String, dynamic>>> getFollowedUsersScores(
    dynamic syncService,
    Map<String, Map<String, dynamic>>? cachedUserScores,
  ) async {
    try {
      final followingList = await syncService.getFollowingList();
      if (followingList == null || followingList.isEmpty) {
        return [];
      }

      // Use cached scores if available, otherwise fetch fresh data
      Map<String, Map<String, dynamic>> userScores;
      if (cachedUserScores != null) {
        userScores = cachedUserScores;
      } else {
        userScores = <String, Map<String, dynamic>>{};
      }

      final usersWithScores = <Map<String, dynamic>>[];

      for (final userId in followingList) {
        // Get user profile
        Map<String, dynamic>? userProfile;
        try {
          userProfile = await syncService.getUserProfile(userId);
        } catch (e) {
          AppLogger.error('Error getting user profile for $userId', e);
          userProfile = null;
        }

        if (userProfile == null) {
          continue; // Skip users without profiles
        }

        final username = userProfile['username'] as String?;
        final displayName = userProfile['display_name'] as String? ?? username;

        if (username == null) {
          continue; // Skip users without usernames
        }

        // Check if we have cached data for this user
        Map<String, dynamic>? stats;
        if (userScores.containsKey(userId)) {
          stats = userScores[userId];
        } else {
          // Fetch fresh stats from the database
          try {
            stats = await syncService.getGameStatsForUser(userId);
            // Cache the result
            userScores[userId] = stats ?? <String, dynamic>{};
          } catch (e) {
            AppLogger.error(
                'Error fetching game stats for user $userId', e);
            // Use empty stats on error
            stats = <String, dynamic>{};
          }
        }

        // Extract score and stars from fetched stats
        final score = stats?['score'] ?? 0;

        usersWithScores.add({
          'username': username,
          'displayName': displayName,
          'userId': userId,
          'score': score,
          'stars': score, // Stars are represented by the score field
        });
      }

      return usersWithScores;
    } catch (e) {
      AppLogger.error('Error getting followed users scores', e);
      return [];
    }
  }

  /// Gets top users for leaderboard
  static Future<List<Map<String, dynamic>>> getTopUsersForLeaderboard(
    dynamic syncService,
  ) async {
    try {
      return await syncService.getTopUsersForLeaderboard();
    } catch (e) {
      AppLogger.error('Error getting top users for leaderboard', e);
      return [];
    }
  }
}