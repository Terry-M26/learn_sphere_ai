// OnboardingScreen - introduction screens for first-time users
// Shows 2 pages explaining app features with Lottie animations
// After completing, user is taken to HomeScreen

import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For Get.off() navigation
import 'package:learn_sphere_ai/helper/global.dart'; // For mq (screen size)
import 'package:learn_sphere_ai/helper/pref.dart'; // To set showOnboarding = false
import 'package:learn_sphere_ai/model/onboard.dart'; // OnBoard data model
import 'package:learn_sphere_ai/screen/home_screen.dart'; // Navigate after onboarding
import 'package:lottie/lottie.dart'; // For Lottie animations

// StatelessWidget - PageController handles page state internally
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {
    // PageController manages which page is currently visible
    // Used for PageView navigation and page indicators
    final c = PageController();

    // List of onboarding pages - each OnBoard contains title, subtitle, lottie filename
    final list = [
      // Page 1: Lecture management feature
      OnBoard(
        title: "Save your lectures",
        subtitle:
            "The app will help you to save, manage and summarise your lectures with AI to make your learning experience more organised and efficient.",
        lottie:
            "Onboarding_Animation_1", // Animation filename (without extension)
      ),

      // Page 2: AI Tutor feature
      OnBoard(
        title: "Ask AI Tutor",
        subtitle:
            "An AI tutor will help you to answer your questions and provide you with the best possible answers and provide mock papers to prepare for your exams.",
        lottie: "Onboarding_Animation_2",
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // Dark background
      body: SafeArea(
        // PageView.builder creates pages on demand (efficient for many pages)
        child: PageView.builder(
          controller: c, // Connect to PageController
          itemCount: list.length, // Number of pages
          itemBuilder: (ctx, ind) {
            // Check if this is the last page (for button text)
            final isLast = ind == list.length - 1;

            // Each page layout
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1), // Push content down
                  // Lottie animation container with glow effect
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 5, // Blue glow behind animation
                        ),
                      ],
                    ),
                    // Load Lottie animation from assets
                    child: Lottie.asset(
                      "assets/lottie/${list[ind].lottie}.json",
                      height: mq.height * 0.45, // 45% of screen height
                    ),
                  ),

                  const Spacer(flex: 1), // Space between animation and text
                  // Page title - large bold text
                  Text(
                    list[ind].title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5, // Tighter letter spacing
                      height: 1.2, // Line height
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Page subtitle - description text
                  Container(
                    constraints: BoxConstraints(maxWidth: mq.width * 0.85),
                    child: Text(
                      list[ind].subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[400], // Muted gray color
                        height: 1.5, // Generous line height for readability
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2), // More space before indicators
                  // Page indicator dots - shows current page
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      list.length,
                      // AnimatedContainer smoothly animates size/color changes
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        // Current page indicator is wider (32px vs 8px)
                        width: ind == i ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          // Current page is blue, others are gray
                          color: ind == i
                              ? const Color(0xFF4A90E2)
                              : Colors.grey[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Next/Get Started button with gradient
                  Container(
                    width: double.infinity, // Full width
                    height: 56,
                    decoration: BoxDecoration(
                      // Blue gradient background
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      // Blue glow shadow
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A90E2).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (isLast) {
                          // Last page - complete onboarding
                          // IMPORTANT: Set to false so onboarding doesn't show again
                          Pref.showOnboarding = false;
                          // Navigate to HomeScreen, replacing this screen
                          Get.off(() => const HomeScreen());
                        } else {
                          // Not last page - go to next page with animation
                          c.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      // Transparent button to show container's gradient
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      // Button text changes based on page
                      child: Text(
                        isLast ? "Get Started" : "Next",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32), // Bottom padding
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
