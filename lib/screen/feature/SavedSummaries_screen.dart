import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:learn_sphere_ai/service/database.dart';

class SavedSummariesScreen extends StatefulWidget {
  const SavedSummariesScreen({super.key});

  @override
  State<SavedSummariesScreen> createState() => _SavedSummariesScreenState();
}

class _SavedSummariesScreenState extends State<SavedSummariesScreen> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final String _userId = FirebaseAuth.instance.currentUser!.uid;
  Stream<QuerySnapshot>? _summariesStream;

  @override
  void initState() {
    super.initState();
    _initializeSummaries();
  }

  void _initializeSummaries() async {
    _summariesStream = await _databaseMethods.getSummaries(_userId);
    setState(() {});
  }

  Future<void> _exportAsPdf(String title, String content) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Generating PDF...'),
            ],
          ),
        ),
      );

      // Create PDF document
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();
      final PdfGraphics graphics = page.graphics;

      // Title
      graphics.drawString(
        title,
        PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 30),
      );

      // Date
      final dateStr =
          'Generated: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}';
      graphics.drawString(
        dateStr,
        PdfStandardFont(
          PdfFontFamily.helvetica,
          10,
          style: PdfFontStyle.italic,
        ),
        brush: PdfSolidBrush(PdfColor(128, 128, 128)),
        bounds: Rect.fromLTWH(0, 35, page.getClientSize().width, 15),
      );

      // Content
      final PdfTextElement textElement = PdfTextElement(
        text: content,
        font: PdfStandardFont(PdfFontFamily.helvetica, 12),
      );

      final PdfLayoutFormat layoutFormat = PdfLayoutFormat(
        layoutType: PdfLayoutType.paginate,
      );

      textElement.draw(
        page: page,
        bounds: Rect.fromLTWH(
          0,
          60,
          page.getClientSize().width,
          page.getClientSize().height - 60,
        ),
        format: layoutFormat,
      );

      // Save to temp directory
      final Directory tempDir = await getTemporaryDirectory();
      final String sanitizedTitle = title
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_');
      final String filePath = '${tempDir.path}/${sanitizedTitle}_summary.pdf';

      final File file = File(filePath);
      await file.writeAsBytes(await document.save());
      document.dispose();

      // Close loading dialog
      Navigator.of(context).pop();

      // Open the PDF
      await OpenFile.open(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF exported successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(String summaryId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Summary'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _databaseMethods.deleteSummary(_userId, summaryId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Summary deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );
  }

  void _showViewDialog(String title, String content, String summaryId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _exportAsPdf(title, content);
                    },
                    icon: const Icon(Icons.picture_as_pdf_rounded),
                    label: const Text('Export PDF'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    final date = timestamp.toDate();
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
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
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 253, 174, 3),
                Color.fromARGB(255, 245, 16, 17),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bookmark_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Saved Summaries',
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
      body: _summariesStream == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _summariesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border_rounded,
                          size: 80,
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No saved summaries yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your saved summaries will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title'] ?? 'Untitled';
                    final content = data['content'] ?? '';
                    final createdAt = data['createdAt'] as Timestamp?;

                    return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: 4,
                            shadowColor: Colors.orange.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () =>
                                  _showViewDialog(title, content, doc.id),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isDark
                                        ? [
                                            Colors.grey.shade800,
                                            Colors.grey.shade700,
                                          ]
                                        : [Colors.white, Colors.orange.shade50],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.summarize_rounded,
                                            color: Colors.orange.shade600,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _formatDate(createdAt),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? Colors.grey.shade500
                                                      : Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: Icon(
                                            Icons.more_vert,
                                            color: isDark
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade600,
                                          ),
                                          onSelected: (value) {
                                            if (value == 'export') {
                                              _exportAsPdf(title, content);
                                            } else if (value == 'delete') {
                                              _showDeleteDialog(doc.id, title);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'export',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .picture_as_pdf_rounded,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text('Export as PDF'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete_rounded,
                                                    size: 20,
                                                    color: Colors.red,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.red.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      content,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade700,
                                        height: 1.4,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: index * 100),
                          duration: 400.ms,
                        )
                        .slideX(
                          begin: 0.1,
                          end: 0,
                          delay: Duration(milliseconds: index * 100),
                          duration: 400.ms,
                        );
                  },
                );
              },
            ),
    );
  }
}
