import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_key.dart';
import '../utils/automatic_error_reporter.dart';

/// Service to manage API keys for the application
class ApiKeyManager {
  static const String _storageKey = 'api_keys';

  /// Generates a new API key with secure randomness
  static String generateApiKey() {
    final randomBytes = List<int>.generate(32, (i) => i);
    // This is a placeholder implementation. In a real scenario, 
    // you'd use a crypto library to generate a proper random key
    final encoded = base64Encode(randomBytes.take(32).toList());
    // Remove problematic characters and ensure key is URL-safe
    return encoded.replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
  }

  /// Stores a new API key in shared preferences
  Future<bool> saveApiKey(ApiKey apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingKeys = await getAllApiKeys();
      
      // Check if the key already exists
      final existingIndex = existingKeys.indexWhere((k) => k.id == apiKey.id);
      if (existingIndex != -1) {
        // Update existing key
        existingKeys[existingIndex] = apiKey;
      } else {
        // Add new key
        existingKeys.add(apiKey);
      }
      
      final jsonList = existingKeys.map((key) => key.toJson()).toList();
      return await prefs.setStringList(_storageKey, 
          jsonList.map((map) => jsonEncode(map)).toList());
    } catch (e) {
      AutomaticErrorReporter.reportStorageError(
        message: 'Error saving API key: $e',
        additionalInfo: {
          'api_key_id': apiKey.id,
          'api_key_name': apiKey.name,
        }
      );
      return false;
    }
  }

  /// Retrieves all stored API keys
  Future<List<ApiKey>> getAllApiKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStringList = prefs.getStringList(_storageKey) ?? [];
      
      return jsonStringList
          .map((jsonString) => ApiKey.fromJson(jsonDecode(jsonString)))
          .toList();
    } catch (e) {
      AutomaticErrorReporter.reportStorageError(
        message: 'Error retrieving API keys: $e',
        additionalInfo: {
          'operation': 'getAllApiKeys',
        }
      );
      return [];
    }
  }

  /// Deletes an API key by ID
  Future<bool> deleteApiKey(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingKeys = await getAllApiKeys();
      
      final updatedKeys = existingKeys.where((key) => key.id != id).toList();
      final jsonList = updatedKeys.map((key) => key.toJson()).toList();
      
      return await prefs.setStringList(_storageKey, 
          jsonList.map((map) => jsonEncode(map)).toList());
    } catch (e) {
      AutomaticErrorReporter.reportStorageError(
        message: 'Error deleting API key: $e',
        additionalInfo: {
          'api_key_id': id,
        }
      );
      return false;
    }
  }

  /// Updates an existing API key
  Future<bool> updateApiKey(ApiKey updatedKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingKeys = await getAllApiKeys();
      
      final index = existingKeys.indexWhere((key) => key.id == updatedKey.id);
      if (index != -1) {
        existingKeys[index] = updatedKey;
        
        final jsonList = existingKeys.map((key) => key.toJson()).toList();
        return await prefs.setStringList(_storageKey, 
            jsonList.map((map) => jsonEncode(map)).toList());
      } else {
        return false; // Key not found
      }
    } catch (e) {
      AutomaticErrorReporter.reportStorageError(
        message: 'Error updating API key: $e',
        additionalInfo: {
          'api_key_id': updatedKey.id,
          'api_key_name': updatedKey.name,
        }
      );
      return false;
    }
  }

  /// Finds an API key by ID
  Future<ApiKey?> getApiKeyById(String id) async {
    final allKeys = await getAllApiKeys();
    try {
      return allKeys.firstWhere((key) => key.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Finds an API key by its value
  Future<ApiKey?> findApiKey(String keyValue) async {
    final allKeys = await getAllApiKeys();
    try {
      return allKeys.firstWhere((key) => key.key == keyValue);
    } catch (e) {
      return null;
    }
  }

  /// Revokes (sets as inactive) an API key by ID
  Future<bool> revokeApiKey(String id) async {
    try {
      final apiKey = await getApiKeyById(id);
      if (apiKey != null) {
        final updatedKey = apiKey.copyWith(isActive: false);
        return await updateApiKey(updatedKey);
      }
      return false;
    } catch (e) {
      AutomaticErrorReporter.reportStorageError(
        message: 'Error revoking API key: $e',
        additionalInfo: {
          'api_key_id': id,
        }
      );
      return false;
    }
  }

  /// Re-enables an API key that was previously revoked
  Future<bool> activateApiKey(String id) async {
    try {
      final apiKey = await getApiKeyById(id);
      if (apiKey != null) {
        final updatedKey = apiKey.copyWith(isActive: true);
        return await updateApiKey(updatedKey);
      }
      return false;
    } catch (e) {
      AutomaticErrorReporter.reportStorageError(
        message: 'Error activating API key: $e',
        additionalInfo: {
          'api_key_id': id,
        }
      );
      return false;
    }
  }

  /// Increments the request count for an API key
  Future<bool> incrementRequestCount(String id) async {
    try {
      final apiKey = await getApiKeyById(id);
      if (apiKey != null) {
        final updatedKey = apiKey.copyWith(
          requestCount: apiKey.requestCount + 1,
          lastUsedAt: DateTime.now(),
        );
        return await updateApiKey(updatedKey);
      }
      return false;
    } catch (e) {
      AutomaticErrorReporter.reportStorageError(
        message: 'Error incrementing request count: $e',
        additionalInfo: {
          'api_key_id': id,
        }
      );
      return false;
    }
  }
}