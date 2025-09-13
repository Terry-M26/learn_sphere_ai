import 'package:flutter/material.dart';
import 'package:learn_sphere_ai/helper/pref.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;
  
  static final _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
    ),
  );
  
  static final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
  );
  
  ThemeProvider() {
    _loadThemeFromHive();
  }
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemeToHive();
    notifyListeners();
  }
  
  void _loadThemeFromHive() {
    _isDarkMode = Pref.isDarkMode;
    notifyListeners();
  }
  
  void _saveThemeToHive() {
    Pref.isDarkMode = _isDarkMode;
  }
}
