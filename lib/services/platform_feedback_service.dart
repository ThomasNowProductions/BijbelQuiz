import 'dart:io';
import 'package:flutter/foundation.dart';
import 'logger.dart';

/// A service for managing platform-specific visual feedback durations
/// to ensure consistent user experience across Android and Linux platforms.
class PlatformFeedbackService {
  static const int _standardFeedbackDuration = 650; // Base duration in milliseconds
  static const int _slowModeFeedbackDuration = 950; // Slow mode duration in milliseconds
  
  /// Platform-specific timing adjustments to normalize visual feedback
  static const Map<String, double> _platformMultipliers = {
    'android': 1.0,    // Android baseline
    'linux': 0.85,    // Linux tends to show feedback longer, so reduce it
    'web': 1.0,       // Web baseline
    'ios': 1.0,       // iOS baseline
    'macos': 0.9,     // macOS similar to Linux
    'windows': 1.0,   // Windows baseline
  };
  
  late String _currentPlatform;
  late double _platformMultiplier;
  
  /// Initialize the platform feedback service
  Future<void> initialize() async {
    _detectPlatform();
    AppLogger.info('PlatformFeedbackService initialized for $_currentPlatform with multiplier $_platformMultiplier');
  }
  
  /// Detect the current platform and set appropriate multiplier
  void _detectPlatform() {
    if (kIsWeb) {
      _currentPlatform = 'web';
    } else {
      _currentPlatform = Platform.operatingSystem.toLowerCase();
    }
    
    _platformMultiplier = _platformMultipliers[_currentPlatform] ?? 1.0;
    
    AppLogger.info('Platform detected: $_currentPlatform, feedback multiplier: $_platformMultiplier');
  }
  
  /// Get the standardized feedback duration for the current platform
  /// 
  /// This method ensures that red/green color feedback appears for exactly
  /// the same perceived duration across all platforms by applying platform-specific
  /// timing adjustments.
  Duration getStandardizedFeedbackDuration({bool slowMode = false}) {
    final baseDuration = slowMode ? _slowModeFeedbackDuration : _standardFeedbackDuration;
    final adjustedDuration = (baseDuration * _platformMultiplier).round();
    
    AppLogger.debug('Feedback duration: base=$baseDuration, adjusted=$adjustedDuration (platform: $_currentPlatform)');
    
    return Duration(milliseconds: adjustedDuration);
  }
  
  /// Get platform-specific transition pause duration
  /// 
  /// Some platforms may need slightly different transition timing
  /// to maintain smooth visual flow.
  Duration getTransitionPauseDuration() {
    const basePause = 300; // milliseconds
    final adjustedPause = (basePause * _platformMultiplier).round();
    
    return Duration(milliseconds: adjustedPause);
  }
  
  /// Get information about current platform settings
  Map<String, dynamic> getPlatformInfo() {
    return {
      'platform': _currentPlatform,
      'multiplier': _platformMultiplier,
      'standardDuration': getStandardizedFeedbackDuration().inMilliseconds,
      'slowModeDuration': getStandardizedFeedbackDuration(slowMode: true).inMilliseconds,
    };
  }
  
  /// Check if the current platform tends to show feedback longer
  bool get platformShowsLongerFeedback => _platformMultiplier < 1.0;
  
  /// Check if the current platform tends to show feedback shorter
  bool get platformShowsShorterFeedback => _platformMultiplier > 1.0;
}