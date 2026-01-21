import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'ChallengeMode_screen.dart';
import 'Quiz_screen.dart';

class QuizResultsScreen extends StatefulWidget {
  final String lectureTitle;
  final List<Map<String, dynamic>> questions;
  final List<int> selectedAnswers;
  final String difficulty;
  final String lectureText;
  final bool isFromHistory;

  const QuizResultsScreen({
    super.key,
    required this.lectureTitle,
    required this.questions,
    required this.selectedAnswers,
    required this.difficulty,
    required this.lectureText,
    this.isFromHistory = false,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  late int _correctCount;
  late int _incorrectCount;
  late double _scorePercentage;
  late List<bool> _isCorrectList;

  @override
  void initState() {
    super.initState();
    _calculateResults();
  }

  void _calculateResults() {
    _isCorrectList = [];
    _correctCount = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      final isCorrect =
          widget.selectedAnswers[i] == widget.questions[i]['correctAnswer'];
      _isCorrectList.add(isCorrect);
      if (isCorrect) _correctCount++;
    }

    _incorrectCount = widget.questions.length - _correctCount;
    _scorePercentage = (_correctCount / widget.questions.length) * 100;
  }

  String _getPerformanceMessage() {
    if (_scorePercentage >= 90) return 'Excellent! 🌟';
    if (_scorePercentage >= 80) return 'Great Job! 👏';
    if (_scorePercentage >= 70) return 'Good Work! 👍';
    if (_scorePercentage >= 60) return 'Not Bad! 📚';
    if (_scorePercentage >= 50) return 'Keep Practicing! 💪';
    return 'Need More Study! 📖';
  }

  Color _getScoreColor() {
    if (_scorePercentage >= 80) return Colors.green;
    if (_scorePercentage >= 60) return Colors.orange;
    return Colors.red;
  }

  void _retryQuiz() {
    Get.off(
      () => QuizScreen(
        lectureTitle: widget.lectureTitle,
        questionCount: widget.questions.length,
        difficulty: widget.difficulty,
        lectureText: widget.lectureText,
      ),
    );
  }

  void _newQuiz() {
    Get.off(() => const ChallengeModeScreen());
  }

  void _goHome() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goHome();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black,
          centerTitle: true,
          automaticallyImplyLeading: false,
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
                Icon(Icons.analytics_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Quiz Results',
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Score Card
              _buildScoreCard(isDark)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8), duration: 500.ms),

              const SizedBox(height: 20),

              // Stats Row
              _buildStatsRow(isDark)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms),

              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(isDark)
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms),

              const SizedBox(height: 24),

              // Questions Review Header
              Row(
                children: [
                  Icon(
                    Icons.list_alt_rounded,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Question Review',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_incorrectCount mistake${_incorrectCount != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const SizedBox(height: 16),

              // Questions List
              ...List.generate(widget.questions.length, (index) {
                return _buildQuestionReviewCard(index, isDark)
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 500 + (index * 100)),
                      duration: 400.ms,
                    )
                    .slideY(begin: 0.1, end: 0, duration: 400.ms);
              }),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 230, 30, 220).withOpacity(0.8),
            const Color.fromARGB(255, 10, 180, 247).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _getPerformanceMessage(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: _scorePercentage / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor()),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_scorePercentage.toInt()}%',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$_correctCount/${widget.questions.length}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.difficulty} • ${widget.questions.length} Questions',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_rounded,
            label: 'Correct',
            value: '$_correctCount',
            color: Colors.green,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.cancel_rounded,
            label: 'Incorrect',
            value: '$_incorrectCount',
            color: Colors.red,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.percent_rounded,
            label: 'Accuracy',
            value: '${_scorePercentage.toInt()}%',
            color: _getScoreColor(),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
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
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    // If viewing from history, show only a back button
    if (widget.isFromHistory) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Back to History'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark
                ? Colors.grey.shade700
                : Colors.grey.shade200,
            foregroundColor: isDark ? Colors.white : Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _retryQuiz,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry Quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.grey.shade700
                  : Colors.grey.shade200,
              foregroundColor: isDark ? Colors.white : Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
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
              onPressed: _newQuiz,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Quiz'),
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
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionReviewCard(int index, bool isDark) {
    final question = widget.questions[index];
    final selectedAnswer = widget.selectedAnswers[index];
    final correctAnswer = question['correctAnswer'] as int;
    final isCorrect = _isCorrectList[index];
    final options = question['options'] as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? Colors.green.shade300 : Colors.red.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: !isCorrect, // Expand incorrect answers by default
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCorrect ? Icons.check_rounded : Icons.close_rounded,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
          title: Text(
            'Question ${index + 1}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            isCorrect ? 'Correct' : 'Incorrect',
            style: TextStyle(
              color: isCorrect ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          children: [
            // Question Text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                question['question'],
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Options
            ...List.generate(options.length, (optIndex) {
              final isSelectedOption = selectedAnswer == optIndex;
              final isCorrectOption = correctAnswer == optIndex;

              Color? bgColor;
              Color? borderColor;
              IconData? icon;

              if (isCorrectOption) {
                bgColor = Colors.green.shade50;
                borderColor = Colors.green;
                icon = Icons.check_circle_rounded;
              } else if (isSelectedOption && !isCorrect) {
                bgColor = Colors.red.shade50;
                borderColor = Colors.red;
                icon = Icons.cancel_rounded;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      bgColor ??
                      (isDark ? Colors.grey.shade700 : Colors.grey.shade50),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        borderColor ??
                        (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                    width: borderColor != null ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCorrectOption
                            ? Colors.green
                            : (isSelectedOption && !isCorrect
                                  ? Colors.red
                                  : (isDark
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade300)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + optIndex),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color:
                                isCorrectOption ||
                                    (isSelectedOption && !isCorrect)
                                ? Colors.white
                                : (isDark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade700),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        options[optIndex],
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: isCorrectOption || isSelectedOption
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (icon != null)
                      Icon(
                        icon,
                        color: isCorrectOption ? Colors.green : Colors.red,
                        size: 20,
                      ),
                  ],
                ),
              );
            }),

            // Explanation (only for incorrect answers)
            if (!isCorrect) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explanation',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            question['explanation'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
