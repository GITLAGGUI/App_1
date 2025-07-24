import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'app_logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      AppLogger.error('Error signing in: $e', tag: 'AUTH');
      return null;
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      AppLogger.error('Error registering: $e', tag: 'AUTH');
      return null;
    }
  }

  // Sign in with Google - Updated for new API
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // If user cancels the sign-in
      if (googleUser == null) {
        AppLogger.warning('Google sign-in was cancelled by user', tag: 'AUTH');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      AppLogger.info('Google sign-in successful: ${userCredential.user?.email}', tag: 'AUTH');
      return userCredential;
    } catch (e) {
      AppLogger.error('Error signing in with Google: $e', tag: 'AUTH');
      return null;
    }
  }

  // Sign in with Apple - Simplified version
  Future<UserCredential?> signInWithApple() async {
    try {
      // Check if Apple Sign In is available
      if (!await SignInWithApple.isAvailable()) {
        AppLogger.warning('Apple Sign In is not available on this device', tag: 'AUTH');
        return null;
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(oauthCredential);
      AppLogger.info('Apple sign-in successful: ${userCredential.user?.email}', tag: 'AUTH');
      return userCredential;
    } catch (e) {
      AppLogger.error('Error signing in with Apple: $e', tag: 'AUTH');
      return null;
    }
  }

  // Sign in with Facebook
  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      
      if (loginResult.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential = 
            FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
        
        return await _auth.signInWithCredential(facebookAuthCredential);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error signing in with Facebook: $e', tag: 'AUTH');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
      await _auth.signOut();
    } catch (e) {
      AppLogger.error('Error signing out: $e', tag: 'AUTH');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      AppLogger.error('Error resetting password: $e', tag: 'AUTH');
    }
  }
}