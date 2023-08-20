import 'package:flutter/material.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/views/home.dart';
import 'package:loan_app/ui/widgets/app_background.dart';
import 'package:loan_app/ui/widgets/custom_button.dart';

class MPINScreen extends StatefulWidget {
  const MPINScreen({super.key});

  @override
  State<MPINScreen> createState() => _MPINScreenState();
}

class _MPINScreenState extends State<MPINScreen> {
  final List<TextEditingController> _digitControllers =
      List.generate(4, (index) => TextEditingController());
  String _verificationStatus = '';

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < 4; i++)
                      Container(
                        width: 68,
                        height: 68,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(
                          child: TextFormField(
                            cursorColor: Colors.black,
                            controller: _digitControllers[i],
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 24),
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              // going forward
                              if (value.isNotEmpty) {
                                if (i < 3) {
                                  FocusScope.of(context).nextFocus();
                                } else {
                                  FocusScope.of(context).unfocus();
                                  _verifyMPIN();
                                }
                              }
                              // going backward
                              else {
                                if (i > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                              }
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: CustomButton(
                  onPressed: _verifyMPIN,
                  buttonText: 'Verify MPIN',
                ),
              ),
              const SizedBox(height: 20),
              errorText(_verificationStatus),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyMPIN() async {
    try {
      String mpin =
          _digitControllers.map((controller) => controller.text).join();

      if (mpin.isEmpty || mpin.length != 4) {
        setState(() {
          _verificationStatus = 'Enter 4-digit MPIN';
        });
      } else {
        final result = await _fetchMPINFromFirestoreAndMatch(mpin);
        if (result == 'Enter MPIN' || result == 'Invalid MPIN') {
          setState(() {
            _verificationStatus = result;
          });
        } else if (result == 'MPIN verified!') {
          setState(() {
            _verificationStatus = result;
          });
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        } else {
          setState(() {
            _verificationStatus = 'Something went wrong';
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> _fetchMPINFromFirestoreAndMatch(String mpin) async {
    try {
      return FirestoreService()
          .fetchMPINFromFirestoreAndMatch(int.parse(mpin))
          .then((value) => value);
    } catch (e) {
      print(e);
      return '';
    }
  }
}

Widget errorText(String error) {
  TextStyle errorTextStyle;
  if (error == 'MPIN verified!') {
    errorTextStyle = const TextStyle(color: Colors.green);
  } else {
    errorTextStyle = const TextStyle(color: Colors.red);
  }

  return Text(
    error,
    style: errorTextStyle,
  );
}