import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screen/feature/AITutorChat.dart';

enum HomeType { aiTutor}

extension MyHomeType on HomeType {
  //title
  String get title => switch (this) {
        HomeType.aiTutor => 'AI Tutor',
      };

  //lottie
  String get lottie => switch (this) {
        HomeType.aiTutor => 'ai_hand_waving.json',
      };

  //for alignment
  bool get leftAlign => switch (this) {
        HomeType.aiTutor => true,
      };

  //for padding
  EdgeInsets get padding => switch (this) {
        HomeType.aiTutor => EdgeInsets.zero,
      };


  //for navigation
  VoidCallback get onTap => switch (this) {
        HomeType.aiTutor => () => Get.to(() => const AITutorChat()),
      };
}