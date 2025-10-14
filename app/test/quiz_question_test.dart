import 'package:flutter_test/flutter_test.dart';
import 'package:bijbelquiz/models/quiz_question.dart';

void main() {
  group('QuizQuestion', () {
    test('should create QuizQuestion with required parameters', () {
      final question = QuizQuestion(
        question: 'What is the first book of the Bible?',
        correctAnswer: 'Genesis',
        incorrectAnswers: ['Exodus', 'Leviticus', 'Numbers'],
        difficulty: 'easy',
        type: QuestionType.mc,
      );

      expect(question.question, 'What is the first book of the Bible?');
      expect(question.correctAnswer, 'Genesis');
      expect(question.incorrectAnswers, ['Exodus', 'Leviticus', 'Numbers']);
      expect(question.difficulty, 'easy');
      expect(question.type, QuestionType.mc);
      expect(question.categories, isEmpty);
      expect(question.biblicalReference, isNull);
    });

    test('should create QuizQuestion with optional parameters', () {
      final question = QuizQuestion(
        question: 'In which city was Jesus born?',
        correctAnswer: 'Bethlehem',
        incorrectAnswers: ['Nazareth', 'Jerusalem'],
        difficulty: 'medium',
        type: QuestionType.mc,
        categories: ['New Testament', 'Christmas'],
        biblicalReference: 'Matthew 2:1',
      );

      expect(question.categories, ['New Testament', 'Christmas']);
      expect(question.biblicalReference, 'Matthew 2:1');
    });

    test('should parse from JSON - multiple choice', () {
      final json = {
        'question': 'What is 2+2?',
        'correctAnswer': '4',
        'incorrectAnswers': ['3', '5', '6'],
        'difficulty': 'easy',
        'type': 'mc',
        'categories': ['Math', 'Basic'],
        'biblicalReference': 'Genesis 1:1',
      };

      final question = QuizQuestion.fromJson(json);

      expect(question.question, 'What is 2+2?');
      expect(question.correctAnswer, '4');
      expect(question.incorrectAnswers, ['3', '5', '6']);
      expect(question.difficulty, 'easy');
      expect(question.type, QuestionType.mc);
      expect(question.categories, ['Math', 'Basic']);
      expect(question.biblicalReference, 'Genesis 1:1');
    });

    test('should parse from JSON - fill in the blank', () {
      final json = {
        'question': 'Complete the verse: "In the beginning ___"',
        'correctAnswer': 'God created',
        'incorrectAnswers': ['was the word', 'there was light'],
        'difficulty': 'medium',
        'type': 'fitb',
      };

      final question = QuizQuestion.fromJson(json);

      expect(question.type, QuestionType.fitb);
      expect(question.correctAnswer, 'God created');
    });

    test('should parse from JSON - true/false with provided incorrect answers', () {
      final json = {
        'question': 'Is God real?',
        'correctAnswer': 'Waar',
        'incorrectAnswers': ['Niet waar'],
        'difficulty': 'easy',
        'type': 'tf',
      };

      final question = QuizQuestion.fromJson(json);

      expect(question.type, QuestionType.tf);
      expect(question.incorrectAnswers, ['Niet waar']);
    });

    test('should generate incorrect answers for true/false when not provided - Waar', () {
      final json = {
        'question': 'Is Jesus the Son of God?',
        'correctAnswer': 'Waar',
        'difficulty': 'easy',
        'type': 'tf',
      };

      final question = QuizQuestion.fromJson(json);

      expect(question.incorrectAnswers, ['Niet waar']);
    });

    test('should generate incorrect answers for true/false when not provided - Niet waar', () {
      final json = {
        'question': 'Is the Bible fiction?',
        'correctAnswer': 'Niet waar',
        'difficulty': 'easy',
        'type': 'tf',
      };

      final question = QuizQuestion.fromJson(json);

      expect(question.incorrectAnswers, ['Waar']);
    });

    test('should generate incorrect answers for true/false when not provided - True', () {
      final json = {
        'question': 'God exists?',
        'correctAnswer': 'True',
        'difficulty': 'easy',
        'type': 'tf',
      };

      final question = QuizQuestion.fromJson(json);

      expect(question.incorrectAnswers, ['Niet waar']);
    });

    test('should generate incorrect answers for true/false when not provided - False', () {
      final json = {
        'question': 'Is sin good?',
        'correctAnswer': 'False',
        'difficulty': 'easy',
        'type': 'tf',
      };

      final question = QuizQuestion.fromJson(json);

      expect(question.incorrectAnswers, ['Waar']);
    });

    test('should handle empty JSON gracefully', () {
      final Map<String, dynamic> json = {};

      final question = QuizQuestion.fromJson(json);

      expect(question.question, '');
      expect(question.correctAnswer, '');
      expect(question.incorrectAnswers, isEmpty);
      expect(question.difficulty, '');
      expect(question.type, QuestionType.mc);
    });

    test('should serialize to JSON', () {
      final question = QuizQuestion(
        question: 'Test question?',
        correctAnswer: 'Yes',
        incorrectAnswers: ['No', 'Maybe'],
        difficulty: 'easy',
        type: QuestionType.mc,
        categories: ['Test Category'],
        biblicalReference: 'Test 1:1',
      );

      final json = question.toJson();

      expect(json['question'], 'Test question?');
      expect(json['correctAnswer'], 'Yes');
      expect(json['incorrectAnswers'], ['No', 'Maybe']);
      expect(json['difficulty'], 'easy');
      expect(json['type'], 'mc');
      expect(json['categories'], ['Test Category']);
      expect(json['biblicalReference'], 'Test 1:1');
    });

    test('should shuffle answer options', () {
      final question = QuizQuestion(
        question: 'What is the capital of France?',
        correctAnswer: 'Paris',
        incorrectAnswers: ['London', 'Berlin', 'Madrid'],
        difficulty: 'easy',
        type: QuestionType.mc,
      );

      final options = question.allOptions;
      expect(options.length, 4);
      expect(options.contains('Paris'), isTrue);
      expect(options.contains('London'), isTrue);
      expect(options.contains('Berlin'), isTrue);
      expect(options.contains('Madrid'), isTrue);
    });

    test('should return correct answer index', () {
      final question = QuizQuestion(
        question: 'What is 5 * 5?',
        correctAnswer: '25',
        incorrectAnswers: ['15', '20', '30'],
        difficulty: 'easy',
        type: QuestionType.mc,
      );

      final index = question.correctAnswerIndex;
      expect(question.allOptions[index], '25');
    });

    test('should return primary category', () {
      final question = QuizQuestion(
        question: 'Bible question',
        correctAnswer: 'Answer',
        incorrectAnswers: ['Wrong1', 'Wrong2'],
        difficulty: 'easy',
        type: QuestionType.mc,
        categories: ['Old Testament', 'Genesis', 'Creation'],
      );

      expect(question.category, 'Old Testament');
    });

    test('should return empty string when no categories', () {
      final question = QuizQuestion(
        question: 'Bible question',
        correctAnswer: 'Answer',
        incorrectAnswers: ['Wrong1', 'Wrong2'],
        difficulty: 'easy',
        type: QuestionType.mc,
      );

      expect(question.category, '');
    });

    test('should handle single incorrect answer for true/false', () {
      final question = QuizQuestion(
        question: 'Is water wet?',
        correctAnswer: 'Waar',
        incorrectAnswers: ['Niet waar'],
        difficulty: 'easy',
        type: QuestionType.tf,
      );

      expect(question.allOptions.length, 2);
      expect(question.allOptions.contains('Waar'), isTrue);
      expect(question.allOptions.contains('Niet waar'), isTrue);
    });
  });

  group('QuestionType parsing', () {
    test('should parse mc type from JSON', () {
      final json = {'type': 'mc'};
      final question = QuizQuestion.fromJson(json);
      expect(question.type, QuestionType.mc);
    });

    test('should parse fitb type from JSON', () {
      final json = {'type': 'fitb'};
      final question = QuizQuestion.fromJson(json);
      expect(question.type, QuestionType.fitb);
    });

    test('should parse tf type from JSON', () {
      final json = {'type': 'tf'};
      final question = QuizQuestion.fromJson(json);
      expect(question.type, QuestionType.tf);
    });

    test('should default to mc for unknown type', () {
      final json = {'type': 'unknown'};
      final question = QuizQuestion.fromJson(json);
      expect(question.type, QuestionType.mc);
    });

    test('should default to mc for null type', () {
      final Map<String, dynamic> json = {};
      final question = QuizQuestion.fromJson(json);
      expect(question.type, QuestionType.mc);
    });
  });

  group('Incorrect answers parsing', () {
    test('should parse list of incorrect answers from JSON', () {
      final json = {
        'incorrectAnswers': ['Wrong1', 'Wrong2', 'Wrong3'],
        'type': 'mc'
      };
      final question = QuizQuestion.fromJson(json);
      expect(question.incorrectAnswers, ['Wrong1', 'Wrong2', 'Wrong3']);
    });

    test('should handle empty incorrect answers list', () {
      final json = {
        'incorrectAnswers': [],
        'type': 'mc'
      };
      final question = QuizQuestion.fromJson(json);
      expect(question.incorrectAnswers, isEmpty);
    });

    test('should handle non-list incorrect answers', () {
      final json = {
        'incorrectAnswers': 'not a list',
        'type': 'mc'
      };
      final question = QuizQuestion.fromJson(json);
      expect(question.incorrectAnswers, isEmpty);
    });

    test('should generate opposites for TF - Waar', () {
      final json = {
        'correctAnswer': 'Waar',
        'type': 'tf'
      };
      final question = QuizQuestion.fromJson(json);
      expect(question.incorrectAnswers, ['Niet waar']);
    });

    test('should generate opposites for TF - Niet waar', () {
      final json = {
        'correctAnswer': 'Niet waar',
        'type': 'tf'
      };
      final question = QuizQuestion.fromJson(json);
      expect(question.incorrectAnswers, ['Waar']);
    });

    test('should generate opposites for TF - True', () {
      final json = {
        'correctAnswer': 'True',
        'type': 'tf'
      };
      final question = QuizQuestion.fromJson(json);
      expect(question.incorrectAnswers, ['Niet waar']);
    });

    test('should generate opposites for TF - False', () {
      final json = {
        'correctAnswer': 'False',
        'type': 'tf'
      };
      final question = QuizQuestion.fromJson(json);
      expect(question.incorrectAnswers, ['Waar']);
    });

    test('should fallback for unknown TF answer', () {
      final json = {
        'correctAnswer': 'Unknown',
        'type': 'tf'
      };
      final question = QuizQuestion.fromJson(json);
      expect(question.incorrectAnswers, ['Niet waar']);
    });
  });

  group('Categories parsing', () {
    test('should parse list of categories from JSON', () {
      final json = {
        'categories': ['Old Testament', 'Genesis', 'Creation']
      };
      final question = QuizQuestion.fromJson(json);
      expect(question.categories, ['Old Testament', 'Genesis', 'Creation']);
    });

    test('should handle empty categories list', () {
      final json = {
        'categories': []
      };
      final question = QuizQuestion.fromJson(json);
      expect(question.categories, isEmpty);
    });

    test('should handle non-list categories', () {
      final json = {
        'categories': 'not a list'
      };
      final question = QuizQuestion.fromJson(json);
      expect(question.categories, isEmpty);
    });
  });
}
