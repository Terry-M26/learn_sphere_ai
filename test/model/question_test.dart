import 'package:flutter_test/flutter_test.dart';
import 'package:learn_sphere_ai/model/question.dart';

void main() {
  group('Question Model', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        // Arrange
        final json = {
          'question': 'What is Flutter?',
          'options': ['A framework', 'A language', 'A database', 'An OS'],
          'correctAnswer': 0,
          'explanation': 'Flutter is a UI framework by Google',
        };

        // Act
        final question = Question.fromJson(json);

        // Assert
        expect(question.question, 'What is Flutter?');
        expect(question.options.length, 4);
        expect(question.options[0], 'A framework');
        expect(question.correctAnswer, 0);
        expect(question.explanation, 'Flutter is a UI framework by Google');
      });

      test('handles missing question field with empty string default', () {
        // Arrange
        final json = {
          'options': ['A', 'B', 'C', 'D'],
          'correctAnswer': 1,
          'explanation': 'Test',
        };

        // Act
        final question = Question.fromJson(json);

        // Assert
        expect(question.question, '');
      });

      test('handles missing options field with empty list default', () {
        // Arrange
        final json = {
          'question': 'Test question?',
          'correctAnswer': 0,
          'explanation': 'Test',
        };

        // Act
        final question = Question.fromJson(json);

        // Assert
        expect(question.options, isEmpty);
      });

      test('handles null options gracefully', () {
        // Arrange
        final json = {
          'question': 'Test question?',
          'options': null,
          'correctAnswer': 0,
          'explanation': 'Test',
        };

        // Act
        final question = Question.fromJson(json);

        // Assert
        expect(question.options, isEmpty);
      });

      test('handles missing correctAnswer with zero default', () {
        // Arrange
        final json = {
          'question': 'Test question?',
          'options': ['A', 'B', 'C', 'D'],
          'explanation': 'Test',
        };

        // Act
        final question = Question.fromJson(json);

        // Assert
        expect(question.correctAnswer, 0);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        // Arrange
        final question = Question(
          question: 'What is Dart?',
          options: ['Language', 'Framework', 'Database', 'Tool'],
          correctAnswer: 0,
          explanation: 'Dart is a programming language',
        );

        // Act
        final json = question.toJson();

        // Assert
        expect(json['question'], 'What is Dart?');
        expect(json['options'], ['Language', 'Framework', 'Database', 'Tool']);
        expect(json['correctAnswer'], 0);
        expect(json['explanation'], 'Dart is a programming language');
      });
    });

    group('isValid', () {
      test('returns true for valid question', () {
        // Arrange
        final question = Question(
          question: 'What is 2 + 2?',
          options: ['3', '4', '5', '6'],
          correctAnswer: 1,
          explanation: 'Basic math',
        );

        // Act & Assert
        expect(question.isValid(), true);
      });

      test('returns false when question is empty', () {
        // Arrange
        final question = Question(
          question: '',
          options: ['A', 'B', 'C', 'D'],
          correctAnswer: 0,
          explanation: 'Test',
        );

        // Act & Assert
        expect(question.isValid(), false);
      });

      test('returns false when options less than 4', () {
        // Arrange
        final question = Question(
          question: 'Test question?',
          options: ['A', 'B', 'C'],
          correctAnswer: 0,
          explanation: 'Test',
        );

        // Act & Assert
        expect(question.isValid(), false);
      });

      test('returns false when options more than 4', () {
        // Arrange
        final question = Question(
          question: 'Test question?',
          options: ['A', 'B', 'C', 'D', 'E'],
          correctAnswer: 0,
          explanation: 'Test',
        );

        // Act & Assert
        expect(question.isValid(), false);
      });

      test('returns false when correctAnswer is negative', () {
        // Arrange
        final question = Question(
          question: 'Test question?',
          options: ['A', 'B', 'C', 'D'],
          correctAnswer: -1,
          explanation: 'Test',
        );

        // Act & Assert
        expect(question.isValid(), false);
      });

      test('returns false when correctAnswer >= 4', () {
        // Arrange
        final question = Question(
          question: 'Test question?',
          options: ['A', 'B', 'C', 'D'],
          correctAnswer: 4,
          explanation: 'Test',
        );

        // Act & Assert
        expect(question.isValid(), false);
      });
    });

    group('serialization roundtrip', () {
      test('toJson and fromJson preserves data correctly', () {
        // Arrange
        final original = Question(
          question: 'What is the capital of France?',
          options: ['London', 'Paris', 'Berlin', 'Madrid'],
          correctAnswer: 1,
          explanation: 'Paris is the capital of France',
        );

        // Act
        final json = original.toJson();
        final restored = Question.fromJson(json);

        // Assert
        expect(restored.question, original.question);
        expect(restored.options, original.options);
        expect(restored.correctAnswer, original.correctAnswer);
        expect(restored.explanation, original.explanation);
      });

      test('toMap and fromMap preserves data correctly', () {
        // Arrange
        final original = Question(
          question: 'What is the largest planet?',
          options: ['Earth', 'Mars', 'Jupiter', 'Saturn'],
          correctAnswer: 2,
          explanation: 'Jupiter is the largest planet in our solar system',
        );

        // Act
        final map = original.toMap();
        final restored = Question.fromMap(map);

        // Assert
        expect(restored.question, original.question);
        expect(restored.options, original.options);
        expect(restored.correctAnswer, original.correctAnswer);
        expect(restored.explanation, original.explanation);
      });
    });
  });
}
