import 'package:flutter_test/flutter_test.dart';
import 'package:bijbelquiz/models/learning_module.dart';

void main() {
  group('LearningModule', () {
    test('should create LearningModule with required parameters', () {
      final module = LearningModule(
        id: 'test_module',
        title: 'Test Module',
        description: 'A test module',
        objective: 'Learn something',
        index: 0,
        sections: const [],
      );

      expect(module.id, 'test_module');
      expect(module.title, 'Test Module');
      expect(module.description, 'A test module');
      expect(module.objective, 'Learn something');
      expect(module.index, 0);
      expect(module.sections, isEmpty);
      expect(module.funFacts, isEmpty);
      expect(module.relatedCategory, isNull);
      expect(module.practiceQuestionCount, 5);
      expect(module.estimatedMinutes, 5);
    });

    test('should create LearningModule with optional parameters', () {
      final module = LearningModule(
        id: 'test_module',
        title: 'Test Module',
        description: 'A test module',
        objective: 'Learn something',
        index: 1,
        iconHint: 'menu_book',
        sections: const [],
        funFacts: ['Fun fact 1', 'Fun fact 2'],
        relatedCategory: 'Genesis',
        practiceQuestionCount: 10,
        estimatedMinutes: 15,
      );

      expect(module.iconHint, 'menu_book');
      expect(module.funFacts.length, 2);
      expect(module.relatedCategory, 'Genesis');
      expect(module.practiceQuestionCount, 10);
      expect(module.estimatedMinutes, 15);
    });

    test('should serialize to JSON', () {
      final module = LearningModule(
        id: 'test_module',
        title: 'Test Module',
        description: 'A test module',
        objective: 'Learn something',
        index: 0,
        sections: const [
          LearningSection(
            title: 'Section 1',
            content: 'Content here',
            keyPoints: ['Point 1', 'Point 2'],
          ),
        ],
        funFacts: ['Fun fact'],
      );

      final json = module.toJson();

      expect(json['id'], 'test_module');
      expect(json['title'], 'Test Module');
      expect(json['description'], 'A test module');
      expect(json['objective'], 'Learn something');
      expect(json['index'], 0);
      expect(json['sections'], isA<List>());
      expect(json['sections'].length, 1);
      expect(json['funFacts'], ['Fun fact']);
    });

    test('should parse from JSON', () {
      final json = {
        'id': 'intro_bible',
        'title': 'Wat is de Bijbel?',
        'description': 'Een introductie tot het belangrijkste boek ter wereld',
        'objective': 'Je leert wat de Bijbel is',
        'index': 0,
        'iconHint': 'menu_book',
        'estimatedMinutes': 5,
        'relatedCategory': 'Algemeen',
        'practiceQuestionCount': 5,
        'sections': [
          {
            'title': 'Het Woord van God',
            'content': 'De Bijbel is een verzameling van geschriften.',
            'keyPoints': ['Punt 1', 'Punt 2'],
          },
        ],
        'funFacts': ['De Bijbel is vertaald in meer dan 700 talen!'],
      };

      final module = LearningModule.fromJson(json);

      expect(module.id, 'intro_bible');
      expect(module.title, 'Wat is de Bijbel?');
      expect(module.index, 0);
      expect(module.iconHint, 'menu_book');
      expect(module.sections.length, 1);
      expect(module.sections[0].title, 'Het Woord van God');
      expect(module.sections[0].keyPoints.length, 2);
      expect(module.funFacts.length, 1);
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': 'test',
        'title': 'Test',
        'description': 'Desc',
        'objective': 'Obj',
        'index': 0,
      };

      final module = LearningModule.fromJson(json);

      expect(module.sections, isEmpty);
      expect(module.funFacts, isEmpty);
      expect(module.iconHint, isNull);
      expect(module.relatedCategory, isNull);
    });

    test('should handle string numbers in JSON', () {
      final json = {
        'id': 'test',
        'title': 'Test',
        'description': 'Desc',
        'objective': 'Obj',
        'index': '5',
        'practiceQuestionCount': '10',
        'estimatedMinutes': '15',
      };

      final module = LearningModule.fromJson(json);

      expect(module.index, 5);
      expect(module.practiceQuestionCount, 10);
      expect(module.estimatedMinutes, 15);
    });

    test('should copy with updated fields', () {
      final original = LearningModule(
        id: 'test',
        title: 'Original',
        description: 'Original desc',
        objective: 'Original obj',
        index: 0,
        sections: const [],
      );

      final copied = original.copyWith(
        title: 'Updated',
        index: 1,
      );

      expect(copied.id, 'test'); // unchanged
      expect(copied.title, 'Updated');
      expect(copied.description, 'Original desc'); // unchanged
      expect(copied.index, 1);
    });
  });

  group('LearningSection', () {
    test('should create LearningSection with required parameters', () {
      const section = LearningSection(
        title: 'Test Section',
        content: 'Test content',
      );

      expect(section.title, 'Test Section');
      expect(section.content, 'Test content');
      expect(section.keyPoints, isEmpty);
      expect(section.imageAsset, isNull);
    });

    test('should create LearningSection with optional parameters', () {
      const section = LearningSection(
        title: 'Test Section',
        content: 'Test content',
        keyPoints: ['Point 1', 'Point 2'],
        imageAsset: 'assets/test.png',
      );

      expect(section.keyPoints.length, 2);
      expect(section.imageAsset, 'assets/test.png');
    });

    test('should serialize to JSON', () {
      const section = LearningSection(
        title: 'Test',
        content: 'Content',
        keyPoints: ['Point'],
      );

      final json = section.toJson();

      expect(json['title'], 'Test');
      expect(json['content'], 'Content');
      expect(json['keyPoints'], ['Point']);
    });

    test('should parse from JSON', () {
      final json = {
        'title': 'Section Title',
        'content': 'Section content here',
        'keyPoints': ['Key 1', 'Key 2'],
        'imageAsset': 'assets/image.png',
      };

      final section = LearningSection.fromJson(json);

      expect(section.title, 'Section Title');
      expect(section.content, 'Section content here');
      expect(section.keyPoints.length, 2);
      expect(section.imageAsset, 'assets/image.png');
    });
  });

  group('LearningAchievement', () {
    test('should create LearningAchievement with required parameters', () {
      const achievement = LearningAchievement(
        id: 'first_module',
        name: 'First Step',
        description: 'Complete your first module',
        iconHint: '🎯',
        criteriaType: 'module_complete',
        criteriaValue: 1,
      );

      expect(achievement.id, 'first_module');
      expect(achievement.name, 'First Step');
      expect(achievement.description, 'Complete your first module');
      expect(achievement.iconHint, '🎯');
      expect(achievement.criteriaType, 'module_complete');
      expect(achievement.criteriaValue, 1);
    });

    test('should serialize to JSON', () {
      const achievement = LearningAchievement(
        id: 'test',
        name: 'Test Achievement',
        description: 'Test desc',
        iconHint: '⭐',
        criteriaType: 'quiz_perfect',
        criteriaValue: 100,
      );

      final json = achievement.toJson();

      expect(json['id'], 'test');
      expect(json['name'], 'Test Achievement');
      expect(json['criteriaType'], 'quiz_perfect');
      expect(json['criteriaValue'], 100);
    });

    test('should parse from JSON', () {
      final json = {
        'id': 'streak_7',
        'name': 'Week Streak',
        'description': 'Learn 7 days in a row',
        'iconHint': '🔥',
        'criteriaType': 'streak',
        'criteriaValue': 7,
      };

      final achievement = LearningAchievement.fromJson(json);

      expect(achievement.id, 'streak_7');
      expect(achievement.name, 'Week Streak');
      expect(achievement.criteriaType, 'streak');
      expect(achievement.criteriaValue, 7);
    });

    test('should use default icon when missing', () {
      final json = {
        'id': 'test',
        'name': 'Test',
        'description': 'Desc',
        'criteriaType': 'test',
        'criteriaValue': 1,
      };

      final achievement = LearningAchievement.fromJson(json);

      expect(achievement.iconHint, '🏆');
    });
  });
}
