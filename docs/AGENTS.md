# AI Agent Development Guidelines

This document provides guidelines for AI agents making changes to the BijbelQuiz codebase. These standards ensure consistency, maintainability, and proper tracking across the application.

## Standardized Theme Elements

When making UI changes, always use the standardized theme elements from `@app/lib/theme/app_theme.dart`:

### Available Themes
- `appLightTheme` - Standard light theme (loaded from themes.json)
- `appDarkTheme` - Standard dark theme (loaded from themes.json)
- `oledTheme` - Optimized for OLED displays (loaded from themes.json)
- `greenTheme` - Green color scheme (loaded from themes.json)
- `orangeTheme` - Orange color scheme (loaded from themes.json)
- `greyTheme` - Grey/dark theme (loaded from themes.json)

### Theme Usage
Always use the theme through Flutter's `Theme.of(context)` method to ensure consistency:
```dart
// Correct usage:
Text(
  'Sample Text',
  style: Theme.of(context).textTheme.titleLarge,
)

Container(
  color: Theme.of(context).colorScheme.primary,
  child: ...
)
```

### Responsive Utilities
Use the provided responsive utilities for scalable UI elements:
- `getResponsiveFontSize(BuildContext context, double baseSize)` - Get responsive font size
- `getResponsivePadding(BuildContext context, EdgeInsets basePadding)` - Get responsive padding

## Analytics Integration

Always implement analytics tracking using `@app/lib/services/tracking_service.dart` (replaces analytics_service.dart):

### Accessing Tracking Service
```dart
final trackingService = TrackingService();
```

### Feature Tracking Standards
Use the standardized constants for consistent tracking:
- Features: `TrackingService.FEATURE_QUIZ_GAMEPLAY`, `TrackingService.FEATURE_LESSON_SYSTEM`, etc.
- Actions: `TrackingService.ACTION_ACCESSED`, `TrackingService.ACTION_USED`, `TrackingService.ACTION_COMPLETED`, etc.

### Event Tracking Methods
- `trackFeatureUsage()` - General feature usage tracking
- `trackFeatureStart()` - When user starts using a feature
- `trackFeatureSuccess()` - When user successfully uses a feature
- `trackFeatureCompletion()` - When user completes a feature flow
- `screen()` - Track screen views
- `capture()` - Track custom events
- `trackQuizStart()` / `trackQuizComplete()` - Track quiz gameplay
- `trackThemePurchase()` / `trackThemeChange()` - Track theme usage
- `trackLessonStart()` / `trackLessonComplete()` - Track lesson system
- `trackSkipUsed()` / `trackRetryUsed()` - Track specific feature usage
- `trackAnalyticsToggle()` - Track user preference changes
- And many more specialized tracking methods

## Automattic Error Reporting

Always use proper error reporting from `@app/lib/utils/automatic_error_reporter.dart`:

### Automatic Error Reporting
Use the appropriate reporting method for different error types:
- `AutomaticErrorReporter.reportBiblicalReferenceError()` - For biblical reference issues
- `AutomaticErrorReporter.reportQuestionError()` - For question-related issues
- `AutomaticErrorReporter.reportNetworkError()` - For network/API errors
- `AutomaticErrorReporter.reportStorageError()` - For storage-related errors
- `AutomaticErrorReporter.reportAuthenticationError()` - For authentication/login issues
- `AutomaticErrorReporter.reportAudioError()` - For sound/audio playback issues
- `AutomaticErrorReporter.reportAnimationError()` - For animation controller issues
- `AutomaticErrorReporter.reportPerformanceError()` - For performance monitoring issues
- `AutomaticErrorReporter.reportConnectionError()` - For network connectivity issues
- `AutomaticErrorReporter.reportPlatformFeedbackError()` - For platform-specific feedback issues
- `AutomaticErrorReporter.reportUIRenderingError()` - For UI rendering/widget issues
- `AutomaticErrorReporter.reportProviderError()` - For state management/provider issues
- `AutomaticErrorReporter.reportThemeError()` - For theme loading/configuration issues
- `AutomaticErrorReporter.reportServiceInitializationError()` - For service startup issues

### Error Reporting Best Practices
- Include relevant context in the `additionalInfo` parameter
- Use descriptive error messages that help with debugging
- Always specify the `questionId` when available for question-related errors
- Include specific details like URLs, status codes, file paths, user IDs, or platform info where applicable
- Use appropriate error types that match the AppErrorType enum when possible
- Report errors early in catch blocks to ensure they're captured before other processing
