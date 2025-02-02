import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices{

  final _firebaseaAuth = FirebaseAuth.instance;

  User? getCurrentUser(){
    return _firebaseaAuth.currentUser;
  } 

  signInWithGoogle() async{

    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    if(gUser == null) return ;

    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    return await _firebaseaAuth.signInWithCredential(credential);
  }

}