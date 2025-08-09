import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Handles activation status and code verification against backend API.
class ActivationService {
  static const String _prefsKey = 'bq_activation';
  static const String apiUrl =
      'https://backendbijbelquiz.vercel.app/api/activation-codes.php';

  /// Returns true if the app was previously activated.
  Future<bool> isActivated() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefsKey);
    if (data == null || data.isEmpty) return false;
    try {
      final obj = json.decode(data) as Map<String, dynamic>;
      final code = obj['code'];
      return code is String && code.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Verifies [code] with the backend API. When valid, stores activation locally.
  Future<bool> verifyCode(String code) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return false;

    final uri = Uri.parse(
      '$apiUrl?code=${Uri.encodeQueryComponent(normalized)}',
    );

    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return false;

    final body = json.decode(res.body);
    final valid = body is Map<String, dynamic> ? body['valid'] == true : false;

    if (valid) {
      final prefs = await SharedPreferences.getInstance();
      final payload = {
        'code': normalized,
        'at': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString(_prefsKey, json.encode(payload));
    }

    return valid;
  }

  /// Clears activation (for debug/support use).
  Future<void> clearActivation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}