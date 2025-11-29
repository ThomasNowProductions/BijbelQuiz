import 'dart:convert';

/// Represents a learning module for beginners.
/// Each module contains educational content about Bible concepts and themes.
class LearningModule {
  /// Unique identifier for the module
  final String id;

  /// Display title for the module
  final String title;

  /// Short description of what the module covers
  final String description;

  /// The learning objective - what the user will learn
  final String objective;

  /// Sequential index in the learning path (0-based)
  final int index;

  /// Icon hint for UI (material icon name or emoji)
  final String? iconHint;

  /// The main content sections of the module
  final List<LearningSection> sections;

  /// Fun facts or encouragement messages
  final List<String> funFacts;

  /// Related quiz category for practice questions
  final String? relatedCategory;

  /// Number of practice questions to show after completing the module
  final int practiceQuestionCount;

  /// Estimated time to complete in minutes
  final int estimatedMinutes;

  const LearningModule({
    required this.id,
    required this.title,
    required this.description,
    required this.objective,
    required this.index,
    required this.sections,
    this.iconHint,
    this.funFacts = const [],
    this.relatedCategory,
    this.practiceQuestionCount = 5,
    this.estimatedMinutes = 5,
  });

  factory LearningModule.fromJson(Map<String, dynamic> json) {
    return LearningModule(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      objective: json['objective']?.toString() ?? '',
      index: (json['index'] is int)
          ? json['index'] as int
          : int.tryParse(json['index']?.toString() ?? '') ?? 0,
      iconHint: json['iconHint']?.toString(),
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => LearningSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      funFacts: (json['funFacts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      relatedCategory: json['relatedCategory']?.toString(),
      practiceQuestionCount: (json['practiceQuestionCount'] is int)
          ? json['practiceQuestionCount'] as int
          : int.tryParse(json['practiceQuestionCount']?.toString() ?? '') ?? 5,
      estimatedMinutes: (json['estimatedMinutes'] is int)
          ? json['estimatedMinutes'] as int
          : int.tryParse(json['estimatedMinutes']?.toString() ?? '') ?? 5,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'objective': objective,
        'index': index,
        'iconHint': iconHint,
        'sections': sections.map((s) => s.toJson()).toList(),
        'funFacts': funFacts,
        'relatedCategory': relatedCategory,
        'practiceQuestionCount': practiceQuestionCount,
        'estimatedMinutes': estimatedMinutes,
      };

  @override
  String toString() => jsonEncode(toJson());

  LearningModule copyWith({
    String? id,
    String? title,
    String? description,
    String? objective,
    int? index,
    String? iconHint,
    List<LearningSection>? sections,
    List<String>? funFacts,
    String? relatedCategory,
    int? practiceQuestionCount,
    int? estimatedMinutes,
  }) {
    return LearningModule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      objective: objective ?? this.objective,
      index: index ?? this.index,
      iconHint: iconHint ?? this.iconHint,
      sections: sections ?? this.sections,
      funFacts: funFacts ?? this.funFacts,
      relatedCategory: relatedCategory ?? this.relatedCategory,
      practiceQuestionCount:
          practiceQuestionCount ?? this.practiceQuestionCount,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }
}

/// Represents a section within a learning module.
class LearningSection {
  /// Section title
  final String title;

  /// Main content text (supports simple markdown-like formatting)
  final String content;

  /// Optional key points or bullet list items
  final List<String> keyPoints;

  /// Optional image asset path
  final String? imageAsset;

  const LearningSection({
    required this.title,
    required this.content,
    this.keyPoints = const [],
    this.imageAsset,
  });

  factory LearningSection.fromJson(Map<String, dynamic> json) {
    return LearningSection(
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      keyPoints: (json['keyPoints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageAsset: json['imageAsset']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'keyPoints': keyPoints,
        'imageAsset': imageAsset,
      };
}

/// Achievement/badge for completing learning milestones.
class LearningAchievement {
  /// Unique identifier
  final String id;

  /// Display name
  final String name;

  /// Description of what the user achieved
  final String description;

  /// Icon hint for the badge
  final String iconHint;

  /// Criteria type: 'module_complete', 'quiz_perfect', 'streak', 'milestone'
  final String criteriaType;

  /// Criteria value (e.g., module index, streak count)
  final int criteriaValue;

  const LearningAchievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconHint,
    required this.criteriaType,
    required this.criteriaValue,
  });

  factory LearningAchievement.fromJson(Map<String, dynamic> json) {
    return LearningAchievement(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconHint: json['iconHint']?.toString() ?? '🏆',
      criteriaType: json['criteriaType']?.toString() ?? '',
      criteriaValue: (json['criteriaValue'] is int)
          ? json['criteriaValue'] as int
          : int.tryParse(json['criteriaValue']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconHint': iconHint,
        'criteriaType': criteriaType,
        'criteriaValue': criteriaValue,
      };
}
