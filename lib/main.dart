// Main entry point for LearnSphere AI Flutter application
// This file initializes Firebase, Hive database, and sets up the app structure

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For controlling system UI (status bar, orientation)
import 'package:get/get_navigation/src/root/get_material_app.dart'; // GetX navigation package for screen routing
import 'package:learn_sphere_ai/helper/global.dart'; // Global constants like app name
import 'package:learn_sphere_ai/helper/pref.dart'; // Hive-based local storage preferences
import 'package:learn_sphere_ai/helper/theme_provider.dart'; // Provider for dark/light theme management
import 'package:learn_sphere_ai/screen/splash_screen.dart'; // Initial splash screen widget
import 'package:provider/provider.dart'; // State management package for theme
import 'package:firebase_core/firebase_core.dart'; // Firebase core initialization
import 'firebase_options.dart'; // Auto-generated Firebase configuration

// Main function - entry point of the application
// async because we need to wait for Firebase and Hive initialization
Future<void> main() async {
  // Ensures Flutter bindings are initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with platform-specific configuration (Android/iOS/Web)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive local database for storing user preferences
  // This must complete before accessing any Pref values
  await Pref.initialze();

  // Set immersive sticky mode - hides status bar and navigation bar
  // They reappear temporarily when user swipes from edge
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Lock app to portrait orientation only (no landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Start the Flutter application with MyApp as root widget
  runApp(const MyApp());
}

// Root widget of the application
// StatelessWidget because app configuration doesn't change after build
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor with optional key parameter
  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider wraps the app to provide theme state to all widgets
    // Any widget can access ThemeProvider using Provider.of or Consumer
    return ChangeNotifierProvider(
      // Creates a single instance of ThemeProvider when app starts
      create: (context) => ThemeProvider(),
      // Consumer rebuilds its child whenever ThemeProvider notifies listeners
      child: Consumer<ThemeProvider>(
        // Builder function receives the current themeProvider instance
        builder: (context, themeProvider, child) {
          // GetMaterialApp enables GetX navigation (Get.to, Get.off, etc.)
          return GetMaterialApp(
            title: appName, // App name from global.dart constants
            debugShowCheckedModeBanner:
                false, // Removes debug banner in top-right corner
            theme: themeProvider
                .currentTheme, // Dynamic theme based on dark/light mode
            home: const SplashScreen(), // First screen shown when app launches
          );
        },
      ),
    );
  }
}
