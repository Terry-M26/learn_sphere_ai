import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_sphere_ai/helper/global.dart';
import 'package:learn_sphere_ai/helper/pref.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Pref.showOnboarding = false;
  }

  @override
  Widget build(BuildContext context) {
    //initialising device size
    mq = MediaQuery.sizeOf(context);

    return Scaffold(body: Center(child: Text("Hello im home screen")));
  }
}
