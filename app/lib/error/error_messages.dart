import 'package:flutter/material.dart';
import 'package:bijbelquiz/l10n/app_localizations.dart';

/// Utility class that provides standardized error messages for common scenarios
class ErrorMessages {
  /// Helper method to get localized strings
  static AppLocalizations _l10n(BuildContext context) =>
      AppLocalizations.of(context)!;

  /// Gets a standardized network error message
  static String getNetworkError(BuildContext context) {
    return _l10n(context).connectionError;
  }

  /// Gets a standardized data loading error message
  static String getDataLoadingError(BuildContext context) {
    return _l10n(context).errorLoadQuestions;
  }

  /// Gets a standardized payment error message
  static String getPaymentError(BuildContext context) {
    return _l10n(context).purchaseError;
  }

  /// Gets a standardized AI error message
  static String getAiError(BuildContext context) {
    return _l10n(context).aiError;
  }

  /// Gets a standardized validation error message
  static String getValidationError(String fieldName) {
    return 'Invalid $fieldName. Please enter a valid value.';
  }

  /// Gets a standardized permission error message
  static String getPermissionError(BuildContext context) {
    return _l10n(context).permissionDenied;
  }

  /// Gets a standardized unknown error message
  static String getUnknownError(BuildContext context) {
    return _l10n(context).unknownError;
  }

  /// Gets a standardized sync error message
  static String getSyncError(BuildContext context) {
    return _l10n(context).syncError;
  }

  /// Gets a standardized storage error message
  static String getStorageError(BuildContext context) {
    return _l10n(context).storageError;
  }

  /// Gets a standardized API error message
  static String getApiError(BuildContext context) {
    return _l10n(context).apiError;
  }
}
