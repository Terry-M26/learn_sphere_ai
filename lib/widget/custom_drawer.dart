// CustomDrawer widget - side navigation drawer for the app
// Contains: logo, user authentication (sign in/out), and navigation items
// Accessed by swiping from left edge or tapping hamburger menu

import 'package:flutter/material.dart';
import 'package:learn_sphere_ai/auth/google_auth.dart'; // Google Sign-In
import 'package:learn_sphere_ai/helper/theme_provider.dart'; // Theme state
import 'package:provider/provider.dart'; // For Consumer widget
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth for user state

// StatelessWidget - drawer content doesn't have internal state
// Auth state is handled by StreamBuilder listening to Firebase
class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {
    // Consumer rebuilds drawer when theme changes
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Drawer(
          child: Container(
            // Gradient background - different colors for dark/light mode
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeProvider.isDarkMode
                    ? [
                        // Dark mode: dark purple gradient
                        const Color.fromARGB(255, 20, 20, 40),
                        const Color.fromARGB(255, 40, 40, 80),
                        const Color.fromARGB(255, 60, 30, 90),
                      ]
                    : [
                        // Light mode: pink to purple gradient
                        const Color.fromARGB(255, 241, 127, 217),
                        const Color.fromARGB(255, 115, 90, 184),
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            // ListView allows scrolling if content exceeds screen
            child: ListView(
              padding: EdgeInsets.zero, // Remove default padding
              children: [
                // Header section with logo and auth
                Container(
                  height: 239, // Fixed height for header
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App logo in circular container
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30), // Circle
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
                      // App name text
                      const Text(
                        'LearnSphere AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // StreamBuilder listens to Firebase auth state changes
                      // Automatically rebuilds when user signs in/out
                      StreamBuilder<User?>(
                        stream: FirebaseAuth.instance.authStateChanges(),
                        builder: (context, snapshot) {
                          final user = snapshot.data; // Current user or null

                          if (user != null) {
                            // === USER IS LOGGED IN ===
                            // Show user info and logout button
                            return Column(
                              children: [
                                // User profile row
                                Row(
                                  children: [
                                    // User avatar with Google photo
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.white,
                                      backgroundImage: user.photoURL != null
                                          ? NetworkImage(user.photoURL!)
                                          : null,
                                      child: user.photoURL == null
                                          ? Icon(
                                              Icons.person,
                                              size: 20,
                                              color: Colors.grey[600],
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    // User email with ellipsis for long emails
                                    Expanded(
                                      child: Text(
                                        user.email ?? 'Unknown',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Logout button
                                Container(
                                  width: double.infinity,
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Sign out from Firebase
                                      await FirebaseAuth.instance.signOut();
                                      // Close the drawer
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: const Text('Logout'),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // === USER NOT LOGGED IN ===
                            // Show Google Sign-In button
                            return Container(
                              width: double.infinity,
                              height: 36,
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    // Attempt Google Sign-In
                                    final googleAuth = GoogleAuth();
                                    final userCredential = await googleAuth
                                        .signInWithGoogle();
                                    if (userCredential != null) {
                                      // Success - close drawer
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    // Show error snackbar on failure
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Sign-in failed: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                // Button content: Google logo + text
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Google logo
                                    Container(
                                      width: 27,
                                      height: 27,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Image.asset(
                                        'assets/images/google_logo.jpg',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Sign in with Google',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ), // End StreamBuilder
                    ],
                  ),
                ),
                // Divider between header and navigation items
                const Divider(color: Colors.white54),
                // Home navigation item
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white),
                  title: const Text(
                    'Home',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close drawer (already on home)
                  },
                ),
                // Settings navigation item (placeholder)
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white),
                  title: const Text(
                    'Settings',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context); // TODO: Navigate to settings
                  },
                ),
                // Help navigation item (placeholder)
                ListTile(
                  leading: const Icon(Icons.help, color: Colors.white),
                  title: const Text(
                    'Help',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context); // TODO: Navigate to help
                  },
                ),
                const Divider(color: Colors.white54), // Bottom divider
              ],
            ),
          ),
        );
      },
    );
  }
}
