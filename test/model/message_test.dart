import 'package:flutter_test/flutter_test.dart';
import 'package:learn_sphere_ai/model/message.dart';

void main() {
  group('Message Model', () {
    group('toMap', () {
      test('correctly converts user message to map', () {
        // Arrange
        final message = Message(
          msg: 'Hello, how are you?',
          msgType: MessageType.user,
        );

        // Act
        final result = message.toMap();

        // Assert
        expect(result, {
          'msg': 'Hello, how are you?',
          'msgType': 'user',
        });
      });

      test('correctly converts bot message to map', () {
        // Arrange
        final message = Message(
          msg: 'I am doing well, thank you!',
          msgType: MessageType.bot,
        );

        // Act
        final result = message.toMap();

        // Assert
        expect(result, {
          'msg': 'I am doing well, thank you!',
          'msgType': 'bot',
        });
      });
    });

    group('fromMap', () {
      test('creates user message from map', () {
        // Arrange
        final map = {'msg': 'Test message', 'msgType': 'user'};

        // Act
        final message = Message.fromMap(map);

        // Assert
        expect(message.msg, 'Test message');
        expect(message.msgType, MessageType.user);
      });

      test('creates bot message from map', () {
        // Arrange
        final map = {'msg': 'Bot response', 'msgType': 'bot'};

        // Act
        final message = Message.fromMap(map);

        // Assert
        expect(message.msg, 'Bot response');
        expect(message.msgType, MessageType.bot);
      });

      test('handles missing msg field with empty string default', () {
        // Arrange
        final map = {'msgType': 'user'};

        // Act
        final message = Message.fromMap(map);

        // Assert
        expect(message.msg, '');
        expect(message.msgType, MessageType.user);
      });
    });

    group('serialization roundtrip', () {
      test('toMap and fromMap preserves data correctly', () {
        // Arrange
        final original = Message(
          msg: 'This is a test message for roundtrip',
          msgType: MessageType.user,
        );

        // Act
        final map = original.toMap();
        final restored = Message.fromMap(map);

        // Assert
        expect(restored.msg, original.msg);
        expect(restored.msgType, original.msgType);
      });
    });
  });
}
