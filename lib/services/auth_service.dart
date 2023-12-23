import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loan_app/ui/views/auth/sign_in.dart';
import 'package:loan_app/ui/widgets/custom_snackbar.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  get user => _auth.currentUser;

  // sign in with email and password
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "success";
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  // register with email and password
  Future<String> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return "success";
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return e.toString();
    }
  }


  // sign out
  Future signOut(BuildContext context) async {
    try {
      return await _auth.signOut().then((value) {
        customSnackbar(message: "Logged out Successfully", context: context);
        // navigate to login page
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SigninScreen()));
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // reset password
  Future resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // change password
  Future changePassword(String password) async {
    try {
      User? user = _auth.currentUser;
      return await user!.updatePassword(password);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // change email
  Future changeEmail(String email) async {
    try {
      User? user = _auth.currentUser;
      return await user!.updateEmail(email);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // FCM Token
  Future<String?> getFCMToken() async{
    return await FirebaseMessaging.instance.getToken();
  }

  // get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // get current user id
  String getCurrentUserId() {
    return _auth.currentUser!.uid;
  }

  // get current user email
  String getCurrentUserEmail() {
    return _auth.currentUser!.email!;
  }

  Future<bool> signInWithGoogle() async {
    bool res = false;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // await _auth.signInWithCredential(credential);
      // return true;
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      res = true;
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      res = false;
    } catch (e) {
      // handle the error here
      print(e.toString());
      res = false;
    }
    return res;
  }

  // signInWithGoogle() async {
  //   GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  //   GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  //   AuthCredential credential = GoogleAuthProvider.credential(
  //     accessToken: googleAuth?.accessToken,
  //     idToken: googleAuth?.idToken,
  //   );

  //   UserCredential userCredential =
  //       await _auth.signInWithCredential(credential);

  //   print(userCredential.user?.displayName);
  // }
}
