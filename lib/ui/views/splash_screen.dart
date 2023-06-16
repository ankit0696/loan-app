import 'package:flutter/material.dart';
import 'package:loan_app/ui/widgets/app_background.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
          child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/app_logo.png',
                // height: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                'Loan App',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              // const CircularProgressIndicator(),
            ],
          ),
        ),
      )),
    );
  }
}
