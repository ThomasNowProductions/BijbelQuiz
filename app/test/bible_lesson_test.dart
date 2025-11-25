import 'package:flutter_test/flutter_test.dart';
import 'package:bijbelquiz/models/bible_lesson.dart';

void main() {
  group('LessonSection', () {
    test('should create LessonSection with required parameters', () {
      const section = LessonSection(
        heading: 'Test Heading',
        content: 'Test content text',
      );

      expect(section.heading, 'Test Heading');
      expect(section.content, 'Test content text');
      expect(section.bibleReference, isNull);
      expect(section.imagePath, isNull);
    });

    test('should create LessonSection with optional parameters', () {
      const section = LessonSection(
        heading: 'Creation Story',
        content: 'In the beginning God created the heavens and the earth.',
        bibleReference: 'Genesis 1:1',
        imagePath: 'assets/images/creation.png',
      );

      expect(section.heading, 'Creation Story');
      expect(section.content, 'In the beginning God created the heavens and the earth.');
      expect(section.bibleReference, 'Genesis 1:1');
      expect(section.imagePath, 'assets/images/creation.png');
    });

    test('should serialize to JSON', () {
      const section = LessonSection(
        heading: 'Test Heading',
        content: 'Test content',
        bibleReference: 'Genesis 1:1',
      );

      final json = section.toJson();

      expect(json['heading'], 'Test Heading');
      expect(json['content'], 'Test content');
      expect(json['bibleReference'], 'Genesis 1:1');
      expect(json['imagePath'], isNull);
    });

    test('should parse from JSON', () {
      final json = {
        'heading': 'Noah\'s Ark',
        'content': 'God told Noah to build an ark.',
        'bibleReference': 'Genesis 6:14',
        'imagePath': 'assets/images/noah.png',
      };

      final section = LessonSection.fromJson(json);

      expect(section.heading, 'Noah\'s Ark');
      expect(section.content, 'God told Noah to build an ark.');
      expect(section.bibleReference, 'Genesis 6:14');
      expect(section.imagePath, 'assets/images/noah.png');
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'heading': 'Simple Section',
        'content': 'Just some content',
      };

      final section = LessonSection.fromJson(json);

      expect(section.heading, 'Simple Section');
      expect(section.content, 'Just some content');
      expect(section.bibleReference, isNull);
      expect(section.imagePath, isNull);
    });

    test('should handle null values in JSON', () {
      final json = {
        'heading': null,
        'content': null,
        'bibleReference': null,
        'imagePath': null,
      };

      final section = LessonSection.fromJson(json);

      expect(section.heading, '');
      expect(section.content, '');
      expect(section.bibleReference, isNull);
      expect(section.imagePath, isNull);
    });
  });

  group('BibleLesson', () {
    test('should create BibleLesson with required parameters', () {
      const lesson = BibleLesson(
        id: 'lesson_001',
        title: 'What is the Bible?',
        description: 'Learn about the Bible',
        category: 'Introduction',
        index: 0,
        sections: [
          LessonSection(heading: 'Section 1', content: 'Content 1'),
          LessonSection(heading: 'Section 2', content: 'Content 2'),
        ],
        questionCategory: 'Algemeen',
      );

      expect(lesson.id, 'lesson_001');
      expect(lesson.title, 'What is the Bible?');
      expect(lesson.description, 'Learn about the Bible');
      expect(lesson.category, 'Introduction');
      expect(lesson.index, 0);
      expect(lesson.sectionCount, 2);
      expect(lesson.hasReadingContent, isTrue);
      expect(lesson.estimatedReadingMinutes, 5); // default
      expect(lesson.quizQuestionCount, 5); // default
    });

    test('should create BibleLesson with optional parameters', () {
      const lesson = BibleLesson(
        id: 'lesson_002',
        title: 'Creation',
        description: 'The story of creation',
        category: 'Genesis',
        index: 1,
        estimatedReadingMinutes: 10,
        iconHint: 'public',
        sections: [],
        keyTerms: ['Creation', 'Adam', 'Eve'],
        questionCategory: 'Genesis',
        quizQuestionCount: 8,
      );

      expect(lesson.estimatedReadingMinutes, 10);
      expect(lesson.iconHint, 'public');
      expect(lesson.keyTerms, ['Creation', 'Adam', 'Eve']);
      expect(lesson.quizQuestionCount, 8);
      expect(lesson.hasReadingContent, isFalse); // no sections
    });

    test('should copy BibleLesson with updated fields', () {
      const original = BibleLesson(
        id: 'lesson_001',
        title: 'Original Title',
        description: 'Original description',
        category: 'Original',
        index: 0,
        sections: [],
        questionCategory: 'Original',
      );

      final copied = original.copyWith(
        title: 'Updated Title',
        index: 5,
      );

      expect(copied.id, 'lesson_001'); // unchanged
      expect(copied.title, 'Updated Title');
      expect(copied.description, 'Original description'); // unchanged
      expect(copied.index, 5);
    });

    test('should serialize to JSON', () {
      const lesson = BibleLesson(
        id: 'lesson_001',
        title: 'Test Lesson',
        description: 'Test description',
        category: 'Test',
        index: 0,
        sections: [
          LessonSection(heading: 'Heading', content: 'Content'),
        ],
        keyTerms: ['term1', 'term2'],
        questionCategory: 'Test',
      );

      final json = lesson.toJson();

      expect(json['id'], 'lesson_001');
      expect(json['title'], 'Test Lesson');
      expect(json['description'], 'Test description');
      expect(json['category'], 'Test');
      expect(json['index'], 0);
      expect(json['sections'], isA<List>());
      expect(json['sections'].length, 1);
      expect(json['keyTerms'], ['term1', 'term2']);
      expect(json['questionCategory'], 'Test');
    });

    test('should parse from JSON', () {
      final json = {
        'id': 'lesson_002',
        'title': 'Noah',
        'description': 'The story of Noah',
        'category': 'Genesis',
        'index': 2,
        'estimatedReadingMinutes': 7,
        'iconHint': 'sailing',
        'sections': [
          {'heading': 'The Flood', 'content': 'God sent a flood.'},
        ],
        'keyTerms': ['Noah', 'Ark', 'Flood'],
        'questionCategory': 'Genesis',
        'quizQuestionCount': 10,
      };

      final lesson = BibleLesson.fromJson(json);

      expect(lesson.id, 'lesson_002');
      expect(lesson.title, 'Noah');
      expect(lesson.description, 'The story of Noah');
      expect(lesson.category, 'Genesis');
      expect(lesson.index, 2);
      expect(lesson.estimatedReadingMinutes, 7);
      expect(lesson.iconHint, 'sailing');
      expect(lesson.sectionCount, 1);
      expect(lesson.keyTerms, ['Noah', 'Ark', 'Flood']);
      expect(lesson.questionCategory, 'Genesis');
      expect(lesson.quizQuestionCount, 10);
    });

    test('should handle string index in JSON', () {
      final json = {
        'id': 'lesson_003',
        'title': 'Test',
        'description': 'Test',
        'category': 'Test',
        'index': '5',
        'sections': [],
        'questionCategory': 'Test',
      };

      final lesson = BibleLesson.fromJson(json);

      expect(lesson.index, 5);
    });

    test('should handle invalid index in JSON', () {
      final json = {
        'id': 'lesson_004',
        'title': 'Test',
        'description': 'Test',
        'category': 'Test',
        'index': 'invalid',
        'sections': [],
        'questionCategory': 'Test',
      };

      final lesson = BibleLesson.fromJson(json);

      expect(lesson.index, 0); // default fallback
    });

    test('should handle null values in JSON', () {
      final json = <String, dynamic>{
        'id': null,
        'title': null,
        'description': null,
        'category': null,
        'index': null,
        'sections': null,
        'questionCategory': null,
      };

      final lesson = BibleLesson.fromJson(json);

      expect(lesson.id, '');
      expect(lesson.title, '');
      expect(lesson.description, '');
      expect(lesson.category, '');
      expect(lesson.index, 0);
      expect(lesson.sections, isEmpty);
      expect(lesson.questionCategory, 'Algemeen'); // default
    });

    test('should convert to string representation', () {
      const lesson = BibleLesson(
        id: 'lesson_001',
        title: 'Test',
        description: 'Test',
        category: 'Test',
        index: 0,
        sections: [],
        questionCategory: 'Test',
      );

      final jsonString = lesson.toString();
      expect(jsonString, isNotEmpty);
      expect(jsonString.contains('lesson_001'), isTrue);
      expect(jsonString.contains('Test'), isTrue);
    });
  });
}
