import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/platform_feedback_service.dart';
import '../services/logger.dart';

/// Demo script to showcase platform-specific feedback timing standardization
class FeedbackTimingDemo {
  static Future<void> demonstratePlatformTiming() async {
    final service = PlatformFeedbackService();
    await service.initialize();
    
    final info = service.getPlatformInfo();
    final platform = kIsWeb ? 'web' : Platform.operatingSystem.toLowerCase();
    
    print('\n=== BijbelQuiz Platform Feedback Timing Demo ===');
    print('Current Platform: $platform');
    print('Platform Multiplier: ${info['multiplier']}');
    print('');
    
    // Show timing comparisons
    print('Feedback Duration Comparison:');
    print('├─ Standard Mode: ${info['standardDuration']}ms');
    print('├─ Slow Mode: ${info['slowModeDuration']}ms');
    print('└─ Transition Pause: ${service.getTransitionPauseDuration().inMilliseconds}ms');
    print('');
    
    // Show platform-specific adjustments
    print('Platform-Specific Adjustments:');
    if (service.platformShowsLongerFeedback) {
      print('├─ This platform tends to show feedback longer');
      print('└─ Duration reduced by ${((1.0 - info['multiplier'] as double) * 100).toStringAsFixed(1)}% for consistency');
    } else if (service.platformShowsShorterFeedback) {
      print('├─ This platform tends to show feedback shorter');
      print('└─ Duration increased by ${(((info['multiplier'] as double) - 1.0) * 100).toStringAsFixed(1)}% for consistency');
    } else {
      print('└─ This platform uses baseline timing (no adjustment needed)');
    }
    print('');
    
    // Simulate timing differences across platforms
    print('Cross-Platform Timing Simulation:');
    final platforms = ['android', 'linux', 'web', 'ios', 'macos', 'windows'];
    final multipliers = {
      'android': 1.0,
      'linux': 0.85,
      'web': 1.0,
      'ios': 1.0,
      'macos': 0.9,
      'windows': 1.0,
    };
    
    for (final platform in platforms) {
      final multiplier = multipliers[platform] ?? 1.0;
      final standardDuration = (650 * multiplier).round();
      final slowDuration = (950 * multiplier).round();
      
      print('├─ $platform: ${standardDuration}ms / ${slowDuration}ms (slow)');
    }
    
    print('');
    print('Result: All platforms now show red/green feedback for the same perceived duration!');
    print('=== Demo Complete ===\n');
  }
}