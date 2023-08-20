import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/models/user.dart';
import 'package:loan_app/services/auth_service.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/widgets/app_background.dart';
import 'package:loan_app/ui/widgets/circular_avatar.dart';
import 'package:loan_app/ui/widgets/custom_back_button.dart';
import 'package:loan_app/ui/widgets/custom_button.dart';
import 'package:loan_app/ui/widgets/custom_snackbar.dart';
import 'package:loan_app/ui/widgets/header.dart';

class ChangeMPIN extends StatelessWidget {
  const ChangeMPIN({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      body: bodyWidget(),
    ));
  }

  Stream<QuerySnapshot> get stream => getUser();

  Stream<QuerySnapshot> getUser() {
    final String leander = AuthService().user.uid;
    return FirestoreService().getCurrentUser(leander);
  }

  Widget bodyWidget() {
    return Builder(
      builder: ((context) {
        return SafeArea(
            child: StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final UserModel user = UserModel.fromJson(
                  snapshot.data!.docs.first.data() as Map<String, dynamic>);
              return ChangeMPINData(user: user);
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
              // return const HomeShimmer();
            } else if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    const Text('No User Data found'),
                    // logout button
                    TextButton(
                      onPressed: () {
                        AuthService().signOut(context);
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
      }),
    );
  }
}

class ChangeMPINData extends StatefulWidget {
  final UserModel user;
  const ChangeMPINData({super.key, required this.user});

  @override
  State<ChangeMPINData> createState() => _ChangeMPINDataState();
}

class _ChangeMPINDataState extends State<ChangeMPINData> {
  final List<TextEditingController> _currentPinControllers =
      List.generate(4, (index) => TextEditingController());

  final List<TextEditingController> _newPinControllers =
      List.generate(4, (index) => TextEditingController());

  final List<TextEditingController> _confirmPinControllers =
      List.generate(4, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color(0xFFF7CF18),
      body: bodyWidget(context),
    ));
  }

  SingleChildScrollView bodyWidget(BuildContext context) {
    final sizeHeight = MediaQuery.of(context).size.height * 0.15;

    return SingleChildScrollView(
      child: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            background(context, sizeHeight),
            Padding(
              padding: EdgeInsets.only(top: sizeHeight),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBackButton(),
                ],
              ),
            ),
            Column(
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: sizeHeight / 2),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 5.0,
                        ),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: const CircularAvatar(
                        imageUrl:
                            "https://avatars.githubusercontent.com/u/61448739?v=4",
                        radius: 80.0,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Header(
                      title: widget.user.name,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20.0),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.70,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18.0, vertical: 10.0),
                          child: extraDetails(context),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container background(BuildContext context, double sizeHeight) {
    return Container(
      margin: EdgeInsets.only(
        top: sizeHeight,
      ),
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        color: Color(0xFFC78E07),
      ),
    );
  }

  Widget extraDetails(BuildContext contaxt) {
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // enter current pin
          widget.user.mpin == null || widget.user.mpin == 0
              ? const SizedBox.shrink()
              : const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Header(title: 'Enter Current M-Pin', fontSize: 16),
                ),

          widget.user.mpin == null || widget.user.mpin == 0
              ? const SizedBox.shrink()
              : Row(
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
                            controller: _currentPinControllers[i],
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

          // enter new pin
          const Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Header(title: 'Enter New M-Pin', fontSize: 16),
          ),
          Row(
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
                      controller: _newPinControllers[i],
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

          // confirm new pin
          const Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Header(title: 'Confirm New M-Pin', fontSize: 16),
          ),
          Row(
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
                      controller: _confirmPinControllers[i],
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
          const Spacer(),
          const SizedBox(height: 20.0),
          CustomButton(
            buttonText: 'Change M-Pin',
            onPressed: () {
              String currentMPIN = '';

              if (widget.user.mpin == null || widget.user.mpin == 0) {
              } else {
                currentMPIN = _currentPinControllers[0].text +
                    _currentPinControllers[1].text +
                    _currentPinControllers[2].text +
                    _currentPinControllers[3].text;
              }

              final String newMPIN = _newPinControllers[0].text +
                  _newPinControllers[1].text +
                  _newPinControllers[2].text +
                  _newPinControllers[3].text;

              final String confirmMPIN = _confirmPinControllers[0].text +
                  _confirmPinControllers[1].text +
                  _confirmPinControllers[2].text +
                  _confirmPinControllers[3].text;

              // new password is 0000 then dont allow
              if (newMPIN == '0000') {
                customSnackbar(
                  message: 'M-Pin cannot be 0000',
                  context: context,
                );

                // clear all the text fields
                for (int i = 0; i < 4; i++) {
                  _currentPinControllers[i].clear();
                  _newPinControllers[i].clear();
                  _confirmPinControllers[i].clear();
                }
              } else {
                if (widget.user.mpin == null || widget.user.mpin == 0) {
                  if (newMPIN == confirmMPIN) {
                    FirestoreService().updateMPIN(
                      mpin: int.parse(newMPIN),
                      context: context,
                    );

                    // clear all the text fields
                    for (int i = 0; i < 4; i++) {
                      _currentPinControllers[i].clear();
                      _newPinControllers[i].clear();
                      _confirmPinControllers[i].clear();
                    }

                    customSnackbar(
                      message: 'M-Pin changed successfully',
                      context: context,
                    );

                    Navigator.pop(context);
                  } else {
                    customSnackbar(
                      message: 'New M-Pin and Confirm M-Pin does not match',
                      context: context,
                    );

                    // clear all the text fields
                    for (int i = 0; i < 4; i++) {
                      _currentPinControllers[i].clear();
                      _newPinControllers[i].clear();
                      _confirmPinControllers[i].clear();
                    }
                  }
                } else {
                  if (currentMPIN == widget.user.mpin.toString()) {
                    if (newMPIN == confirmMPIN) {
                      FirestoreService().updateMPIN(
                        mpin: int.parse(newMPIN),
                        context: context,
                      );

                      // clear all the text fields
                      for (int i = 0; i < 4; i++) {
                        _currentPinControllers[i].clear();
                        _newPinControllers[i].clear();
                        _confirmPinControllers[i].clear();
                      }

                      customSnackbar(
                        message: 'M-Pin changed successfully',
                        context: context,
                      );

                      Navigator.pop(context);
                    } else {
                      customSnackbar(
                        message: 'New M-Pin and Confirm M-Pin does not match',
                        context: context,
                      );

                      // clear all the text fields
                      for (int i = 0; i < 4; i++) {
                        _currentPinControllers[i].clear();
                        _newPinControllers[i].clear();
                        _confirmPinControllers[i].clear();
                      }
                    }
                  } else {
                    customSnackbar(
                      message: 'Current M-Pin is incorrect',
                      context: context,
                    );

                    // clear all the text fields
                    for (int i = 0; i < 4; i++) {
                      _currentPinControllers[i].clear();
                      _newPinControllers[i].clear();
                      _confirmPinControllers[i].clear();
                    }
                  }
                }
              }
            },
          ),

          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
