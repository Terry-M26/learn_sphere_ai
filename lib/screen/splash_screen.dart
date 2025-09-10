import 'package:flutter/material.dart';
import 'package:learn_sphere_ai/helper/global.dart';
import 'package:learn_sphere_ai/screen/home_screen.dart';
import 'package:learn_sphere_ai/screen/onboarding_screen.dart';
import 'package:lottie/lottie.dart';

// Splash screen displays a logo and a progress indicator
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  //Initializing the animation controller and fade animation
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    //Delaying the navigation to the home screen
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(_createFadeRoute());
      }
    });
  }

  //Creating a fade transition route
  Route _createFadeRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const OnboardingScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  //Avoid memory leaks
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            // Fades in the logo image
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
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
            ),

            // Adds a small space between the logo and the text
            const SizedBox(height: 30),

            // Fades in the 'LearnSphere AI' text
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'LearnSphere AI',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),

            // Adds a small space between the text and the progress indicator
            const SizedBox(height: 30),

            // Fades in the progress indicator
            FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
