# Local Development Setup

This document explains how to set up and use the local development environment.

## Prerequisites

- Flutter SDK installed

## Testing the App

The backend APIs have been moved to a separate repository. For local development:

1. Run the app in debug mode:
   ```bash
   flutter run
   ```

2. The app will use the production backend (`https://bijbelquiz.app/api`) by default in debug mode.

## Testing Emergency Messaging

For testing emergency messaging functionality, use the `emergency_message_tool.py` script:

```bash
python3 emergency_message_tool.py
```

## Testing the Update Flow

To test the update flow:

1. Modify the version in your `pubspec.yaml` to be lower than the production version
2. Run the app in debug mode
3. The app should detect the update and show the update dialog

## Running Tests

To run the test suite:

```bash
flutter test
```