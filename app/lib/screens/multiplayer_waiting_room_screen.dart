import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/multiplayer_provider.dart';
import '../services/analytics_service.dart';
import 'online_multiplayer_quiz_screen.dart';

/// Waiting room screen for multiplayer games
class MultiplayerWaitingRoomScreen extends StatefulWidget {
  const MultiplayerWaitingRoomScreen({super.key});

  @override
  State<MultiplayerWaitingRoomScreen> createState() =>
      _MultiplayerWaitingRoomScreenState();
}

class _MultiplayerWaitingRoomScreenState
    extends State<MultiplayerWaitingRoomScreen> {
  @override
  void initState() {
    super.initState();
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.screen(context, 'MultiplayerWaitingRoomScreen');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'Wachtkamer',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _leaveGame(context),
        ),
      ),
      body: Consumer<MultiplayerProvider>(
        builder: (context, multiplayerProvider, child) {
          final gameSession = multiplayerProvider.currentGameSession;
          final currentPlayer = multiplayerProvider.currentPlayer;
          final players = multiplayerProvider.players;

          if (gameSession == null || currentPlayer == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Game code display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Game Code',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          gameSession.gameCode,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                letterSpacing: 4,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Deel deze code met anderen om mee te doen',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Players list
                  Text(
                    'Spelers (${players.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: players.isEmpty
                          ? Center(
                              child: Text(
                                'Geen spelers gevonden',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            )
                          : ListView.builder(
                              itemCount: players.length,
                              itemBuilder: (context, index) {
                                final player = players[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: player.isOrganizer
                                        ? colorScheme.primary
                                        : colorScheme.secondary,
                                    child: Icon(
                                      player.isOrganizer ? Icons.star : Icons.person,
                                      color: player.isOrganizer
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSecondary,
                                    ),
                                  ),
                                  title: Text(
                                    player.playerName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: player.isOrganizer ? FontWeight.bold : FontWeight.normal,
                                        ),
                                  ),
                                  subtitle: player.isOrganizer
                                      ? const Text('Organizer')
                                      : null,
                                  trailing: player.isConnected
                                      ? Icon(
                                          Icons.check_circle,
                                          color: colorScheme.primary,
                                        )
                                      : Icon(
                                          Icons.error,
                                          color: colorScheme.error,
                                        ),
                                );
                              },
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Organizer controls
                  if (currentPlayer.isOrganizer) ...[
                    Text(
                      'Spel instellingen',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aantal vragen: ${gameSession.gameSettings['num_questions'] ?? 10}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tijd limiet: ${gameSession.gameSettings['time_limit_minutes'] != null ? '${gameSession.gameSettings['time_limit_minutes']} minuten' : 'Geen'}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: players.length >= 2 && !multiplayerProvider.isLoading
                          ? () => _startGame(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: multiplayerProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text(
                        multiplayerProvider.isLoading ? 'Starten...' : 'Start Spel',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),

                    if (players.length < 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Minimaal 2 spelers nodig om te starten',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.error,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ] else ...[
                    // Player waiting message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.hourglass_empty,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Wachten tot de organizer het spel start...',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _startGame(BuildContext context) async {
    final multiplayerProvider = Provider.of<MultiplayerProvider>(context, listen: false);

    final success = await multiplayerProvider.startGame();

    if (success && mounted) {
      final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
      analyticsService.capture(context, 'start_multiplayer_game', properties: {
        'player_count': multiplayerProvider.players.length,
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const OnlineMultiplayerQuizScreen(),
        ),
      );
    }
  }

  Future<void> _leaveGame(BuildContext context) async {
    final multiplayerProvider = Provider.of<MultiplayerProvider>(context, listen: false);

    await multiplayerProvider.leaveGameSession();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}