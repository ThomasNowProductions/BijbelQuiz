import 'dart:convert';

/// A section of reading content within a Bible lesson.
/// Each section contains a heading and content text that teaches users
/// about the Bible before they take the quiz.
class LessonSection {
  /// The heading/title for this section
  final String heading;

  /// The main content text for this section
  final String content;

  /// Optional Bible reference (e.g., "Genesis 1:1-5")
  final String? bibleReference;

  /// Optional image path for visual aids
  final String? imagePath;

  const LessonSection({
    required this.heading,
    required this.content,
    this.bibleReference,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'heading': heading,
        'content': content,
        'bibleReference': bibleReference,
        'imagePath': imagePath,
      };

  factory LessonSection.fromJson(Map<String, dynamic> json) => LessonSection(
        heading: json['heading']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        bibleReference: json['bibleReference']?.toString(),
        imagePath: json['imagePath']?.toString(),
      );
}

/// A Bible lesson that combines reading content with quiz questions.
/// This is designed for new users who know nothing about the Bible,
/// providing educational content before testing their knowledge.
class BibleLesson {
  /// Unique identifier for the lesson
  final String id;

  /// Display title (e.g., "De Schepping" / "Creation")
  final String title;

  /// Short description/summary of what the lesson covers
  final String description;

  /// Category for the lesson (e.g., "Oude Testament", "Genesis")
  final String category;

  /// Sequential index in the lesson track (0-based)
  final int index;

  /// Estimated reading time in minutes
  final int estimatedReadingMinutes;

  /// Icon hint for UI (material icon name or emoji)
  final String? iconHint;

  /// The reading sections that teach the user before the quiz
  final List<LessonSection> sections;

  /// Key terms/vocabulary for this lesson
  final List<String> keyTerms;

  /// Backing question category used to fetch quiz questions
  final String questionCategory;

  /// Number of quiz questions after reading
  final int quizQuestionCount;

  const BibleLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.index,
    required this.sections,
    required this.questionCategory,
    this.estimatedReadingMinutes = 5,
    this.iconHint,
    this.keyTerms = const [],
    this.quizQuestionCount = 5,
  });

  /// Total number of reading sections
  int get sectionCount => sections.length;

  /// Check if this lesson has reading content
  bool get hasReadingContent => sections.isNotEmpty;

  BibleLesson copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? index,
    int? estimatedReadingMinutes,
    String? iconHint,
    List<LessonSection>? sections,
    List<String>? keyTerms,
    String? questionCategory,
    int? quizQuestionCount,
  }) {
    return BibleLesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      index: index ?? this.index,
      estimatedReadingMinutes:
          estimatedReadingMinutes ?? this.estimatedReadingMinutes,
      iconHint: iconHint ?? this.iconHint,
      sections: sections ?? this.sections,
      keyTerms: keyTerms ?? this.keyTerms,
      questionCategory: questionCategory ?? this.questionCategory,
      quizQuestionCount: quizQuestionCount ?? this.quizQuestionCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'index': index,
        'estimatedReadingMinutes': estimatedReadingMinutes,
        'iconHint': iconHint,
        'sections': sections.map((s) => s.toJson()).toList(),
        'keyTerms': keyTerms,
        'questionCategory': questionCategory,
        'quizQuestionCount': quizQuestionCount,
      };

  factory BibleLesson.fromJson(Map<String, dynamic> json) => BibleLesson(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        index: (json['index'] is int)
            ? json['index'] as int
            : int.tryParse(json['index']?.toString() ?? '') ?? 0,
        estimatedReadingMinutes: (json['estimatedReadingMinutes'] is int)
            ? json['estimatedReadingMinutes'] as int
            : int.tryParse(json['estimatedReadingMinutes']?.toString() ?? '') ??
                5,
        iconHint: json['iconHint']?.toString(),
        sections: (json['sections'] as List<dynamic>?)
                ?.map((s) =>
                    LessonSection.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
        keyTerms: (json['keyTerms'] as List<dynamic>?)
                ?.map((k) => k.toString())
                .toList() ??
            [],
        questionCategory: json['questionCategory']?.toString() ?? 'Algemeen',
        quizQuestionCount: (json['quizQuestionCount'] is int)
            ? json['quizQuestionCount'] as int
            : int.tryParse(json['quizQuestionCount']?.toString() ?? '') ?? 5,
      );

  @override
  String toString() => jsonEncode(toJson());
}
