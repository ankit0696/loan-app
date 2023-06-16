import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:loan_app/services/auth_service.dart';
import 'package:loan_app/ui/views/home.dart';
import 'package:loan_app/ui/views/sign_up.dart';
import 'package:loan_app/ui/widgets/app_background.dart';
import 'package:loan_app/ui/widgets/circular_avatar.dart';
import 'package:loan_app/ui/widgets/custom_button.dart';
import 'package:loan_app/ui/widgets/custom_snackbar.dart';
import 'package:loan_app/ui/widgets/header.dart';
import 'package:loan_app/ui/widgets/textfield.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final isLogin = true;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  _handleSubmit() {
    try {
      setState(() {
        _loading = true;
      });
      final email = _emailController.value.text;
      final password = _passwordController.value.text;

      if (email.isEmpty || password.isEmpty) {
        customSnackbar(message: 'Please fill all fields', context: context);
        setState(() {
          _loading = false;
        });
        return;
      }

      AuthService().signInWithEmailAndPassword(email, password).then((value) {
        if (value == 'success') {
          setState(() {
            _loading = false;
          });
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        } else {
          customSnackbar(message: 'Login failed', context: context);
          setState(() {
            _loading = false;
          });
        }
      });
    } catch (e) {
      customSnackbar(message: 'Login failed', context: context);
      setState(() {
        _loading = false;
      });
    }
  }

  _googleSignin() {
    try {
      AuthService().signInWithGoogle().then(
        (value) {
          if (value) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
          } else {
            customSnackbar(message: 'Login failed', context: context);
          }
        },
      );
    } catch (e) {
      customSnackbar(message: 'Login failed', context: context);
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
                    const CircularAvatar(
                      imageUrl:
                          "https://avatars.githubusercontent.com/u/61448739?v=4",
                      radius: 80.0,
                    ),
                    const SizedBox(height: 27.0),
                    const Header(title: "Loan App"),
                    const SizedBox(height: 32),
                    textField(
                        hint: 'Enter your email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController),
                    const SizedBox(height: 27.0),
                    textField(
                        hint: 'Enter your password',
                        icon: Icons.lock_outline_rounded,
                        keyboardType: TextInputType.visiblePassword,
                        controller: _passwordController,
                        isPassword: true),
                    const SizedBox(height: 27.0),
                    _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : CustomButton(
                            onPressed: _handleSubmit, buttonText: "Login"),
                    _forgetPassword(),
                    const SizedBox(height: 34.0),
                    _googleLoginButton(),
                    _goToSignup(),
                  ],
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }

  Row _forgetPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {},
          child: const Text(
            'Forget Password?',
            style: TextStyle(
              color: Color(0xff505050),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _googleLoginButton() {
    return InkWell(
      onTap: () {
        _googleSignin();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        height: 50.0,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5.0,
              spreadRadius: 1.0,
              offset: Offset(0.0, 0.0),
            ),
          ],
          // #646262
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: const Color(0xFF9F6609), width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.g_mobiledata,
              color: Colors.red,
            ),
            SizedBox(width: 10.0),
            Text(
              'Login with Google',
              style: TextStyle(color: Color(0xff646262)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _goToSignup() {
    // dont have a account
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
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
                builder: (context) => const SignUpScreen(),
              ),
            );
          },
          child: const Text(
            'Sign up',
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
