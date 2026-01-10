import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ------------------ Email & Password ------------------
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // ------------------ Google Sign-In ------------------
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(provider);
        return userCredential.user;
      } else {
        final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

        // Force sign out first to show account picker
        await googleSignIn.signOut();

        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      throw Exception("Google Sign-In failed: $e");
    }
  }

  // ------------------ Get Current User ------------------
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // ------------------ Check if user is logged in ------------------
  bool get isLoggedIn => _auth.currentUser != null;

  // ------------------ Sign Out ------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
