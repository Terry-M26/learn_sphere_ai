import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseMethods {
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

  Future<Stream<QuerySnapshot>> getModules(String userId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("modules")
        .snapshots();
  }

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

  Future deleteModule(String userId, String moduleId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("modules")
        .doc(moduleId)
        .delete();
  }

  // Lecture Notes Methods
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

  Future<String> uploadPDF(
    String userId,
    String moduleId,
    File file,
    String fileName,
    int fileSize,
  ) async {
    // Upload to Firebase Storage
    String storagePath = 'users/$userId/modules/$moduleId/pdfs/$fileName';
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child(storagePath)
        .putFile(file);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    // Save metadata to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('modules')
        .doc(moduleId)
        .collection('lecture_notes')
        .add({
          'fileName': fileName,
          'downloadUrl': downloadUrl,
          'storagePath': storagePath,
          'fileSize': fileSize,
          'uploadDate': FieldValue.serverTimestamp(),
        });

    return downloadUrl;
  }

  Future<void> deletePDF(
    String userId,
    String moduleId,
    String docId,
    String storagePath,
  ) async {
    // Delete from Storage
    await FirebaseStorage.instance.ref().child(storagePath).delete();

    // Delete from Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('modules')
        .doc(moduleId)
        .collection('lecture_notes')
        .doc(docId)
        .delete();
  }

  Future<void> downloadPDFToFile(String downloadUrl, String filePath) async {
    await FirebaseStorage.instance
        .refFromURL(downloadUrl)
        .writeToFile(File(filePath));
  }

  // Lecture Summary Methods (standalone collection)
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

  Future<Stream<QuerySnapshot>> getSummaries(String userId) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('summaries')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteSummary(String userId, String summaryId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('summaries')
        .doc(summaryId)
        .delete();
  }

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

  // Quiz History Methods
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

  Future<Stream<QuerySnapshot>> getQuizHistory(String userId) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('quiz_history')
        .orderBy('completedAt', descending: true)
        .snapshots();
  }

  Future<void> deleteQuizResult(String userId, String quizId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('quiz_history')
        .doc(quizId)
        .delete();
  }

  Future<DocumentSnapshot> getQuizResult(String userId, String quizId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('quiz_history')
        .doc(quizId)
        .get();
  }
}
