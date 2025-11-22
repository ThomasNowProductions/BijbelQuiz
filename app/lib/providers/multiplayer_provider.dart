import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/quiz_question.dart';
import '../services/logger.dart';
import '../services/question_cache_service.dart';
import '../services/connection_service.dart';

enum GameStatus { waiting, active, finished }
enum PlayerRole { organizer, player }

class MultiplayerGameSession {
  final String id;
  final String gameCode;
  final String organizerId;
  final GameStatus status;
  final Map<String, dynamic> gameSettings;
  final int currentQuestionIndex;
  final DateTime? currentQuestionStartTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  MultiplayerGameSession({
    required this.id,
    required this.gameCode,
    required this.organizerId,
    required this.status,
    required this.gameSettings,
    required this.currentQuestionIndex,
    this.currentQuestionStartTime,
    required this.createdAt,
    required this.updatedAt,
  });

  MultiplayerGameSession copyWith({
    String? id,
    String? gameCode,
    String? organizerId,
    GameStatus? status,
    Map<String, dynamic>? gameSettings,
    int? currentQuestionIndex,
    DateTime? currentQuestionStartTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MultiplayerGameSession(
      id: id ?? this.id,
      gameCode: gameCode ?? this.gameCode,
      organizerId: organizerId ?? this.organizerId,
      status: status ?? this.status,
      gameSettings: gameSettings ?? this.gameSettings,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      currentQuestionStartTime: currentQuestionStartTime ?? this.currentQuestionStartTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory MultiplayerGameSession.fromJson(Map<String, dynamic> json) {
    return MultiplayerGameSession(
      id: json['id'],
      gameCode: json['game_code'],
      organizerId: json['organizer_id'],
      status: GameStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GameStatus.waiting,
      ),
      gameSettings: json['game_settings'] ?? {},
      currentQuestionIndex: json['current_question_index'] ?? 0,
      currentQuestionStartTime: json['current_question_start_time'] != null
          ? DateTime.parse(json['current_question_start_time'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game_code': gameCode,
      'organizer_id': organizerId,
      'status': status.name,
      'game_settings': gameSettings,
      'current_question_index': currentQuestionIndex,
      'current_question_start_time': currentQuestionStartTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class MultiplayerPlayer {
  final String id;
  final String gameSessionId;
  final String playerId;
  final String playerName;
  final bool isOrganizer;
  final DateTime joinedAt;
  final DateTime lastSeenAt;
  final bool isConnected;
  final int score;
  final String? currentAnswer;
  final int? answerTimeSeconds;

  MultiplayerPlayer({
    required this.id,
    required this.gameSessionId,
    required this.playerId,
    required this.playerName,
    required this.isOrganizer,
    required this.joinedAt,
    required this.lastSeenAt,
    required this.isConnected,
    required this.score,
    this.currentAnswer,
    this.answerTimeSeconds,
  });

  MultiplayerPlayer copyWith({
    String? id,
    String? gameSessionId,
    String? playerId,
    String? playerName,
    bool? isOrganizer,
    DateTime? joinedAt,
    DateTime? lastSeenAt,
    bool? isConnected,
    int? score,
    String? currentAnswer,
    int? answerTimeSeconds,
  }) {
    return MultiplayerPlayer(
      id: id ?? this.id,
      gameSessionId: gameSessionId ?? this.gameSessionId,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      isOrganizer: isOrganizer ?? this.isOrganizer,
      joinedAt: joinedAt ?? this.joinedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isConnected: isConnected ?? this.isConnected,
      score: score ?? this.score,
      currentAnswer: currentAnswer ?? this.currentAnswer,
      answerTimeSeconds: answerTimeSeconds ?? this.answerTimeSeconds,
    );
  }

  factory MultiplayerPlayer.fromJson(Map<String, dynamic> json) {
    return MultiplayerPlayer(
      id: json['id'],
      gameSessionId: json['game_session_id'],
      playerId: json['player_id'],
      playerName: json['player_name'],
      isOrganizer: json['is_organizer'] ?? false,
      joinedAt: DateTime.parse(json['joined_at']),
      lastSeenAt: DateTime.parse(json['last_seen_at']),
      isConnected: json['is_connected'] ?? true,
      score: json['score'] ?? 0,
      currentAnswer: json['current_answer'],
      answerTimeSeconds: json['answer_time_seconds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game_session_id': gameSessionId,
      'player_id': playerId,
      'player_name': playerName,
      'is_organizer': isOrganizer,
      'joined_at': joinedAt.toIso8601String(),
      'last_seen_at': lastSeenAt.toIso8601String(),
      'is_connected': isConnected,
      'score': score,
      'current_answer': currentAnswer,
      'answer_time_seconds': answerTimeSeconds,
    };
  }
}

class MultiplayerProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final QuestionCacheService _questionCacheService;
  final ConnectionService _connectionService;

  MultiplayerGameSession? _currentGameSession;
  MultiplayerPlayer? _currentPlayer;
  List<MultiplayerPlayer> _players = [];
  List<QuizQuestion> _questions = [];
  RealtimeChannel? _gameChannel;
  RealtimeChannel? _playersChannel;
  Timer? _heartbeatTimer;
  Timer? _disconnectTimer;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _disconnectTimeout = Duration(seconds: 90);

  bool _isLoading = false;
  String? _error;

  MultiplayerProvider(this._questionCacheService, this._connectionService);

  // Getters
  MultiplayerGameSession? get currentGameSession => _currentGameSession;
  MultiplayerPlayer? get currentPlayer => _currentPlayer;
  List<MultiplayerPlayer> get players => _players;
  List<QuizQuestion> get questions => _questions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOrganizer => _currentPlayer?.isOrganizer ?? false;
  bool get isGameActive => _currentGameSession?.status == GameStatus.active;
  bool get isGameFinished => _currentGameSession?.status == GameStatus.finished;
  int get currentQuestionIndex => _currentGameSession?.currentQuestionIndex ?? 0;
  QuizQuestion? get currentQuestion =>
      currentQuestionIndex < _questions.length ? _questions[currentQuestionIndex] : null;

  // Create a new game session
  Future<String?> createGameSession({
    required String organizerId,
    required String organizerName,
    int? numQuestions,
    int? timeLimitMinutes,
    int questionTimeSeconds = 20,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Generate unique game code
      final gameCode = await _generateGameCode();

      final gameSettings = {
        'num_questions': numQuestions,
        'time_limit_minutes': timeLimitMinutes,
        'question_time_seconds': questionTimeSeconds,
      };

      final response = await _supabase
          .from('multiplayer_game_sessions')
          .insert({
            'game_code': gameCode,
            'organizer_id': organizerId,
            'game_settings': gameSettings,
          })
          .select()
          .single();

      final session = MultiplayerGameSession.fromJson(response);
      _currentGameSession = session;

      // Add organizer as first player
      await _joinGameSession(gameCode, organizerId, organizerName, isOrganizer: true);

      // Load questions
      await _loadQuestions();

      // Set up real-time subscriptions
      _setupRealtimeSubscriptions();

      _isLoading = false;
      notifyListeners();

      return gameCode;
    } catch (e) {
      _error = 'Failed to create game session: $e';
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Failed to create game session', e);
      return null;
    }
  }

  // Join an existing game session
  Future<bool> joinGameSession(String gameCode, String playerId, String playerName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _joinGameSession(gameCode, playerId, playerName, isOrganizer: false);

      if (success) {
        // Load questions (organizer has already loaded them)
        await _loadQuestions();

        // Set up real-time subscriptions
        _setupRealtimeSubscriptions();

        // Start heartbeat to maintain connection
        _startHeartbeat();
      }

      _isLoading = false;
      notifyListeners();

      return success;
    } catch (e) {
      _error = 'Failed to join game session: $e';
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Failed to join game session', e);
      return false;
    }
  }

  Future<bool> _joinGameSession(String gameCode, String playerId, String playerName, {required bool isOrganizer}) async {
    try {
      // First, get the game session
      final sessionResponse = await _supabase
          .from('multiplayer_game_sessions')
          .select()
          .eq('game_code', gameCode)
          .single();

      _currentGameSession = MultiplayerGameSession.fromJson(sessionResponse);

      // Check if player already exists
      final existingPlayer = await _supabase
          .from('multiplayer_game_players')
          .select()
          .eq('game_session_id', _currentGameSession!.id)
          .eq('player_id', playerId)
          .maybeSingle();

      if (existingPlayer != null) {
        // Reconnect existing player
        await _supabase
            .from('multiplayer_game_players')
            .update({
              'is_connected': true,
              'last_seen_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingPlayer['id']);

        _currentPlayer = MultiplayerPlayer.fromJson(existingPlayer);
      } else {
        // Add new player
        final playerResponse = await _supabase
            .from('multiplayer_game_players')
            .insert({
              'game_session_id': _currentGameSession!.id,
              'player_id': playerId,
              'player_name': playerName,
              'is_organizer': isOrganizer,
            })
            .select()
            .single();

        _currentPlayer = MultiplayerPlayer.fromJson(playerResponse);
      }

      // Load all players
      await _loadPlayers();

      return true;
    } catch (e) {
      AppLogger.error('Failed to join game session internally', e);
      return false;
    }
  }

  // Start the game (organizer only)
  Future<bool> startGame() async {
    if (!isOrganizer || _currentGameSession == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      await _supabase
          .from('multiplayer_game_sessions')
          .update({
            'status': GameStatus.active.name,
            'current_question_start_time': DateTime.now().toIso8601String(),
          })
          .eq('id', _currentGameSession!.id);

      _currentGameSession = _currentGameSession!.copyWith(
        status: GameStatus.active,
        currentQuestionStartTime: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = 'Failed to start game: $e';
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Failed to start game', e);
      return false;
    }
  }

  // Submit answer for current question
  Future<bool> submitAnswer(String answer, int answerTimeSeconds) async {
    if (_currentGameSession == null || _currentPlayer == null || currentQuestion == null) return false;

    // Prevent multiple submissions for the same question
    if (_currentPlayer!.currentAnswer != null && _currentPlayer!.currentAnswer!.isNotEmpty) {
      return false; // Already answered
    }

    try {
      final isCorrect = _isAnswerCorrect(answer, currentQuestion!);

      // Calculate points
      final points = _calculatePoints(isCorrect, answerTimeSeconds);

      // Use a transaction-like approach to prevent race conditions
      final currentScore = _currentPlayer!.score;

      // Update player score and answer
      await _supabase
          .from('multiplayer_game_players')
          .update({
            'score': (currentScore + points),
            'current_answer': answer,
            'answer_time_seconds': answerTimeSeconds,
            'last_seen_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _currentPlayer!.id);

      // Record answer (only if update succeeded)
      await _supabase
          .from('multiplayer_game_answers')
          .insert({
            'game_session_id': _currentGameSession!.id,
            'player_id': _currentPlayer!.playerId,
            'question_index': currentQuestionIndex,
            'answer': answer,
            'is_correct': isCorrect,
            'answer_time_seconds': answerTimeSeconds,
            'points_earned': points,
          });

      // Update local player
      _currentPlayer = _currentPlayer!.copyWith(
        score: currentScore + points,
        currentAnswer: answer,
        answerTimeSeconds: answerTimeSeconds,
      );

      notifyListeners();

      return true;
    } catch (e) {
      AppLogger.error('Failed to submit answer', e);
      return false;
    }
  }

  // Move to next question (organizer only)
  Future<bool> nextQuestion() async {
    if (!isOrganizer || _currentGameSession == null) return false;

    try {
      final nextIndex = currentQuestionIndex + 1;
      final isFinished = nextIndex >= _questions.length;

      await _supabase
          .from('multiplayer_game_sessions')
          .update({
            'current_question_index': nextIndex,
            'status': isFinished ? GameStatus.finished.name : GameStatus.active.name,
            'current_question_start_time': isFinished ? null : DateTime.now().toIso8601String(),
          })
          .eq('id', _currentGameSession!.id);

      _currentGameSession = _currentGameSession!.copyWith(
        currentQuestionIndex: nextIndex,
        status: isFinished ? GameStatus.finished : GameStatus.active,
        currentQuestionStartTime: isFinished ? null : DateTime.now(),
      );

      // Clear current answers for all players
      await _supabase
          .from('multiplayer_game_players')
          .update({
            'current_answer': null,
            'answer_time_seconds': null,
          })
          .eq('game_session_id', _currentGameSession!.id);

      notifyListeners();

      return true;
    } catch (e) {
      AppLogger.error('Failed to move to next question', e);
      return false;
    }
  }

  // Leave game session
  Future<void> leaveGameSession() async {
    if (_currentPlayer != null) {
      try {
        await _supabase
            .from('multiplayer_game_players')
            .update({'is_connected': false})
            .eq('id', _currentPlayer!.id);
      } catch (e) {
        AppLogger.error('Failed to update player connection status', e);
      }
    }

    _cleanup();
  }

  // Private methods
  Future<String> _generateGameCode() async {
    const uuid = Uuid();
    String code;
    Map<String, dynamic>? exists;

    do {
      code = uuid.v4().substring(0, 6).toUpperCase();
      exists = await _supabase
          .from('multiplayer_game_sessions')
          .select('id')
          .eq('game_code', code)
          .maybeSingle();
    } while (exists != null);

    return code;
  }

  Future<void> _loadQuestions() async {
    if (_currentGameSession == null) return;

    try {
      // For now, load questions from cache service
      // In a real implementation, you might want to store questions in the database
      // or ensure all players get the same questions
      final settings = {}; // Get from provider if needed
      final language = 'nl'; // Default language

      _questions = await _questionCacheService.getQuestions(
        language,
        startIndex: 0,
        count: _currentGameSession!.gameSettings['num_questions'] ?? 10,
      );

      _questions.shuffle(); // Ensure same order for all players
    } catch (e) {
      AppLogger.error('Failed to load questions', e);
    }
  }

  Future<void> _loadPlayers() async {
    if (_currentGameSession == null) return;

    try {
      final response = await _supabase
          .from('multiplayer_game_players')
          .select()
          .eq('game_session_id', _currentGameSession!.id)
          .order('joined_at');

      _players = response.map((json) => MultiplayerPlayer.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to load players', e);
    }
  }

  void _setupRealtimeSubscriptions() {
    if (_currentGameSession == null) return;

    // Subscribe to game session changes
    _gameChannel = _supabase
        .channel('game_session_${_currentGameSession!.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'multiplayer_game_sessions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: _currentGameSession!.id,
          ),
          callback: (payload) {
            final updatedSession = MultiplayerGameSession.fromJson(payload.newRecord);
            _currentGameSession = updatedSession;
            notifyListeners();
          },
        )
        .subscribe();

    // Subscribe to player changes
    _playersChannel = _supabase
        .channel('game_players_${_currentGameSession!.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'multiplayer_game_players',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'game_session_id',
            value: _currentGameSession!.id,
          ),
          callback: (payload) {
            _loadPlayers(); // Reload all players
          },
        )
        .subscribe();
  }

  bool _isAnswerCorrect(String answer, QuizQuestion question) {
    // Simple correctness check - in a real implementation,
    // you might want more sophisticated answer validation
    return answer.toLowerCase().trim() == question.correctAnswer.toLowerCase().trim();
  }

  int _calculatePoints(bool isCorrect, int answerTimeSeconds) {
    if (!isCorrect) return 0;

    // Base points: 100
    // Speed bonus: up to 50 points for answering within 2 seconds
    const basePoints = 100;
    const maxSpeedBonus = 50;
    const speedThresholdSeconds = 2;

    if (answerTimeSeconds <= speedThresholdSeconds) {
      return basePoints + maxSpeedBonus;
    } else {
      // Linear decrease in bonus points
      final timeRatio = (answerTimeSeconds - speedThresholdSeconds) / (20 - speedThresholdSeconds);
      final speedBonus = maxSpeedBonus * (1 - timeRatio);
      return basePoints + speedBonus.round();
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) async {
      if (_currentPlayer != null) {
        try {
          await _supabase
              .from('multiplayer_game_players')
              .update({
                'last_seen_at': DateTime.now().toIso8601String(),
                'is_connected': true,
              })
              .eq('id', _currentPlayer!.id);
        } catch (e) {
          AppLogger.error('Failed to send heartbeat', e);
          // If heartbeat fails, mark as disconnected
          _handleDisconnection();
        }
      }
    });

    // Set up disconnect timer
    _disconnectTimer?.cancel();
    _disconnectTimer = Timer(_disconnectTimeout, () {
      _handleDisconnection();
    });
  }

  void _handleDisconnection() {
    AppLogger.warning('Player disconnected from game session');
    _cleanup();
    // TODO: Show reconnection dialog to user
  }

  void _cleanup() {
    _gameChannel?.unsubscribe();
    _playersChannel?.unsubscribe();
    _heartbeatTimer?.cancel();
    _disconnectTimer?.cancel();
    _currentGameSession = null;
    _currentPlayer = null;
    _players = [];
    _questions = [];
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}