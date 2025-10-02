import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'logger.dart';
import 'gemini_service.dart';
import 'connection_service.dart';

/// Configuration for BibleBot API service
class BibleBotConfig {
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const Duration requestTimeout = Duration(seconds: 45);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration conversationTimeout = Duration(minutes: 30);
}


/// Model class for Bible verse references
class BibleReference {
  final String book;
  final int chapter;
  final int verse;
  final String? endVerse;
  final String translation;

  const BibleReference({
    required this.book,
    required this.chapter,
    required this.verse,
    this.endVerse,
    this.translation = 'Statenvertaling',
  });

  String get formattedReference {
    final verseRange = endVerse != null ? '-$endVerse' : '';
    return '$book $chapter:$verse$verseRange ($translation)';
  }

  Map<String, dynamic> toJson() {
    return {
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'endVerse': endVerse,
      'translation': translation,
    };
  }

  factory BibleReference.fromJson(Map<String, dynamic> json) {
    return BibleReference(
      book: json['book'] as String,
      chapter: json['chapter'] as int,
      verse: json['verse'] as int,
      endVerse: json['endVerse'] as String?,
      translation: json['translation'] as String? ?? 'Statenvertaling',
    );
  }
}

/// Model class for Bible question responses
class BibleResponse {
  final String answer;
  final List<BibleReference> references;
  final String explanation;
  final String? historicalContext;
  final String? theologicalInsight;
  final bool isDirectAnswer;

  const BibleResponse({
    required this.answer,
    required this.references,
    required this.explanation,
    this.historicalContext,
    this.theologicalInsight,
    this.isDirectAnswer = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'references': references.map((ref) => ref.toJson()).toList(),
      'explanation': explanation,
      'historicalContext': historicalContext,
      'theologicalInsight': theologicalInsight,
      'isDirectAnswer': isDirectAnswer,
    };
  }

  factory BibleResponse.fromJson(Map<String, dynamic> json) {
    return BibleResponse(
      answer: json['answer'] as String,
      references: (json['references'] as List<dynamic>?)
          ?.map((ref) => BibleReference.fromJson(ref as Map<String, dynamic>))
          .toList() ?? [],
      explanation: json['explanation'] as String,
      historicalContext: json['historicalContext'] as String?,
      theologicalInsight: json['theologicalInsight'] as String?,
      isDirectAnswer: json['isDirectAnswer'] as bool? ?? false,
    );
  }
}

/// Model class for conversation context
class ConversationContext {
  final String conversationId;
  final List<BibleQuestion> previousQuestions;
  final DateTime lastActivity;
  final Map<String, dynamic> metadata;

  const ConversationContext({
    required this.conversationId,
    required this.previousQuestions,
    required this.lastActivity,
    this.metadata = const {},
  });

  bool get isExpired {
    return DateTime.now().difference(lastActivity) > BibleBotConfig.conversationTimeout;
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'previousQuestions': previousQuestions.map((q) => q.toJson()).toList(),
      'lastActivity': lastActivity.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ConversationContext.fromJson(Map<String, dynamic> json) {
    return ConversationContext(
      conversationId: json['conversationId'] as String,
      previousQuestions: (json['previousQuestions'] as List<dynamic>?)
          ?.map((q) => BibleQuestion.fromJson(q as Map<String, dynamic>))
          .toList() ?? [],
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Model class for Bible questions
class BibleQuestion {
  final String question;
  final String type;
  final DateTime timestamp;
  final String? context;

  BibleQuestion({
    required this.question,
    required this.type,
    DateTime? timestamp,
    this.context,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
    };
  }

  factory BibleQuestion.fromJson(Map<String, dynamic> json) {
    return BibleQuestion(
      question: json['question'] as String,
      type: json['type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      context: json['context'] as String?,
    );
  }
}

/// Model class for BibleBot API error responses
class BibleBotError implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final String? suggestion;

  const BibleBotError({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.suggestion,
  });

  @override
  String toString() => 'BibleBotError: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// A service that provides Bible study assistance using AI, with emphasis on Statenvertaling.
///
/// This service extends the existing GeminiService functionality to handle Bible-related questions,
/// providing contextual explanations, historical background, and theological insights while
/// prioritizing the Statenvertaling (Dutch States Translation) for Dutch users.
///
/// The service follows the established patterns used by other services in the BijbelQuiz app,
/// including proper error handling, logging, and async operations.
class BibleBotService {
  static BibleBotService? _instance;
  late final GeminiService _geminiService;
  late final ConnectionService _connectionService;
  bool _initialized = false;

  // Conversation management
  final Map<String, ConversationContext> _conversations = {};
  static const int _maxConversationHistory = 10;

  // Rate limiting (more conservative for Bible content)
  DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(seconds: 2);

  /// Private constructor for singleton pattern
  BibleBotService._internal() {
    _geminiService = GeminiService.instance;
    _connectionService = ConnectionService();
  }

  /// Gets the singleton instance of the service
  static BibleBotService get instance {
    _instance ??= BibleBotService._internal();
    return _instance!;
  }

  /// Checks if the service is properly initialized and ready to use
  bool get isInitialized => _initialized;

  /// Gets the current initialization status of the service
  bool get isReady => _initialized && _geminiService.isReady;

  /// Initializes the BibleBot service
  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing BibleBot service...');

      // Ensure Gemini service is initialized
      if (!_geminiService.isInitialized) {
        await _geminiService.initialize();
      }

      // Initialize connection service for network monitoring
      await _connectionService.initialize();

      _initialized = true;
      AppLogger.info('BibleBot service initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize BibleBot service', e);
      _initialized = false;
      rethrow;
    }
  }

  /// Ensures the service is initialized before use
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }


  /// Checks if the device has internet connectivity
  Future<bool> _checkConnectivity() async {
    try {
      await _connectionService.checkConnection();
      return _connectionService.isConnected;
    } catch (e) {
      AppLogger.error('Failed to check connectivity', e);
      return false;
    }
  }

  /// Processes a Bible-related question and returns a structured response
  ///
  /// [question] - The Bible question to process
  /// [questionType] - The type of question (for AI context only)
  /// [conversationId] - Optional conversation ID for context tracking
  /// [context] - Additional context for the question
  Future<BibleResponse> askQuestion({
    required String question,
    required String questionType,
    String? conversationId,
    String? context,
  }) async {
    if (question.trim().isEmpty) {
      throw const BibleBotError(message: 'Vraag mag niet leeg zijn');
    }


    // Ensure service is initialized before making API calls
    try {
      await _ensureInitialized();
    } catch (e) {
      AppLogger.error('BibleBot service initialization failed', e);
      if (e is BibleBotError) {
        throw BibleBotError(
          message: 'Kon BibleBot service niet initialiseren: ${e.message}',
          statusCode: e.statusCode,
          errorCode: e.errorCode,
          suggestion: e.suggestion,
        );
      } else {
        throw const BibleBotError(
          message: 'Kon BibleBot service niet initialiseren. Controleer uw configuratie.',
        );
      }
    }

    // Double-check that we're properly initialized
    if (!_initialized || !_geminiService.isReady) {
      throw const BibleBotError(
        message: 'BibleBot service is niet correct geconfigureerd. Controleer uw GEMINI_API_KEY in het .env bestand.',
      );
    }

    // Check network connectivity before proceeding
    final isConnected = await _checkConnectivity();
    if (!isConnected) {
      throw const BibleBotError(
        message: 'Geen internetverbinding gedetecteerd. Controleer uw netwerkverbinding en probeer opnieuw.',
        errorCode: 'NO_CONNECTION',
        suggestion: 'Controleer uw internetverbinding en zorg voor een stabiele netwerkverbinding.',
      );
    }

    await _ensureRateLimit();

    // Create Bible question object
    final bibleQuestion = BibleQuestion(
      question: question,
      type: questionType,
      context: context,
    );

    // Update conversation context if provided
    if (conversationId != null) {
      await _updateConversationContext(conversationId, bibleQuestion);
    }

    AppLogger.info('Processing Bible question: $question (type: $questionType)');

    try {
      final response = await _makeBibleApiRequest(bibleQuestion, conversationId);

      if (response.statusCode == 200) {
        final bibleResponse = await _parseBibleResponse(response.body);
        AppLogger.info('Successfully processed Bible question');
        return bibleResponse;
      } else {
        throw await _handleBibleErrorResponse(response);
      }
    } catch (e) {
      AppLogger.error('Failed to process Bible question', e);
      rethrow;
    }
  }

  /// Ensures requests respect rate limiting
  Future<void> _ensureRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final delay = _minRequestInterval - timeSinceLastRequest;
        AppLogger.info('BibleBot rate limiting: waiting ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// Updates conversation context with new question
  Future<void> _updateConversationContext(String conversationId, BibleQuestion question) async {
    final context = _conversations[conversationId];
    if (context == null) {
      _conversations[conversationId] = ConversationContext(
        conversationId: conversationId,
        previousQuestions: [question],
        lastActivity: DateTime.now(),
      );
    } else {
      if (context.isExpired) {
        _conversations[conversationId] = ConversationContext(
          conversationId: conversationId,
          previousQuestions: [question],
          lastActivity: DateTime.now(),
        );
      } else {
        final updatedQuestions = [question, ...context.previousQuestions]
            .take(_maxConversationHistory)
            .toList();
        _conversations[conversationId] = ConversationContext(
          conversationId: conversationId,
          previousQuestions: updatedQuestions,
          lastActivity: DateTime.now(),
          metadata: context.metadata,
        );
      }
    }
  }

  /// Makes the HTTP request to the Gemini API for Bible questions
  Future<http.Response> _makeBibleApiRequest(BibleQuestion question, String? conversationId) async {
    final url = Uri.parse('${BibleBotConfig.baseUrl}/models/gemini-2.5-flash-lite:generateContent?key=${_geminiService.apiKey}');

    final prompt = _buildBiblePrompt(question, conversationId);
    final requestBody = json.encode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.3, // Lower temperature for more accurate Bible responses
        'topK': 40,
        'topP': 0.85,
        'maxOutputTokens': 4096,
      }
    });

    AppLogger.info('Making Bible API request');

    for (int attempt = 1; attempt <= BibleBotConfig.maxRetries; attempt++) {
      try {
        final response = await _geminiService.httpClient
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: requestBody,
            )
            .timeout(BibleBotConfig.requestTimeout);

        if (response.statusCode == 200) {
          return response;
        } else if (response.statusCode == 429 && attempt < BibleBotConfig.maxRetries) {
          // Rate limited, wait and retry
          final delay = BibleBotConfig.retryDelay * attempt;
          AppLogger.warning('Bible API rate limited, retrying in ${delay.inSeconds}s (attempt $attempt)');
          await Future.delayed(delay);
          continue;
        } else {
          return response;
        }
      } catch (e) {
        if (attempt == BibleBotConfig.maxRetries) {
          throw BibleBotError(
            message: 'Bible API request failed after $attempt attempts: $e',
          );
        }
        AppLogger.warning('Bible API request attempt $attempt failed: $e');
        await Future.delayed(BibleBotConfig.retryDelay * attempt);
      }
    }

    throw const BibleBotError(message: 'All Bible API retry attempts exhausted');
  }

  /// Builds a structured prompt for Bible questions
  String _buildBiblePrompt(BibleQuestion question, String? conversationId) {
    // Get conversation context if available
    String? conversationContext;
    if (conversationId != null) {
      final context = _conversations[conversationId];
      if (context != null && !context.isExpired && context.previousQuestions.length > 1) {
        conversationContext = context.previousQuestions
            .sublist(1) // Skip current question
            .take(3) // Take last 3 questions for context
            .map((q) => '${q.type}: ${q.question}')
            .join('\n');
      }
    }

    return _buildDutchBiblePrompt(question, conversationContext);
  }

  /// Builds a Dutch Bible prompt emphasizing Statenvertaling
  String _buildDutchBiblePrompt(BibleQuestion question, String? conversationContext) {
    return '''
Je bent een Bijbelstudie-assistent gespecialiseerd in de Statenvertaling (Statenbijbel) uit 1637. Je geeft uitsluitend accurate, feitelijke antwoorden op Bijbelgerelateerde vragen gebaseerd op de Bijbeltekst zelf.

VRAAG: "${question.question}"
${conversationContext != null ? 'GESPREKSCONTEXT:\n$conversationContext\n' : ''}

BELANGRIJK: JE MAG ALLEEN VRAGEN BEANTWOORDEN DIE GERELATEERD ZIJN AAN:
- Bijbelverzen en hun uitleg
- Bijbelse context en achtergrond
- Bijbelstudie en tekstverklaring
- Theologische vragen gebaseerd op Bijbeltekst
- Bijbelse referenties en citaten

JE MOET ALLE ANDERE VRAGEN WEIGEREN MET:
- Persoonlijke adviezen ("hoe moet ik bidden?", "hoe moet ik leven?")
- Praktische toepassingen ("wat moet ik doen in situatie X?")
- Persoonlijke meningen of counseling
- Niet-Bijbelse onderwerpen (politiek, nieuws, persoonlijke problemen, etc.)
- Speculatieve vragen ("wat zou er gebeuren als...?")

INSTRUCTIES:
1. Geef ALTIJD eerst de relevante Bijbelverwijzingen uit de Statenvertaling
2. Gebruik de Statenvertaling als primaire referentie voor Nederlandse gebruikers
3. Geef historische context en theologische inzichten waar relevant
4. Beantwoord in het Nederlands met duidelijke, objectieve toon
5. Structureer je antwoord met:
   - Bijbelverwijzingen (boek, hoofdstuk, vers)
   - Uitleg van de tekst
   - Historische achtergrond (indien relevant)
   - Theologische betekenis

VEREISTEN:
- Geef specifieke Bijbelverwijzingen met Statenvertaling waar mogelijk
- Leg verbanden tussen verschillende Bijbelgedeelten
- Geef eerlijke, accurate informatie gebaseerd op de Bijbeltekst
- Vermijd speculatie - blijf bij wat de Bijbel zegt
- Vermijd persoonlijke adviezen of praktische toepassingen
- Geef alleen feitelijke informatie over Bijbelse onderwerpen
- Wees respectvol en objectief in je toon

ANTWOORD FORMAAT:
Geef een JSON object terug met de volgende structuur:
{
  "answer": "Je complete feitelijke antwoord in het Nederlands, of een duidelijke weigering als de vraag niet-Bijbels is",
  "references": [
    {
      "book": "Genesis",
      "chapter": 1,
      "verse": 1,
      "endVerse": "3",
      "translation": "Statenvertaling"
    }
  ],
  "explanation": "Gedetailleerde uitleg van de Bijbeltekst, of uitleg waarom je de vraag niet kunt beantwoorden",
  "historicalContext": "Historische achtergrond informatie (alleen bij Bijbelse vragen)",
  "theologicalInsight": "Theologische betekenis en verbanden (alleen bij Bijbelse vragen)",
  "isDirectAnswer": false
}

Zorg ervoor dat het JSON geldig is en alle velden bevat.
''';
  }


  /// Parses the API response to extract Bible information
  Future<BibleResponse> _parseBibleResponse(String responseBody) async {
    try {
      final Map<String, dynamic> response = json.decode(responseBody);

      // Extract the generated text from Gemini's response
      final candidates = response['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw const BibleBotError(message: 'No response candidates received');
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        throw const BibleBotError(message: 'No content parts in response');
      }

      final generatedText = parts[0]['text'] as String?;
      if (generatedText == null || generatedText.trim().isEmpty) {
        throw const BibleBotError(message: 'Empty response text');
      }

      // Try to extract JSON from the response
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(generatedText);
      if (jsonMatch == null) {
        throw const BibleBotError(message: 'No JSON found in response');
      }

      final jsonText = jsonMatch.group(0)!;
      final Map<String, dynamic> bibleData = json.decode(jsonText);

      return BibleResponse.fromJson(bibleData);
    } catch (e) {
      if (e is BibleBotError) rethrow;

      AppLogger.error('Failed to parse Bible API response, using fallback: $e');

      // Return a fallback response if parsing fails
      return BibleResponse(
        answer: 'Sorry, ik kon geen volledig antwoord genereren. Probeer je vraag anders te formuleren.',
        references: [],
        explanation: 'Er is een technische fout opgetreden bij het verwerken van je vraag.',
      );
    }
  }

  /// Handles error responses from the Bible API
  Future<BibleBotError> _handleBibleErrorResponse(http.Response response) async {
    try {
      final Map<String, dynamic> errorBody = json.decode(response.body);
      final error = errorBody['error'] as Map<String, dynamic>?;

      String suggestion = 'Probeer uw vraag anders te formuleren of controleer uw internetverbinding.';
      if (response.statusCode == 429) {
        suggestion = 'Te veel verzoeken. Wacht even voordat u een nieuwe vraag stelt.';
      } else if (response.statusCode >= 500) {
        suggestion = 'Serverfout. Probeer het over een paar minuten opnieuw.';
      }

      return BibleBotError(
        message: error?['message'] as String? ?? 'Unknown Bible API error',
        statusCode: response.statusCode,
        errorCode: error?['code'] as String?,
        suggestion: suggestion,
      );
    } catch (e) {
      return BibleBotError(
        message: 'Bible API HTTP ${response.statusCode}: ${response.body}',
        statusCode: response.statusCode,
        suggestion: 'Controleer uw internetverbinding en probeer opnieuw.',
      );
    }
  }

  /// Gets conversation context for a given conversation ID
  ConversationContext? getConversationContext(String conversationId) {
    final context = _conversations[conversationId];
    if (context != null && context.isExpired) {
      _conversations.remove(conversationId);
      return null;
    }
    return context;
  }

  /// Clears conversation context for a given conversation ID
  void clearConversationContext(String conversationId) {
    _conversations.remove(conversationId);
    AppLogger.info('Cleared conversation context: $conversationId');
  }

  /// Clears all conversation contexts
  void clearAllConversations() {
    _conversations.clear();
    AppLogger.info('Cleared all conversation contexts');
  }

  /// Gets available question types for Bible questions
  /// Note: Question type validation is now handled by AI prompts
  List<String> getAvailableQuestionTypes() {
    return [
      'verse_explanation',
      'biblical_context',
      'bible_study',
      'theological_question',
      'bible_reference',
      'general_question'
    ];
  }

  /// Disposes of resources used by the service
  void dispose() {
    _conversations.clear();
    _connectionService.dispose();
    AppLogger.info('BibleBot service disposed');
  }
}