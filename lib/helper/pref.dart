import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class Pref {
  static late Box _box;

  static Future<void> initialze() async {
    //Initializing Hive
    final dir = await getApplicationDocumentsDirectory();
    Hive.defaultDirectory = dir.path;
    _box = Hive.box(name: 'myData');
  }

  static bool get showOnboarding =>
      _box.get('showOnboarding', defaultValue: true);
  static set showOnboarding(bool value) => _box.put('showOnboarding', value);

  static bool get isDarkMode => _box.get('isDarkMode', defaultValue: false);
  static set isDarkMode(bool value) => _box.put('isDarkMode', value);
}
