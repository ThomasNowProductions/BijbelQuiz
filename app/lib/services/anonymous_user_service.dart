import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../utils/automatic_error_reporter.dart';

/// Service to manage anonymous user identification
/// Generates and stores a unique, persistent ID for anonymous users
class AnonymousUserService {
  static const String _anonymousUserIdKey = 'anonymous_user_id';
  static const String _anonymousUserIdPrefix = 'anonymous_user_';

  /// Gets a unique persistent ID for the current anonymous user.
  /// If no ID exists, generates a new one and stores it locally.
  Future<String> getAnonymousUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we already have an ID stored
      String? existingId = prefs.getString(_anonymousUserIdKey);

      if (existingId != null && existingId.isNotEmpty) {
        return existingId;
      }

      // Generate a new unique ID
      final newId = _generateUniqueId();

      // Store it for future use
      await prefs.setString(_anonymousUserIdKey, newId);

      return newId;
    } catch (e) {
      // Report error to automatic error tracking system
      await AutomaticErrorReporter.reportAuthenticationError(
        message: 'Failed to get or generate anonymous user ID: ${e.toString()}',
        operation: 'get_anonymous_user_id',
      );
      // Return a fallback ID if everything fails
      return 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Generates a unique anonymous user ID
  /// Format: anonymous_user_{timestamp}_{random_string}
  String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999).toString().padLeft(6, '0');

    return '$_anonymousUserIdPrefix${timestamp}_$random';
  }

  /// Checks if the current user is anonymous (has no authenticated user ID)
  /// This is a helper method that can be used to determine user type
  bool isAnonymousUser(String? userId) {
    return userId == null ||
        userId.isEmpty ||
        userId.startsWith(_anonymousUserIdPrefix);
  }

  /// Clears the anonymous user ID (useful for testing or reset scenarios)
  Future<void> clearAnonymousUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_anonymousUserIdKey);
    } catch (e) {
      // Report error to automatic error tracking system
      await AutomaticErrorReporter.reportAuthenticationError(
        message: 'Failed to clear anonymous user ID: ${e.toString()}',
        operation: 'clear_anonymous_user_id',
      );
      // Don't rethrow - clearing is not critical
    }
  }
}
