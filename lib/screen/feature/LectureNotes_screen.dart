// LectureNotesScreen - View and manage lecture files within a module
// Displays list of uploaded PDF files for a specific module
// Features: upload PDF, download/open PDF, delete files, Firebase Storage integration

import 'dart:io'; // For File operations
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore streams
import 'package:firebase_auth/firebase_auth.dart'; // For user ID
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // For PDF file selection
import 'package:open_file/open_file.dart'; // For opening downloaded PDF
import 'package:path_provider/path_provider.dart'; // For temp directory
import 'package:learn_sphere_ai/service/database.dart'; // For Firestore/Storage operations

// StatefulWidget to manage lecture notes list and upload state
class LectureNotesScreen extends StatefulWidget {
  final String moduleId; // ID of the parent module
  final String moduleName; // Name displayed in AppBar

  const LectureNotesScreen({
    super.key,
    required this.moduleId, // Required to fetch correct notes
    required this.moduleName, // Required for display
  });

  @override
  State<LectureNotesScreen> createState() => _LectureNotesScreenState();
}

class _LectureNotesScreenState extends State<LectureNotesScreen> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final String _userId = FirebaseAuth.instance.currentUser!.uid;
  bool _isUploading = false;
  Stream<QuerySnapshot>? _lectureNotesStream;

  void _initializeLectureNotes() async {
    _lectureNotesStream = await _databaseMethods.getLectureNotes(
      _userId,
      widget.moduleId,
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initializeLectureNotes();
  }

  Future<void> _pickAndUploadPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isUploading = true;
        });

        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        int fileSize = result.files.single.size;

        // Upload using database service
        await _databaseMethods.uploadPDF(
          _userId,
          widget.moduleId,
          file,
          fileName,
          fileSize,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _downloadAndOpenPDF(String downloadUrl, String fileName) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Opening PDF...'),
            ],
          ),
        ),
      );

      // Get temporary directory
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/$fileName';

      // Download file
      await _databaseMethods.downloadPDFToFile(downloadUrl, filePath);

      // Close loading dialog
      Navigator.of(context).pop();

      // Open file
      await OpenFile.open(filePath);
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePDF(
    String docId,
    String storagePath,
    String fileName,
  ) async {
    try {
      // Delete using database service
      await _databaseMethods.deletePDF(
        _userId,
        widget.moduleId,
        docId,
        storagePath,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fileName deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(String docId, String storagePath, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete PDF'),
        content: Text('Are you sure you want to delete "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletePDF(docId, storagePath, fileName);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lecture Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.moduleName,
              style: TextStyle(fontSize: 14, color: Colors.orange),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _pickAndUploadPDF,
        backgroundColor: Colors.blue,
        icon: _isUploading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(Icons.add, color: Colors.white),
        label: Text(
          _isUploading ? 'Uploading...' : 'Add PDF',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _lectureNotesStream == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _lectureNotesStream!,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No lecture notes yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first PDF',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                            size: 32,
                          ),
                        ),
                        title: Text(
                          data['fileName'] ?? 'Unknown',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              'Size: ${_formatFileSize(data['fileSize'] ?? 0)}',
                            ),
                            Text('Date: ${_formatDate(data['uploadDate'])}'),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'open',
                              child: Row(
                                children: [
                                  Icon(Icons.open_in_new, size: 20),
                                  SizedBox(width: 8),
                                  Text('Open'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'open') {
                              _downloadAndOpenPDF(
                                data['downloadUrl'],
                                data['fileName'],
                              );
                            } else if (value == 'delete') {
                              _showDeleteDialog(
                                doc.id,
                                data['storagePath'],
                                data['fileName'],
                              );
                            }
                          },
                        ),
                        onTap: () => _downloadAndOpenPDF(
                          data['downloadUrl'],
                          data['fileName'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
