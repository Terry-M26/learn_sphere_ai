import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:learn_sphere_ai/screen/feature/AddModule.dart';
import 'package:learn_sphere_ai/screen/feature/LectureNotes_screen.dart';
import 'package:learn_sphere_ai/service/database.dart';

class LecturestorageScreen extends StatefulWidget {
  const LecturestorageScreen({super.key});

  @override
  State<LecturestorageScreen> createState() => _State();
}

class _State extends State<LecturestorageScreen> {
  Stream? ModulesStream;

  getModules() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    ModulesStream = await DatabaseMethods().getModules(uid);
    setState(() {});
  }

  @override
  void initState() {
    getModules();
    super.initState();
  }

  Widget allModulesDetails() {
    return StreamBuilder(
      stream: ModulesStream,
      builder: (context, AsyncSnapshot snapshot) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(
                          () => LectureNotesScreen(
                            moduleId: ds.id,
                            moduleName: ds["moduleName"],
                          ),
                        );
                      },
                      child: Card(
                        elevation: 8,
                        shadowColor: Colors.yellow.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [Colors.grey.shade800, Colors.grey.shade700]
                                  : [Colors.white, Colors.blue.shade50],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ds["moduleName"],
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.yellow.shade800,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Module',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.grey.shade700
                                          : Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit_rounded,
                                            color: isDark
                                                ? Colors.blue.shade300
                                                : Colors.blue.shade700,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            Get.to(
                                              () => Module(
                                                moduleId: ds.id,
                                                moduleName: ds["moduleName"],
                                                lecturer: ds["lecturer"],
                                                year: ds["year"],
                                                semester: ds["semester"],
                                                isEditing: true,
                                              ),
                                            );
                                          },
                                          tooltip: 'Edit Module',
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_rounded,
                                            color: isDark
                                                ? Colors.red.shade400
                                                : Colors.red.shade600,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            _showDeleteConfirmationDialog(
                                              ds.id,
                                              ds["moduleName"],
                                            );
                                          },
                                          tooltip: 'Delete Module',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoCard(
                                      Icons.person_rounded,
                                      'Lecturer',
                                      ds["lecturer"],
                                      Colors.orange,
                                      context,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _buildInfoCard(
                                      Icons.calendar_today_rounded,
                                      'Year',
                                      ds["year"],
                                      Colors.green,
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              _buildInfoCard(
                                Icons.school_rounded,
                                'Semester',
                                ds["semester"],
                                Colors.purple,
                                context,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container();
      },
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String label,
    String value,
    MaterialColor color,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? color.withOpacity(0.4) : color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? color.withOpacity(0.3) : color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isDark ? color.shade300 : color.shade700,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? color.shade300 : color.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.orange.shade400],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Get.to(() => Module(isEditing: false)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            'Add Module',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 255, 230, 2),
                const Color.fromARGB(255, 248, 151, 4),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storage_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Lecture Storage',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),

      body: Container(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            Expanded(
              child: allModulesDetails()
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String moduleId, String moduleName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Module'),
          content: Text('Are you sure you want to delete "$moduleName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser!.uid;
                await DatabaseMethods().deleteModule(uid, moduleId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Module "$moduleName" deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
