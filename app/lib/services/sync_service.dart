import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SyncService extends ChangeNotifier {
  final String _baseUrl = 'http://localhost:3000'; // Replace with your backend URL
  final AuthService _authService;

  SyncService(this._authService) {
    _authService.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    if (_authService.isAuthenticated) {
      // User is authenticated, start syncing data
      print('User is authenticated, starting sync...');
      // You might want to trigger an initial sync here
    } else {
      // User is not authenticated, stop syncing data
      print('User is not authenticated, stopping sync...');
    }
  }

  Future<void> syncProgress(Map<String, dynamic> progress) async {
    if (!_authService.isAuthenticated) return;

    final response = await http.put(
      Uri.parse('$_baseUrl/user/stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authService.token}',
      },
      body: json.encode({'progress': progress}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to sync progress');
    }
  }

  Future<void> syncPurchasedItems(Map<String, dynamic> items) async {
    if (!_authService.isAuthenticated) return;

    final response = await http.put(
      Uri.parse('$_baseUrl/user/stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authService.token}',
      },
      body: json.encode({'purchased_items': items}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to sync purchased items');
    }
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
