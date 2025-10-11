import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bijbelquiz/utils/color_parser.dart';

void main() {
  group('ColorParser Tests', () {
    group('Hex Color Parsing', () {
      test('parses 6-digit hex colors correctly', () {
        final color = ColorParser.parseColor('#FF5733', component: 'test');
        expect(color, equals(const Color(0xFFFF5733)));
      });

      test('parses 8-digit hex colors with alpha correctly', () {
        final color = ColorParser.parseColor('#80FF5733', component: 'test');
        expect(color, equals(const Color(0x80FF5733)));
      });

      test('handles 3-digit hex colors correctly', () {
        final color = ColorParser.parseColor('#F53', component: 'test');
        expect(color, equals(const Color.fromARGB(255, 255, 85, 51)));
      });

      test('handles 4-digit hex colors with alpha correctly', () {
        final color = ColorParser.parseColor('#8F53', component: 'test');
        expect(color, equals(const Color.fromARGB(136, 255, 85, 51)));
      });

      test('adds alpha channel to 6-digit hex when missing', () {
        final color = ColorParser.parseColor('#FF5733', component: 'test');
        expect(color.alpha, equals(255));
      });
    });

    group('RGB Color Parsing', () {
      test('parses rgb() format correctly', () {
        final color = ColorParser.parseColor('rgb(255, 87, 51)', component: 'test');
        expect(color, equals(const Color.fromARGB(255, 255, 87, 51)));
      });

      test('parses rgba() format correctly', () {
        final color = ColorParser.parseColor('rgba(255, 87, 51, 0.5)', component: 'test');
        expect(color, equals(const Color.fromARGB(128, 255, 87, 51)));
      });

      test('handles rgb values with spaces correctly', () {
        final color = ColorParser.parseColor('rgb( 255 , 87 , 51 )', component: 'test');
        expect(color, equals(const Color.fromARGB(255, 255, 87, 51)));
      });

      test('clamps RGB values to valid range', () {
        final color = ColorParser.parseColor('rgb(300, -10, 51)', component: 'test');
        expect(color, equals(const Color.fromARGB(255, 255, 0, 51)));
      });
    });

    group('HSL Color Parsing', () {
      test('parses hsl() format correctly', () {
        final color = ColorParser.parseColor('hsl(0, 100%, 50%)', component: 'test');
        expect(color, equals(const Color.fromARGB(255, 255, 0, 0)));
      });

      test('parses hsla() format correctly', () {
        final color = ColorParser.parseColor('hsla(0, 100%, 50%, 0.5)', component: 'test');
        expect(color, equals(const Color.fromARGB(128, 255, 0, 0)));
      });

      test('handles HSL values with spaces correctly', () {
        final color = ColorParser.parseColor('hsl( 0 , 100% , 50% )', component: 'test');
        expect(color, equals(const Color.fromARGB(255, 255, 0, 0)));
      });
    });

    group('Color Name Parsing', () {
      test('parses basic color names correctly', () {
        final color = ColorParser.parseColor('red', component: 'test');
        expect(color, equals(const Color(0xFFFF0000)));
      });

      test('parses extended color names correctly', () {
        final color = ColorParser.parseColor('dodgerblue', component: 'test');
        expect(color, equals(const Color(0xFF1E90FF)));
      });

      test('handles case insensitive color names', () {
        final color1 = ColorParser.parseColor('RED', component: 'test');
        final color2 = ColorParser.parseColor('red', component: 'test');
        expect(color1, equals(color2));
      });
    });

    group('Color Object Handling', () {
      test('returns Color objects as-is', () {
        const originalColor = Color(0xFF5733FF);
        final color = ColorParser.parseColor(originalColor, component: 'test');
        expect(color, equals(originalColor));
      });

      test('handles integer color values', () {
        final color = ColorParser.parseColor(0xFF5733FF, component: 'test');
        expect(color, equals(const Color(0xFF5733FF)));
      });
    });

    group('Color Normalization', () {
      test('normalizes colors to hex format correctly', () {
        const color = Color(0x80FF5733);
        final hex = ColorParser.normalizeColorToHex(color);
        expect(hex, equals('#80FF5733'));
      });

      test('handles fully opaque colors correctly', () {
        const color = Color(0xFFFF5733);
        final hex = ColorParser.normalizeColorToHex(color);
        expect(hex, equals('#FFFF5733'));
      });
    });

    group('Contrast Validation', () {
      test('validates good contrast ratios', () {
        const black = Color(0xFF000000);
        const white = Color(0xFFFFFFFF);
        final isValid = ColorParser.validateContrast(black, white);
        expect(isValid, isTrue);
      });

      test('validates poor contrast ratios', () {
        const darkGray = Color(0xFF333333);
        const mediumGray = Color(0xFF666666);
        final isValid = ColorParser.validateContrast(darkGray, mediumGray);
        expect(isValid, isFalse);
      });

      test('accepts custom contrast ratio thresholds', () {
        const white = Color(0xFFFFFFFF);
        const lightGray = Color(0xFFCCCCCC);
        final isValid = ColorParser.validateContrast(white, lightGray, minRatio: 1.5);
        expect(isValid, isTrue);
      });
    });

    group('Luminance Calculation', () {
      test('calculates luminance for black correctly', () {
        const black = Color(0xFF000000);
        // We can't directly test _calculateLuminance as it's private,
        // but we can test it indirectly through contrast validation
        const white = Color(0xFFFFFFFF);
        final isValid = ColorParser.validateContrast(black, white);
        expect(isValid, isTrue);
      });

      test('calculates luminance for white correctly', () {
        const white = Color(0xFFFFFFFF);
        const black = Color(0xFF000000);
        final isValid = ColorParser.validateContrast(white, black);
        expect(isValid, isTrue);
      });
    });

    group('Gemini Response Parsing', () {
      test('extracts colors from valid JSON response', () {
        const response = '''
        Here's a color palette for you:
        {
          "primary": "#2563EB",
          "secondary": "#7C3AED",
          "tertiary": "#DC2626",
          "background": "#FFFFFF",
          "surface": "#F8FAFC"
        }
        ''';

        final colors = ColorParser.extractColorsFromGeminiResponse(response);
        expect(colors.containsKey('primary'), isTrue);
        expect(colors.containsKey('secondary'), isTrue);
        expect(colors['primary'], equals(const Color(0xFF2563EB)));
      });

      test('handles malformed JSON gracefully', () {
        const response = 'This is not a valid JSON response with colors.';

        final colors = ColorParser.extractColorsFromGeminiResponse(response);
        // Should return fallback colors
        expect(colors.containsKey('primary'), isTrue);
        expect(colors.containsKey('background'), isTrue);
      });

      test('extracts partial color data', () {
        const response = '''
        Here is a color palette:
        {
          "primary": "#2563EB",
          "background": "#FFFFFF"
        }
        More text after the JSON.
        ''';

        final colors = ColorParser.extractColorsFromGeminiResponse(response);
        expect(colors.containsKey('primary'), isTrue);
        expect(colors.containsKey('secondary'), isTrue); // Should have fallback
        expect(colors['primary'], equals(const Color(0xFF2563EB)));
      });
    });

    group('On-Color Generation', () {
      test('generates appropriate on-colors for dark backgrounds', () {
        const darkColor = Color(0xFF2563EB);
        final onColors = ColorParser.generateOnColors({'primary': darkColor});
        expect(onColors['onPrimary'], equals(Colors.white));
      });

      test('generates appropriate on-colors for light backgrounds', () {
        const lightColor = Color(0xFFFFF8DC); // Light yellow
        final onColors = ColorParser.generateOnColors({'background': lightColor});
        expect(onColors['onBackground'], equals(Colors.black));
      });
    });

    group('Error Handling', () {
      test('handles null input gracefully', () {
        final color = ColorParser.parseColor(null, component: 'test');
        expect(color, isNotNull);
      });

      test('handles empty string input gracefully', () {
        final color = ColorParser.parseColor('', component: 'test');
        expect(color, isNotNull);
      });

      test('handles invalid color strings gracefully', () {
        final color = ColorParser.parseColor('invalid-color', component: 'test');
        expect(color, isNotNull);
      });

      test('provides component-specific fallback colors', () {
        final primaryColor = ColorParser.parseColor(null, component: 'primary');
        final backgroundColor = ColorParser.parseColor(null, component: 'background');

        expect(primaryColor, isNot(equals(backgroundColor)));
      });
    });

    group('Color Palette Validation', () {
      test('validates complete color palettes', () {
        final colors = {
          'primary': const Color(0xFF2563EB),
          'secondary': const Color(0xFF7C3AED),
          'background': const Color(0xFFFFFFFF),
          'surface': const Color(0xFFF8FAFC),
        };

        final validation = ColorParser.validateColorPalette(colors);
        expect(validation.containsKey('primaryContrast'), isTrue);
        expect(validation.containsKey('secondaryContrast'), isTrue);
      });

      test('handles incomplete color palettes', () {
        final colors = {
          'primary': const Color(0xFF2563EB),
        };

        final validation = ColorParser.validateColorPalette(colors);
        // Should not throw and should handle missing colors gracefully
        expect(validation, isA<Map<String, bool>>());
      });
    });

    group('Edge Cases', () {
      test('handles very dark colors correctly', () {
        const veryDark = Color(0xFF0A0A0A);
        final color = ColorParser.parseColor('#0A0A0A', component: 'test');
        expect(color, equals(veryDark));
      });

      test('handles very light colors correctly', () {
        const veryLight = Color(0xFFF5F5F5);
        final color = ColorParser.parseColor('#F5F5F5', component: 'test');
        expect(color, equals(veryLight));
      });

      test('handles transparent colors correctly', () {
        const transparent = Color(0x00FF5733);
        final color = ColorParser.parseColor('#00FF5733', component: 'test');
        expect(color, equals(transparent));
      });
    });
  });
}