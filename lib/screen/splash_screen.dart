// SplashScreen - first screen shown when app launches
// Displays logo animation for 3 seconds, then navigates to:
// - OnboardingScreen (first-time users)
// - HomeScreen (returning users)

import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For Get.off() navigation
import 'package:learn_sphere_ai/helper/global.dart'; // For mq (screen size)
import 'package:learn_sphere_ai/helper/pref.dart'; // For showOnboarding preference
import 'package:learn_sphere_ai/screen/home_screen.dart'; // Main app screen
import 'package:learn_sphere_ai/screen/onboarding_screen.dart'; // First-time user intro
import 'package:lottie/lottie.dart'; // For Lottie animations

// StatefulWidget because we need initState for delayed navigation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key}); // Constructor

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait 3 seconds then navigate to next screen
    // Future.delayed schedules code to run after specified duration
    Future.delayed(const Duration(seconds: 3), () {
      // Check if widget is still mounted (not disposed)
      if (mounted) {
        // Get.off replaces current screen (can't go back to splash)
        // Check Pref.showOnboarding to decide which screen to show
        Get.off(
          () => Pref.showOnboarding
              ? const OnboardingScreen() // First-time user
              : const HomeScreen(), // Returning user
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize global screen size variable
    mq = MediaQuery.sizeOf(context);

    return Scaffold(
      // Dark background for splash screen
      backgroundColor: const Color(0xFF1a1a1a),

      // Center all content vertically and horizontally
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          children: [
            // Logo container with shadow and rounded corners
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, // White background for logo
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5), // Shadow below
                  ),
                ],
              ),
              // ClipRRect clips child to rounded rectangle
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                // Lottie animation - plays automatically
                child: Lottie.asset(
                  'assets/lottie/LearnSphere_Animation.json',
                  width: mq.width * 0.4, // 40% of screen width
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 30), // Spacing
            // App name text
            Text(
              'LearnSphere AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9), // Slightly transparent
              ),
            ),

            const SizedBox(height: 30), // Spacing
            // Loading spinner to indicate app is loading
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5, // Thin stroke
                // AlwaysStoppedAnimation keeps color constant
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
