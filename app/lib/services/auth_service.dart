import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  final String _baseUrl = 'http://localhost:3000'; // Replace with your backend URL
  String? _token;

  bool get isAuthenticated => _token != null;
  String? get token => _token;

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      _token = json.decode(response.body)['data']['session']['access_token'];
      notifyListeners();
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> signup(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      _token = json.decode(response.body)['data']['session']['access_token'];
      notifyListeners();
    } else {
      throw Exception('Failed to signup');
    }
  }

  Future<void> logout() async {
    _token = null;
    notifyListeners();
  }
}
