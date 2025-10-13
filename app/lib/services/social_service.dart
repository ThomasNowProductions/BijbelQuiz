import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SocialService extends ChangeNotifier {
  final String _baseUrl = 'http://localhost:3000'; // Replace with your backend URL
  final AuthService _authService;

  SocialService(this._authService);

  Future<List<String>> searchUsers(String query) async {
    if (!_authService.isAuthenticated) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/social/users?q=$query'),
      headers: {
        'Authorization': 'Bearer ${_authService.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((user) => user['username'] as String).toList();
    } else {
      throw Exception('Failed to search users');
    }
  }

  Future<void> followUser(String userId) async {
    if (!_authService.isAuthenticated) return;

    final response = await http.post(
      Uri.parse('$_baseUrl/social/follow/$userId'),
      headers: {
        'Authorization': 'Bearer ${_authService.token}',
      },
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to follow user');
    }
  }

  Future<void> unfollowUser(String userId) async {
    if (!_authService.isAuthenticated) return;

    final response = await http.delete(
      Uri.parse('$_baseUrl/social/unfollow/$userId'),
      headers: {
        'Authorization': 'Bearer ${_authService.token}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to unfollow user');
    }
  }

  Future<List<String>> getFollowedUsers() async {
    if (!_authService.isAuthenticated) return [];

    // This endpoint is not implemented in the backend yet,
    // so we'll return a placeholder for now.
    await Future.delayed(const Duration(milliseconds: 500));
    return ['user1', 'user2'];
  }
}
