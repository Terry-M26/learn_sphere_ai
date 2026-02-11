// CustomLoading widget - displays animated loading indicator
// Uses Lottie animation for a polished loading experience

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // For playing Lottie JSON animations

// Reusable loading widget - can be used anywhere in the app
// StatelessWidget because it has no internal state to manage
class CustomLoading extends StatelessWidget {
  const CustomLoading({super.key}); // Constructor with optional key

  @override
  Widget build(BuildContext context) {
    // Display the LearnSphere logo animation as loading indicator
    // width: 100 sets the animation size
    return Lottie.asset('assets/lottie/LearnSphere_Animation.json', width: 100);
  }
}
