import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'logger.dart';
import '../utils/automatic_error_reporter.dart';

/// A service for monitoring network connectivity and optimizing for poor connections
class ConnectionService {
  static const Duration _connectionTimeout = Duration(seconds: 5);
  static const Duration _retryDelay = Duration(seconds: 2);
  static const int _maxRetries = 3;

  bool _isConnected = true;
  bool _isSlowConnection = false;
  ConnectionType _connectionType = ConnectionType.unknown;
  Timer? _connectionCheckTimer;
  final List<ConnectionStatus> _connectionHistory = [];
  static bool disableTimersForTest = false;
  Function(bool isConnected, ConnectionType connectionType)?
      _onConnectionStatusChanged;

  /// Whether the device is currently connected to the internet
  bool get isConnected => _isConnected;

  /// Whether the connection is slow
  bool get isSlowConnection => _isSlowConnection;

  /// The current connection type
  ConnectionType get connectionType => _connectionType;

  /// Whether to use offline mode
  bool get shouldUseOfflineMode => !_isConnected || _isSlowConnection;

  /// Whether we're connected to WiFi
  bool get isWiFiConnected => _connectionType == ConnectionType.fast;

  /// Initialize the connection service
  Future<void> initialize() async {
    if (disableTimersForTest) return;

    try {
      // Skip connection checking on web for now
      if (kIsWeb) {
        _isConnected = true;
        _connectionType = ConnectionType.fast;
        _isSlowConnection = false;
        AppLogger.info('Connection service initialized for web platform');
        return;
      }

      await _checkConnection();
      _startConnectionMonitoring();
    } catch (e) {
      // Report error to automatic error tracking system
      await AutomaticErrorReporter.reportServiceInitializationError(
        message: 'Failed to initialize connection service: ${e.toString()}',
        serviceName: 'ConnectionService',
        initializationStep: 'connection_check_and_monitoring',
      );
      AppLogger.error('Error initializing ConnectionService', e);
      // Continue with default disconnected state
      _isConnected = false;
      _connectionType = ConnectionType.none;
    }
  }

  /// Check current connection status
  Future<void> _checkConnection() async {
    final previousConnectionState = _isConnected;
    final previousConnectionType = _connectionType;

    try {
      // Use connectivity_plus to check connection type
      // On some Linux environments, this might fail with DBus errors.
      // We catch this specific error and fallback to pinging.
      ConnectivityResult connectivityResult = ConnectivityResult.none;
      try {
        final connectivityResults = await (Connectivity().checkConnectivity());
        connectivityResult = connectivityResults.isNotEmpty
            ? connectivityResults.first
            : ConnectivityResult.none;
      } catch (e) {
        // This is a common issue on some Linux environments (DBus error).
        // We log it as debug to avoid spamming the user, as we have a fallback.
        AppLogger.debug(
            'Connectivity platform check failed (likely DBus error), falling back to ping: $e');
        // Default to wifi/ethernet assumption if we can't check, but rely on ping to confirm
        connectivityResult = ConnectivityResult.wifi;
      }

      if (connectivityResult == ConnectivityResult.none) {
        // Even if platform says none, we might want to double check with ping if we suspect platform issues?
        // But usually 'none' is reliable. The issue is when it throws.
        _isConnected = false;
        _connectionType = ConnectionType.none;
        AppLogger.info(
            'Connection checked: not connected (platform reported none)');
      } else {
        // Test connection with a simple ping
        try {
          final result = await InternetAddress.lookup('google.com')
              .timeout(const Duration(seconds: 2));

          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            _isConnected = true;

            // Determine connection type based on connectivity result
            if (connectivityResult == ConnectivityResult.wifi ||
                connectivityResult == ConnectivityResult.ethernet) {
              _connectionType = ConnectionType.fast;
              _isSlowConnection = false;
            } else {
              await _determineConnectionType();
            }
            AppLogger.info(
                'Connection checked: connected via ${connectivityResult.toString()}');
          } else {
            _isConnected = false;
            _connectionType = ConnectionType.none;
            AppLogger.info('Connection checked: not connected (ping failed)');
          }
        } catch (e) {
          _isConnected = false;
          _connectionType = ConnectionType.none;
          AppLogger.info(
              'Connection checked: not connected (ping threw exception)');
        }
      }
    } catch (e) {
      // This outer catch block handles unexpected errors in the flow
      // But we should try to assume connected if it was just a logic error?
      // No, safest is to assume disconnected if everything blows up, but we tried to handle the DBus one above.
      _isConnected = false;
      _connectionType = ConnectionType.none;
      AppLogger.error('Error checking connection', e);
    }

    _recordConnectionStatus();

    // Track connection status changes if state changed
    if (previousConnectionState != _isConnected ||
        previousConnectionType != _connectionType) {
      // Note: This would need to be called from a widget that has access to BuildContext
      // For now, we'll add a callback mechanism
      _onConnectionStatusChanged?.call(_isConnected, _connectionType);
    }
  }

  /// Determine connection type and speed
  Future<void> _determineConnectionType() async {
    try {
      // Simple speed test by timing a small request
      final stopwatch = Stopwatch()..start();

      final socket = await Socket.connect('google.com', 80)
          .timeout(const Duration(seconds: 1));
      await socket.close();

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds;

      if (responseTime < 100) {
        _connectionType = ConnectionType.fast;
        _isSlowConnection = false;
      } else if (responseTime < 500) {
        _connectionType = ConnectionType.moderate;
        _isSlowConnection = false;
      } else {
        _connectionType = ConnectionType.slow;
        _isSlowConnection = true;
      }
    } catch (e) {
      _connectionType = ConnectionType.slow;
      _isSlowConnection = true;
    }
  }

  /// Start periodic connection monitoring
  void _startConnectionMonitoring() {
    if (disableTimersForTest) return;
    _connectionCheckTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _checkConnection();
    });
  }

  /// Record connection status for analytics
  void _recordConnectionStatus() {
    final status = ConnectionStatus(
      timestamp: DateTime.now(),
      isConnected: _isConnected,
      connectionType: _connectionType,
      isSlow: _isSlowConnection,
    );

    _connectionHistory.add(status);

    // Keep only last 10 status records
    if (_connectionHistory.length > 10) {
      _connectionHistory.removeAt(0);
    }
  }

  /// Set callback for connection status changes
  void setConnectionStatusCallback(
      Function(bool isConnected, ConnectionType connectionType)? callback) {
    _onConnectionStatusChanged = callback;
  }

  /// Execute a network request with connection-aware retry logic
  Future<T> executeWithRetry<T>(
    Future<T> Function() request, {
    int maxRetries = _maxRetries,
    Duration? retryDelay,
  }) async {
    int attempts = 0;
    final delay = retryDelay ?? _retryDelay;

    while (attempts < maxRetries) {
      try {
        if (!_isConnected) {
          throw Exception('No internet connection');
        }

        return await request().timeout(_getOptimalTimeout());
      } catch (e) {
        attempts++;

        if (attempts >= maxRetries) {
          rethrow;
        }

        // Wait before retrying, with exponential backoff
        await Future.delayed(delay * attempts);

        // Re-check connection before retry
        await _checkConnection();
      }
    }

    throw Exception('Max retries exceeded');
  }

  /// Get optimal timeout based on connection type
  Duration _getOptimalTimeout() {
    switch (_connectionType) {
      case ConnectionType.fast:
        return const Duration(seconds: 10);
      case ConnectionType.moderate:
        return const Duration(seconds: 15);
      case ConnectionType.slow:
        return const Duration(seconds: 30);
      case ConnectionType.none:
      case ConnectionType.unknown:
        return const Duration(seconds: 5);
    }
  }

  /// Get connection recommendations
  Map<String, dynamic> getConnectionRecommendations() {
    return {
      'useOfflineMode': shouldUseOfflineMode,
      'reduceDataUsage': _isSlowConnection,
      'cacheData': _isSlowConnection || !_isConnected,
      'connectionQuality': _connectionType.toString(),
      'retryFailedRequests': _isConnected && !_isSlowConnection,
    };
  }

  /// Returns connection statistics as a map
  Map<String, dynamic> getConnectionStats() {
    if (_connectionHistory.isEmpty) {
      return {
        'totalChecks': 0,
        'successfulConnections': 0,
        'failedConnections': 0,
        'averageResponseTime': 0,
      };
    }

    final successful = _connectionHistory.where((s) => s.isConnected).length;
    final failed = _connectionHistory.where((s) => !s.isConnected).length;

    return {
      'totalChecks': _connectionHistory.length,
      'successfulConnections': successful,
      'failedConnections': failed,
      'successRate': successful / _connectionHistory.length,
      'currentStatus': _isConnected ? 'connected' : 'disconnected',
      'connectionType': _connectionType.toString(),
    };
  }

  /// Force a connection check
  Future<void> checkConnection() async {
    await _checkConnection();
  }

  /// Dispose of resources
  void dispose() {
    _connectionCheckTimer?.cancel();
    _connectionHistory.clear();
  }
}

/// Connection type enumeration
///
/// Represents the type of network connection detected.
enum ConnectionType {
  fast,
  moderate,
  slow,
  none,
  unknown,
}

/// Connection status record
///
/// Holds information about a single connection check event.
class ConnectionStatus {
  final DateTime timestamp;
  final bool isConnected;
  final ConnectionType connectionType;
  final bool isSlow;

  /// Creates a new [ConnectionStatus] record.
  ConnectionStatus({
    required this.timestamp,
    required this.isConnected,
    required this.connectionType,
    required this.isSlow,
  });
}
