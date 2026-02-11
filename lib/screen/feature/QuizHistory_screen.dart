// QuizHistoryScreen - View past quiz attempts and results
// Displays list of completed quizzes with scores and dates
// Features: view detailed results, delete quiz history, real-time updates
// Requires authentication to access

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // For animations
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore streams
import 'package:get/get.dart'; // For navigation
import 'package:learn_sphere_ai/helper/auth_helper.dart'; // For login check
import 'package:learn_sphere_ai/service/database.dart'; // For Firestore operations
import 'QuizResults_screen.dart'; // View detailed results

// StatefulWidget to manage quiz history stream
class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key}); // Constructor

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  Stream<QuerySnapshot>? _quizHistoryStream;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
  }

  Future<void> _checkAuthAndLoad() async {
    if (!AuthHelper.isLoggedIn) {
      // Should not happen as we check before navigating, but handle gracefully
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return;
    }
    _userId = AuthHelper.userId;
    _loadQuizHistory();
  }

  Future<void> _loadQuizHistory() async {
    if (_userId == null) return;
    final stream = await DatabaseMethods().getQuizHistory(_userId!);
    setState(() {
      _quizHistoryStream = stream;
    });
  }

  Future<void> _deleteQuiz(String quizId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Quiz?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$title"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseMethods().deleteQuizResult(_userId!, quizId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting quiz: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewQuizDetails(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final questions = (data['questions'] as List<dynamic>)
        .map((q) => q as Map<String, dynamic>)
        .toList();
    final selectedAnswers = (data['selectedAnswers'] as List<dynamic>)
        .map((a) => a as int)
        .toList();

    Get.to(
      () => QuizResultsScreen(
        lectureTitle: data['title'] ?? 'Quiz',
        questions: questions,
        selectedAnswers: selectedAnswers,
        difficulty: data['difficulty'] ?? 'Medium',
        lectureText: '',
        isFromHistory: true,
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
              Icon(Icons.history_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Quiz History',
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
      body: _quizHistoryStream == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _quizHistoryStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading quiz history',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return _buildQuizCard(doc, isDark, index)
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 50 * index),
                          duration: 400.ms,
                        )
                        .slideY(begin: 0.1, end: 0, duration: 400.ms);
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 230, 30, 220).withOpacity(0.1),
                  const Color.fromARGB(255, 10, 180, 247).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.quiz_outlined,
              size: 64,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Quiz History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete a quiz to see your results here',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Take a Quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildQuizCard(DocumentSnapshot doc, bool isDark, int index) {
    final data = doc.data() as Map<String, dynamic>;
    final title = data['title'] ?? 'Quiz';
    final score = data['score'] ?? 0;
    final totalQuestions = data['totalQuestions'] ?? 0;
    final difficulty = data['difficulty'] ?? 'Medium';
    final completedAt = data['completedAt'] as Timestamp?;

    final scorePercentage = totalQuestions > 0
        ? (score / totalQuestions * 100).toInt()
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewQuizDetails(doc),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Score Circle
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getScoreColor(scorePercentage).withOpacity(0.2),
                            _getScoreColor(scorePercentage).withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getScoreColor(scorePercentage),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$scorePercentage%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(scorePercentage),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$score/$totalQuestions correct',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Delete Button
                    IconButton(
                      onPressed: () => _deleteQuiz(doc.id, title),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red.shade400,
                      ),
                      tooltip: 'Delete',
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Tags Row
                Row(
                  children: [
                    // Difficulty Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(
                          difficulty,
                        ).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getDifficultyColor(
                            difficulty,
                          ).withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        difficulty,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getDifficultyColor(difficulty),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Questions Count
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$totalQuestions questions',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Date
                    if (completedAt != null)
                      Text(
                        _formatDate(completedAt.toDate()),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // View Details Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 230, 30, 220),
                        Color.fromARGB(255, 10, 180, 247),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'View Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
