import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/settings_provider.dart';
import 'logger.dart';
import '../utils/automatic_error_reporter.dart';

/// PostHog-based tracking service that routes through backend proxy
/// to protect project API keys - no keys stored in client
class TrackingService {
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  static bool _isInitialized = false;
  late final http.Client _httpClient;
  String? _backendUrl;
  String? _distinctId;
  String? _authToken;
  String? _anonymousFallbackId;
  bool _disposed = false;

  /// Cached RouteObserver instance for singleton behavior
  RouteObserver<ModalRoute<void>>? _observer;

  /// Queue for offline analytics
  final List<Map<String, dynamic>> _offlineQueue = [];
  static const String _queueKey = 'analytics_offline_queue';
  
  /// Maximum size of the offline queue - oldest entries are dropped when exceeded
  static const int _maxOfflineQueueSize = 1000;

  /// Initializes the tracking service with backend proxy
  ///
  /// This should be called once when the app starts.
  Future<void> init() async {
    if (_isInitialized) {
      AppLogger.info('Proxy tracking service already initialized');
      return;
    }

    AppLogger.info('Initializing proxy tracking service...');
    final trackingInitStart = DateTime.now();

    try {
      // Initialize HTTP client
      _httpClient = http.Client();

      // Load backend URL from environment
      _backendUrl = dotenv.env['BACKEND_URL'];
      if (_backendUrl == null || _backendUrl!.isEmpty) {
        _backendUrl = 'https://backend.bijbelquiz.app';
        AppLogger.info('Using default backend URL: $_backendUrl');
      }

      // Ensure we have a persistent anonymous user ID
      AppLogger.info('Ensuring persistent user ID...');
      final userIdStart = DateTime.now();
      await _ensurePersistentUserId();
      final userIdDuration = DateTime.now().difference(userIdStart);
      AppLogger.info(
          'Persistent user ID ensured in ${userIdDuration.inMilliseconds}ms');

      // Load offline queue
      await _loadOfflineQueue();

      // Process any queued events
      await _processOfflineQueue();

      _isInitialized = true;
      final totalDuration = DateTime.now().difference(trackingInitStart);
      AppLogger.info(
          'Proxy tracking service initialized successfully in ${totalDuration.inMilliseconds}ms');
    } catch (e) {
      AppLogger.error('Failed to initialize proxy tracking service: $e', e);
      rethrow;
    }
  }

  /// Sets the authentication token for API requests
  void setAuthToken(String? token) {
    _authToken = token;
    AppLogger.info(_authToken != null ? 'Auth token set for tracking' : 'Auth token cleared');
  }

  /// Returns a [RouteObserver] that can be used to automatically track screen views.
  /// Returns a cached singleton instance to ensure consistent observer behavior.
  RouteObserver<ModalRoute<void>> getObserver() {
    _observer ??= RouteObserver<ModalRoute<void>>();
    return _observer!;
  }

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

    // Skip tracking in debug mode
    if (kDebugMode) {
      AppLogger.info('Skipping screen tracking in debug mode: $screenName');
      return;
    }

    AppLogger.info('Tracking screen view via proxy: $screenName');
    try {
      await _captureInternal(
        '\$screen',
        properties: {
          '\$screen_name': screenName,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      AppLogger.info('Screen view tracked successfully via proxy: $screenName');
    } catch (e) {
      AppLogger.error('Failed to track screen view: $screenName', e);

      // Report error to automatic error tracking system
      await AutomaticErrorReporter.reportStorageError(
        message: 'Failed to track screen view',
        operation: 'screen_tracking',
        additionalInfo: {
          'screen_name': screenName,
          'error': e.toString(),
          'analytics_enabled': settings.analyticsEnabled,
          'debug_mode': kDebugMode,
        },
      );
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

    // Skip tracking in debug mode
    if (kDebugMode) {
      AppLogger.info('Skipping event tracking in debug mode: $eventName');
      return;
    }

    AppLogger.info(
        'Tracking event via proxy: $eventName${properties != null ? ' with properties: $properties' : ''}');
    try {
      await _captureInternal(eventName, properties: properties);
      AppLogger.info('Event tracked successfully via proxy: $eventName');
    } catch (e) {
      AppLogger.error('Failed to track event: $eventName', e);

      // Report error to automatic error tracking system
      await AutomaticErrorReporter.reportStorageError(
        message: 'Failed to track event',
        operation: 'event_tracking',
        additionalInfo: {
          'event_name': eventName,
          'properties': properties?.toString(),
          'error': e.toString(),
          'analytics_enabled': settings.analyticsEnabled,
          'debug_mode': kDebugMode,
        },
      );
    }
  }

  /// Internal method to capture events via backend proxy
  Future<void> _captureInternal(String eventName,
      {Map<String, Object>? properties}) async {
    if (!_isInitialized) {
      AppLogger.warning('Proxy tracking not initialized, queueing event');
      _queueEvent(eventName, properties);
      return;
    }

    // Generate and cache anonymous fallback ID once
    _anonymousFallbackId ??= _generateAnonymousId();
    
    final payload = {
      'event': eventName,
      'distinctId': _distinctId ?? _anonymousFallbackId,
      'properties': {
        ...?properties,
        '\$lib': 'bijbelquiz-flutter',
        '\$lib_version': '1.0.0',
      },
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      final response = await _sendToProxy(payload);

      if (response.statusCode == 200) {
        AppLogger.info('Event tracked successfully via proxy: $eventName');
      } else {
        AppLogger.warning('Failed to track event, queueing for retry');
        _queueEvent(eventName, properties);
      }
    } catch (e) {
      AppLogger.error('Failed to track event: $eventName', e);
      _queueEvent(eventName, properties);
    }
  }

  /// Send event to backend proxy
  Future<http.Response> _sendToProxy(Map<String, dynamic> payload) async {
    final url = Uri.parse('$_backendUrl/api/posthog');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Add auth token if available
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return await _httpClient
        .post(
          url,
          headers: headers,
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 10));
  }

  /// Queue event for offline processing
  void _queueEvent(String eventName, Map<String, Object>? properties) {
    // Obtain a single id value to ensure consistency
    final distinctId = _distinctId ?? _generateAnonymousId();
    
    _offlineQueue.add({
      'event': eventName,
      'distinctId': distinctId,
      'properties': properties,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Enforce max queue size - drop oldest entries
    while (_offlineQueue.length > _maxOfflineQueueSize) {
      _offlineQueue.removeAt(0);
    }
    
    _saveOfflineQueue();
  }

  /// Load offline queue from storage
  Future<void> _loadOfflineQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);
      if (queueJson != null) {
        final queue = jsonDecode(queueJson) as List<dynamic>;
        _offlineQueue.clear();
        
        // Safely iterate and accept only map-like entries
        for (final element in queue) {
          if (element is Map) {
            _offlineQueue.add(Map<String, dynamic>.from(element));
          } else {
            AppLogger.warning('Skipping invalid queue entry: $element');
          }
        }
        
        AppLogger.info('Loaded ${_offlineQueue.length} queued events');
      }
    } catch (e) {
      AppLogger.warning('Failed to load offline queue: $e');
    }
  }

  /// Save offline queue to storage
  Future<void> _saveOfflineQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_queueKey, jsonEncode(_offlineQueue));
    } catch (e) {
      AppLogger.warning('Failed to save offline queue: $e');
    }
  }

  /// Process queued events
  Future<void> _processOfflineQueue() async {
    if (_offlineQueue.isEmpty) return;

    AppLogger.info('Processing ${_offlineQueue.length} offline events');

    final events = List<Map<String, dynamic>>.from(_offlineQueue);
    _offlineQueue.clear();
    await _saveOfflineQueue();

    // Send events in batch with timeout and auth header
    try {
      final url = Uri.parse('$_backendUrl/api/posthog');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      
      final response = await _httpClient
          .post(
            url,
            headers: headers,
            body: jsonEncode({'events': events}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        // Re-queue events if batch failed
        _offlineQueue.addAll(events);
        await _saveOfflineQueue();
      }
    } catch (e) {
      // Re-queue events if request failed
      _offlineQueue.addAll(events);
      await _saveOfflineQueue();
    }
  }

  /// Ensures we have a persistent anonymous user ID stored in shared preferences
  Future<void> _ensurePersistentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'tracking_anonymous_user_id';

    if (!prefs.containsKey(key)) {
      // Generate a new persistent ID and store it
      final newId = _generateAnonymousId();
      await prefs.setString(key, newId);
      _distinctId = newId;
      AppLogger.info('Created new persistent anonymous user ID: $newId');
    } else {
      _distinctId = prefs.getString(key);
      AppLogger.info('Using existing persistent anonymous user ID: $_distinctId');
    }
  }

  /// Generate an anonymous user ID
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

  // ===== COMPREHENSIVE FEATURE USAGE TRACKING =====

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

  /// Track when a user starts using a feature
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

  /// Specific app usage events

  /// Track when user starts a quiz
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

  /// ===== PROXY-SPECIFIC METHODS =====

  /// Disable analytics data collection
  Future<void> disableAnalytics() async {
    AppLogger.info('Analytics disabled (proxy)');
  }

  /// Enable analytics data collection
  Future<void> enableAnalytics() async {
    AppLogger.info('Analytics enabled (proxy)');
  }

  /// Get the current user's distinct ID
  Future<String> getDistinctId() async {
    return _distinctId ?? _generateAnonymousId();
  }

  /// Identify a user with PostHog via proxy
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
          'Proxy tracking not initialized, skipping user identification');
      return;
    }

    AppLogger.info('Identifying user via proxy: $userId');
    try {
      await _captureInternal(
        '\$identify',
        properties: {
          '\$user_id': userId,
          ...?userProperties,
        },
      );
      AppLogger.info('User identified successfully via proxy: $userId');
    } catch (e) {
      AppLogger.error('Failed to identify user: $userId', e);
    }
  }

  /// Reset tracking data (useful for logout)
  Future<void> reset() async {
    _distinctId = null;
    _authToken = null;
    _anonymousFallbackId = null;
    
    // Clear stored ID
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tracking_anonymous_user_id');
    
    AppLogger.info('Proxy tracking data reset successfully');
  }

  /// Disposes of resources used by the service
  /// This method is idempotent - safe to call multiple times
  void dispose() {
    if (_disposed) return;
    
    _httpClient.close();
    _offlineQueue.clear();
    _disposed = true;
    AppLogger.info('Tracking service disposed');
  }

  /// ===== COMPATIBILITY METHODS FOR REPORTING =====

  /// Get comprehensive feature usage statistics (legacy method for compatibility)
  Future<Map<String, dynamic>> getFeatureUsageStats() async {
    AppLogger.info(
        'getFeatureUsageStats called - check PostHog dashboard for analytics');
    return {};
  }

  /// Generate a feature usage report for decision making (legacy method for compatibility)
  Future<String> generateFeatureUsageReport() async {
    AppLogger.info(
        'generateFeatureUsageReport called - check PostHog dashboard for analytics');
    return '''
# Feature Usage Analytics Report
Generated on: ${DateTime.now().toIso8601String()}

## Note
This application now uses PostHog via backend proxy for analytics.
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
  Future<Map<String, dynamic>> getFeatureInsights(String feature) async {
    AppLogger.info(
        'getFeatureInsights called for $feature - check PostHog dashboard for insights');
    return {
      'feature': feature,
      'note': 'Use PostHog dashboard for detailed insights',
      'recommendation': 'Check PostHog analytics for feature usage data',
    };
  }

  /// Create a feature usage analytics widget for display in settings (legacy method for compatibility)
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
            'This app uses PostHog via secure backend proxy for privacy-focused analytics. '
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