import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/models/user.dart';
import 'package:loan_app/services/auth_service.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/views/home.dart';
import 'package:loan_app/ui/views/sign_in.dart';
import 'package:loan_app/ui/widgets/circular_avatar.dart';
import 'package:loan_app/ui/widgets/custom_snackbar.dart';
import 'package:loan_app/ui/widgets/header.dart';
import 'package:loan_app/ui/widgets/textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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

      AuthService().registerWithEmailAndPassword(email, password).then((value) {
        if (value == 'success') {
          final user = UserModel(
            name: name,
            email: email,
            id: AuthService().user.uid,
          );
          FirestoreService().addUser(user);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        } else {
          customSnackbar(message: 'Sign up failed', context: context);
          setState(() {
            _loading = false;
          });
        }
      });
    } catch (e) {
      customSnackbar(message: 'Sign up failed', context: context);
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
              const Header(title: "Sign Up", fontSize: 15.0),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              // name
              textField(
                  hint: 'Enter your name',
                  icon: Icons.person,
                  keyboardType: TextInputType.name,
                  controller: _nameController),
              // Email
              textField(
                  hint: 'Enter your email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController),
              // Password
              textField(
                  hint: 'Enter your password',
                  icon: Icons.lock,
                  keyboardType: TextInputType.visiblePassword,
                  controller: _passwordController,
                  isPassword: true),
              const SizedBox(height: 30.0),
              _signupButton(),
              const SizedBox(height: 20.0),
              _goToSignin(),
            ],
          ),
        ),
      ),
    ));
  }

  _signupButton() {
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
            : const Text(
                'Sign Up',
              ),
      ),
    );
  }

  _goToSignin() {
    // dont have a account
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account?",
          style: TextStyle(color: Colors.white),
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
