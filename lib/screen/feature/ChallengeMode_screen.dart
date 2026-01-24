import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:get/get.dart';
import 'package:learn_sphere_ai/apis/apis.dart';
import 'package:learn_sphere_ai/helper/auth_helper.dart';
import 'Quiz_screen.dart';
import 'QuizHistory_screen.dart';

class ChallengeModeScreen extends StatefulWidget {
  const ChallengeModeScreen({super.key});

  @override
  State<ChallengeModeScreen> createState() => _ChallengeModeScreenState();
}

class _ChallengeModeScreenState extends State<ChallengeModeScreen> {
  String? _selectedFileName;
  String? _extractedPdfText;
  bool _isPdfSelected = false;
  bool _isExtractingText = false;
  bool _isGenerating = false;

  // Progress tracking for chunked generation
  int _currentChunk = 0;
  int _totalChunks = 0;
  String? _lastError;

  // Quiz settings
  int _selectedQuestionCount = 10;
  String _selectedDifficulty = 'Medium';

  final List<int> _questionCountOptions = [5, 10, 20, 30];
  final List<String> _difficultyOptions = ['Easy', 'Medium', 'Hard'];

  @override
  void dispose() {
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

  bool get _canGenerateQuiz {
    if (_isExtractingText || _isGenerating) return false;
    return _isPdfSelected &&
        _extractedPdfText != null &&
        _extractedPdfText!.isNotEmpty;
  }

  Future<bool> _checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('api.openai.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> _generateQuiz() async {
    if (!_canGenerateQuiz) return;

    // Check network connectivity first
    final hasNetwork = await _checkNetworkConnectivity();
    if (!hasNetwork) {
      _showNoNetworkDialog();
      return;
    }

    setState(() {
      _isGenerating = true;
      _currentChunk = 0;
      _totalChunks = 0;
      _lastError = null;
    });

    try {
      // Generate questions using AI with progress callback
      final questions = await APIs.generateQuizQuestions(
        text: _extractedPdfText!,
        questionCount: _selectedQuestionCount,
        difficulty: _selectedDifficulty,
        onProgress: (current, total) {
          setState(() {
            _currentChunk = current;
            _totalChunks = total;
          });
        },
      );

      setState(() {
        _isGenerating = false;
        _currentChunk = 0;
        _totalChunks = 0;
      });

      if (questions.isEmpty) {
        setState(() {
          _lastError = 'Could not generate questions from the lecture content.';
        });
        _showRetryDialog();
        return;
      }

      if (questions.length < _selectedQuestionCount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Generated ${questions.length} questions (requested $_selectedQuestionCount)',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // Navigate to Quiz screen with generated questions
      Get.to(
        () => QuizScreen(
          lectureTitle: _selectedFileName ?? 'Quiz',
          questionCount: questions.length,
          difficulty: _selectedDifficulty,
          lectureText: _extractedPdfText!,
          questions: questions,
        ),
      );
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _currentChunk = 0;
        _totalChunks = 0;
        _lastError = e.toString();
      });
      _showRetryDialog();
    }
  }

  void _showNoNetworkDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('No Internet'),
          ],
        ),
        content: const Text(
          'Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateQuiz();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Generation Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Could not generate quiz questions.'),
            if (_lastError != null) ...[
              const SizedBox(height: 8),
              Text(
                _lastError!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 12),
            const Text('Would you like to try again?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _generateQuiz();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
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
                Color.fromARGB(255, 230, 30, 220),
                Color.fromARGB(255, 10, 180, 247),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.quiz_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Challenge Mode',
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
              Color.fromARGB(255, 230, 30, 220),
              Color.fromARGB(255, 10, 180, 247),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            if (!AuthHelper.isLoggedIn) {
              final loggedIn = await AuthHelper.showLoginRequiredDialog(
                context,
                featureName: 'Quiz History',
              );
              if (!loggedIn) return;
            }
            Get.to(() => const QuizHistoryScreen());
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.history_rounded, color: Colors.white),
          label: const Text(
            'History',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info Card
            _buildInfoCard(isDark)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms),

            const SizedBox(height: 20),

            // PDF Upload Section
            _buildPdfUploadSection(isDark)
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms),

            const SizedBox(height: 20),

            // Quiz Settings Section
            _buildQuizSettingsSection(isDark)
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms),

            const SizedBox(height: 24),

            // Generate Quiz Button
            _buildGenerateButton(isDark)
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 230, 30, 220).withOpacity(0.1),
            const Color.fromARGB(255, 10, 180, 247).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.purple.withOpacity(0.3)
              : Colors.purple.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 230, 30, 220),
                  Color.fromARGB(255, 10, 180, 247),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Test Your Knowledge',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload a lecture PDF and let AI generate multiple choice questions to challenge yourself!',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
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
              ? Colors.purple.shade400
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
                ? Colors.purple.shade400
                : Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            _selectedFileName ?? 'Upload Lecture PDF',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _isExtractingText
                ? 'Extracting text from PDF...'
                : (_isPdfSelected
                      ? (_extractedPdfText != null &&
                                _extractedPdfText!.isNotEmpty
                            ? '${_extractedPdfText!.length} characters extracted • Ready to generate quiz'
                            : 'No text could be extracted')
                      : 'Select a PDF file to generate questions from'),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
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
                  backgroundColor: Colors.purple.shade400,
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

  Widget _buildQuizSettingsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
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
          Row(
            children: [
              Icon(
                Icons.settings_rounded,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Quiz Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Question Count
          Text(
            'Number of Questions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _questionCountOptions.map((count) {
              final isSelected = _selectedQuestionCount == count;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedQuestionCount = count),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: count != _questionCountOptions.last ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 230, 30, 220),
                                Color.fromARGB(255, 10, 180, 247),
                              ],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade300),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Difficulty
          Text(
            'Difficulty Level',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _difficultyOptions.map((difficulty) {
              final isSelected = _selectedDifficulty == difficulty;
              final color = _getDifficultyColor(difficulty);
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDifficulty = difficulty),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: difficulty != _difficultyOptions.last ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.2)
                          : (isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : (isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade300),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        difficulty,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? color
                              : (isDark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Widget _buildGenerateButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _canGenerateQuiz
            ? const LinearGradient(
                colors: [
                  Color.fromARGB(255, 230, 30, 220),
                  Color.fromARGB(255, 10, 180, 247),
                ],
              )
            : null,
        boxShadow: _canGenerateQuiz
            ? [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: _canGenerateQuiz ? _generateQuiz : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _canGenerateQuiz
              ? Colors.transparent
              : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          foregroundColor: Colors.white,
          disabledForegroundColor: isDark
              ? Colors.grey.shade500
              : Colors.grey.shade500,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isGenerating
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
                    _totalChunks > 1
                        ? 'Processing chunk $_currentChunk/$_totalChunks...'
                        : 'Generating Quiz...',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Generate Quiz',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
