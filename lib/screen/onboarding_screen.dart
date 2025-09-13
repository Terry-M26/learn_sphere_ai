import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_sphere_ai/helper/global.dart';
import 'package:learn_sphere_ai/model/onboard.dart';
import 'package:learn_sphere_ai/screen/home_screen.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = PageController();

    final list = [
      OnBoard(
        title: "Save your lectures",
        subtitle:
            "The app will help you to save, manage and summarise your lectures with AI to make your learning experience more organised and efficient.",
        lottie: "Onboarding_Animation_1",
      ),

      OnBoard(
        title: "Ask AI Tutor",
        subtitle:
            "An AI tutor will help you to answer your questions and provide you with the best possible answers and provide mock papers to prepare for your exams.",
        lottie: "Onboarding_Animation_2",
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: PageView.builder(
          controller: c,
          itemCount: list.length,
          itemBuilder: (ctx, ind) {
            final isLast = ind == list.length - 1;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),

                  // Animation Container with subtle shadow
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Lottie.asset(
                      "assets/lottie/${list[ind].lottie}.json",
                      height: mq.height * 0.45,
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Title with better typography
                  Text(
                    list[ind].title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle with improved readability
                  Container(
                    constraints: BoxConstraints(maxWidth: mq.width * 0.85),
                    child: Text(
                      list[ind].subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[400],
                        height: 1.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Page indicators with smooth animation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      list.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: ind == i ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: ind == i
                              ? const Color(0xFF4A90E2)
                              : Colors.grey[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Enhanced button with gradient and shadow
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
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
                          Get.off(
                            () => const HomeScreen(),
                            transition: Transition.fadeIn,
                            duration: const Duration(milliseconds: 1600),
                          );
                        } else {
                          c.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
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

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
