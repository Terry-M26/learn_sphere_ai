import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/home_type.dart' as homeType;
import '../screen/feature/ChallengeMode_screen.dart';
import '../screen/feature/LectureStorage_screen.dart';
import '../screen/feature/LectureSummary_screen.dart';

enum FeatureCards {
  aiTutorChat(
    title: 'AI Tutor Chat',
    subtitle: 'Get instant help and explanations from your personal AI tutor',
    imagePath: 'assets/images/AI_tutor_chat_icon.png',
    gradientColors: [
      Color.fromARGB(255, 0, 194, 253),
      Color.fromARGB(207, 0, 136, 248),
    ],
  ),
  challengeMode(
    title: 'Challenge Mode',
    subtitle: 'Test your knowledge with AI-generated practice questions',
    imagePath: 'assets/images/challenge_icon.png',
    gradientColors: [
      Color.fromARGB(255, 230, 30, 220),
      Color.fromARGB(255, 10, 180, 247),
    ],
  ),
  lectureStorage(
    title: 'Lecture Storage',
    subtitle: 'Save, organize and summarize your lectures with AI',
    imagePath: 'assets/images/lecture_library_logo.png',
    gradientColors: [
      Color.fromARGB(255, 253, 174, 3),
      Color.fromARGB(255, 255, 222, 36),
    ],
  ),
  lectureSummary(
    title: 'Lecture Summary',
    subtitle: 'Save your lecture summary with AI',
    imagePath: 'assets/images/lecture_summary_icon.png',
    gradientColors: [
      Color.fromARGB(255, 253, 174, 3),
      Color.fromARGB(255, 245, 16, 17),
    ],
  );

  const FeatureCards({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.gradientColors,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final List<Color> gradientColors;

  /// Get the onTap callback for each feature
  VoidCallback get onTap {
    switch (this) {
      case FeatureCards.aiTutorChat:
        return homeType.HomeType.aiTutor.onTap;
      case FeatureCards.challengeMode:
        return () {
          Get.to(() => const ChallengeModeScreen());
        };
      case FeatureCards.lectureStorage:
        return () {
          Get.to(() => const LecturestorageScreen());
        };
      case FeatureCards.lectureSummary:
        return () {
          Get.to(() => const LectureSummaryScreen());
        };
    }
  }
}
