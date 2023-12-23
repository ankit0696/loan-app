import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/models/user.dart';
import 'package:loan_app/services/auth_service.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/views/auth/sign_in.dart';
import 'package:loan_app/ui/views/home.dart';
import 'package:loan_app/ui/widgets/app_background.dart';
import 'package:loan_app/ui/widgets/custom_button.dart';
import 'package:loan_app/ui/widgets/custom_snackbar.dart';
import 'package:loan_app/ui/widgets/header.dart';
import 'package:loan_app/ui/widgets/textfield.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final isLogin = true;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  _handleSubmit() {
    try {
      setState(() {
        _loading = true;
      });
      final name = _nameController.value.text;
      final email = _emailController.value.text;
      final password = _passwordController.value.text;

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        customSnackbar(message: 'Please fill all fields', context: context);
        setState(() {
          _loading = false;
        });
        return;
      }

      AuthService().registerWithEmailAndPassword(email, password).then((value) async{
        if (value == 'success') {
          final user = UserModel(
            name: name,
            email: email,
            id: AuthService().user.uid,
            fcmToken:await AuthService().getFCMToken() ?? '', 
          );
          FirestoreService().addUser(user);
          setState(() {
            _loading = false;
          });
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) =>  const HomePage()));
        } else {
          customSnackbar(message: 'Sign up failed', context: context);
          setState(() {
            _loading = false;
          });
        }
      });
    } catch (e) {
      customSnackbar(message: 'Sign up failed', context: context);
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
          child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // const CircularAvatar(
                    //   imageUrl:
                    //       "https://avatars.githubusercontent.com/u/61448739?v=4",
                    //   radius: 80.0,
                    // ),
                    Image.asset(
                      'assets/images/sign_up.png',
                      // height: MediaQuery.of(context).size.height * 0.35,
                      width: MediaQuery.of(context).size.width * 0.6,
                    ),
                    const SizedBox(height: 20.0),
                    const Header(title: "Loan App"),
                    const SizedBox(height: 32),
                    // name
                    textField(
                      hint: 'Enter your name',
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.name,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 27.0),
                    // Email
                    textField(
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 27.0),
                    // Password
                    textField(
                      hint: 'Enter your password',
                      icon: Icons.lock_outline_rounded,
                      keyboardType: TextInputType.visiblePassword,
                      controller: _passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 30.0),
                    _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : CustomButton(
                            onPressed: _handleSubmit, buttonText: "Sign Up"),
                    const SizedBox(height: 20.0),
                    _goToSignin(),
                  ],
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }

  /// The function returns a row with a text and a button that navigates to the SigninScreen when
  /// pressed.
  ///
  /// Returns:
  ///   A Row widget containing a Text widget and a TextButton widget. The Text widget displays the text
  /// "Already have an account?" and the TextButton widget displays the text "Sign in". When the
  /// TextButton is pressed, it navigates to the SigninScreen.
  _goToSignin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account?",
          style: TextStyle(
            color: Color(0xff505050),
            fontWeight: FontWeight.w400,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SigninScreen(),
              ),
            );
          },
          child: const Text(
            'Sign in',
            style: TextStyle(
              color: Color(0xff505050),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
