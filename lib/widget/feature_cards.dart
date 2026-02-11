// FeatureCards enum - defines all feature cards shown on HomeScreen
// Each enum value contains all properties needed to render a feature card
// This approach keeps feature data centralized and easy to modify

import 'package:flutter/material.dart'; // For Color, VoidCallback
import 'package:get/get.dart'; // For Get.to() navigation
import '../screen/feature/AITutorChat.dart'; // AI Tutor chat screen
import '../screen/feature/ChallengeMode_screen.dart'; // Quiz feature screen
import '../screen/feature/LectureStorage_screen.dart'; // File storage screen
import '../screen/feature/LectureSummary_screen.dart'; // Summary feature screen

// Enum defining all feature cards with their properties
// To add a new feature: add new enum value with all required properties
enum FeatureCards {
  // AI Tutor Chat - conversational AI for learning assistance
  aiTutorChat(
    title: 'AI Tutor Chat',
    subtitle: 'Get instant help and explanations from your personal AI tutor',
    imagePath: 'assets/images/AI_tutor_chat_icon.png', // Icon asset path
    gradientColors: [
      // Card background gradient (cyan to blue)
      Color.fromARGB(255, 0, 194, 253),
      Color.fromARGB(207, 0, 136, 248),
    ],
  ),
  // Challenge Mode - AI-generated quizzes from lecture content
  challengeMode(
    title: 'Challenge Mode',
    subtitle: 'Test your knowledge with AI-generated practice questions',
    imagePath: 'assets/images/challenge_icon.png',
    gradientColors: [
      // Pink to cyan gradient
      Color.fromARGB(255, 230, 30, 220),
      Color.fromARGB(255, 10, 180, 247),
    ],
  ),
  // Lecture Storage - upload and manage lecture files
  lectureStorage(
    title: 'Lecture Storage',
    subtitle: 'Save, organize and summarize your lectures with AI',
    imagePath: 'assets/images/lecture_library_logo.png',
    gradientColors: [
      // Orange to yellow gradient
      Color.fromARGB(255, 253, 174, 3),
      Color.fromARGB(255, 255, 222, 36),
    ],
  ),
  // Lecture Summary - AI-powered text summarization
  lectureSummary(
    title: 'Lecture Summary',
    subtitle: 'Save your lecture summary with AI',
    imagePath: 'assets/images/lecture_summary_icon.png',
    gradientColors: [
      // Orange to red gradient
      Color.fromARGB(255, 253, 174, 3),
      Color.fromARGB(255, 245, 16, 17),
    ],
  );

  // Constructor - all properties required for each feature card
  const FeatureCards({
    required this.title, // Card title text
    required this.subtitle, // Description text
    required this.imagePath, // Path to icon asset
    required this.gradientColors, // Background gradient colors
  });

  final String title; // Main heading on the card
  final String subtitle; // Description shown below title
  final String imagePath; // Asset path for feature icon
  final List<Color> gradientColors; // 2 colors for LinearGradient

  // Navigation callback - called when user taps the feature card
  // Returns appropriate navigation function for each feature
  VoidCallback get onTap {
    switch (this) {
      case FeatureCards.aiTutorChat:
        // Navigate to AI Tutor chat screen
        return () {
          Get.to(() => const AITutorChat());
        };
      case FeatureCards.challengeMode:
        // Navigate to Challenge Mode quiz screen
        return () {
          Get.to(() => const ChallengeModeScreen());
        };
      case FeatureCards.lectureStorage:
        // Navigate to Lecture Storage file management
        return () {
          Get.to(() => const LecturestorageScreen());
        };
      case FeatureCards.lectureSummary:
        // Navigate to Lecture Summary screen
        return () {
          Get.to(() => const LectureSummaryScreen());
        };
    }
  }
}
