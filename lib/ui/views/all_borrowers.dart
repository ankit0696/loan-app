import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/models/borrower.dart';
import 'package:loan_app/models/transaction.dart';
import 'package:loan_app/services/auth_service.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/views/account.dart';
import 'package:loan_app/ui/widgets/app_background.dart';
import 'package:loan_app/ui/widgets/custom_back_button.dart';
import 'package:loan_app/ui/widgets/custom_snackbar.dart';
import 'package:loan_app/ui/widgets/formate_amount.dart';
import 'package:loan_app/ui/widgets/header.dart';
import 'package:url_launcher/url_launcher.dart';

class AllBorrowers extends StatefulWidget {
  const AllBorrowers({super.key});

  @override
  State<AllBorrowers> createState() => _AllBorrowersState();
}

Stream<QuerySnapshot> get stream => getBorrower();

Stream<QuerySnapshot> getBorrower() {
  final String? leander = AuthService().user.uid;
  return FirestoreService().getBorrowers(leander!);
}

class _AllBorrowersState extends State<AllBorrowers> {
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
          child: Scaffold(
        backgroundColor: Colors.transparent,
        body: bodyWidget(),
      )),
    );
  }

  Center bodyWidget() {
    final sizeHeight = MediaQuery.of(context).size.height * 0.15;

    return Center(
      child: SingleChildScrollView(
        child: Stack(
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
                          color: Colors.transparent,
                          width: 5.0,
                        ),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: const SizedBox(height: 80),
                    ),
                    // const SizedBox(height: 20.0),
                    const Header(
                      title: "All Borrowers", //widget.user.name,
                      fontSize: 20,
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
                        height: MediaQuery.of(context).size.height * 0.80,
                        child: borrowers(),
                      )
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

  Widget borrowers() {
    return StreamBuilder<QuerySnapshot>(
        stream: stream,
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
            physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              BorrowerModel borrower = BorrowerModel.fromJson(
                  snapshot.data!.docs[index].data() as Map<String, dynamic>);
              return ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://avatars.githubusercontent.com/u/61448739?v=4"),
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountPage(
                              borrowerId: borrower.id,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(borrower.name,
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black)),
                        ],
                      ),
                    ),
                    Text(
                        "Borrowed on: ${borrower.date.toIso8601String().split("T")[0]}",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                trailing: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.message,
                            color: borrower.phone != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                          onPressed: borrower.phone != null
                              ? () async {
                                  try {
                                    // write a custom message

                                    final Uri url = Uri(
                                      scheme: 'sms',
                                      path: borrower.phone,
                                      queryParameters: <String, String>{
                                        'body': "Hello ${borrower.name},"
                                            "\n\nYou have borrowed from me on ${borrower.date.toIso8601String().split("T")[0]}."
                                            "\n\nPlease pay me ${getMonthName()} month intrest back as soon as possible."
                                            "\n\nThanks"
                                      },
                                    );
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      // ignore: use_build_context_synchronously
                                      customSnackbar(
                                          message:
                                              "Not able to message ${borrower.name}",
                                          context: context);
                                      throw 'Could not launch $url';
                                    }
                                  } catch (e) {
                                    // ignore: use_build_context_synchronously
                                    customSnackbar(
                                        message:
                                            "Not able to message ${borrower.name}",
                                        context: context);
                                  }
                                  // launch("tel://${borrower.phone}");
                                }
                              : () {
                                  customSnackbar(
                                      message: "No phone number found",
                                      context: context);
                                },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.call_rounded,
                            color: borrower.phone != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                          onPressed: borrower.phone != null
                              ? () async {
                                  try {
                                    final Uri url = Uri(
                                        scheme: 'tel', path: borrower.phone);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      // ignore: use_build_context_synchronously
                                      customSnackbar(
                                          message:
                                              "Not able to call ${borrower.name}",
                                          context: context);
                                      throw 'Could not launch $url';
                                    }
                                  } catch (e) {
                                    // ignore: use_build_context_synchronously
                                    customSnackbar(
                                        message:
                                            "Not able to call ${borrower.name}",
                                        context: context);
                                  }
                                  // launch("tel://${borrower.phone}");
                                }
                              : () {
                                  customSnackbar(
                                      message: "No phone number found",
                                      context: context);
                                },
                        ),
                      ],
                    )),
              );
            },
          );
        });
  }

  Container background(BuildContext context, double sizeHeight) {
    return Container(
      margin: EdgeInsets.only(
        top: sizeHeight,
      ),
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        color: Color(0xFFC78E07),
      ),
    );
  }

  // get current month name
  String getMonthName() {
    final now = DateTime.now();
    final String monthName = now.month.toString();

    // get current month name
    switch (monthName) {
      case "1":
        return "January";
      case "2":
        return "February";
      case "3":
        return "March";
      case "4":
        return "April";
      case "5":
        return "May";
      case "6":
        return "June";
      case "7":
        return "July";
      case "8":
        return "August";
      case "9":
        return "September";
      case "10":
        return "October";
      case "11":
        return "November";
      case "12":
        return "December";
      default:
        return "January";
    }
  }
}
