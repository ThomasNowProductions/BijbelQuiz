import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';
import 'dart:async';
import '../providers/settings_provider.dart';
import 'logger.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// PostHog-based tracking service that replaces the in-house Supabase tracking solution
/// while maintaining the same interface for backward compatibility
class TrackingService {
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  static bool _isInitialized = false;

  /// Initializes the tracking service with PostHog
  ///
  /// This should be called once when the app starts.
  Future<void> init() async {
    if (_isInitialized) {
      AppLogger.info('PostHog tracking service already initialized');
      return;
    }

    AppLogger.info('Initializing PostHog tracking service...');
    final trackingInitStart = DateTime.now();

    try {
      // Ensure we have a persistent anonymous user ID
      AppLogger.info('Ensuring persistent user ID...');
      final userIdStart = DateTime.now();
      await _ensurePersistentUserId();
      final userIdDuration = DateTime.now().difference(userIdStart);
      AppLogger.info(
          'Persistent user ID ensured in ${userIdDuration.inMilliseconds}ms');

      // Load PostHog configuration from environment variables
      AppLogger.info('Loading PostHog configuration...');
      final configStart = DateTime.now();
      final apiKey = dotenv.env['POSTHOG_API_KEY'];
      final host = dotenv.env['POSTHOG_HOST'] ?? 'https://us.i.posthog.com';
      final configDuration = DateTime.now().difference(configStart);

      if (apiKey == null ||
          apiKey.isEmpty ||
          apiKey == 'YOUR_POSTHOG_API_KEY_HERE') {
        throw Exception(
            'PostHog API key not found in environment variables. Please check your .env file.');
      }

      AppLogger.info(
          'PostHog configuration loaded in ${configDuration.inMilliseconds}ms');

      // Configure PostHog
      AppLogger.info('Configuring PostHog...');
      final posthogConfigStart = DateTime.now();
      final config = PostHogConfig(apiKey);
      config.debug = kDebugMode; // Use debug mode in development
      config.captureApplicationLifecycleEvents = true;
      config.host = host;
      final posthogConfigDuration =
          DateTime.now().difference(posthogConfigStart);
      AppLogger.info(
          'PostHog configured in ${posthogConfigDuration.inMilliseconds}ms');

      // Setup PostHog
      AppLogger.info('Setting up PostHog...');
      final posthogSetupStart = DateTime.now();
      await Posthog().setup(config);
      final posthogSetupDuration = DateTime.now().difference(posthogSetupStart);
      AppLogger.info(
          'PostHog setup completed in ${posthogSetupDuration.inMilliseconds}ms');

      _isInitialized = true;
      final totalDuration = DateTime.now().difference(trackingInitStart);
      AppLogger.info(
          'PostHog tracking service initialized successfully in ${totalDuration.inMilliseconds}ms with API key: ${apiKey.substring(0, 8)}...');
    } catch (e) {
      AppLogger.error('Failed to initialize PostHog tracking service: $e', e);
      rethrow;
    }
  }

  /// Returns a [PosthogObserver] that can be used to automatically track screen views.
  /// This now returns the actual PostHog observer for automatic screen tracking.
  PosthogObserver getObserver() => PosthogObserver();

  /// Tracks a screen view event.
  ///
  /// This should be called when a screen is displayed.
  /// The [screenName] is the name of the screen.
  Future<void> screen(BuildContext context, String screenName) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // Skip tracking if analytics are disabled in settings
    if (!settings.analyticsEnabled) {
      AppLogger.info(
          'Analytics disabled in settings, skipping screen tracking for: $screenName');
      return;
    }

    if (!_isInitialized) {
      AppLogger.warning('PostHog not initialized, skipping screen tracking');
      return;
    }

    AppLogger.info('Tracking screen view with PostHog: $screenName');
    try {
      await Posthog().screen(
        screenName: screenName,
        properties: {
          'screen_name': screenName,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      AppLogger.info('Screen view tracked successfully: $screenName');
    } catch (e) {
      AppLogger.error('Failed to track screen view: $screenName', e);
    }
  }

  /// Tracks a custom event.
  ///
  /// The [eventName] is the name of the event.
  /// The [properties] are any additional data to send with the event.
  Future<void> capture(BuildContext context, String eventName,
      {Map<String, Object>? properties}) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // Skip tracking if analytics are disabled in settings
    if (!settings.analyticsEnabled) {
      AppLogger.info(
          'Analytics disabled in settings, skipping event tracking for: $eventName');
      return;
    }

    if (!_isInitialized) {
      AppLogger.warning('PostHog not initialized, skipping event tracking');
      return;
    }

    AppLogger.info(
        'Tracking event with PostHog: $eventName${properties != null ? ' with properties: $properties' : ''}');
    try {
      await Posthog().capture(
        eventName: eventName,
        properties: properties,
      );
      AppLogger.info('Event tracked successfully: $eventName');
    } catch (e) {
      AppLogger.error('Failed to track event: $eventName', e);
    }
  }

  /// Ensures we have a persistent anonymous user ID stored in shared preferences
  Future<void> _ensurePersistentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'tracking_anonymous_user_id';

    if (!prefs.containsKey(key)) {
      // Generate a new persistent ID and store it
      final newId =
          'anon_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(12)}';
      await prefs.setString(key, newId);
      AppLogger.info('Created new persistent anonymous user ID: $newId');
    }
  }

  /// Gets the persistent anonymous user ID
  Future<String> _getPersistentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'tracking_anonymous_user_id';

    // This should not be null since _ensurePersistentUserId is called during init
    String? storedId = prefs.getString(key);
    if (storedId == null) {
      // Fallback: generate a new ID if somehow none exists
      storedId = _generateAnonymousId();
      await prefs.setString(key, storedId);
    }
    return storedId;
  }

  /// Generate an anonymous user ID if needed (fallback method)
  String _generateAnonymousId() {
    return 'anon_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(12)}';
  }

  /// Generate a random string of specified length
  String _generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// ===== COMPREHENSIVE FEATURE USAGE TRACKING =====

  /// Standardized feature names for consistent tracking
  static const String featureQuizGameplay = 'quiz_gameplay';
  static const String featureLessonSystem = 'lesson_system';
  static const String featureQuestionCategories = 'question_categories';
  static const String featureBiblicalReferences = 'biblical_references';
  static const String featureSkipQuestion = 'skip_question';
  static const String featureRetryWithPoints = 'retry_with_points';
  static const String featureStreakTracking = 'streak_tracking';
  static const String featureProgressiveDifficulty = 'progressive_difficulty';
  static const String featurePowerUps = 'power_ups';
  static const String featureThemePurchases = 'theme_purchases';
  static const String featureAiThemeGenerator = 'ai_theme_generator';
  static const String featureSocialFeatures = 'social_features';
  static const String featurePromoCards = 'promo_cards';
  static const String featureSettings = 'settings';
  static const String featureThemeSelection = 'theme_selection';
  static const String featureAnalyticsSettings = 'analytics_settings';
  static const String featureLanguageSettings = 'language_settings';
  static const String featureOnboarding = 'onboarding';
  static const String featureDonationSystem = 'donation_system';
  static const String featureSatisfactionSurveys = 'satisfaction_surveys';
  static const String featureDifficultyFeedback = 'difficulty_feedback';
  static const String featureMultiplayerGame = 'multiplayer_game';

  /// Standardized action names for consistent tracking
  static const String actionAccessed = 'accessed';
  static const String actionUsed = 'used';
  static const String actionPurchased = 'purchased';
  static const String actionUnlocked = 'unlocked';
  static const String actionAttempted = 'attempted';
  static const String actionCompleted = 'completed';
  static const String actionDismissed = 'dismissed';
  static const String actionEnabled = 'enabled';
  static const String actionDisabled = 'disabled';
  static const String actionChanged = 'changed';
  static const String actionStarted = 'started';
  static const String actionFinished = 'finished';

  /// Enhanced feature usage tracking with standardized features and actions
  /// This is the primary method for tracking which features users interact with
  Future<void> trackFeatureUsage(
      BuildContext context, String feature, String action,
      {Map<String, Object>? additionalProperties}) async {
    final properties = Map<String, Object>.from(additionalProperties ?? {});
    properties.addAll({
      'feature': feature,
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await capture(context, 'feature_usage', properties: properties);
  }

  /// Track when a user starts using a feature (for engagement metrics)
  Future<void> trackFeatureStart(BuildContext context, String feature,
      {Map<String, Object>? additionalProperties}) async {
    await trackFeatureUsage(context, feature, actionStarted,
        additionalProperties: additionalProperties);
  }

  /// Track when a user successfully uses a feature
  Future<void> trackFeatureSuccess(BuildContext context, String feature,
      {Map<String, Object>? additionalProperties}) async {
    await trackFeatureUsage(context, feature, actionUsed,
        additionalProperties: additionalProperties);
  }

  /// Track when a user attempts but fails to use a feature
  Future<void> trackFeatureAttempt(BuildContext context, String feature,
      {Map<String, Object>? additionalProperties}) async {
    await trackFeatureUsage(context, feature, actionAttempted,
        additionalProperties: additionalProperties);
  }

  /// Track when a user purchases/unlocks a feature
  Future<void> trackFeaturePurchase(BuildContext context, String feature,
      {Map<String, Object>? additionalProperties}) async {
    await trackFeatureUsage(context, feature, actionPurchased,
        additionalProperties: additionalProperties);
  }

  /// Track when a user completes a feature or flow
  Future<void> trackFeatureCompletion(BuildContext context, String feature,
      {Map<String, Object>? additionalProperties}) async {
    await trackFeatureUsage(context, feature, actionCompleted,
        additionalProperties: additionalProperties);
  }

  /// Track when a user dismisses or cancels a feature
  Future<void> trackFeatureDismissal(BuildContext context, String feature,
      {Map<String, Object>? additionalProperties}) async {
    await trackFeatureUsage(context, feature, actionDismissed,
        additionalProperties: additionalProperties);
  }

  /// Specific app usage events - these are the primary tracked events
  /// All events contain no PII, only anonymous usage patterns

  /// Track when user starts a quiz (without question details)
  Future<void> trackQuizStart(BuildContext context,
      {String? category, int? difficulty}) async {
    final properties = <String, Object>{};
    if (category != null) properties['category'] = category;
    if (difficulty != null) properties['difficulty'] = difficulty;

    await trackFeatureUsage(context, featureQuizGameplay, actionStarted,
        additionalProperties: properties);
  }

  /// Track when user completes a quiz
  Future<void> trackQuizComplete(BuildContext context,
      {int? score, int? maxScore, int? questionsAnswered}) async {
    final properties = <String, Object>{};
    if (score != null) properties['score'] = score;
    if (maxScore != null) properties['max_score'] = maxScore;
    if (questionsAnswered != null) {
      properties['questions_answered'] = questionsAnswered;
    }

    await trackFeatureUsage(context, featureQuizGameplay, actionCompleted,
        additionalProperties: properties);
  }

  /// Track when user purchases/unlocks a theme
  Future<void> trackThemePurchase(
      BuildContext context, String themeName) async {
    await trackFeatureUsage(context, featureThemePurchases, actionPurchased,
        additionalProperties: {'theme_name': themeName});
  }

  /// Track when user changes theme
  Future<void> trackThemeChange(BuildContext context, String themeName) async {
    await trackFeatureUsage(context, featureThemeSelection, actionChanged,
        additionalProperties: {'theme_name': themeName});
  }

  /// Track when user starts a lesson
  Future<void> trackLessonStart(BuildContext context, String lessonId) async {
    await trackFeatureUsage(context, featureLessonSystem, actionStarted,
        additionalProperties: {'lesson_id': lessonId});
  }

  /// Track when user completes a lesson
  Future<void> trackLessonComplete(
      BuildContext context, String lessonId) async {
    await trackFeatureUsage(context, featureLessonSystem, actionCompleted,
        additionalProperties: {'lesson_id': lessonId});
  }

  /// Track when user uses skip feature
  Future<void> trackSkipUsed(BuildContext context) async {
    await trackFeatureUsage(context, featureSkipQuestion, actionUsed);
  }

  /// Track when user uses retry feature
  Future<void> trackRetryUsed(BuildContext context) async {
    await trackFeatureUsage(context, featureRetryWithPoints, actionUsed);
  }

  /// Track when user enables/disables analytics
  Future<void> trackAnalyticsToggle(BuildContext context, bool enabled) async {
    await trackFeatureUsage(context, featureAnalyticsSettings,
        enabled ? actionEnabled : actionDisabled);
  }

  /// Track when user changes language
  Future<void> trackLanguageChange(
      BuildContext context, String languageCode) async {
    await trackFeatureUsage(context, featureLanguageSettings, actionChanged,
        additionalProperties: {'language_code': languageCode});
  }

  /// Track when user accesses settings
  Future<void> trackSettingsAccess(BuildContext context) async {
    await trackFeatureUsage(context, featureSettings, actionAccessed);
  }

  /// Track when user starts onboarding
  Future<void> trackOnboardingStart(BuildContext context) async {
    await trackFeatureUsage(context, featureOnboarding, actionStarted);
  }

  /// Track when user completes onboarding
  Future<void> trackOnboardingComplete(BuildContext context) async {
    await trackFeatureUsage(context, featureOnboarding, actionCompleted);
  }

  /// Track when user makes a donation
  Future<void> trackDonationInitiated(BuildContext context) async {
    await trackFeatureUsage(context, featureDonationSystem, actionStarted);
  }

  /// Track when user completes a donation
  Future<void> trackDonationCompleted(BuildContext context) async {
    await trackFeatureUsage(context, featureDonationSystem, actionCompleted);
  }

  /// Track when user accesses satisfaction survey
  Future<void> trackSatisfactionSurveyAccess(BuildContext context) async {
    await trackFeatureUsage(
        context, featureSatisfactionSurveys, actionAccessed);
  }

  /// Track when user submits satisfaction survey
  Future<void> trackSatisfactionSurveySubmit(
      BuildContext context, int rating) async {
    await trackFeatureUsage(
        context, featureSatisfactionSurveys, actionCompleted,
        additionalProperties: {'rating': rating});
  }

  /// Track when user provides difficulty feedback
  Future<void> trackDifficultyFeedback(
      BuildContext context, String feedbackType,
      {int? difficultyRating}) async {
    final properties = <String, Object>{'feedback_type': feedbackType};
    if (difficultyRating != null) {
      properties['difficulty_rating'] = difficultyRating;
    }

    await trackFeatureUsage(context, featureDifficultyFeedback, actionUsed,
        additionalProperties: properties);
  }

  /// Track when user starts multiplayer game
  Future<void> trackMultiplayerGameStart(BuildContext context) async {
    await trackFeatureUsage(context, featureMultiplayerGame, actionStarted);
  }

  /// Track when user completes multiplayer game
  Future<void> trackMultiplayerGameComplete(BuildContext context,
      {int? placement, int? score}) async {
    final properties = <String, Object>{};
    if (placement != null) properties['placement'] = placement;
    if (score != null) properties['score'] = score;

    await trackFeatureUsage(context, featureMultiplayerGame, actionCompleted,
        additionalProperties: properties);
  }

  /// Track when user uses power-up
  Future<void> trackPowerUpUsed(
      BuildContext context, String powerUpType) async {
    await trackFeatureUsage(context, featurePowerUps, actionUsed,
        additionalProperties: {'power_up_type': powerUpType});
  }

  /// Track when user views promo cards
  Future<void> trackPromoCardViewed(
      BuildContext context, String cardType) async {
    await trackFeatureUsage(context, featurePromoCards, actionAccessed,
        additionalProperties: {'card_type': cardType});
  }

  /// Track when user starts using AI theme generator
  Future<void> trackAiThemeGeneratorStart(BuildContext context) async {
    await trackFeatureUsage(context, featureAiThemeGenerator, actionStarted);
  }

  /// Track when user completes using AI theme generator
  Future<void> trackAiThemeGeneratorComplete(BuildContext context,
      {bool success = true}) async {
    await trackFeatureUsage(context, featureAiThemeGenerator,
        success ? actionCompleted : actionAttempted,
        additionalProperties: {'success': success});
  }

  /// Track social feature usage
  Future<void> trackSocialFeatureUsed(
      BuildContext context, String socialAction) async {
    await trackFeatureUsage(context, featureSocialFeatures, actionUsed,
        additionalProperties: {'social_action': socialAction});
  }

  /// Track when user views question categories
  Future<void> trackCategoryView(BuildContext context, String category) async {
    await trackFeatureUsage(context, featureQuestionCategories, actionAccessed,
        additionalProperties: {'category': category});
  }

  /// Track when user views biblical references
  Future<void> trackBiblicalReferenceView(BuildContext context, String book,
      {int? chapter}) async {
    final properties = <String, Object>{'book': book};
    if (chapter != null) properties['chapter'] = chapter;

    await trackFeatureUsage(context, featureBiblicalReferences, actionAccessed,
        additionalProperties: properties);
  }

  /// Track when user uses progressive difficulty feature
  Future<void> trackProgressiveDifficultyUsed(
      BuildContext context, int level) async {
    await trackFeatureUsage(context, featureProgressiveDifficulty, actionUsed,
        additionalProperties: {'level': level});
  }

  /// Track when user engages with streak tracking
  Future<void> trackStreakFeatureUsed(BuildContext context) async {
    await trackFeatureUsage(context, featureStreakTracking, actionUsed);
  }

  /// ===== POSTHOG-SPECIFIC METHODS =====

  /// Disable analytics data collection
  Future<void> disableAnalytics() async {
    if (!_isInitialized) {
      AppLogger.warning('PostHog not initialized, cannot disable analytics');
      return;
    }

    try {
      await Posthog().disable();
      AppLogger.info('PostHog analytics disabled');
    } catch (e) {
      AppLogger.error('Failed to disable PostHog analytics', e);
    }
  }

  /// Enable analytics data collection
  Future<void> enableAnalytics() async {
    if (!_isInitialized) {
      AppLogger.warning('PostHog not initialized, cannot enable analytics');
      return;
    }

    try {
      await Posthog().enable();
      AppLogger.info('PostHog analytics enabled');
    } catch (e) {
      AppLogger.error('Failed to enable PostHog analytics', e);
    }
  }

  /// Get the current user's distinct ID
  Future<String> getDistinctId() async {
    try {
      return await Posthog().getDistinctId();
    } catch (e) {
      AppLogger.error('Failed to get distinct ID: $e', e);
      return await _getPersistentUserId();
    }
  }

  /// Identify a user with PostHog
  Future<void> identifyUser(BuildContext context, String userId,
      {Map<String, Object>? userProperties}) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    if (!settings.analyticsEnabled) {
      AppLogger.info(
          'Analytics disabled in settings, skipping user identification');
      return;
    }

    if (!_isInitialized) {
      AppLogger.warning(
          'PostHog not initialized, skipping user identification');
      return;
    }

    AppLogger.info('Identifying user with PostHog: $userId');
    try {
      await Posthog().identify(
        userId: userId,
        userProperties: userProperties,
      );
      AppLogger.info('User identified successfully: $userId');
    } catch (e) {
      AppLogger.error('Failed to identify user: $userId', e);
    }
  }

  /// Register super properties with PostHog
  Future<void> registerSuperProperty(String key, Object value) async {
    if (!_isInitialized) {
      AppLogger.warning(
          'PostHog not initialized, skipping super property registration');
      return;
    }

    try {
      await Posthog().register(key, value);
      AppLogger.info('Super property registered: $key = $value');
    } catch (e) {
      AppLogger.error('Failed to register super property: $key', e);
    }
  }

  /// Unregister super properties with PostHog
  Future<void> unregisterSuperProperty(String key) async {
    if (!_isInitialized) {
      AppLogger.warning(
          'PostHog not initialized, skipping super property unregistration');
      return;
    }

    try {
      await Posthog().unregister(key);
      AppLogger.info('Super property unregistered: $key');
    } catch (e) {
      AppLogger.error('Failed to unregister super property: $key', e);
    }
  }

  /// Reset PostHog data (useful for logout)
  Future<void> reset() async {
    if (!_isInitialized) {
      AppLogger.warning('PostHog not initialized, cannot reset');
      return;
    }

    try {
      await Posthog().reset();
      AppLogger.info('PostHog data reset successfully');
    } catch (e) {
      AppLogger.error('Failed to reset PostHog data', e);
    }
  }

  /// Check if a feature flag is enabled
  Future<bool> isFeatureEnabled(String flagKey) async {
    if (!_isInitialized) {
      AppLogger.warning('PostHog not initialized, cannot check feature flag');
      return false;
    }

    try {
      return await Posthog().isFeatureEnabled(flagKey);
    } catch (e) {
      AppLogger.error('Failed to check feature flag: $flagKey', e);
      return false;
    }
  }

  /// Get feature flag value
  Future<String?> getFeatureFlag(String flagKey) async {
    if (!_isInitialized) {
      AppLogger.warning('PostHog not initialized, cannot get feature flag');
      return null;
    }

    try {
      final result = await Posthog().getFeatureFlag(flagKey);
      return result?.toString();
    } catch (e) {
      AppLogger.error('Failed to get feature flag: $flagKey', e);
      return null;
    }
  }

  /// Reload feature flags
  Future<void> reloadFeatureFlags() async {
    if (!_isInitialized) {
      AppLogger.warning('PostHog not initialized, cannot reload feature flags');
      return;
    }

    try {
      await Posthog().reloadFeatureFlags();
      AppLogger.info('Feature flags reloaded successfully');
    } catch (e) {
      AppLogger.error('Failed to reload feature flags', e);
    }
  }

  /// ===== COMPATIBILITY METHODS FOR REPORTING =====

  /// Get comprehensive feature usage statistics (legacy method for compatibility)
  /// Note: This now returns an empty map since PostHog handles analytics differently
  Future<Map<String, dynamic>> getFeatureUsageStats() async {
    AppLogger.info(
        'getFeatureUsageStats called - PostHog handles analytics differently');
    return {};
  }

  /// Generate a feature usage report for decision making (legacy method for compatibility)
  /// Note: This now returns a placeholder since PostHog handles analytics differently
  Future<String> generateFeatureUsageReport() async {
    AppLogger.info(
        'generateFeatureUsageReport called - PostHog handles analytics differently');
    return '''
# Feature Usage Analytics Report
Generated on: ${DateTime.now().toIso8601String()}

## Note
This application now uses PostHog for analytics. 
Please check your PostHog dashboard for detailed analytics and feature usage reports.

## PostHog Benefits
- Real-time analytics
- Advanced segmentation
- Feature flags
- A/B testing
- Session replay
- Privacy-focused
''';
  }

  /// Get feature usage insights for a specific feature (legacy method for compatibility)
  /// Note: This now returns an empty map since PostHog handles analytics differently
  Future<Map<String, dynamic>> getFeatureInsights(String feature) async {
    AppLogger.info(
        'getFeatureInsights called for $feature - PostHog handles analytics differently');
    return {
      'feature': feature,
      'note': 'Use PostHog dashboard for detailed insights',
      'recommendation': 'Check PostHog analytics for feature usage data',
    };
  }

  /// Create a feature usage analytics widget for display in settings (legacy method for compatibility)
  /// Note: This now returns a placeholder widget since PostHog handles analytics differently
  Widget buildFeatureUsageWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics & Privacy',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'This app now uses PostHog for privacy-focused analytics. '
            'All analytics can be disabled in the privacy settings.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Visit your PostHog dashboard for detailed analytics and insights.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
        ],
      ),
    );
  }
}
