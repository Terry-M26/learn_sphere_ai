import 'package:flutter/material.dart';
import 'package:learn_sphere_ai/helper/theme_provider.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Drawer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeProvider.isDarkMode
                    ? [
                        const Color.fromARGB(255, 20, 20, 40),
                        const Color.fromARGB(255, 40, 40, 80),
                        const Color.fromARGB(255, 60, 30, 90),
                      ]
                    : [
                        const Color.fromARGB(255, 241, 127, 217),
                        const Color.fromARGB(255, 115, 90, 184),
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'LearnSphere AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white),
                  title: const Text(
                    'Home',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white),
                  title: const Text(
                    'Settings',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help, color: Colors.white),
                  title: const Text(
                    'Help',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(color: Colors.white54),
              ],
            ),
          ),
        );
      },
    );
  }
}
