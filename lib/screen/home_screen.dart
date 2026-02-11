// HomeScreen - main dashboard screen of the app
// Displays feature cards for: AI Tutor, Challenge Mode, Lecture Storage, Lecture Summary
// Includes: theme toggle, navigation drawer, connectivity checking

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemChrome UI mode
import 'package:flutter_animate/flutter_animate.dart'; // For .animate() extension
import 'package:learn_sphere_ai/helper/global.dart'; // For mq (screen size)
import 'package:learn_sphere_ai/helper/pref.dart'; // For showOnboarding preference
import 'package:learn_sphere_ai/helper/theme_provider.dart'; // Theme state management
import 'package:learn_sphere_ai/helper/connectivity_service.dart'; // Internet check
import 'package:learn_sphere_ai/widget/feature_cards.dart'; // FeatureCards enum
import 'package:learn_sphere_ai/widget/custom_drawer.dart'; // Navigation drawer
import 'package:provider/provider.dart'; // For Consumer widget

// StatefulWidget because we manage connectivity state
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // Constructor

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isConnected = true; // Tracks internet connectivity status
  bool _isCheckingConnection = true; // Shows loading spinner during check

  @override
  void initState() {
    super.initState();
    // Enable edge-to-edge display (content extends behind system bars)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Ensure onboarding won't show again (user has reached home)
    Pref.showOnboarding = false;
    // Check internet connection on screen load
    _checkConnectivity();
  }

  // Check internet connectivity and update state
  // Called on init and when user taps retry button
  Future<void> _checkConnectivity() async {
    setState(() => _isCheckingConnection = true); // Show loading
    // Perform actual connectivity check
    final connected = await ConnectivityService.checkInternetConnection();
    setState(() {
      _isConnected = connected; // Update connection status
      _isCheckingConnection = false; // Hide loading
    });
  }

  // Build the "No Internet" warning banner
  // Shown when _isConnected is false
  Widget _buildNoInternetBanner(bool isDark) {
    return Container(
      width: double.infinity, // Full width
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // Red gradient background for warning
        gradient: LinearGradient(
          colors: [Colors.red.shade600, Colors.red.shade400],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Wifi-off icon in semi-transparent container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Warning text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No Internet Connection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Please connect to use LearnSphere AI',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Retry button - shows spinner while checking
          IconButton(
            onPressed: _checkConnectivity, // Retry connection check
            icon: _isCheckingConnection
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Retry',
          ),
        ],
      ),
      // Animate banner sliding in from top
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.3, end: 0);
  }

  // Build a single feature card widget
  // feature: FeatureCards enum value with title, subtitle, icon, colors
  // index: position in list (used for staggered animation delay)
  Widget _buildFeatureCard(FeatureCards feature, int index) {
    return Container(
          margin: const EdgeInsets.only(bottom: 18), // Space between cards
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // Shadow behind card
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          // Material + InkWell for ripple effect on tap
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: feature.onTap, // Navigate to feature screen
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  // Gradient background from feature's colors
                  gradient: LinearGradient(
                    colors: feature.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  // Colored glow shadow matching gradient
                  boxShadow: [
                    BoxShadow(
                      color: feature.gradientColors.first.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                // Card content: icon, title, subtitle, arrow
                child: Row(
                  children: [
                    // Feature icon in semi-transparent container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(
                        feature.imagePath, // Icon from assets
                        width: 40,
                        height: 40,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Title and subtitle text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature.title, // Feature name
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            feature.subtitle, // Feature description
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
                    // Arrow icon indicating tappable
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
        )
        // Staggered entrance animation - each card delays based on index
        .animate(delay: Duration(milliseconds: 200 + (index * 150)))
        .slideY(
          // Slide up from below
          begin: 0.3,
          end: 0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        )
        .fadeIn(
          // Fade in
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
        )
        .scale(
          // Scale up from 80% to 100%
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack, // Slight overshoot
        );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize global screen size variable
    mq = MediaQuery.sizeOf(context);

    // Consumer rebuilds when theme changes
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          extendBodyBehindAppBar:
              true, // Body extends behind transparent AppBar
          // Transparent AppBar with menu and theme toggle
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            // Menu button to open drawer
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                // Theme-aware color
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // Open navigation drawer
                },
              ),
            ),
            // App title in AppBar
            title: Text(
              'LearnSphere AI',
              style: TextStyle(
                // Theme-aware text color
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Theme toggle button in AppBar
            actions: [
              IconButton(
                // Show sun icon in dark mode, moon in light mode
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                onPressed: () {
                  themeProvider.toggleTheme(); // Toggle dark/light mode
                },
              ),
            ],
            elevation: 1, // Slight shadow
            // Rounded bottom corners
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(9)),
            ),
          ),
          drawer: const CustomDrawer(), // Navigation drawer widget
          // Main body with background image
          body: Container(
            decoration: BoxDecoration(
              // Theme-specific background image
              image: DecorationImage(
                image: AssetImage(
                  themeProvider.isDarkMode
                      ? 'assets/images/background_DM.jpg' // Dark mode background
                      : 'assets/images/background_LM.jpg', // Light mode background
                ),
                fit: BoxFit.cover, // Cover entire screen
              ),
            ),
            // SafeArea avoids system UI (notch, status bar)
            child: SafeArea(
              // LayoutBuilder provides parent constraints
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // SingleChildScrollView enables scrolling
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(), // iOS-style bounce
                    // Ensure content fills at least full height
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20), // Top spacing
                            // Show no internet banner if disconnected
                            if (!_isConnected)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildNoInternetBanner(
                                  themeProvider.isDarkMode,
                                ),
                              ),

                            const SizedBox(height: 20),

                            // Home header with icon and text
                            // Home header row with slide animation
                            Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.home, size: 32),
                                      onPressed: () {}, // No action needed
                                      // Theme-aware color
                                      color: themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    Text(
                                      "Home",
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                )
                                // Slide in from left animation
                                .animate()
                                .slideX(
                                  begin: -0.2,
                                  end: 0,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOutCubic,
                                )
                                .fadeIn(
                                  duration: const Duration(milliseconds: 500),
                                ),

                            const SizedBox(height: 30),
                            // Subtitle text with animation
                            Text(
                                  'Select a feature',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    // Muted color for subtitle
                                    color: themeProvider.isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.black,
                                    height: 1.4,
                                  ),
                                )
                                // Delayed slide up animation
                                .animate(
                                  delay: const Duration(milliseconds: 100),
                                )
                                .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOutCubic,
                                )
                                .fadeIn(
                                  duration: const Duration(milliseconds: 500),
                                ),

                            const SizedBox(height: 12),

                            // Generate feature cards from FeatureCards enum
                            // asMap() gives index, entries.map iterates with index
                            ...FeatureCards.values.asMap().entries.map(
                              (entry) =>
                                  _buildFeatureCard(entry.value, entry.key),
                            ),

                            const SizedBox(height: 32), // Bottom padding
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
