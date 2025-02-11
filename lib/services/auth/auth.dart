// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthServices{

  final _firebaseaAuth = FirebaseAuth.instance;

  User? getCurrentUser(){
    return _firebaseaAuth.currentUser;
  } 

  signInWithGoogle() async{

    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    if(gUser == null) {
      return null;
    } 

    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    UserCredential userCredential = await _firebaseaAuth.signInWithCredential(credential);
    User? user = userCredential.user;

      if (user != null) {
        // Save first-time login status
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool hasLoggedInBefore = prefs.getBool('hasLoggedInBefore') ?? false;

        if (!hasLoggedInBefore) {
          await prefs.setBool('hasLoggedInBefore', true);
        }

        return user.displayName; // Return the Google user's name
      }

      return null;
    
  }

}