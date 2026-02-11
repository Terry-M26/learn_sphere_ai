// DatabaseMethods - Firestore and Firebase Storage operations
// Handles all database CRUD operations for the app
// Collections: users/{userId}/modules, conversations, quizHistory, summaries
// Also handles file uploads to Firebase Storage

import 'dart:io'; // For File operations
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database
import 'package:firebase_storage/firebase_storage.dart'; // File storage

// Singleton-style class with static-like methods for database operations
class DatabaseMethods {
  // ==================== MODULE METHODS ====================

  // Add a new module to user's collection
  // Returns DocumentReference of created document
  Future addModuleDetails(
    Map<String, dynamic> moduleDetails,
    String userId,
  ) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("modules")
        .add(moduleDetails);
  }

  // Get real-time stream of user's modules
  // Returns Stream that updates when modules change
  Future<Stream<QuerySnapshot>> getModules(String userId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("modules")
        .snapshots();
  }

  // Update existing module details
  Future updateModuleDetails(
    String userId,
    String moduleId,
    Map<String, dynamic> moduleDetails,
  ) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("modules")
        .doc(moduleId)
        .update(moduleDetails);
  }

  // Delete a module document
  Future deleteModule(String userId, String moduleId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("modules")
        .doc(moduleId)
        .delete();
  }

  // ==================== LECTURE NOTES METHODS ====================

  // Get real-time stream of lecture notes for a module
  // Ordered by upload date (newest first)
  Future<Stream<QuerySnapshot>> getLectureNotes(
    String userId,
    String moduleId,
  ) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('modules')
        .doc(moduleId)
        .collection('lecture_notes')
        .orderBy('uploadDate', descending: true)
        .snapshots();
  }

  // Upload PDF to Firebase Storage and save metadata to Firestore
  // Returns download URL of uploaded file
  Future<String> uploadPDF(
    String userId,
    String moduleId,
    File file,
    String fileName,
    int fileSize,
  ) async {
    // Build storage path: users/{uid}/modules/{moduleId}/pdfs/{filename}
    String storagePath = 'users/$userId/modules/$moduleId/pdfs/$fileName';
    // Upload file to Firebase Storage
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child(storagePath)
        .putFile(file);

    // Wait for upload to complete and get download URL
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    // Save file metadata to Firestore for listing
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('modules')
        .doc(moduleId)
        .collection('lecture_notes')
        .add({
          'fileName': fileName,
          'downloadUrl': downloadUrl,
          'storagePath': storagePath, // Needed for deletion
          'fileSize': fileSize,
          'uploadDate': FieldValue.serverTimestamp(),
        });

    return downloadUrl;
  }

  // Delete PDF from both Storage and Firestore
  Future<void> deletePDF(
    String userId,
    String moduleId,
    String docId,
    String storagePath,
  ) async {
    // Delete file from Firebase Storage
    await FirebaseStorage.instance.ref().child(storagePath).delete();

    // Delete metadata from Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('modules')
        .doc(moduleId)
        .collection('lecture_notes')
        .doc(docId)
        .delete();
  }

  // Download PDF from Storage to local file
  Future<void> downloadPDFToFile(String downloadUrl, String filePath) async {
    await FirebaseStorage.instance
        .refFromURL(downloadUrl)
        .writeToFile(File(filePath));
  }

  // ==================== SUMMARY METHODS ====================

  // Save AI-generated summary to Firestore
  // Returns DocumentReference of created document
  Future<DocumentReference> saveSummary(
    String userId,
    String title,
    String content,
  ) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('summaries')
        .add({
          'title': title,
          'content': content,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  // Get real-time stream of user's summaries (newest first)
  Future<Stream<QuerySnapshot>> getSummaries(String userId) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('summaries')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Delete a summary document
  Future<void> deleteSummary(String userId, String summaryId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('summaries')
        .doc(summaryId)
        .delete();
  }

  // Update existing summary content
  Future<void> updateSummary(
    String userId,
    String summaryId,
    String title,
    String content,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('summaries')
        .doc(summaryId)
        .update({
          'title': title,
          'content': content,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  // ==================== QUIZ HISTORY METHODS ====================

  // Save completed quiz result to Firestore
  // Stores questions, answers, score for later review
  Future<DocumentReference> saveQuizResult(
    String userId,
    Map<String, dynamic> quizData,
  ) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('quiz_history')
        .add({
          'title': quizData['title'],
          'score': quizData['score'],
          'totalQuestions': quizData['totalQuestions'],
          'difficulty': quizData['difficulty'],
          'questions': quizData['questions'],
          'selectedAnswers': quizData['selectedAnswers'],
          'completedAt': FieldValue.serverTimestamp(),
        });
  }

  // Get real-time stream of quiz history (newest first)
  Future<Stream<QuerySnapshot>> getQuizHistory(String userId) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('quiz_history')
        .orderBy('completedAt', descending: true)
        .snapshots();
  }

  // Delete a quiz result document
  Future<void> deleteQuizResult(String userId, String quizId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('quiz_history')
        .doc(quizId)
        .delete();
  }

  // Get a single quiz result by ID
  Future<DocumentSnapshot> getQuizResult(String userId, String quizId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('quiz_history')
        .doc(quizId)
        .get();
  }

  // ==================== CHAT HISTORY METHODS ====================

  // Save new AI Tutor conversation
  // Returns DocumentReference for tracking conversation ID
  Future<DocumentReference> saveConversation(
    String userId,
    List<Map<String, dynamic>> messages,
  ) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chat_history')
        .add({
          'messages': messages,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  // Update existing conversation with new messages
  Future<void> updateConversation(
    String userId,
    String conversationId,
    List<Map<String, dynamic>> messages,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chat_history')
        .doc(conversationId)
        .update({
          'messages': messages,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  // Get real-time stream of conversations (most recent first)
  Stream<QuerySnapshot> getConversations(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chat_history')
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  // Get a single conversation by ID
  Future<DocumentSnapshot> getConversation(
    String userId,
    String conversationId,
  ) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chat_history')
        .doc(conversationId)
        .get();
  }

  // Delete a conversation document
  Future<void> deleteConversation(String userId, String conversationId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chat_history')
        .doc(conversationId)
        .delete();
  }

  // Enforce conversation limit - delete oldest conversations if limit exceeded
  Future<void> enforceConversationLimit(
    String userId,
    int maxConversations,
  ) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chat_history')
        .orderBy('updatedAt', descending: true)
        .get();

    if (querySnapshot.docs.length > maxConversations) {
      // Delete conversations beyond the limit (oldest ones)
      final docsToDelete = querySnapshot.docs.sublist(maxConversations);
      for (final doc in docsToDelete) {
        await doc.reference.delete();
      }
    }
  }
}
