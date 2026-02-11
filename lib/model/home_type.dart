// HomeType enum - defines the AI Tutor feature type
// Used for navigation and UI configuration of the AI Tutor chat

import 'package:flutter/material.dart'; // For EdgeInsets, VoidCallback
import 'package:get/get.dart'; // For Get.to() navigation

import '../screen/feature/AITutorChat.dart'; // AI Tutor chat screen

// Enum with single value for AI Tutor feature
// Can be extended to add more home screen feature types
enum HomeType { aiTutor }

// Extension adds properties and methods to HomeType enum
// Allows accessing title, lottie, etc. via HomeType.aiTutor.title
extension MyHomeType on HomeType {
  // Display title for the feature
  String get title => switch (this) {
    HomeType.aiTutor => 'AI Tutor',
  };

  // Lottie animation filename for the feature card
  String get lottie => switch (this) {
    HomeType.aiTutor => 'ai_hand_waving.json',
  };

  // Whether to left-align content (true) or center it
  bool get leftAlign => switch (this) {
    HomeType.aiTutor => true,
  };

  // Custom padding for the feature card content
  EdgeInsets get padding => switch (this) {
    HomeType.aiTutor => EdgeInsets.zero, // No extra padding
  };

  // Navigation callback when feature card is tapped
  // Uses GetX navigation to push the appropriate screen
  VoidCallback get onTap => switch (this) {
    HomeType.aiTutor => () => Get.to(() => const AITutorChat()),
  };
}
