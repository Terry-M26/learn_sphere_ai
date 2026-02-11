// Preferences class for managing local storage using Hive database
// Hive is a lightweight, fast key-value database for Flutter

import 'package:hive/hive.dart'; // Hive database package
import 'package:path_provider/path_provider.dart'; // To get app documents directory path

// Static class - all methods/properties accessed via Pref.methodName
// No need to create instance, just use Pref.showOnboarding directly
class Pref {
  // Hive Box - the actual storage container for our data
  // 'late' because initialized in initialze() method
  static late Box _box;

  // Initialize Hive database - MUST be called before using any Pref values
  // Called once in main.dart during app startup
  static Future<void> initialze() async {
    // Get the app's documents directory (platform-specific location)
    final dir = await getApplicationDocumentsDirectory();
    // Set Hive's default storage location
    Hive.defaultDirectory = dir.path;
    // Open or create a box named 'myData' to store preferences
    _box = Hive.box(name: 'myData');
  }

  // Getter: Returns true if onboarding should be shown (first app launch)
  // defaultValue: true means new users see onboarding
  static bool get showOnboarding =>
      _box.get('showOnboarding', defaultValue: true);
  // Setter: Set to false after user completes onboarding
  static set showOnboarding(bool value) => _box.put('showOnboarding', value);

  // Getter: Returns user's theme preference (false = light mode by default)
  static bool get isDarkMode => _box.get('isDarkMode', defaultValue: false);
  // Setter: Saves theme preference when user toggles dark/light mode
  static set isDarkMode(bool value) => _box.put('isDarkMode', value);
}
