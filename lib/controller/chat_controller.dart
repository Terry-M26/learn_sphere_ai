// ChatController - GetX controller for AI Tutor chat state management
// Manages: message list, conversation persistence, API calls to AI
// Uses GetX reactive state (.obs) for automatic UI updates

import 'package:firebase_auth/firebase_auth.dart'; // For user ID
import 'package:flutter/material.dart'; // For TextEditingController
import 'package:get/get.dart'; // For GetxController and .obs reactive state
import 'package:learn_sphere_ai/apis/apis.dart'; // For AI API calls
import 'package:learn_sphere_ai/model/message.dart'; // Message model
import 'package:learn_sphere_ai/service/database.dart'; // For Firestore operations

// GetxController provides lifecycle management and reactive state
class ChatController extends GetxController {
  final textC = TextEditingController(); // Text input controller
  final DatabaseMethods _db = DatabaseMethods(); // Firestore helper

  // Limits to prevent excessive data usage
  static const int _maxApiContextMessages =
      20; // Max messages sent to AI for context
  static const int _maxSavedMessages =
      50; // Max messages saved per conversation
  static const int _maxSavedConversations = 20; // Max conversations per user

  String?
  currentConversationId; // Firestore document ID of current conversation

  // Initial greeting message from AI tutor
  final _initialMessage = Message(
    msg: 'Hello, I am Albert, your AI tutor, how can I assist you today?',
    msgType: MessageType.bot,
  );

  // Reactive message list - .obs makes it observable for Obx widgets
  // UI automatically rebuilds when list changes
  final list = <Message>[].obs;

  // Constructor - add initial greeting when controller is created
  ChatController() {
    list.add(_initialMessage);
  }

  // Build conversation history for API context
  // Excludes initial greeting and "Thinking..." placeholder
  // Limited to last _maxApiContextMessages to prevent token overflow
  List<Map<String, String>> _buildConversationHistory() {
    final history = <Map<String, String>>[];

    for (final msg in list) {
      // Skip the initial greeting and "Thinking..." placeholder
      if (msg.msg == _initialMessage.msg || msg.msg == 'Thinking...') continue;

      // Convert to OpenAI message format
      history.add({
        "role": msg.msgType == MessageType.user ? "user" : "assistant",
        "content": msg.msg,
      });
    }

    // Truncate to last N messages to stay within token limits
    if (history.length > _maxApiContextMessages) {
      return history.sublist(history.length - _maxApiContextMessages);
    }

    return history;
  }

  // Send question to AI and get response
  // Called when user taps send button
  Future<void> askQuestion() async {
    if (textC.text.trim().isNotEmpty) {
      final question = textC.text;

      // Add user message to list
      list.add(Message(msg: question, msgType: MessageType.user));
      // Add temporary "Thinking..." placeholder
      list.add(Message(msg: 'Thinking...', msgType: MessageType.bot));

      // Build conversation history for context
      final history = _buildConversationHistory();
      // Remove the last user message since API adds it separately
      if (history.isNotEmpty && history.last['role'] == 'user') {
        history.removeLast();
      }

      // Call AI API with question and conversation history
      final res = await APIs.getAnswer(question, conversationHistory: history);

      // Replace "Thinking..." with actual response
      list.removeLast();
      list.add(Message(msg: res, msgType: MessageType.bot));

      // Clear input field
      textC.clear();
    }
  }

  // Check if conversation has actual user messages
  // Used to skip saving empty conversations
  bool get hasUserMessages {
    return list.any((msg) => msg.msgType == MessageType.user);
  }

  // Save conversation to Firestore
  // Truncates to last _maxSavedMessages to limit storage
  Future<void> saveConversation() async {
    if (!hasUserMessages) return; // Skip if no actual conversation

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Must be logged in to save

    // Truncate to last N messages for storage efficiency
    final messagesToSave = list.length > _maxSavedMessages
        ? list.sublist(list.length - _maxSavedMessages)
        : list.toList();
    // Convert Message objects to Maps for Firestore
    final messagesMap = messagesToSave.map((m) => m.toMap()).toList();

    if (currentConversationId != null) {
      // Update existing conversation document
      await _db.updateConversation(
        user.uid,
        currentConversationId!,
        messagesMap,
      );
    } else {
      // Create new conversation document
      final docRef = await _db.saveConversation(user.uid, messagesMap);
      currentConversationId = docRef.id;

      // Enforce conversation limit - delete oldest if too many
      await _db.enforceConversationLimit(user.uid, _maxSavedConversations);
    }
  }

  // Load a saved conversation from history
  // Called when user selects a conversation from ChatHistoryScreen
  void loadConversation(String conversationId, List<dynamic> messages) {
    currentConversationId = conversationId; // Set current ID for updates
    list.clear(); // Clear current messages
    // Convert each map back to Message object
    for (var msg in messages) {
      list.add(Message.fromMap(Map<String, dynamic>.from(msg)));
    }
  }

  // Start a fresh conversation
  // Called when user taps "New Chat" button
  void newConversation() {
    currentConversationId = null; // Reset conversation ID
    list.clear(); // Clear all messages
    list.add(_initialMessage); // Add initial greeting
  }
}
