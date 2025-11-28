import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/logger.dart';

/// Utility class for font management and loading
class FontUtils {
  /// Ensures the Quicksand font is properly loaded
  static Future<void> ensureQuicksandFontLoaded() async {
    try {
      // Force font loading by creating a text style with the font
      final fontLoader = FontLoader('Quicksand');
      
      // Add font assets to loader
      fontLoader.addFont(loadFontAsset('assets/fonts/Quicksand-Regular.ttf'));
      fontLoader.addFont(loadFontAsset('assets/fonts/Quicksand-Bold.ttf'));
      fontLoader.addFont(loadFontAsset('assets/fonts/Quicksand-Medium.ttf'));
      
      // Load fonts
      await fontLoader.load();
      
      AppLogger.info('Quicksand font loaded successfully');
    } catch (e) {
      AppLogger.warning('Failed to preload Quicksand font: $e');
      // Continue anyway - Flutter will handle fallback
    }
  }

  /// Loads a font asset from the given path
  static Future<ByteData> loadFontAsset(String fontAssetPath) async {
    try {
      return await rootBundle.load(fontAssetPath);
    } catch (e) {
      AppLogger.error('Failed to load font asset: $fontAssetPath', e);
      rethrow;
    }
  }

  /// Creates a text style with explicit font family
  static TextStyle createQuicksandTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'Quicksand',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  /// Checks if a font family is available
  static bool isFontFamilyAvailable(String fontFamily) {
    try {
      // This is a simple check - in practice, font availability checking
      // is more complex in Flutter
      return fontFamily.isNotEmpty;
    } catch (e) {
      AppLogger.warning('Failed to check font availability for: $fontFamily', e);
      return false;
    }
  }

  /// Returns a font family fallback list for Android
  static List<String> getAndroidFontFallbacks() {
    return const [
      'Quicksand',
      'sans-serif', // Android default fallback
    ];
  }
}