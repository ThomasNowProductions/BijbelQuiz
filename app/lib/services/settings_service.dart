import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SettingsService extends ChangeNotifier {
  final String _baseUrl = 'http://localhost:3000'; // Replace with your backend URL
  final AuthService _authService;

  SettingsService(this._authService);

  Future<void> updateProfileVisibility(String visibility) async {
    if (!_authService.isAuthenticated) return;

    final response = await http.put(
      Uri.parse('$_baseUrl/settings/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authService.token}',
      },
      body: json.encode({'visibility': visibility}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile visibility');
    }
  }

  Future<void> updateRealTimeSync(bool enabled) async {
    if (!_authService.isAuthenticated) return;

    final response = await http.put(
      Uri.parse('$_baseUrl/settings/sync'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authService.token}',
      },
      body: json.encode({'enabled': enabled}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update real-time sync');
    }
  }
}
