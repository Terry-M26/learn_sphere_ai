// ThemeProvider - manages dark/light theme state using Provider pattern
// Extends ChangeNotifier to notify widgets when theme changes

import 'package:flutter/material.dart'; // For ThemeData, Colors, etc.
import 'package:learn_sphere_ai/helper/pref.dart'; // For persisting theme preference

// ChangeNotifier allows widgets to listen for changes via Consumer or Provider.of
// When notifyListeners() is called, all listening widgets rebuild
class ThemeProvider extends ChangeNotifier {
  // Private variable to track current theme state
  bool _isDarkMode = false;

  // Public getter - widgets use this to check current theme
  // Example: themeProvider.isDarkMode ? darkColor : lightColor
  bool get isDarkMode => _isDarkMode;

  // Returns the appropriate ThemeData based on current mode
  // Used in GetMaterialApp's theme property
  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  // Light theme configuration - white backgrounds, dark text
  static final _lightTheme = ThemeData(
    brightness: Brightness.light, // Tells Flutter this is a light theme
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor:
        Colors.white, // Default background for Scaffold widgets
    // AppBar styling - transparent background with black icons/text
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black, // Icon and text color in AppBar
    ),
  );

  // Dark theme configuration - dark backgrounds, light text
  static final _darkTheme = ThemeData(
    brightness: Brightness.dark, // Tells Flutter this is a dark theme
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.black, // Dark background for Scaffold
    // AppBar styling - transparent background with white icons/text
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white, // Icon and text color in AppBar
    ),
  );

  // Constructor - called when Provider creates this instance
  // Loads saved theme preference from Hive database
  ThemeProvider() {
    _loadThemeFromHive();
  }

  // Toggle between dark and light mode
  // Called when user taps theme toggle button in AppBar
  void toggleTheme() {
    _isDarkMode = !_isDarkMode; // Flip the boolean
    _saveThemeToHive(); // Persist to local storage
    notifyListeners(); // Trigger rebuild of all listening widgets
  }

  // Load saved theme preference from Hive on app startup
  void _loadThemeFromHive() {
    _isDarkMode = Pref.isDarkMode; // Read from local storage
    notifyListeners(); // Update UI with loaded preference
  }

  // Save current theme preference to Hive for persistence
  void _saveThemeToHive() {
    Pref.isDarkMode = _isDarkMode; // Write to local storage
  }
}
