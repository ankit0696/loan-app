import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:loan_app/services/auth_service.dart';
import 'package:loan_app/ui/views/home.dart';
import 'package:loan_app/ui/views/sign_up.dart';
import 'package:loan_app/ui/widgets/circular_avatar.dart';
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
    final email = _emailController.value.text;
    final password = _passwordController.value.text;

    if (email.isEmpty || password.isEmpty) {
      customSnackbar(message: 'Please fill all fields', context: context);
      return;
    }

    AuthService().signInWithEmailAndPassword(email, password).then((value) {
      if (value == 'success') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        customSnackbar(message: 'Login failed', context: context);
      }
    });
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
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
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
              const SizedBox(height: 20.0),
              const Header(
                title: "Loan App",
                fontSize: 25.0,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              textField(
                  hint: 'Enter your email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController),
              textField(
                  hint: 'Enter your password',
                  icon: Icons.lock,
                  keyboardType: TextInputType.visiblePassword,
                  controller: _passwordController,
                  isPassword: true),
              const SizedBox(height: 30.0),
              _loginButton(),
              const SizedBox(height: 20.0),
              _googleLoginButton(),
              _signup(),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _loginButton() {
    return SizedBox(
      height: 50.0,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ElevatedButton(
        onPressed: () {
          _handleSubmit();
        },
        child: _loading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : const Text('Login'),
      ),
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
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5.0,
              spreadRadius: 1.0,
              offset: Offset(0.0, 0.0),
            ),
          ],
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.g_mobiledata,
              color: Colors.black,
            ),
            SizedBox(width: 10.0),
            Text(
              'Login with Google',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signup() {
    // dont have a account
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.white),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignupScreen(),
              ),
            );
          },
          child: const Text(
            'Sign up',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
