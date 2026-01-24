import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_sphere_ai/auth/google_auth.dart';

class AuthHelper {
  static bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  static User? get currentUser => FirebaseAuth.instance.currentUser;

  static String? get userId => FirebaseAuth.instance.currentUser?.uid;

  /// Shows a login required dialog with option to sign in
  /// Returns true if user successfully logged in, false otherwise
  static Future<bool> showLoginRequiredDialog(
    BuildContext context, {
    required String featureName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final googleAuth = GoogleAuth();
                final userCredential = await googleAuth.signInWithGoogle();
                if (userCredential != null) {
                  Navigator.pop(context, true);
                } else {
                  Navigator.pop(context, false);
                }
              } catch (e) {
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
    return result ?? false;
  }

  /// Shows a snackbar indicating the feature requires login
  static void showLoginRequiredSnackbar(
    BuildContext context,
    String featureName,
  ) {
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Sign In',
          textColor: Colors.white,
          onPressed: () async {
            try {
              final googleAuth = GoogleAuth();
              await googleAuth.signInWithGoogle();
            } catch (e) {
              // Ignore sign-in errors from snackbar
            }
          },
        ),
      ),
    );
  }
}
