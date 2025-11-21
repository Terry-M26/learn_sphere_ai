import 'package:cloud_firestore/cloud_firestore.dart';

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
}
