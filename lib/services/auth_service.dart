import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_insta/pages/sign_in_page.dart';
import 'package:my_insta/pages/sign_up_page.dart';
import 'package:my_insta/services/utils_service.dart';

import 'hive_service.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static Future<User?> signUpUser(
      BuildContext context, String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user!.updateDisplayName(name);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The password provided is too weak.')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The account already exists for that email.')));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }

  static Future<User?> signInUser(
      BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (kDebugMode) {
        print(userCredential.user.toString());
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Utils.showSnackBar('No user found for that email.', context);
      } else if (e.code == 'wrong-password') {
        Utils.showSnackBar('Wrong password provided for that user.', context);
      }
    }
    return null;
  }

  static void signOutUser(BuildContext context) async {
    await _auth.signOut();
    HiveDB.removeUid();
    Navigator.pushReplacementNamed(context, SignInPage.id);
  }

  static void deleteAccount(BuildContext context) async {
    try {
      _auth.currentUser!.delete();
      HiveDB.removeUid();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignUpPage()), (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Utils.showSnackBar('The user must re-authenticate before this operation can be executed.', context);
      }
    }
  }
}