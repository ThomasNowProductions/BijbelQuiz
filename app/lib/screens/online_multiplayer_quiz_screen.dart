import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/multiplayer_provider.dart';
import '../services/analytics_service.dart';

class OnlineMultiplayerQuizScreen extends StatelessWidget {
  const OnlineMultiplayerQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Multiplayer Quiz'),
      ),
      body: const Center(
        child: Text('Online multiplayer quiz screen - coming soon!'),
      ),
    );
  }
}