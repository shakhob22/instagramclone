import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagramclone/pages/signin_page.dart';
import 'package:instagramclone/services/prefs_service.dart';
import 'package:instagramclone/services/utils_service.dart';

class AuthService{
  static final _auth = FirebaseAuth.instance;

  static Future<User?> signInUser(String email, String password) async {
    User? user;
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
      return user;
    }  on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Utils.fireToast('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Utils.fireToast('Wrong password provided.');
      } else {
        Utils.fireToast('Invalid email address or password');
      }
    }
    return null;
  }

  static Future<User?> signUpUser(String name, String email, String password) async {
    User? user;
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Utils.fireToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Utils.fireToast('The account already exists for that email.');
      } else {
        Utils.fireToast('Invalid email address or password');
      }
    }
    return null;
  }

  static void signOutUser(BuildContext context) {
    _auth.signOut();
    Prefs.removeUserId().then((value) {
      Navigator.pushReplacementNamed(context, SignInPage.id);
    });
  }
}
