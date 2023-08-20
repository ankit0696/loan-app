import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/models/user.dart';
import 'package:loan_app/services/auth_service.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/views/change_mpin.dart';
import 'package:loan_app/ui/widgets/app_background.dart';
import 'package:loan_app/ui/widgets/circular_avatar.dart';
import 'package:loan_app/ui/widgets/custom_back_button.dart';
import 'package:loan_app/ui/widgets/custom_button.dart';
import 'package:loan_app/ui/widgets/custom_snackbar.dart';
import 'package:loan_app/ui/widgets/header.dart';
import 'package:loan_app/ui/widgets/textfield.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
              return Profile(user: user);
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

class Profile extends StatefulWidget {
  final UserModel user;
  const Profile({Key? key, required this.user}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
      height: MediaQuery.of(context).size.height * 0.69,
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
    return Column(
      children: [
        textField(
          keyboardType: TextInputType.name,
          label: 'Name',
          hint: widget.user.name,
          controller: TextEditingController(text: widget.user.name),
          icon: Icons.person,
          onIconTap: () {
            customSnackbar(message: 'Name cannot be changed', context: context);
          },
        ),
        textField(
          keyboardType: TextInputType.emailAddress,
          label: 'Email',
          hint: widget.user.email,
          controller: TextEditingController(text: widget.user.email),
          icon: Icons.email,
          onIconTap: () {
            customSnackbar(
                message: 'Email cannot be changed', context: context);
          },
        ),
        const SizedBox(height: 20.0),
        CustomButton(
          buttonText: 'Update Profile',
          onPressed: () {
            customSnackbar(
                message: 'Profile cannot be updated', context: context);
          },
        ),
        const Spacer(),
        CustomButton(
          buttonText: 'Change M-Pin',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChangeMPIN(),
              ),
            );
          },
        ),
        const SizedBox(height: 20.0),
        CustomButton(
          buttonColor: Colors.red[300],
          buttonText: 'Logout',
          onPressed: () {
            AuthService().signOut(context);
          },
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
