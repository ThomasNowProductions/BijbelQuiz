import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:bijbelquiz/services/logger.dart';

/// Test to verify that the themes JSON is valid and can be loaded
void main() async {
  try {
    // Load and verify the themes JSON file
    final String jsonString = await rootBundle.loadString('assets/themes/themes.json');
    final Map<String, dynamic> json = jsonDecode(jsonString);
    
    AppLogger.info('✓ Themes JSON loaded successfully');
    AppLogger.info('✓ Found ${json['themes'].length} themes:');

    final themes = json['themes'] as Map<String, dynamic>;
    for (final entry in themes.entries) {
      AppLogger.info('  - ${entry.key}: ${entry.value['name']} (${entry.value['type']} theme)');
    }

    AppLogger.info('\n✓ Centralized theme system is ready!');
    AppLogger.info('✓ You can now add/remove themes by just updating assets/themes/themes.json');
  } catch (e) {
    AppLogger.error('✗ Error loading themes: $e');
  }
}