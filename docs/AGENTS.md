# AI Agent Development Guidelines

Guidelines for AI agents making changes to the BijbelQuiz codebase.

## Build, Lint, and Test Commands

All commands run from `/home/thomas/Programming/BijbelQuiz/app` directory.

```bash
# Core commands
flutter pub get                    # Install dependencies
flutter analyze                   # Run linter
flutter test                      # Run all tests

# Run single test
flutter test --name "test_name"              # Exact match
flutter test --plain-name "substring"        # Substring match
flutter test test/quiz_question_test.dart     # Specific file

# Run app
flutter run -d chrome        # Web
flutter run -d linux         # Desktop
flutter run                  # Default device
```

**After any code changes, always run:** `flutter analyze && flutter test`

## Code Style Guidelines

### Import Order
1. Dart SDK (`dart:*`)
2. Flutter framework (`package:flutter/*`)
3. Third-party packages (`package:provider/*`)
4. Relative project imports (`../models/*`)

### Naming Conventions
- Classes: `PascalCase` (e.g., `QuizQuestion`)
- Methods/Variables: `camelCase` (e.g., `loadStats`)
- Private members: `_prefix` (e.g., `_score`)
- Constants: `camelCase` (e.g., `scoreKey`)
- Files: `snake_case.dart` (e.g., `quiz_question.dart`)

### Documentation
- Use `///` for public API documentation
- Use `//` for inline comments sparingly

### Error Handling Pattern
```dart
try {
  // Code
} catch (e) {
  final appError = ErrorHandler().fromException(
    e, type: AppErrorType.storage,
    userMessage: 'User message',
    context: {'operation': 'op_name'},
  );
  AppLogger.error(appError.userMessage, e);
  await AutomaticErrorReporter.reportStorageError(
    message: 'Technical message',
    operation: 'op_name',
    additionalInfo: {'key': 'value'},
  );
}
```

### Key Guidelines
1. Use `final` for immutable variables
2. Use `const` for compile-time constants
3. Avoid `print()` - use `AppLogger.info/debug/error/warning`
4. Use `Theme.of(context)` for theming
5. Prefer named parameters for functions with multiple args
6. Null safety: Use `String?` for nullable types
7. Always handle errors in async methods

### Linting Rules
- `avoid_slow_async_io`, `cancel_subscriptions`, `close_sinks`
- `use_key_in_widget_constructors`, `prefer_void_to_null`
- `throw_in_finally`, `unnecessary_statements`, `valid_regexps`
- `no_logic_in_create_state`

### State Management (Provider)
```dart
class MyProvider extends ChangeNotifier {
  int _value = 0;
  int get value => _value;
  void updateValue(int newValue) {
    _value = newValue;
    notifyListeners();
  }
}
```

### Testing Pattern
```dart
void main() {
  group('ClassName', () {
    test('should do something', () {
      final obj = ClassName();
      final result = obj.doSomething();
      expect(result, expectedValue);
    });
  });
}
```

## Standardized Theme Elements

Use themes from `@app/lib/theme/app_theme.dart`:
- `appLightTheme`, `appDarkTheme`, `oledTheme`
- `greenTheme`, `orangeTheme`, `greyTheme`

```dart
Text('Text', style: Theme.of(context).textTheme.titleLarge)
Container(color: Theme.of(context).colorScheme.primary)
```

## Analytics Integration

Use `@app/lib/services/tracking_service.dart`:
```dart
final trackingService = TrackingService();
await trackingService.trackFeatureUsage(context,
  TrackingService.featureQuizGameplay,
  TrackingService.actionStarted);
await trackingService.trackQuizStart(context);
await trackingService.trackThemeChange(context, 'oledTheme');
```

## Automatic Error Reporting

Use `@app/lib/utils/automatic_error_reporter.dart`:
```dart
await AutomaticErrorReporter.reportBiblicalReferenceError(
  message: 'Error', reference: 'Genesis 1:1');
await AutomaticErrorReporter.reportQuestionError(
  message: 'Error', questionId: 'q123');
await AutomaticErrorReporter.reportNetworkError(
  message: 'Error', url: 'https://api.example.com', statusCode: 500);
await AutomaticErrorReporter.reportStorageError(
  message: 'Error', operation: 'save_stats');
await AutomaticErrorReporter.reportAudioError(
  message: 'Playback failed', assetPath: 'assets/sounds/click.mp3');
```

### Best Practices
- Include context in `additionalInfo`
- Always specify `questionId` when available
- Use appropriate `AppErrorType` values

### Available Error Types
`AppErrorType.biblicalReference`, `question`, `network`, `storage`,
`authentication`, `audio`, `animation`, `performance`, `connection`,
`ui`, `provider`, `theme`, `service`
