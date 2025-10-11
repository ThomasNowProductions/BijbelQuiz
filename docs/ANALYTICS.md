# Analytics Documentation

This document explains the comprehensive analytics setup in the BijbelQuiz application, which uses PostHog for event tracking and product analytics.

## Overview

We use the `posthog_flutter` package to send events to PostHog. This allows us to understand how users interact with the app, identify areas for improvement, and make data-driven decisions.

Users can opt out of analytics collection through a setting in the app's settings screen. All analytics methods respect this preference.

## AnalyticsService

The `AnalyticsService` is a comprehensive wrapper around the `posthog_flutter` package that provides extensive event tracking capabilities. It is located in `bijbelquiz/lib/services/analytics_service.dart`.

### Core Methods

-   `init()`: Initializes the PostHog SDK with configuration and API keys
-   `getObserver()`: Returns a `PosthogObserver` for automatic screen view tracking
-   `screen(BuildContext context, String screenName)`: Tracks screen views with user preference checks
-   `capture(BuildContext context, String eventName, {Map<String, Object>? properties})`: Tracks custom events with optional properties

### Comprehensive Event Tracking Methods

#### App Lifecycle Tracking
-   `trackAppLaunch(BuildContext context)`: Tracks app launches with device and version information
-   `trackSessionEvent(BuildContext context, String event)`: Tracks session start/end events

#### User Engagement Tracking
-   `trackUserEngagement(BuildContext context, String action)`: Tracks user interactions and engagement
-   `trackUserFlow(BuildContext context, String flow, String step)`: Tracks user journey flows
-   `trackConversionFunnel(BuildContext context, String funnel, String step, bool success)`: Tracks conversion events

#### Performance Monitoring
-   `trackPerformance(BuildContext context, String metric, Duration duration)`: Tracks performance metrics and timing
-   `trackTimeBasedEvent(BuildContext context, String event, Duration duration)`: Tracks time-based user behaviors

#### Quiz Gameplay Analytics
-   `trackQuizEvent(BuildContext context, String event)`: Tracks quiz-specific events
-   `trackQuestionInteraction(BuildContext context, String interaction, String questionType)`: Tracks question-level interactions
-   `trackLearningProgress(BuildContext context, String activity, String progress)`: Tracks learning and progress events

#### Scoring and Achievement Tracking
-   `trackScoringEvent(BuildContext context, String event, int points)`: Tracks scoring events
-   `trackAchievement(BuildContext context, String achievement, String milestone)`: Tracks achievements and milestones

#### User Behavior Analytics
-   `trackUserBehavior(BuildContext context, String behavior, String category)`: Tracks behavioral patterns
-   `trackContentInteraction(BuildContext context, String contentType, String interaction, String contentId)`: Tracks content engagement
-   `trackSearchEvent(BuildContext context, String searchType, String query, int resultsCount)`: Tracks search behavior

#### Technical Event Tracking
-   `trackTechnicalEvent(BuildContext context, String event, String status)`: Tracks technical events and errors
-   `trackError(BuildContext context, String errorType, String errorMessage)`: Tracks errors with context
-   `trackFeatureUsage(BuildContext context, String feature, String action)`: Tracks feature usage patterns

#### Business Metrics
-   `trackBusinessMetric(BuildContext context, String metric, double value)`: Tracks business KPIs

#### Accessibility Tracking
-   `trackAccessibilityEvent(BuildContext context, String event, String element)`: Tracks accessibility feature usage

#### Feedback and Preferences
-   `trackFeedback(BuildContext context, String feedbackType, String feedbackValue)`: Tracks user feedback
-   `trackPreferenceChange(BuildContext context, String preference, String value)`: Tracks settings changes

## Tracked Events

The following is a list of all the events that are currently being tracked in the app.

### `lesson_select_screen.dart`

-   **Screen View**: `LessonSelectScreen`
-   **Load Lessons**: `load_lessons`
-   **Load Lessons Error**: `load_lessons_error`
-   **Show Promo Card**: `show_promo_card`
-   **Tap Settings**: `tap_settings`
-   **Tap Store**: `tap_store`
-   **Dismiss Promo Card**: `dismiss_promo_card`
-   **Tap Donation Promo**: `tap_donation_promo`
-   **Tap Satisfaction Promo**: `tap_satisfaction_promo`
-   **Tap Follow Promo**: `tap_follow_promo`
-   **Tap Locked Lesson**: `tap_locked_lesson`
-   **Tap Unplayable Lesson**: `tap_unplayable_lesson`
-   **Tap Lesson**: `tap_lesson`
-   **Start Quiz**: `start_quiz`
-   **Start Practice Quiz**: `start_practice_quiz`

### `quiz_screen.dart`

-   **Screen View**: `QuizScreen`
-   **Show Time Up Dialog**: `show_time_up_dialog`
-   **Retry With Points**: `retry_with_points`
-   **Next Question From Time Up**: `next_question_from_time_up`
-   **Language Changed**: `language_changed`
-   **Lesson Completed**: `lesson_completed`
-   **Skip Question**: `skip_question`
-   **Unlock Biblical Reference**: `unlock_biblical_reference`

### `settings_screen.dart`

-   **Screen View**: `SettingsScreen`
-   **Open Status Page**: `open_status_page`
-   **Check For Updates**: `check_for_updates`
-   **Change Theme**: `change_theme`
-   **Change Game Speed**: `change_game_speed`
-   **Toggle Mute**: `toggle_mute`
-   **Toggle Notifications**: `toggle_notifications`
-   **Donate**: `donate`
-   **Show Reset and Logout Dialog**: `show_reset_and_logout_dialog`
-   **Reset and Logout**: `reset_and_logout`
-   **Show Introduction**: `show_introduction`
-   **Report Issue**: `report_issue`
-   **Export Stats**: `export_stats`
-   **Import Stats**: `import_stats`
-   **Clear Question Cache**: `clear_question_cache`
-   **Contact Us**: `contact_us`
-   **Show Social Media Dialog**: `show_social_media_dialog`
-   **Follow Social Media**: `follow_social_media`

### `guide_screen.dart`

-   **Screen View**: `GuideScreen`
-   **Guide Page Viewed**: `guide_page_viewed`
-   **Guide Completed**: `guide_completed`
-   **Guide Donation Button Clicked**: `guide_donation_button_clicked`
-   **Guide Notification Permission Requested**: `guide_notification_permission_requested`

### `lesson_complete_screen.dart`

-   **Screen View**: `LessonCompleteScreen`
-   **Retry Lesson From Complete**: `retry_lesson_from_complete`
-   **Start Next Lesson From Complete**: `start_next_lesson_from_complete`

### `store_screen.dart`

-   **Screen View**: `StoreScreen`
-   **Purchase Power-up**: `purchase_powerup`
-   **Purchase Theme**: `purchase_theme`

## How to Add New Tracking Events

To add a new tracking event, you can use the `AnalyticsService` with any of its comprehensive tracking methods.

### Basic Event Tracking

1.  Get an instance of the `AnalyticsService` using `Provider.of<AnalyticsService>(context, listen: false)`.
2.  Call the appropriate tracking method based on the type of event.

### Usage Examples

```dart
final analytics = Provider.of<AnalyticsService>(context, listen: false);

// Basic event tracking
await analytics.capture(context, 'custom_event', properties: {'custom_property': 'value'});

// App lifecycle tracking
await analytics.trackAppLaunch(context);

// User engagement tracking
await analytics.trackUserEngagement(context, 'button_clicked');

// Performance tracking
await analytics.trackPerformance(context, 'question_load_time', Duration(milliseconds: 500));

// Quiz gameplay tracking
await analytics.trackQuizEvent(context, 'quiz_started');

// Question interaction tracking
await analytics.trackQuestionInteraction(context, 'answer_selected', 'multiple_choice');

// Learning progress tracking
await analytics.trackLearningProgress(context, 'lesson_completed', 'beginner');

// Achievement tracking
await analytics.trackAchievement(context, 'streak_milestone', '10_correct_answers');

// Error tracking
await analytics.trackError(context, 'network_error', 'Failed to load questions');

// Feature usage tracking
await analytics.trackFeatureUsage(context, 'power_up', 'used');

// Business metric tracking
await analytics.trackBusinessMetric(context, 'retention_rate', 0.85);

// Accessibility tracking
await analytics.trackAccessibilityEvent(context, 'screen_reader_used', 'question_text');

// Feedback tracking
await analytics.trackFeedback(context, 'rating', '5_stars');

// Preference change tracking
await analytics.trackPreferenceChange(context, 'theme', 'dark');
```

### Event Categories

The service provides specialized methods for different types of events:

- **App Lifecycle**: Launch, session, and background/foreground events
- **User Engagement**: Interactions, flows, and conversion funnels
- **Performance**: Timing, metrics, and technical performance
- **Quiz Gameplay**: Question interactions, scoring, and progress
- **Learning**: Progress tracking, achievements, and milestones
- **Technical**: Errors, connectivity, and system events
- **Business**: KPIs, retention, and conversion metrics
- **Accessibility**: Screen reader and accessibility feature usage
- **Feedback**: Ratings, reviews, and user preferences

### Best Practices

1. **Always use appropriate method**: Choose the specific tracking method that matches your event type for better categorization and analysis
2. **Include relevant context**: Provide meaningful properties that help analyze user behavior
3. **Respect user preferences**: All methods automatically check analytics settings
4. **Use consistent naming**: Follow the established naming conventions for events and properties
5. **Track errors**: Use `trackError()` for comprehensive error reporting with context

Note that all tracking methods require a `BuildContext` parameter to check the user's analytics preference setting and will automatically skip tracking if analytics are disabled.
