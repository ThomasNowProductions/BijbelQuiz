import 'package:flutter/material.dart';
import '../services/error_reporting_service.dart';
import '../error/error_types.dart';
import '../services/logger.dart';
import '../providers/settings_provider.dart';

/// Utility class for automatic error reporting in specific app features
class AutomaticErrorReporter {
  /// Reports errors related to biblical reference functionality
  static Future<void> reportBiblicalReferenceError({
    required String message,
    required String reference,
    String? userMessage,
    String? questionId,
    Map<String, dynamic>? additionalInfo,
    BuildContext? context,
  }) async {
    try {
      // Check if automatic bug reporting is enabled
      final isEnabled = await SettingsProvider.isAutomaticBugReportingEnabled();
      if (!isEnabled) {
        AppLogger.info(
            'Automatic bug reporting is disabled, skipping biblical reference error report');
        return;
      }

      await ErrorReportingService().reportSimpleError(
        message: message,
        type:
            AppErrorType.api, // Most biblical reference issues are API related
        userMessage: userMessage ?? 'Biblical reference error',
        questionId: questionId,
        additionalInfo: {
          'feature': 'biblical_reference',
          'reference': reference,
          ...?additionalInfo,
        },
      );
    } catch (e) {
      // If error reporting itself fails, we just log it locally but don't break functionality
      AppLogger.warning('Failed to auto-report biblical reference error: $e');
    }
  }

  /// Reports errors related to question loading/data issues
  static Future<void> reportQuestionError({
    required String message,
    String? userMessage,
    required String questionId,
    String? questionText,
    Map<String, dynamic>? additionalInfo,
    BuildContext? context,
  }) async {
    try {
      // Check if automatic bug reporting is enabled
      final isEnabled = await SettingsProvider.isAutomaticBugReportingEnabled();
      if (!isEnabled) {
        AppLogger.info(
            'Automatic bug reporting is disabled, skipping question error report');
        return;
      }

      await ErrorReportingService().reportSimpleError(
        message: message,
        type: AppErrorType.dataLoading,
        userMessage: userMessage ?? 'Question data error',
        questionId: questionId,
        additionalInfo: {
          'feature': 'question_system',
          'question_text': questionText,
          ...?additionalInfo,
        },
      );
    } catch (e) {
      AppLogger.warning('Failed to auto-report question error: $e');
    }
  }

  /// Reports errors related to network/API functionality
  static Future<void> reportNetworkError({
    required String message,
    String? userMessage,
    String? url,
    int? statusCode,
    String? questionId,
    Map<String, dynamic>? additionalInfo,
    BuildContext? context,
  }) async {
    try {
      // Check if automatic bug reporting is enabled
      final isEnabled = await SettingsProvider.isAutomaticBugReportingEnabled();
      if (!isEnabled) {
        AppLogger.info(
            'Automatic bug reporting is disabled, skipping network error report');
        return;
      }

      await ErrorReportingService().reportSimpleError(
        message: message,
        type: AppErrorType.network,
        userMessage: userMessage ?? 'Network error',
        questionId: questionId,
        additionalInfo: {
          'feature': 'network',
          'url': url,
          'status_code': statusCode,
          ...?additionalInfo,
        },
      );
    } catch (e) {
      AppLogger.warning('Failed to auto-report network error: $e');
    }
  }

  /// Reports errors related to storage functionality
  static Future<void> reportStorageError({
    required String message,
    String? userMessage,
    String? operation,
    String? filePath,
    String? questionId,
    Map<String, dynamic>? additionalInfo,
    BuildContext? context,
  }) async {
    try {
      // Check if automatic bug reporting is enabled
      final isEnabled = await SettingsProvider.isAutomaticBugReportingEnabled();
      if (!isEnabled) {
        AppLogger.info(
            'Automatic bug reporting is disabled, skipping storage error report');
        return;
      }

      await ErrorReportingService().reportSimpleError(
        message: message,
        type: AppErrorType.storage,
        userMessage: userMessage ?? 'Storage error',
        questionId: questionId,
        additionalInfo: {
          'feature': 'storage',
          'operation': operation,
          'file_path': filePath,
          ...?additionalInfo,
        },
      );
    } catch (e) {
      AppLogger.warning('Failed to auto-report storage error: $e');
    }
  }

  /// Reports errors related to authentication functionality
  static Future<void> reportAuthenticationError({
    required String message,
    String? userMessage,
    String? operation,
    String? userId,
    Map<String, dynamic>? additionalInfo,
    BuildContext? context,
  }) async {
    try {
      // Check if automatic bug reporting is enabled
      final isEnabled = await SettingsProvider.isAutomaticBugReportingEnabled();
      if (!isEnabled) {
        AppLogger.info(
            'Automatic bug reporting is disabled, skipping authentication error report');
        return;
      }

      await ErrorReportingService().reportSimpleError(
        message: message,
        type: AppErrorType.network, // Most auth issues are network/API related
        userMessage: userMessage ?? 'Authentication error',
        additionalInfo: {
          'feature': 'authentication',
          'operation': operation,
          'user_id': userId,
          ...?additionalInfo,
        },
      );
    } catch (e) {
      AppLogger.warning('Failed to auto-report authentication error: $e');
    }
  }

  /// Reports errors related to sound/audio functionality
  static Future<void> reportAudioError({
    required String message,
    String? userMessage,
    String? soundType,
    String? filePath,
    Map<String, dynamic>? additionalInfo,
    BuildContext? context,
  }) async {
    try {
      // Check if automatic bug reporting is enabled
      final isEnabled = await SettingsProvider.isAutomaticBugReportingEnabled();
      if (!isEnabled) {
        AppLogger.info(
            'Automatic bug reporting is disabled, skipping audio error report');
        return;
      }

      await ErrorReportingService().reportSimpleError(
        message: message,
        type: AppErrorType.storage, // Audio issues are often file/storage related
        userMessage: userMessage ?? 'Audio error',
        additionalInfo: {
          'feature': 'audio',
          'sound_type': soundType,
          'file_path': filePath,
          ...?additionalInfo,
        },
      );
    } catch (e) {
      AppLogger.warning('Failed to auto-report audio error: $e');
    }
  }

  /// Reports errors related to animation functionality
  static Future<void> reportAnimationError({
    required String message,
    String? userMessage,
    String? animationType,
    String? controllerName,
    Map<String, dynamic>? additionalInfo,
    BuildContext? context,
  }) async {
    try {
      // Check if automatic bug reporting is enabled
      final isEnabled = await SettingsProvider.isAutomaticBugReportingEnabled();
      if (!isEnabled) {
        AppLogger.info(
            'Automatic bug reporting is disabled, skipping animation error report');
        return;
      }

      await ErrorReportingService().reportSimpleError(
        message: message,
        type: AppErrorType.unknown, // Animation errors are UI-related
        userMessage: userMessage ?? 'Animation error',
        additionalInfo: {
          'feature': 'animation',
          'animation_type': animationType,
          'controller_name': controllerName,
          ...?additionalInfo,
        },
      );
    } catch (e) {
      AppLogger.warning('Failed to auto-report animation error: $e');
    }
  }

  /// Reports errors related to performance monitoring
  static Future<void> reportPerformanceError({
    required String message,
    String? userMessage,
    String? metric,
    double? value,
    Map<String, dynamic>? additionalInfo,
    BuildContext? context,
  }) async {
    try {
      // Check if automatic bug reporting is enabled
      final isEnabled = await SettingsProvider.isAutomaticBugReportingEnabled();
      if (!isEnabled) {
        AppLogger.info(
            'Automatic bug reporting is disabled, skipping performance error report');
        return;
      }

      await ErrorReportingService().reportSimpleError(
        message: message,
        type: AppErrorType.unknown, // Performance issues are system-related
        userMessage: userMessage ?? 'Performance error',
        additionalInfo: {
          'feature': 'performance',
          'metric': metric,
          'value': value,
          ...?additionalInfo,
        },
      );
    } catch (e) {
      AppLogger.warning('Failed to auto-report performance error: $e');
    }
  }

  /// Reports errors related to connection monitoring
  static Future<void> reportConnectionError({
    required String message,
    String? userMessage,
    String? connectionType,
    bool? wasConnected,
    Map<String, dynamic>? additionalInfo,
    BuildContext? context,
  }) async {
    try {
      // Check if automatic bug reporting is enabled
      final isEnabled = await SettingsProvider.isAutomaticBugReportingEnabled();
      if (!isEnabled) {
        AppLogger.info(
            'Automatic bug reporting is disabled, skipping connection error report');
        return;
      }

      await ErrorReportingService().reportSimpleError(
        message: message,
        type: AppErrorType.network,
        userMessage: userMessage ?? 'Connection error',
        additionalInfo: {
          'feature': 'connection',
          'connection_type': connectionType,
          'was_connected': wasConnected,
          ...?additionalInfo,
        },
      );
    } catch (e) {
      AppLogger.warning('Failed to auto-report connection error: $e');
    }
  }

  /// Reports errors related to platform feedback functionality
  static Future<void> reportPlatformFeedbackError({
    required String message,
    String? userMessage,
    String? platform,
    String? feedbackType,
    Map<String, dynamic>? additionalInfo,
    BuildContext? context,
  }) async {
    try {
      // Check if automatic bug reporting is enabled
      final isEnabled = await SettingsProvider.isAutomaticBugReportingEnabled();
      if (!isEnabled) {
        AppLogger.info(
            'Automatic bug reporting is disabled, skipping platform feedback error report');
        return;
      }

      await ErrorReportingService().reportSimpleError(
        message: message,
        type: AppErrorType.unknown, // Platform feedback is UI-related
        userMessage: userMessage ?? 'Platform feedback error',
        additionalInfo: {
          'feature': 'platform_feedback',
          'platform': platform,
          'feedback_type': feedbackType,
          ...?additionalInfo,
        },
      );
    } catch (e) {
      AppLogger.warning('Failed to auto-report platform feedback error: $e');
    }
  }

  /// Reports errors related to UI rendering
  static Future<void> reportUIRenderingError({
    required String message,
    String? userMessage,
    String? widgetName,
    String? screenName,
    Map<String, dynamic>? additionalInfo,
    BuildContext? context,
  }) async {
    try {
      // Check if automatic bug reporting is enabled
      final isEnabled = await SettingsProvider.isAutomaticBugReportingEnabled();
      if (!isEnabled) {
        AppLogger.info(
            'Automatic bug reporting is disabled, skipping UI rendering error report');
        return;
      }

      await ErrorReportingService().reportSimpleError(
        message: message,
        type: AppErrorType.unknown, // UI errors are rendering-related
        userMessage: userMessage ?? 'UI rendering error',
        additionalInfo: {
          'feature': 'ui_rendering',
          'widget_name': widgetName,
          'screen_name': screenName,
          ...?additionalInfo,
        },
      );
    } catch (e) {
      AppLogger.warning('Failed to auto-report UI rendering error: $e');
    }
  }

  /// Reports errors related to provider/state management
  static Future<void> reportProviderError({
    required String message,
    String? userMessage,
    String? providerName,
    String? operation,
    Map<String, dynamic>? additionalInfo,
    BuildContext? context,
  }) async {
    try {
      // Check if automatic bug reporting is enabled
      final isEnabled = await SettingsProvider.isAutomaticBugReportingEnabled();
      if (!isEnabled) {
        AppLogger.info(
            'Automatic bug reporting is disabled, skipping provider error report');
        return;
      }

      await ErrorReportingService().reportSimpleError(
        message: message,
        type: AppErrorType.unknown, // Provider errors are state management related
        userMessage: userMessage ?? 'Provider error',
        additionalInfo: {
          'feature': 'provider',
          'provider_name': providerName,
          'operation': operation,
          ...?additionalInfo,
        },
      );
    } catch (e) {
      AppLogger.warning('Failed to auto-report provider error: $e');
    }
  }

  /// Reports errors related to theme loading
  static Future<void> reportThemeError({
    required String message,
    String? userMessage,
    String? themeName,
    String? operation,
    Map<String, dynamic>? additionalInfo,
    BuildContext? context,
  }) async {
    try {
      // Check if automatic bug reporting is enabled
      final isEnabled = await SettingsProvider.isAutomaticBugReportingEnabled();
      if (!isEnabled) {
        AppLogger.info(
            'Automatic bug reporting is disabled, skipping theme error report');
        return;
      }

      await ErrorReportingService().reportSimpleError(
        message: message,
        type: AppErrorType.storage, // Theme issues are often file/storage related
        userMessage: userMessage ?? 'Theme error',
        additionalInfo: {
          'feature': 'theme',
          'theme_name': themeName,
          'operation': operation,
          ...?additionalInfo,
        },
      );
    } catch (e) {
      AppLogger.warning('Failed to auto-report theme error: $e');
    }
  }

  /// Reports errors related to service initialization
  static Future<void> reportServiceInitializationError({
    required String message,
    String? userMessage,
    String? serviceName,
    String? initializationStep,
    Map<String, dynamic>? additionalInfo,
    BuildContext? context,
  }) async {
    try {
      // Check if automatic bug reporting is enabled
      final isEnabled = await SettingsProvider.isAutomaticBugReportingEnabled();
      if (!isEnabled) {
        AppLogger.info(
            'Automatic bug reporting is disabled, skipping service initialization error report');
        return;
      }

      await ErrorReportingService().reportSimpleError(
        message: message,
        type: AppErrorType.unknown, // Service initialization errors are system-related
        userMessage: userMessage ?? 'Service initialization error',
        additionalInfo: {
          'feature': 'service_initialization',
          'service_name': serviceName,
          'initialization_step': initializationStep,
          ...?additionalInfo,
        },
      );
    } catch (e) {
      AppLogger.warning('Failed to auto-report service initialization error: $e');
    }
  }
}
