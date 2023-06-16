import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/models/borrower.dart';
import 'package:loan_app/models/user.dart';
import 'package:loan_app/services/auth_service.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/views/account.dart';
import 'package:loan_app/ui/views/borrower_form.dart';
import 'package:loan_app/ui/views/new_loan.dart';
import 'package:loan_app/ui/views/sign_in.dart';
import 'package:loan_app/ui/views/transaction.dart';
import 'package:loan_app/ui/widgets/app_background.dart';
import 'package:loan_app/ui/widgets/circular_avatar.dart';
import 'package:loan_app/ui/widgets/header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: bodyWidget(),
      ),
    );
  }

  Stream<QuerySnapshot> get stream => getUser();

  Stream<QuerySnapshot> getUser() {
    final String leander = AuthService().user.uid;
    print("leander $leander");
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
              return Home(user: user);
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    const Text('No User Data found'),
                    // logout button
                    TextButton(
                      onPressed: () {
                        AuthService().signOut();

                        // navigate to login page
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SigninScreen()));
                      },
                      child: Text('Logout'),
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

class Home extends StatefulWidget {
  final UserModel user;
  const Home({Key? key, required this.user}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

Stream<QuerySnapshot> get stream => getBorrower();

Stream<QuerySnapshot> getBorrower() {
  final String? leander = AuthService().user.uid;
  return FirestoreService().getBorrowers(leander!);
}

class _HomeState extends State<Home> {
  List<BorrowerModel> borrower = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: _floatingActionButton(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topNavBar(widget.user),
              _spaceInBetween(),
              _borrowerCard(),
              _spaceInBetween(height: 20.0),
              const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Header(title: "Transactions"),
              ),
              Expanded(
                child: transactions(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _topNavBar(UserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25.0),
          bottomRight: Radius.circular(25.0),
        ),
        color: Colors.grey[400],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircularAvatar(
                imageUrl:
                    "https://avatars.githubusercontent.com/u/61448739?v=4",
                radius: 60.0,
              ),
              const SizedBox(width: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Header(
                    title: user.name,
                    fontSize: 20.0,
                    color: const Color.fromARGB(255, 137, 136, 136),
                  ),
                  const Header(
                      title: "Welcome Back!",
                      fontSize: 20.0,
                      color: Colors.black),
                ],
              ),
            ],
          ),
          InkWell(
            onTap: () {
              AuthService().signOut();

              // navigate to login page
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SigninScreen()));
            },
            child: Container(
              height: 50.0,
              width: 50.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 137, 136, 136),
              ),
              child: const Icon(
                Icons.notifications,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _borrowerCard() {
    // make a scrollable list of circular avatar
    return SizedBox(
      height: 125.0,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
              padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
              child: Header(title: "Borrowers")),
          Flexible(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BorrowForm()));
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 60.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white24,
                              border: Border.all(
                                  color: const Color.fromARGB(
                                      255, 137, 136, 136))),
                          child: const Icon(
                            Icons.add,
                            color: Color.fromARGB(255, 137, 136, 136),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        const Text(
                          "Add",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }
                    if (snapshot.hasData) {
                      final List<BorrowerModel> borrowers = snapshot.data!.docs
                          .map((e) => BorrowerModel.fromJson(
                              e.data() as Map<String, dynamic>))
                          .toList();
                      return Row(
                        children: [
                          for (var borrower in borrowers)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AccountPage(
                                              borrowerId: borrower.id)));
                                },
                                child: Column(
                                  children: [
                                    const CircularAvatar(
                                      imageUrl:
                                          "https://avatars.githubusercontent.com/u/61448739?v=4",
                                      // borrower.imageUrl ?? "", // check for null
                                      radius: 60.0,
                                    ),
                                    const SizedBox(height: 10.0),
                                    Text(
                                      borrower.name,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget transactions() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            backgroundImage: NetworkImage(
                "https://avatars.githubusercontent.com/u/61448739?v=4"),
          ),
          title: const Text("Alina",
              style: TextStyle(fontSize: 15, color: Colors.black)),
          subtitle: const Text(
            "Paid you 1000",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text("10/10/2021",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text("10:00 AM",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Alert dialog
        _alertBox();
      },
      child: const Icon(Icons.add),
    );
  }

  Future<dynamic> _alertBox() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shadowColor: Colors.white,
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Create New", style: TextStyle(color: Colors.white)),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                    height: 25.0,
                    width: 25.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 137, 136, 136),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 13.0,
                    )),
              ),
            ],
          ),
          content: const Text(
              'Would you like to create a new loan or transaction?',
              style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child: const Text('New Loan'),
              onPressed: () {
                // Perform action for new loan
                // Navigator.pushReplacement(context,
                //     MaterialPageRoute(builder: (context) => LoanForm()));
              },
            ),
            TextButton(
              child: const Text('New Transaction'),
              onPressed: () {
                // Perform action for new transaction
                // Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => const TransactionForm()));
              },
            ),
          ],
        );
      },
    );
  }

  Widget _spaceInBetween({double? height}) {
    return SizedBox(height: height ?? 20);
  }
}
