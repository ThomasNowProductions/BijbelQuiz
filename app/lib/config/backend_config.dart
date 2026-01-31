import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/logger.dart';

/// Configuration for the BijbelQuiz Backend API Proxy
///
/// This class manages the configuration for routing API requests through
/// the secure backend proxy at backend.bijbelquiz.app
class BackendConfig {
  static String? _baseUrl;
  static String? _authToken;
  static bool _initialized = false;
  static bool _isExplicitlyConfigured = false;
  
  /// Default production backend URL
  static const String defaultBackendUrl = 'https://backend.bijbelquiz.app';

  /// Backend base URL
  static String get baseUrl {
    if (_baseUrl != null) return _baseUrl!;
    
    // Try to load from environment
    final envUrl = dotenv.env['BACKEND_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Default production URL
    return defaultBackendUrl;
  }

  /// Check if backend is explicitly configured (not just using defaults)
  static bool get isConfigured => _isExplicitlyConfigured;

  /// Gemini API endpoint
  static String get geminiEndpoint => '$baseUrl/api/gemini';

  /// Supabase API endpoint
  static String get supabaseEndpoint => '$baseUrl/api/supabase';

  /// PostHog API endpoint
  static String get posthogEndpoint => '$baseUrl/api/posthog';

  /// Health check endpoint
  static String get healthEndpoint => '$baseUrl/api/health';

  /// Initialize the backend configuration
  static Future<void> initialize() async {
    if (_initialized) return;

    AppLogger.info('Initializing Backend configuration...');

    // Load from environment variables
    _baseUrl = dotenv.env['BACKEND_URL'];
    
    if (_baseUrl == null || _baseUrl!.isEmpty) {
      AppLogger.warning('BACKEND_URL not set in environment, using default');
      _baseUrl = defaultBackendUrl;
    } else {
      // Mark as explicitly configured when URL comes from environment
      _isExplicitlyConfigured = true;
    }

    AppLogger.info('Backend URL configured: $_baseUrl');
    _initialized = true;
  }
  
  /// Reset configuration for testing purposes
  @visibleForTesting
  static void reset() {
    _baseUrl = null;
    _authToken = null;
    _initialized = false;
    _isExplicitlyConfigured = false;
  }

  /// Set the authentication token for API requests
  static void setAuthToken(String? token) {
    _authToken = token;
    AppLogger.info(token != null 
      ? 'Auth token set' 
      : 'Auth token cleared');
  }

  /// Get the current authentication token
  static Future<String?> getAuthToken() async {
    // Return cached token if available
    if (_authToken != null) return _authToken;
    
    // Otherwise, try to get from secure storage or Supabase auth
    // This would typically integrate with your auth service
    return null;
  }

  /// Clear the authentication token
  static void clearAuthToken() {
    _authToken = null;
    AppLogger.info('Auth token cleared');
  }

  /// Check backend health
  ///
  /// Note: This method is not yet fully implemented. It currently throws
  /// [UnimplementedError] to indicate that a real health check should be
  /// implemented using an HTTP GET to the backend health endpoint.
  static Future<bool> checkHealth() async {
    throw UnimplementedError(
      'Health check is not implemented. '
      'Implement by making an HTTP GET request to $healthEndpoint '
      'and returning true only on a successful 200 response.'
    );
  }
}