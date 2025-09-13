import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_sphere_ai/helper/global.dart';
import 'package:learn_sphere_ai/helper/pref.dart';
import 'package:learn_sphere_ai/screen/home_screen.dart';
import 'package:learn_sphere_ai/screen/onboarding_screen.dart';
import 'package:lottie/lottie.dart';

// Splash screen displays a logo and a progress indicator
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delaying the navigation to the home screen
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Get.off(
          () => Pref.showOnboarding
              ? const OnboardingScreen()
              : const HomeScreen(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.sizeOf(context);

    return Scaffold(
      // Sets the background color to a dark grey
      backgroundColor: const Color(0xFF1a1a1a),

      // The main content of the screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Lottie.asset(
                  'assets/lottie/LearnSphere_Animation.json',
                  width: mq.width * 0.4,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 'LearnSphere AI' text
            Text(
              'LearnSphere AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),

            const SizedBox(height: 30),

            // Progress indicator
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
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
