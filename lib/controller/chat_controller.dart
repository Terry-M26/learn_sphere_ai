import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_sphere_ai/apis/apis.dart';
import 'package:learn_sphere_ai/model/message.dart';
import 'package:learn_sphere_ai/service/database.dart';

class ChatController extends GetxController {
  final textC = TextEditingController();
  final DatabaseMethods _db = DatabaseMethods();

  // Limits
  static const int _maxApiContextMessages = 20;
  static const int _maxSavedMessages = 50;
  static const int _maxSavedConversations = 20;

  String? currentConversationId;

  final _initialMessage = Message(
    msg: 'Hello, I am Albert, your AI tutor, how can I assist you today?',
    msgType: MessageType.bot,
  );

  final list = <Message>[].obs;

  ChatController() {
    list.add(_initialMessage);
  }

  // Build conversation history for API context (excludes initial greeting and "Thinking...")
  // Limited to last _maxApiContextMessages to prevent token overflow
  List<Map<String, String>> _buildConversationHistory() {
    final history = <Map<String, String>>[];

    for (final msg in list) {
      // Skip the initial greeting and "Thinking..." placeholder
      if (msg.msg == _initialMessage.msg || msg.msg == 'Thinking...') continue;

      history.add({
        "role": msg.msgType == MessageType.user ? "user" : "assistant",
        "content": msg.msg,
      });
    }

    // Limit to last N messages for API context
    if (history.length > _maxApiContextMessages) {
      return history.sublist(history.length - _maxApiContextMessages);
    }

    return history;
  }

  Future<void> askQuestion() async {
    if (textC.text.trim().isNotEmpty) {
      final question = textC.text;

      //user
      list.add(Message(msg: question, msgType: MessageType.user));
      list.add(Message(msg: 'Thinking...', msgType: MessageType.bot));

      // Build history before adding current question (it's added in API)
      final history = _buildConversationHistory();
      // Remove the last user message from history since API adds it
      if (history.isNotEmpty && history.last['role'] == 'user') {
        history.removeLast();
      }

      final res = await APIs.getAnswer(question, conversationHistory: history);

      //bot
      list.removeLast();
      list.add(Message(msg: res, msgType: MessageType.bot));

      //clear
      textC.clear();
    }
  }

  // Check if conversation has actual user messages (not just initial greeting)
  bool get hasUserMessages {
    return list.any((msg) => msg.msgType == MessageType.user);
  }

  // Save conversation to Firebase (truncated to last _maxSavedMessages)
  Future<void> saveConversation() async {
    if (!hasUserMessages) return; // Skip if no actual conversation

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Truncate to last N messages for storage
    final messagesToSave = list.length > _maxSavedMessages
        ? list.sublist(list.length - _maxSavedMessages)
        : list.toList();
    final messagesMap = messagesToSave.map((m) => m.toMap()).toList();

    if (currentConversationId != null) {
      // Update existing conversation
      await _db.updateConversation(
        user.uid,
        currentConversationId!,
        messagesMap,
      );
    } else {
      // Create new conversation and enforce conversation limit
      final docRef = await _db.saveConversation(user.uid, messagesMap);
      currentConversationId = docRef.id;

      // Delete oldest conversations if limit exceeded
      await _db.enforceConversationLimit(user.uid, _maxSavedConversations);
    }
  }

  // Load conversation from history
  void loadConversation(String conversationId, List<dynamic> messages) {
    currentConversationId = conversationId;
    list.clear();
    for (var msg in messages) {
      list.add(Message.fromMap(Map<String, dynamic>.from(msg)));
    }
  }

  // Start a new conversation
  void newConversation() {
    currentConversationId = null;
    list.clear();
    list.add(_initialMessage);
  }
}
