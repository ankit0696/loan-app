import 'package:flutter/material.dart';
import 'package:loan_app/ui/views/sign_in.dart';
import 'package:loan_app/ui/views/sign_up.dart';
import 'package:loan_app/ui/widgets/custom_button.dart';

class BordingPage extends StatefulWidget {
  const BordingPage({super.key});

  @override
  State<BordingPage> createState() => _BordingPageState();
}

class _BordingPageState extends State<BordingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.maxFinite,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF2C94C),
              Color(0xFFE7C440),
              Color(0xFFD9B136),
              Color(0xFFC9940E),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // use an imahe from assets
            Image.asset(
              'assets/images/bording_logo.png',
              height: MediaQuery.of(context).size.height * 0.35,
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: CustomButton(
                buttonText: "Sign Up",
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const SignUpScreen();
                  }));
                },
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: CustomButton(
                buttonColor: Colors.white,
                buttonText: "Sign In",
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const SigninScreen();
                  }));
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: Color(0xFF505050),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 5),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const SignUpScreen();
                  }));
                  },
                  child: const Text(
                    "Register Now",
                    style: TextStyle(
                      // 505050
                      color: Color(0xFF505050),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
