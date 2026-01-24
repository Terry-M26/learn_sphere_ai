import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:learn_sphere_ai/apis/apis.dart';
import 'package:learn_sphere_ai/helper/auth_helper.dart';
import 'package:learn_sphere_ai/service/database.dart';
import 'package:learn_sphere_ai/screen/feature/SavedSummaries_screen.dart';

class LectureSummaryScreen extends StatefulWidget {
  const LectureSummaryScreen({super.key});

  @override
  State<LectureSummaryScreen> createState() => _LectureSummaryScreenState();
}

class _LectureSummaryScreenState extends State<LectureSummaryScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedFileName;
  String? _extractedPdfText;
  bool _isPdfSelected = false;
  bool _isSummarizing = false;
  bool _isExtractingText = false;
  String? _generatedSummary;
  int _currentChunk = 0;
  int _totalChunks = 0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isExtractingText = true;
          _selectedFileName = result.files.single.name;
          _isPdfSelected = true;
          _textController.clear();
        });

        // Extract text from PDF
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        final extractedText = await _extractTextFromPdf(bytes);

        setState(() {
          _extractedPdfText = extractedText;
          _isExtractingText = false;
        });

        if (extractedText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not extract text from PDF. It may be image-based.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Extracted ${extractedText.length} characters from PDF',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isExtractingText = false;
        _isPdfSelected = false;
        _selectedFileName = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> _extractTextFromPdf(List<int> bytes) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      String text = PdfTextExtractor(document).extractText();
      document.dispose();
      return text.trim();
    } catch (e) {
      debugPrint('PDF text extraction error: $e');
      return '';
    }
  }

  void _clearPDF() {
    setState(() {
      _selectedFileName = null;
      _extractedPdfText = null;
      _isPdfSelected = false;
    });
  }

  // Maximum characters per chunk (~3000 chars ≈ 750 tokens, leaving room for system prompt)
  static const int _maxChunkSize = 3000;

  List<String> _splitIntoChunks(String text) {
    final chunks = <String>[];

    if (text.length <= _maxChunkSize) {
      return [text];
    }

    int start = 0;
    while (start < text.length) {
      int end = start + _maxChunkSize;

      if (end >= text.length) {
        chunks.add(text.substring(start));
        break;
      }

      // Try to break at a paragraph or sentence boundary
      int breakPoint = text.lastIndexOf('\n\n', end);
      if (breakPoint <= start) {
        breakPoint = text.lastIndexOf('. ', end);
      }
      if (breakPoint <= start) {
        breakPoint = text.lastIndexOf(' ', end);
      }
      if (breakPoint <= start) {
        breakPoint = end;
      }

      chunks.add(text.substring(start, breakPoint + 1).trim());
      start = breakPoint + 1;
    }

    return chunks;
  }

  Future<void> _summarize() async {
    final textToProcess = _textToSummarize;

    if (textToProcess.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No text to summarize'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSummarizing = true;
      _generatedSummary = null;
      _currentChunk = 0;
      _totalChunks = 0;
    });

    try {
      String summary;
      final chunks = _splitIntoChunks(textToProcess);

      if (chunks.length == 1) {
        // Small text - summarize directly
        summary = await APIs.summarizeText(textToProcess);
      } else {
        // Large text - process in chunks
        setState(() {
          _totalChunks = chunks.length;
        });

        final chunkSummaries = <String>[];

        for (int i = 0; i < chunks.length; i++) {
          setState(() {
            _currentChunk = i + 1;
          });

          final chunkSummary = await APIs.summarizeChunk(
            chunks[i],
            i + 1,
            chunks.length,
          );

          if (chunkSummary.isNotEmpty) {
            chunkSummaries.add(chunkSummary);
          }
        }

        // Combine all chunk summaries
        if (chunkSummaries.length > 1) {
          setState(() {
            _currentChunk = 0; // Indicate combining phase
          });
          summary = await APIs.combineSummaries(chunkSummaries);
        } else if (chunkSummaries.length == 1) {
          summary = chunkSummaries.first;
        } else {
          summary = 'Could not generate summary. Please try again.';
        }
      }

      setState(() {
        _generatedSummary = summary;
        _textController.text = summary;
        _isSummarizing = false;
        // Clear PDF selection so user can edit/save the summary
        _isPdfSelected = false;
        _selectedFileName = null;
        _extractedPdfText = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Summary generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isSummarizing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating summary: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveSummary() async {
    // Check if user is logged in
    if (!AuthHelper.isLoggedIn) {
      final loggedIn = await AuthHelper.showLoginRequiredDialog(
        context,
        featureName: 'Save Summary',
      );
      if (!loggedIn) return;
    }
    _showSaveDialog();
  }

  void _showSaveDialog() {
    final nameController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Save Summary'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Summary Name',
              hintText: 'Enter a name for this summary',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            enabled: !isSaving,
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final title = nameController.text.trim();
                      if (title.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a name'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSaving = true);

                      try {
                        final userId = FirebaseAuth.instance.currentUser!.uid;
                        await DatabaseMethods().saveSummary(
                          userId,
                          title,
                          _textController.text,
                        );

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Summary saved successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error saving: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _openSavedSummaries() async {
    // Check if user is logged in
    if (!AuthHelper.isLoggedIn) {
      final loggedIn = await AuthHelper.showLoginRequiredDialog(
        context,
        featureName: 'Saved Summaries',
      );
      if (!loggedIn) return;
    }
    Get.to(() => const SavedSummariesScreen());
  }

  bool get _canSummarize {
    if (_isExtractingText) return false;
    if (_isPdfSelected) {
      return _extractedPdfText != null && _extractedPdfText!.isNotEmpty;
    }
    return _textController.text.trim().isNotEmpty;
  }

  String get _textToSummarize {
    if (_isPdfSelected && _extractedPdfText != null) {
      return _extractedPdfText!;
    }
    return _textController.text.trim();
  }

  bool get _canSave {
    return _textController.text.trim().isNotEmpty && !_isSummarizing;
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
              Icon(Icons.summarize_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Lecture Summary',
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 253, 174, 3),
              Color.fromARGB(255, 245, 16, 17),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _openSavedSummaries,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.list_rounded, color: Colors.white),
          label: const Text(
            'Saved',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PDF Upload Section
            _buildPdfUploadSection(isDark)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms),

            const SizedBox(height: 16),

            // Divider with "OR"
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 16),

            // Text Input Section
            _buildTextInputSection(isDark)
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(isDark)
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms),

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildPdfUploadSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isPdfSelected
              ? Colors.orange.shade400
              : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          width: _isPdfSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.picture_as_pdf_rounded,
            size: 48,
            color: _isPdfSelected
                ? Colors.orange.shade400
                : Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            _selectedFileName ?? 'Upload PDF to Summarize',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isExtractingText
                ? 'Extracting text from PDF...'
                : (_isPdfSelected
                      ? (_extractedPdfText != null &&
                                _extractedPdfText!.isNotEmpty
                            ? '${_extractedPdfText!.length} characters extracted'
                            : 'No text could be extracted')
                      : 'Select a PDF file from your device'),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _isPdfSelected || _isExtractingText
                    ? null
                    : _pickPDF,
                icon: _isExtractingText
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.upload_file_rounded),
                label: Text(_isExtractingText ? 'Extracting...' : 'Choose PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade400,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_isPdfSelected) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _clearPDF,
                  icon: Icon(Icons.close_rounded, color: Colors.red.shade400),
                  tooltip: 'Remove PDF',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: !_isPdfSelected && _textController.text.isNotEmpty
              ? Colors.orange.shade400
              : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          width: !_isPdfSelected && _textController.text.isNotEmpty ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Paste Text to Summarize',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          TextField(
            controller: _textController,
            enabled: !_isPdfSelected,
            maxLines: 8,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: _isPdfSelected
                  ? 'Clear PDF selection to paste text here...'
                  : 'Paste your lecture notes or text here...',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            ),
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        // Summarize Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _canSummarize && !_isSummarizing ? _summarize : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade500,
              foregroundColor: Colors.white,
              disabledBackgroundColor: isDark
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: _isSummarizing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _totalChunks > 0
                            ? (_currentChunk == 0
                                  ? 'Combining summaries...'
                                  : 'Processing chunk $_currentChunk/$_totalChunks...')
                            : 'Summarizing...',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded),
                      SizedBox(width: 8),
                      Text(
                        'Summarize',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 12),

        // Save Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _canSave ? _saveSummary : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green.shade600,
              side: BorderSide(
                color: _canSave
                    ? Colors.green.shade400
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.save_rounded,
                  color: _canSave
                      ? Colors.green.shade600
                      : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                ),
                const SizedBox(width: 8),
                Text(
                  'Save Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _canSave
                        ? Colors.green.shade600
                        : (isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
