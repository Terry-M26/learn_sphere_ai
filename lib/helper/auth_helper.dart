// AuthHelper - utility class for authentication-related operations
// Provides static methods for checking login status and showing login dialogs

import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import 'package:flutter/material.dart'; // For BuildContext, widgets
import 'package:learn_sphere_ai/auth/google_auth.dart'; // Google Sign-In implementation

// Static utility class - no instance needed
// Usage: AuthHelper.isLoggedIn, AuthHelper.showLoginRequiredDialog()
class AuthHelper {
  // Check if user is currently logged in
  // Returns true if Firebase has a current user, false otherwise
  static bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  // Get the current Firebase User object (null if not logged in)
  // User object contains: uid, email, displayName, photoURL, etc.
  static User? get currentUser => FirebaseAuth.instance.currentUser;

  // Get just the user ID string (null if not logged in)
  // Used for Firestore document paths: users/{userId}/...
  static String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // Shows a modal dialog prompting user to sign in
  // Returns true if user successfully logged in, false if cancelled/failed
  // featureName: displayed in dialog to tell user why login is needed
  static Future<bool> showLoginRequiredDialog(
    BuildContext context, { // Required for showing dialog
    required String featureName, // e.g., "save chat history"
  }) async {
    // showDialog returns the value passed to Navigator.pop()
    final result = await showDialog<bool>(
      context: context,
      // Builder creates the dialog widget
      builder: (context) => AlertDialog(
        // Rounded corners for modern look
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Sign In Required',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please sign in to access $featureName.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Your data will be saved to your account.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            // Cancel button - closes dialog and returns false
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            // Sign In button - attempts Google sign-in
            onPressed: () async {
              try {
                // Create GoogleAuth instance and attempt sign-in
                final googleAuth = GoogleAuth();
                final userCredential = await googleAuth.signInWithGoogle();
                if (userCredential != null) {
                  // Success - close dialog and return true
                  Navigator.pop(context, true);
                } else {
                  // Sign-in returned null - return false
                  Navigator.pop(context, false);
                }
              } catch (e) {
                // Show error message if sign-in fails
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sign-in failed: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context, false);
              }
            },
            icon: const Icon(Icons.login_rounded, size: 18),
            label: const Text('Sign In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
    // Return result, defaulting to false if dialog dismissed without selection
    return result ?? false;
  }

  // Shows a snackbar at bottom of screen with sign-in option
  // Less intrusive than dialog - good for quick notifications
  static void showLoginRequiredSnackbar(
    BuildContext context, // Required for ScaffoldMessenger
    String featureName, // Action that requires login, e.g., "save progress"
  ) {
    // ScaffoldMessenger manages snackbars for the current Scaffold
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('Sign in required to $featureName')),
          ],
        ),
        backgroundColor: Colors.orange[700],
        behavior: SnackBarBehavior
            .floating, // Floats above content instead of sticking to bottom
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ), // Rounded corners
        // Action button on the snackbar for quick sign-in
        action: SnackBarAction(
          label: 'Sign In',
          textColor: Colors.white,
          onPressed: () async {
            try {
              // Attempt Google sign-in when user taps action
              final googleAuth = GoogleAuth();
              await googleAuth.signInWithGoogle();
            } catch (e) {
              // Silently ignore errors - snackbar already dismissed
            }
          },
        ),
      ),
    );
  }
}
