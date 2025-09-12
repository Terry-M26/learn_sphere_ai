import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_sphere_ai/helper/global.dart';
import 'package:learn_sphere_ai/helper/pref.dart';
import 'package:learn_sphere_ai/model/feature.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Pref.showOnboarding = false;
  }

  final List<Feature> features = [
    Feature(
      title: 'AI Tutor Chat',
      subtitle: 'Get instant help and explanations from your personal AI tutor',
      icon: Icons.psychology_rounded,
      gradientColors: [const Color(0xFF6E45E2), const Color(0xFF89D4CF)],
      onTap: () {},
    ),
    Feature(
      title: 'Challenge Mode',
      subtitle: 'Test your knowledge with AI-generated practice questions',
      icon: Icons.quiz_rounded,
      gradientColors: [const Color(0xFFFF6B6B), const Color(0xFF4ECDC4)],
      onTap: () {},
    ),
    Feature(
      title: 'Lecture Storage',
      subtitle: 'Save, organize and summarize your lectures with AI',
      icon: Icons.library_books_rounded,
      gradientColors: [const Color(0xFFFF9A9E), const Color(0xFFFAD0C4)],
      onTap: () {},
    ),
    Feature(
      title: 'Lecture Summary',
      subtitle: 'Save your lecture summary with AI',
      icon: Icons.insights_rounded,
      gradientColors: [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)],
      onTap: () {},
    ),
  ];

  Widget _buildFeatureCard(Feature feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: feature.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: feature.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: feature.gradientColors.first.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(feature.icon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feature.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // Welcome Header
                      Text(
                        'Welcome to',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'LearnSphere AI',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your intelligent learning environment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[500],
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Feature Cards
                      ...features.map((feature) => _buildFeatureCard(feature)),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
