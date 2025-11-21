import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:learn_sphere_ai/service/database.dart';

class Module extends StatefulWidget {
  final String? moduleId;
  final String? moduleName;
  final String? lecturer;
  final String? year;
  final String? semester;
  final bool isEditing;

  const Module({
    super.key,
    this.moduleId,
    this.moduleName,
    this.lecturer,
    this.year,
    this.semester,
    this.isEditing = false,
  });

  @override
  State<Module> createState() => _ModuleState();
}

class _ModuleState extends State<Module> {
  TextEditingController _moduleNameController = TextEditingController();
  TextEditingController _lecturerController = TextEditingController();
  TextEditingController _semesterController = TextEditingController();
  TextEditingController _yearController = TextEditingController();

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _moduleNameController.text = widget.moduleName ?? '';
      _lecturerController.text = widget.lecturer ?? '';
      _yearController.text = widget.year ?? '';
      _semesterController.text = widget.semester ?? '';
    }
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    IconData icon,
    String hint,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.blue.shade300 : Colors.blue.shade800,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey.shade600 : Colors.blue.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.grey : Colors.blue).withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isEditing
                  ? [Colors.orange.shade600, Colors.blue.shade600]
                  : [Colors.blue.shade600, Colors.orange.shade400],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isEditing
                    ? Icons.edit_rounded
                    : Icons.add_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                widget.isEditing ? 'Edit Module' : 'Add Module',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Colors.grey.shade800, Colors.grey.shade700]
                      : [Colors.blue.shade50, Colors.white],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey.shade600 : Colors.blue.shade200,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    widget.isEditing
                        ? Icons.edit_note_rounded
                        : Icons.library_books_rounded,
                    size: 48,
                    color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.isEditing
                        ? 'Update Module Information'
                        : 'Create New Module',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.blue.shade300
                          : Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.isEditing
                        ? 'Modify the details below to update your module'
                        : 'Fill in the details below to add a new module',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
            SizedBox(height: 32),
            _buildFormField(
                  'Module/Subject Name',
                  _moduleNameController,
                  Icons.book_rounded,
                  'Enter module or subject name',
                  context,
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 100.ms)
                .slideX(begin: -0.3, end: 0),

            SizedBox(height: 24),
            _buildFormField(
                  'Lecturer/Teacher',
                  _lecturerController,
                  Icons.person_rounded,
                  'Enter lecturer or teacher name',
                  context,
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideX(begin: 0.3, end: 0),

            SizedBox(height: 24),
            _buildFormField(
                  'Academic Year',
                  _yearController,
                  Icons.calendar_today_rounded,
                  'Enter academic year (e.g., 2nd year)',
                  context,
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 300.ms)
                .slideX(begin: -0.3, end: 0),

            SizedBox(height: 24),
            _buildFormField(
                  'Semester',
                  _semesterController,
                  Icons.school_rounded,
                  'Enter semester (e.g., 2nd semester)',
                  context,
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideX(begin: 0.3, end: 0),

            SizedBox(height: 40),
            Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.isEditing
                          ? [Colors.orange.shade600, Colors.orange.shade800]
                          : [Colors.blue.shade600, Colors.blue.shade800],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.isEditing ? Colors.orange : Colors.blue)
                            .withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_moduleNameController.text.isEmpty ||
                          _lecturerController.text.isEmpty ||
                          _yearController.text.isEmpty ||
                          _semesterController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill in all fields'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Map<String, dynamic> moduleDetails = {
                        "moduleName": _moduleNameController.text,
                        "lecturer": _lecturerController.text,
                        "year": _yearController.text,
                        "semester": _semesterController.text,
                        "userId": uid,
                      };

                      if (widget.isEditing && widget.moduleId != null) {
                        await DatabaseMethods().updateModuleDetails(
                          uid,
                          widget.moduleId!,
                          moduleDetails,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Module updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        await DatabaseMethods().addModuleDetails(
                          moduleDetails,
                          uid,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Module added successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }

                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isEditing
                              ? Icons.update_rounded
                              : Icons.add_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          widget.isEditing ? "Update Module" : "Add Module",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 500.ms)
                .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}
