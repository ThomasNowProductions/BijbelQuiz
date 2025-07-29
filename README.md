# BijbelQuiz

BijbelQuiz is a cross-platform Bible quiz app designed to test and improve your knowledge of the Bible. It features multiple choice, fill-in-the-blank, and true/false questions, and is optimized for both low-end devices and poor internet connections.

**Note: The app is only available in Dutch. All in-app content, questions, and UI are in Dutch.**

## Features

- Multiple question types (multiple choice, fill-in-the-blank, true/false)
- Tracks your score, streaks, and progress
- Local notifications and reminders
- Sound effects and haptic feedback
- Performance optimizations for low-end devices
- Offline caching of questions
- Telemetry and analytics (with user consent)

## Getting Started

1. **Install Flutter**: Make sure you have [Flutter](https://flutter.dev/docs/get-started/install) installed.

2. **Clone the repository**:

   ```sh
   git clone <repo-url>
   cd BijbelQuiz
   ```

3. **Install dependencies**:

   ```sh
   flutter pub get
   ```

4. **Run the app**:

   ```sh
   flutter run
   ```

## Project Structure

- `lib/` - Main Dart source code
- `assets/` - Question data, fonts, and sounds
- `android/`, `ios/`, `linux/`, `macos/`, `windows/` - Platform-specific code
- `test/` - Tests

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Build & Test

To build for your platform:

- **Web:**
  ```sh
  flutter build web
  ```
- **Android:**
  ```sh
  flutter build apk --release
  ```
- **iOS:**
  ```sh
  flutter build ios --release
  ```
- **Linux:**
  ```sh
  flutter build linux --release
  ```
- **macOS:**
  ```sh
  flutter build macos --release
  ```
- **Windows:**
  ```sh
  flutter build windows --release
  ```

To run tests:

```sh
flutter test
```

## Asset Licenses

See [ASSETS_LICENSES.md](ASSETS_LICENSES.md) for details on the licenses of fonts, images, and sounds used in this app.

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0). See [LICENSE.md](LICENSE.md) for details.

## Contact

For questions, suggestions, or security issues, contact: thomasnowprod@proton.me
