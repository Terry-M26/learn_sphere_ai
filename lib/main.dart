import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:learn_sphere_ai/helper/global.dart';
import 'package:learn_sphere_ai/helper/pref.dart';
import 'package:learn_sphere_ai/helper/theme_provider.dart';
import 'package:learn_sphere_ai/screen/splash_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Initializing Hive
  await Pref.initialze();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return GetMaterialApp(
            title: appName,
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
