import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/views/auth/m_pin.dart';
import 'package:loan_app/ui/views/bording_screen/bording_screen.dart';
import 'package:loan_app/ui/views/home.dart';
import 'package:loan_app/ui/views/splash_screen.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  bool isInitialized = false;

  Future<dynamic> initializeApp() async {
    await Future.delayed(const Duration(seconds: 2), () {});
    FirebaseApp snapshot = await _initialization;
    return Future.value(true);
  }

  @override
  void initState() {
    super.initState();
    initializeApp().then((value) {
      if (value) {
        setState(() {
          isInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isInitialized
        ? StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              if (authSnapshot.hasError) {
                return const Scaffold(
                  body: Center(
                    child: Text(
                      'Error: Something went wrong',
                    ),
                  ),
                );
              }

              if (authSnapshot.connectionState == ConnectionState.active) {
                Object? user = authSnapshot.data;

                if (user == null) {
                  return const OnbordingScreen();
                } else {
                  // chek if user has MPIN
                  FirestoreService().hasMPIN().then((value) {
                    if (value) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MPINScreen()));
                    } else {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()));
                    }
                  });
                  // return MPINScreen();
                }
              }
              return const SplashScreen();
            })
        : const SplashScreen();
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Something went wrong"),
      ),
    );
  }
}
