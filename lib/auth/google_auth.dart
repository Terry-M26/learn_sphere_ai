// GoogleAuth - handles Google Sign-In authentication flow
// Integrates with Firebase Authentication for user management

import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth for credential management
import 'package:google_sign_in/google_sign_in.dart'; // Google Sign-In SDK

// Class to handle Google authentication
// Usage: final auth = GoogleAuth(); await auth.signInWithGoogle();
class GoogleAuth {
  // Main method to perform Google Sign-In
  // Returns UserCredential on success, null if cancelled
  Future<UserCredential?> signInWithGoogle() async {
    // Get Firebase Auth singleton instance
    FirebaseAuth auth = FirebaseAuth.instance;
    // Create GoogleSignIn instance for OAuth flow
    final GoogleSignIn googleSignIn = GoogleSignIn();

    // Sign out first to force account selection dialog
    // Without this, it auto-selects the last used account
    await googleSignIn.signOut();

    // Trigger Google Sign-In UI - shows account picker dialog
    // Returns null if user cancels the sign-in
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // Get authentication tokens from the signed-in Google account
    // Contains accessToken and idToken needed for Firebase
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    // Create Firebase credential from Google tokens
    // This credential is used to sign in to Firebase Auth
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken, // Short-lived access token
      idToken: googleAuth.idToken, // JWT containing user info
    );
    // Sign in to Firebase using the Google credential
    // Creates new Firebase user if first time, or links to existing
    final UserCredential userCredential = await auth.signInWithCredential(
      credential,
    );
    // Return the UserCredential containing user info and tokens
    return userCredential;
  }
}
