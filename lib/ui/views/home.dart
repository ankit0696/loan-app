import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/models/borrower.dart';
import 'package:loan_app/models/transaction.dart';
import 'package:loan_app/models/user.dart';
import 'package:loan_app/services/auth_service.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/services/notification_service.dart';
import 'package:loan_app/ui/shimmer_screens/home_shimmer.dart';
import 'package:loan_app/ui/shimmer_screens/transaction_card.dart';
import 'package:loan_app/ui/views/account.dart';
import 'package:loan_app/ui/views/all_borrowers.dart';
import 'package:loan_app/ui/views/all_transactions.dart';
import 'package:loan_app/ui/views/borrower_form.dart';
import 'package:loan_app/ui/views/profile_page.dart';
import 'package:loan_app/ui/widgets/app_background.dart';
import 'package:loan_app/ui/widgets/circular_avatar.dart';
import 'package:loan_app/ui/widgets/custom_snackbar.dart';
import 'package:loan_app/ui/widgets/formate_amount.dart';
import 'package:loan_app/ui/widgets/header.dart';
import 'package:loan_app/ui/widgets/transaction_card_widget.dart';

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
              // return const Center(
              //   child: CircularProgressIndicator(),
              // );
              return const HomeShimmer();
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

Stream<QuerySnapshot> get streamTransaction => getTransactions();

Stream<QuerySnapshot> getTransactions() {
  return FirestoreService().getAllTransactions(limit: 10);
}

Future<QuerySnapshot> getBorrowersDetails(String borrowerId) async {
  return await FirestoreService().getBorrowerDetailsById(borrowerId);
}

class _HomeState extends State<Home> {
  List<BorrowerModel> borrower = [];

  NotificationService notificationService = NotificationService();

// financial information
  double totalInvestedAmount = 0;
  double totalInterestEarned = 0;
  double totalPrincipalEarned = 0;
  double totalIntrestEarnedThisMonth = 0;
  double totalPrincipalEarnedThisMonth = 0;

  @override
  void initState() {
    notificationService.getNotificationPermission();
    fetchFinancialInformation();
    updateFcmToken();
    super.initState();
  }

  // update FCM Token if different
  Future<void> updateFcmToken() async {
    print("This is step one");
    FirestoreService().updateFCMTokenIfDifferent();
  }

  Future<void> fetchFinancialInformation() async {
    String lenderId = AuthService().user.uid;
    totalInvestedAmount =
        await FirestoreService().getTotalInvestedAmount(lenderId);
    totalInterestEarned =
        await FirestoreService().getTotalInterestEarned(lenderId);
    totalIntrestEarnedThisMonth =
        await FirestoreService().getTotalInterestEarnedThisMonth(lenderId);

    // totalPrincipalEarned =
    //     await FirestoreService().getTotalPrincipalEarned(lenderId);
    setState(() {
      // Refresh the UI to display the results
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          // floatingActionButton: _floatingActionButton(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topNavBar(widget.user),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _spaceInBetween(),
                      _borrowerCard(),
                      _spaceInBetween(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            const Header(title: "Transactions"),
                            const Spacer(),
                            //view all button
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AllTransactions()));
                              },
                              child: const Header(
                                title: "View All",
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: transactions(),
                      ),
                    ],
                  ),
                ),
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
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25.0),
          bottomRight: Radius.circular(25.0),
        ),
        // color: Colors.grey[400],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfilePage()));
                    },
                    child: const CircularAvatar(
                      imageUrl:
                          "https://avatars.githubusercontent.com/u/61448739?v=4",
                      radius: 60.0,
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Header(
                        title: user.name,
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                      Row(
                        children: [
                          const Header(
                              title: "Welcome Back!",
                              fontSize: 20.0,
                              color: Colors.black),
                          IconButton(
                            onPressed: () async {
                              fetchFinancialInformation().then((value) {
                                showModalBottomSheet(
                                  showDragHandle: true,
                                  useRootNavigator: true,
                                  useSafeArea: true,
                                  elevation: 8.0,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                  ),
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.45,
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Header(
                                                title: "Financial Information",
                                              ),
                                              // refresh data
                                              IconButton(
                                                onPressed: () {
                                                  fetchFinancialInformation();
                                                },
                                                icon: const Icon(Icons.refresh),
                                              )
                                            ],
                                          ),
                                          _financialInformationCard(
                                            "Invested Amount",
                                            totalInvestedAmount,
                                          ),
                                          _financialInformationCard(
                                            "Interest Earned",
                                            totalInterestEarned,
                                          ),
                                          _financialInformationCard(
                                            "Current Month Interest",
                                            totalIntrestEarnedThisMonth,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              });
                            },
                            icon: const Icon(Icons.info_rounded),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  customSnackbar(
                    message: "Under Development",
                    context: context,
                    color: Colors.red,
                  );
                },
                child: Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.43),
                    border: const Border.fromBorderSide(
                      BorderSide(
                        color: Colors.white,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _financialInformationCard(String title, double amount) {
    return InkWell(
      onDoubleTap: () {
        // fetchFinancialInformation call the function
        fetchFinancialInformation();
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              formatAmount(amount),
              // "\$${amount.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.green,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                const Header(title: "Borrowers"),
                const Spacer(),
                //view all button
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllBorrowers(),
                      ),
                    );
                  },
                  child: const Header(
                    title: "View All",
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
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
                          builder: (context) => const BorrowForm(),
                        ),
                      );
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
                                      builder: (context) =>
                                          AccountPage(borrowerId: borrower.id),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    // const CircularAvatar(
                                    //   imageUrl:
                                    //       "https://avatars.githubusercontent.com/u/61448739?v=4",
                                    //   // borrower.imageUrl ?? "", // check for null
                                    //   radius: 60.0,
                                    // ),
                                    CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFFF7CF18),
                                        radius: 30.0,
                                        child: Text(
                                          getInitials(borrower.name),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        )),
                                    const SizedBox(height: 10.0),
                                    SizedBox(
                                      width: 75.0,
                                      child: Text(
                                        borrower.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          color: Colors.black,
                                          fontSize: 15.0,
                                        ),
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
    return StreamBuilder<QuerySnapshot>(
        stream: streamTransaction,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text("Something went wrong",
                    style: TextStyle(color: Colors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Data Found"));
          }

          return ListView.builder(
            // physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              TransactionModel transaction = TransactionModel.fromJson(
                  snapshot.data!.docs[index].data() as Map<String, dynamic>);
              return FutureBuilder<QuerySnapshot>(
                  future: getBorrowersDetails(transaction.borrowerId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text("Something went wrong",
                              style: TextStyle(color: Colors.red)));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: TransactionCardShimmer());
                    }
                    BorrowerModel borrower = BorrowerModel.fromJson(
                        snapshot.data!.docs[0].data() as Map<String, dynamic>);

                    return ListTile(
                      leading: CircleAvatar(
                          backgroundColor: const Color(0xFFF7CF18),
                          child: Text(
                            getInitials(borrower.name),
                            style: const TextStyle(color: Colors.white),
                          )),
                      title: transactionCard(transaction),
                      subtitle: Text(transaction.description ?? "",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(transaction.date.toIso8601String().split("T")[0],
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                          Text(borrower.name,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    );
                  });
            },
          );
        });
  }

  Widget _spaceInBetween({double? height}) {
    return SizedBox(height: height ?? 20);
  }
}
