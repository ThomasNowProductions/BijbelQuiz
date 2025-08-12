import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmergencyMessage {
  final String message;
  final bool isBlocking;
  final DateTime expiresAt;

  EmergencyMessage({
    required this.message,
    required this.isBlocking,
    required this.expiresAt,
  });

  factory EmergencyMessage.fromJson(Map<String, dynamic> json) {
    return EmergencyMessage(
      message: json['message'],
      isBlocking: json['isBlocking'] ?? false,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(json['expiresAt'] * 1000),
    );
  }
}

class EmergencyService {
  static const String _baseUrl = 'https://backendbijbelquiz.vercel.app/api';
  static const String _endpoint = '/emergency';
  static const Duration _pollingInterval = Duration(minutes: 5);
  
  final BuildContext context;
  Timer? _pollingTimer;
  EmergencyMessage? _currentMessage;
  bool _isShowingDialog = false;

  EmergencyService(this.context);

  // Start polling for emergency messages
  void startPolling() {
    // Initial check
    _checkForEmergency();
    
    // Set up periodic polling
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      _checkForEmergency();
    });
  }

  // Stop polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // Check for emergency messages from the server
  Future<void> _checkForEmergency() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // We have an emergency message
        final data = jsonDecode(response.body);
        final message = EmergencyMessage.fromJson(data);
        
        // Only show if it's a new message or different from current one
        if (_currentMessage?.message != message.message) {
          _currentMessage = message;
          _showEmergencyDialog(message);
        }
      } else if (response.statusCode == 204) {
        // No emergency message
        _currentMessage = null;
      }
    } catch (e) {
      // Log error but don't show to user
      debugPrint('Error checking for emergency message: $e');
    }
  }

  // Show the emergency dialog
  void _showEmergencyDialog(EmergencyMessage message) async {
    // Prevent multiple dialogs
    if (_isShowingDialog) return;
    _isShowingDialog = true;
    
    await showDialog(
      context: context,
      barrierDismissible: !message.isBlocking, // Blocking dialogs can't be dismissed
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => !message.isBlocking,
          child: AlertDialog(
            title: const Text('Belangrijke mededeling', 
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text(message.message),
            actions: <Widget>[
              if (!message.isBlocking)
                TextButton(
                  child: const Text('Sluiten'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              if (message.isBlocking)
                Text(
                  'Deze melding kan niet worden gesloten',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        );
      },
    );
    
    _isShowingDialog = false;
  }

  // Clean up resources
  void dispose() {
    stopPolling();
  }
}
