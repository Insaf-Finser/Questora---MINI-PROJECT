import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AuthResult {
  final bool status;
  final bool isFirstLogin;
  final User? user;
  final String? error;

  AuthResult({
    required this.status,
    this.isFirstLogin = false,
    this.user,
    this.error,
  });
}

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(status: false, error: 'User cancelled sign-in');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      final bool isFirstLogin = userCredential.additionalUserInfo?.isNewUser ?? false;

      return AuthResult(
        status: true,
        isFirstLogin: isFirstLogin,
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        status: false,
        error: e.message ?? 'Google sign-in failed',
      );
    } catch (e) {
      return AuthResult(
        status: false,
        error: e.toString(),
      );
    }
  }
}
