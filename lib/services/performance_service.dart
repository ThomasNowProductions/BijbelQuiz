import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'logger.dart';

/// A service for monitoring and optimizing app performance on low-end devices
class PerformanceService {
  bool _isLowEndDevice = false;
  double _averageFrameRate = 60.0;
  final List<double> _frameRates = [];
  final List<double> _memoryUsage = [];
  Timer? _monitoringTimer;
  
  /// Whether the device is detected as low-end
  bool get isLowEndDevice => _isLowEndDevice;
  
  /// Current average frame rate
  double get averageFrameRate => _averageFrameRate;
  
  /// Initialize the performance service
  Future<void> initialize() async {
    await _detectDeviceCapabilities();
    AppLogger.info('PerformanceService initialized');
    _startMonitoring();
  }
  
  /// Detect if the device is low-end based on available resources
  Future<void> _detectDeviceCapabilities() async {
    try {
      // Skip platform-specific detection on web
      if (kIsWeb) {
        _isLowEndDevice = false; // Default to standard device on web
        AppLogger.info('Device capabilities: Web platform, Low-end: $_isLowEndDevice');
        return;
      }
      
      // Simple detection based on available memory and CPU cores
      final processorCount = Platform.numberOfProcessors;
      
      // Consider device low-end if it has limited resources
      _isLowEndDevice = processorCount <= 2; // Less than 2 CPU cores
      
      AppLogger.info('Device capabilities: CPU cores: $processorCount, Low-end: $_isLowEndDevice');
    } catch (e) {
      AppLogger.error('Error detecting device capabilities', e);
      _isLowEndDevice = false; // Default to standard device
    }
  }
  
  /// Start performance monitoring
  void _startMonitoring() {
    if (_isLowEndDevice) {
      _monitoringTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _checkMemoryUsage();
      });
    }
  }
  
  /// Check current memory usage
  void _checkMemoryUsage() {
    // Simplified memory tracking
    if (_memoryUsage.length > 20) {
      _memoryUsage.removeAt(0);
    }
    _memoryUsage.add(DateTime.now().millisecondsSinceEpoch.toDouble());
  }
  
  /// Get optimal animation duration based on device capabilities
  Duration getOptimalAnimationDuration(Duration defaultDuration) {
    if (_isLowEndDevice) {
      return Duration(milliseconds: (defaultDuration.inMilliseconds * 0.7).round());
    }
    return defaultDuration;
  }
  
  /// Get optimal timer duration based on device capabilities
  Duration getOptimalTimerDuration(Duration defaultDuration) {
    if (_isLowEndDevice) {
      return Duration(seconds: (defaultDuration.inSeconds * 1.2).round());
    }
    return defaultDuration;
  }
  
  /// Update frame rate (called from the app's frame callback)
  void updateFrameRate(double frameRate) {
    _frameRates.add(frameRate);
    if (_frameRates.length > 10) {
      _frameRates.removeAt(0);
    }
    
    if (_frameRates.isNotEmpty) {
      _averageFrameRate = _frameRates.reduce((a, b) => a + b) / _frameRates.length;
    }
  }
  
  /// Dispose of resources
  void dispose() {
    _monitoringTimer?.cancel();
    _frameRates.clear();
    _memoryUsage.clear();
  }
} 