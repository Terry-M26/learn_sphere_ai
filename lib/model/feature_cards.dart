import 'package:flutter/material.dart';

enum FeatureCards {
  aiTutorChat(
    title: 'AI Tutor Chat',
    subtitle: 'Get instant help and explanations from your personal AI tutor',
    icon: Icons.psychology_rounded,
    gradientColors: [Color(0xFF6E45E2), Color(0xFF89D4CF)],
  ),
  challengeMode(
    title: 'Challenge Mode',
    subtitle: 'Test your knowledge with AI-generated practice questions',
    icon: Icons.quiz_rounded,
    gradientColors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
  ),
  lectureStorage(
    title: 'Lecture Storage',
    subtitle: 'Save, organize and summarize your lectures with AI',
    icon: Icons.library_books_rounded,
    gradientColors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
  ),
  lectureSummary(
    title: 'Lecture Summary',
    subtitle: 'Save your lecture summary with AI',
    icon: Icons.insights_rounded,
    gradientColors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
  );

  const FeatureCards({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;

  /// Get the onTap callback for each feature
  VoidCallback get onTap {
    switch (this) {
      case FeatureCards.aiTutorChat:
        return () {
          // TODO: Navigate to AI Tutor Chat screen
          print('AI Tutor Chat tapped');
        };
      case FeatureCards.challengeMode:
        return () {
          // TODO: Navigate to Challenge Mode screen
          print('Challenge Mode tapped');
        };
      case FeatureCards.lectureStorage:
        return () {
          // TODO: Navigate to Lecture Storage screen
          print('Lecture Storage tapped');
        };
      case FeatureCards.lectureSummary:
        return () {
          // TODO: Navigate to Lecture Summary screen
          print('Lecture Summary tapped');
        };
    }
  }
}
