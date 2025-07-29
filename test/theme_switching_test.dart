import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bijbelquiz/providers/settings_provider.dart';
import 'package:bijbelquiz/theme/app_theme.dart';

void main() {
  group('Theme Switching Tests', () {
    testWidgets('should switch from custom theme to normal theme without errors', (WidgetTester tester) async {
      // Create a settings provider and wait for it to initialize
      final settingsProvider = SettingsProvider();
      
      // Wait for the provider to finish loading
      while (settingsProvider.isLoading) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      
      // Set initial custom theme
      await settingsProvider.setCustomTheme('oled');
      await settingsProvider.setThemeMode(ThemeMode.light);
      
      // Wait for theme changes to complete
      await tester.pump(const Duration(milliseconds: 150));
      
      // Build widget with custom theme
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settingsProvider),
          ],
          child: MaterialApp(
            theme: oledTheme,
            home: const Scaffold(
              body: Center(
                child: Text('Test'),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Switch to normal theme
      await settingsProvider.setCustomTheme(null);
      await settingsProvider.setThemeMode(ThemeMode.light);
      
      // Wait for theme changes to complete
      await tester.pump(const Duration(milliseconds: 150));
      
      // Rebuild with normal theme
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settingsProvider),
          ],
          child: MaterialApp(
            theme: appLightTheme,
            home: const Scaffold(
              body: Center(
                child: Text('Test'),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify no errors occurred
      expect(tester.takeException(), isNull);
    });
    
    testWidgets('should handle rapid theme changes without GlobalKey errors', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();
      
      // Wait for the provider to finish loading
      while (settingsProvider.isLoading) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      
      // Rapidly change themes
      await settingsProvider.setCustomTheme('green');
      await settingsProvider.setCustomTheme('orange');
      await settingsProvider.setCustomTheme(null);
      await settingsProvider.setThemeMode(ThemeMode.dark);
      
      // Wait for all theme changes to complete
      await tester.pump(const Duration(milliseconds: 150));
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settingsProvider),
          ],
          child: MaterialApp(
            theme: appDarkTheme,
            home: const Scaffold(
              body: Center(
                child: Text('Test'),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify no GlobalKey errors
      expect(tester.takeException(), isNull);
    });
  });
} 