import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'logger.dart';
import '../utils/color_parser.dart';
import '../utils/automatic_error_reporter.dart';

/// Configuration for Gemini API service via backend proxy
class GeminiConfig {
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
}

/// Model class for color palette responses
class ColorPalette {
  final String primary;
  final String secondary;
  final String tertiary;
  final String background;
  final String surface;
  final String onPrimary;
  final String onSecondary;
  final String onBackground;
  final String onSurface;

  const ColorPalette({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.surface,
    required this.onPrimary,
    required this.onSecondary,
    required this.onBackground,
    required this.onSurface,
  });

  factory ColorPalette.fromJson(Map<String, dynamic> json) {
    return ColorPalette(
      primary: json['primary'] as String? ?? '#2563EB',
      secondary: json['secondary'] as String? ?? '#7C3AED',
      tertiary: json['tertiary'] as String? ?? '#DC2626',
      background: json['background'] as String? ?? '#FFFFFF',
      surface: json['surface'] as String? ?? '#F8FAFC',
      onPrimary: json['onPrimary'] as String? ?? '#FFFFFF',
      onSecondary: json['onSecondary'] as String? ?? '#FFFFFF',
      onBackground: json['onBackground'] as String? ?? '#1F2937',
      onSurface: json['onSurface'] as String? ?? '#1F2937',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'secondary': secondary,
      'tertiary': tertiary,
      'background': background,
      'surface': surface,
      'onPrimary': onPrimary,
      'onSecondary': onSecondary,
      'onBackground': onBackground,
      'onSurface': onSurface,
    };
  }

  /// Creates a ColorPalette from parsed colors with validation
  factory ColorPalette.fromParsedColors(Map<String, Color> colors) {
    final onColors = ColorParser.generateOnColors(colors);

    return ColorPalette(
      primary:
          ColorParser.normalizeColorToHex(colors['primary'] ?? Colors.blue),
      secondary:
          ColorParser.normalizeColorToHex(colors['secondary'] ?? Colors.purple),
      tertiary:
          ColorParser.normalizeColorToHex(colors['tertiary'] ?? Colors.red),
      background:
          ColorParser.normalizeColorToHex(colors['background'] ?? Colors.white),
      surface: ColorParser.normalizeColorToHex(
          colors['surface'] ?? Colors.grey.shade50),
      onPrimary: ColorParser.normalizeColorToHex(
          onColors['onPrimary'] ?? Colors.white),
      onSecondary: ColorParser.normalizeColorToHex(
          onColors['onSecondary'] ?? Colors.white),
      onBackground: ColorParser.normalizeColorToHex(
          onColors['onBackground'] ?? Colors.black),
      onSurface: ColorParser.normalizeColorToHex(
          onColors['onSurface'] ?? Colors.black),
    );
  }
}

/// Model class for Gemini API error responses
class GeminiError implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  const GeminiError({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() =>
      'GeminiError: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// A service that provides an interface to the Gemini API through the secure backend proxy.
///
/// This service routes all requests through backend.bijbelquiz.app to keep API keys secure.
/// No API keys are stored or used in the client application.
class GeminiService {
  static GeminiService? _instance;
  late final http.Client _httpClient;
  bool _initialized = false;
  String? _backendUrl;
  String? _authToken;

  // Rate limiting
  DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(seconds: 1);

  /// Private constructor for singleton pattern
  GeminiService._internal() {
    _httpClient = http.Client();
  }

  /// Gets the singleton instance of the service
  static GeminiService get instance {
    _instance ??= GeminiService._internal();
    return _instance!;
  }

  /// Ensures the service is initialized before use
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// Checks if the service is properly initialized and ready to use
  bool get isInitialized => _initialized;

  /// Gets the current initialization status of the service
  /// Returns true if the service is ready to use, false otherwise
  bool get isReady => _initialized && _backendUrl != null;

  /// Gets the HTTP client for external access
  http.Client get httpClient => _httpClient;

  /// Gets the backend URL
  String? get backendUrl => _backendUrl;

  /// Sets the authentication token for API requests
  void setAuthToken(String? token) {
    _authToken = token;
    AppLogger.info(_authToken != null ? 'Auth token set' : 'Auth token cleared');
  }

  /// Initializes the Gemini service via backend proxy
  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing Gemini service via backend proxy...');

      // Load backend URL from environment
      String? envBackendUrl = dotenv.env['BACKEND_URL'];
      
      if (envBackendUrl == null || envBackendUrl.isEmpty) {
        // Fallback to default production URL
        envBackendUrl = 'https://backend.bijbelquiz.app';
        AppLogger.info('Using default backend URL: $envBackendUrl');
      } else {
        AppLogger.info('Backend URL loaded from environment: $envBackendUrl');
      }

      _backendUrl = envBackendUrl;
      _initialized = true;
      AppLogger.info('Gemini service initialized successfully via backend proxy');
    } catch (e) {
      AppLogger.error('Failed to initialize Gemini service', e);
      _initialized = false;
      rethrow;
    }
  }

  /// Generates a color palette based on the provided text description
  ///
  /// [description] - A text description of the desired theme (e.g., "ocean sunset", "forest morning")
  /// Returns a [ColorPalette] with hex color codes for different UI elements
  Future<ColorPalette> generateColorsFromText(String description) async {
    if (description.trim().isEmpty) {
      throw const GeminiError(message: 'Description cannot be empty');
    }

    // Ensure service is initialized before making API calls
    try {
      await _ensureInitialized();
    } catch (e) {
      AppLogger.error('Gemini service initialization failed', e);
      if (e is GeminiError) {
        throw GeminiError(
          message:
              'Failed to initialize Gemini service: ${e.message}. Please check your configuration.',
          statusCode: e.statusCode,
          errorCode: e.errorCode,
        );
      } else {
        throw const GeminiError(
          message:
              'Failed to initialize Gemini service. Please check your configuration.',
        );
      }
    }

    // Double-check that we're properly initialized
    if (!_initialized || _backendUrl == null) {
      throw const GeminiError(
        message:
            'Gemini service is not properly configured. Please check your BACKEND_URL configuration.',
      );
    }

    await _ensureRateLimit();

    AppLogger.info('Generating color palette via backend proxy: $description');

    try {
      final response = await _makeProxyRequest(description);

      if (response.statusCode == 200) {
        final colorPalette = await _parseResponse(response.body);
        AppLogger.info('Successfully generated color palette via proxy');
        return colorPalette;
      } else {
        throw await _handleErrorResponse(response);
      }
    } catch (e) {
      AppLogger.error('Failed to generate color palette via proxy', e);

      // Report error to automatic error tracking system
      await AutomaticErrorReporter.reportNetworkError(
        message: 'Failed to generate color palette via backend proxy',
        url: '$_backendUrl/api/gemini',
        additionalInfo: {
          'description': description,
          'error': e.toString(),
          'operation': 'color_palette_generation',
          'service_initialized': _initialized,
        },
      );

      rethrow;
    }
  }

  /// Ensures requests respect rate limiting
  Future<void> _ensureRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final delay = _minRequestInterval - timeSinceLastRequest;
        AppLogger.info('Rate limiting: waiting ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// Makes the HTTP request to the backend proxy
  Future<http.Response> _makeProxyRequest(String description) async {
    final url = Uri.parse('$_backendUrl/api/gemini');

    final requestBody = json.encode({
      'description': description,
      'temperature': 0.7,
      'maxOutputTokens': 2048,
    });

    AppLogger.info('Making request to Gemini proxy API');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Add auth token if available
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    for (int attempt = 1; attempt <= GeminiConfig.maxRetries; attempt++) {
      try {
        final response = await _httpClient
            .post(
              url,
              headers: headers,
              body: requestBody,
            )
            .timeout(GeminiConfig.requestTimeout);

        if (response.statusCode == 200) {
          return response;
        } else if (response.statusCode == 429 &&
            attempt < GeminiConfig.maxRetries) {
          // Rate limited by backend, wait and retry
          final delay = GeminiConfig.retryDelay * attempt;
          AppLogger.warning(
              'Rate limited by backend, retrying in ${delay.inSeconds}s (attempt $attempt)');
          await Future.delayed(delay);
          continue;
        } else {
          return response;
        }
      } catch (e) {
        if (attempt == GeminiConfig.maxRetries) {
          throw GeminiError(
            message: 'Network request failed after $attempt attempts: $e',
          );
        }
        AppLogger.warning('Request attempt $attempt failed: $e');
        await Future.delayed(GeminiConfig.retryDelay * attempt);
      }
    }

    throw const GeminiError(message: 'All retry attempts exhausted');
  }

  /// Parses the API response to extract color information
  Future<ColorPalette> _parseResponse(String responseBody) async {
    try {
      final Map<String, dynamic> response = json.decode(responseBody);

      // Check for API errors from backend
      if (response['success'] == false) {
        final error = response['error'] as Map<String, dynamic>?;
        throw GeminiError(
          message: error?['message'] ?? 'Unknown API error',
          statusCode: error?['statusCode'],
          errorCode: error?['code'],
        );
      }

      // Extract palette from successful response
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const GeminiError(message: 'No data in response');
      }

      final paletteJson = data['palette'] as Map<String, dynamic>?;
      if (paletteJson == null) {
        throw const GeminiError(message: 'No palette in response data');
      }

      final palette = ColorPalette.fromJson(paletteJson);

      // Validate accessibility compliance
      final colors = <String, Color>{
        'primary': ColorParser.parseColor(palette.primary) ?? Colors.blue,
        'secondary': ColorParser.parseColor(palette.secondary) ?? Colors.purple,
        'tertiary': ColorParser.parseColor(palette.tertiary) ?? Colors.red,
        'background': ColorParser.parseColor(palette.background) ?? Colors.white,
        'surface': ColorParser.parseColor(palette.surface) ?? Colors.grey.shade50,
      };

      final validation = ColorParser.validateColorPalette(colors);

      // Log any accessibility issues
      if (!validation.values.every((isValid) => isValid)) {
        AppLogger.warning('Color palette may not meet accessibility standards');
        validation.forEach((component, isValid) {
          if (!isValid) {
            AppLogger.warning('Accessibility issue: $component');
          }
        });
      }

      return palette;
    } on GeminiError {
      rethrow;
    } catch (e) {
      AppLogger.error(
          'Failed to parse API response, using fallback colors: $e');

      // Return a palette with fallback colors if parsing fails
      final fallbackColors = ColorParser.getFallbackColorPalette();
      return ColorPalette.fromParsedColors(fallbackColors);
    }
  }

  /// Handles error responses from the API
  Future<GeminiError> _handleErrorResponse(http.Response response) async {
    try {
      final Map<String, dynamic> body = json.decode(response.body);
      final error = body['error'] as Map<String, dynamic>?;

      return GeminiError(
        message: error?['message'] ?? 'Unknown API error',
        statusCode: response.statusCode,
        errorCode: error?['code'],
      );
    } catch (e) {
      return GeminiError(
        message: 'HTTP ${response.statusCode}: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Disposes of resources used by the service
  void dispose() {
    _httpClient.close();
    _instance = null;
    AppLogger.info('Gemini service disposed');
  }
}