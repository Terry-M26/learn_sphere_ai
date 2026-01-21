import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_sphere_ai/service/database.dart';
import 'QuizResults_screen.dart';

class QuizScreen extends StatefulWidget {
  final String lectureTitle;
  final int questionCount;
  final String difficulty;
  final String lectureText;
  final List<Map<String, dynamic>>? questions;

  const QuizScreen({
    super.key,
    required this.lectureTitle,
    required this.questionCount,
    required this.difficulty,
    required this.lectureText,
    this.questions,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  late List<Map<String, dynamic>> _questions;
  late List<int?> _selectedAnswers;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Use provided questions or generate mock for testing
    _questions = widget.questions ?? _generateMockQuestions();
    _selectedAnswers = List.filled(_questions.length, null);
  }

  List<Map<String, dynamic>> _generateMockQuestions() {
    // Mock questions for UI testing (fallback)
    return List.generate(widget.questionCount, (index) {
      return {
        'question':
            'This is sample question ${index + 1} about the lecture content. What is the correct answer for this ${widget.difficulty.toLowerCase()} level question?',
        'options': [
          'Option A - This could be the answer',
          'Option B - This might be correct',
          'Option C - Consider this option',
          'Option D - Or perhaps this one',
        ],
        'correctAnswer': index % 4,
        'explanation':
            'The correct answer is Option ${String.fromCharCode(65 + (index % 4))} because this explanation demonstrates how the AI will provide context about why this answer is correct and the others are not.',
      };
    });
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _goToQuestion(int index) {
    setState(() {
      _currentQuestionIndex = index;
    });
  }

  bool get _allQuestionsAnswered {
    return !_selectedAnswers.contains(null);
  }

  int get _answeredCount {
    return _selectedAnswers.where((a) => a != null).length;
  }

  Future<void> _submitQuiz() async {
    if (!_allQuestionsAnswered) {
      _showIncompleteDialog();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Calculate score
    int correctCount = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i]['correctAnswer']) {
        correctCount++;
      }
    }

    // Save quiz result to Firebase
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await DatabaseMethods().saveQuizResult(userId, {
        'title': widget.lectureTitle,
        'score': correctCount,
        'totalQuestions': _questions.length,
        'difficulty': widget.difficulty,
        'questions': _questions,
        'selectedAnswers': _selectedAnswers.cast<int>(),
      });
    } catch (e) {
      debugPrint('Error saving quiz result: $e');
    }

    setState(() {
      _isSubmitting = false;
    });

    // Navigate to results screen
    Get.off(
      () => QuizResultsScreen(
        lectureTitle: widget.lectureTitle,
        questions: _questions,
        selectedAnswers: _selectedAnswers.cast<int>(),
        difficulty: widget.difficulty,
        lectureText: widget.lectureText,
      ),
    );
  }

  void _showIncompleteDialog() {
    final unansweredCount = _selectedAnswers.where((a) => a == null).length;
    final unansweredIndices = <int>[];
    for (int i = 0; i < _selectedAnswers.length; i++) {
      if (_selectedAnswers[i] == null) {
        unansweredIndices.add(i + 1);
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Incomplete Quiz'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have $unansweredCount unanswered question${unansweredCount > 1 ? 's' : ''}:',
            ),
            const SizedBox(height: 8),
            Text(
              'Questions: ${unansweredIndices.join(', ')}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Please answer all questions before submitting.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Go to first unanswered question
              final firstUnanswered = _selectedAnswers.indexOf(null);
              if (firstUnanswered != -1) {
                _goToQuestion(firstUnanswered);
              }
            },
            child: const Text('Go to First Unanswered'),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.exit_to_app_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Exit Quiz?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to exit? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentQuestion = _questions[_currentQuestionIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitConfirmation();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _showExitConfirmation,
          ),
          title: Column(
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.difficulty,
                style: TextStyle(
                  fontSize: 12,
                  color: _getDifficultyColor(widget.difficulty),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_answeredCount/${_questions.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress Bar
            _buildProgressBar(isDark),

            // Question Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question Card
                    _buildQuestionCard(currentQuestion, isDark)
                        .animate(key: ValueKey(_currentQuestionIndex))
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.1, end: 0, duration: 300.ms),

                    const SizedBox(height: 20),

                    // Options
                    ...List.generate(
                      (currentQuestion['options'] as List).length,
                      (index) =>
                          _buildOptionCard(
                                index,
                                currentQuestion['options'][index],
                                isDark,
                              )
                              .animate(
                                key: ValueKey(
                                  '${_currentQuestionIndex}_$index',
                                ),
                              )
                              .fadeIn(
                                delay: Duration(milliseconds: 50 * index),
                                duration: 300.ms,
                              )
                              .slideX(begin: 0.1, end: 0, duration: 300.ms),
                    ),

                    const SizedBox(height: 20),

                    // Question Navigator
                    _buildQuestionNavigator(isDark),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            _buildBottomNavigation(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (_currentQuestionIndex + 1) / _questions.length,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 230, 30, 220),
                Color.fromARGB(255, 10, 180, 247),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 230, 30, 220),
                  Color.fromARGB(255, 10, 180, 247),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Q${_currentQuestionIndex + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            question['question'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(int index, String option, bool isDark) {
    final isSelected = _selectedAnswers[_currentQuestionIndex] == index;
    final optionLetter = String.fromCharCode(65 + index);

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? Colors.purple.shade900.withOpacity(0.5)
                    : Colors.purple.shade50)
              : (isDark ? Colors.grey.shade800 : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.purple.shade400
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
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
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  optionLetter,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: Colors.purple.shade400,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionNavigator(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'Question Navigator',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_questions.length, (index) {
              final isAnswered = _selectedAnswers[index] != null;
              final isCurrent = index == _currentQuestionIndex;

              return GestureDetector(
                onTap: () => _goToQuestion(index),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isCurrent
                        ? const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 230, 30, 220),
                              Color.fromARGB(255, 10, 180, 247),
                            ],
                          )
                        : null,
                    color: isCurrent
                        ? null
                        : (isAnswered
                              ? Colors.green.shade100
                              : (isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade200)),
                    borderRadius: BorderRadius.circular(8),
                    border: isAnswered && !isCurrent
                        ? Border.all(color: Colors.green.shade400, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isCurrent
                            ? Colors.white
                            : (isAnswered
                                  ? Colors.green.shade700
                                  : (isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600)),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Previous Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Previous'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.grey.shade700
                      : Colors.grey.shade200,
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  disabledBackgroundColor: isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  disabledForegroundColor: isDark
                      ? Colors.grey.shade600
                      : Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Next/Submit Button
            Expanded(
              flex: 2,
              child: _currentQuestionIndex == _questions.length - 1
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 230, 30, 220),
                            Color.fromARGB(255, 10, 180, 247),
                          ],
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitQuiz,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_rounded),
                        label: Text(
                          _isSubmitting ? 'Submitting...' : 'Submit Quiz',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _nextQuestion,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ),
          ],
        ),
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
}
