import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/models/loan.dart';
import 'package:loan_app/models/transaction.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/views/transaction.dart';
import 'package:loan_app/ui/widgets/card_view.dart';
import 'package:loan_app/ui/widgets/custom_back_button.dart';
import 'package:loan_app/ui/widgets/custom_button.dart';
import 'package:loan_app/ui/widgets/custom_snackbar.dart';
import 'package:loan_app/ui/widgets/formate_amount.dart';
import 'package:loan_app/ui/widgets/header.dart';

class LoanDetails extends StatelessWidget {
  final String borrowerId;
  final String loanId;
  const LoanDetails({Key? key, required this.borrowerId, required this.loanId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF7CF18), body: bodyWidget());
  }

  Stream<QuerySnapshot> get stream => getLoan(borrowerId, loanId);

  Stream<QuerySnapshot> getLoan(String borrowerId, String loanId) {
    return FirestoreService().getLoan(borrowerId, loanId);
  }

  Widget bodyWidget() {
    return Builder(builder: ((context) {
      return SafeArea(
          child: StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No Data Found"));
                }
                LoanModel loan = LoanModel.fromJson(
                    snapshot.data!.docs.first.data() as Map<String, dynamic>);
                return Loan(loan: loan);
              }));
    }));
  }
}

class Loan extends StatefulWidget {
  final LoanModel loan;
  const Loan({Key? key, required this.loan}) : super(key: key);

  @override
  State<Loan> createState() => _LoanState();
}

class _LoanState extends State<Loan> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      // floatingActionButton: _floatingActionButton(),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: CustomButton(
          onPressed: () {
            if (widget.loan.isActive) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TransactionForm(loan: widget.loan)));
            } else {
              customSnackbar(message: "Loan is not Active", context: context);
            }
          },
          buttonText: "Add transaction",
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: const Color(0xFFF7CF18),
      body: bodyWidget(),
      // make a button to add new transaction which is alway visible
    ));
  }

  Stream<QuerySnapshot> get stream => getTransactions();

  Stream<QuerySnapshot> getTransactions() {
    return FirestoreService()
        .getTransactions(widget.loan.id, widget.loan.borrowerId);
  }

  Widget bodyWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomBackButton(),

              // make loan inactive dialogbox to ask are yuo sure
              !widget.loan.isActive
                  ? TextButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                    title: const Text("Are you sure?"),
                                    actions: [
                                      TextButton(
                                        child: const Text("No"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      TextButton(
                                          child: const Text("Yes"),
                                          onPressed: () {
                                            FirestoreService()
                                                .updateActiveOfLoan(
                                                    widget.loan.id,
                                                    isActive: true);
                                            Navigator.pop(context);
                                          })
                                    ]));
                      },
                      child: const Text("Open Loan"))
                  : TextButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                    title: const Text("Are you sure?"),
                                    actions: [
                                      TextButton(
                                        child: const Text("No"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      TextButton(
                                          child: const Text("Yes"),
                                          onPressed: () {
                                            FirestoreService()
                                                .updateActiveOfLoan(
                                                    widget.loan.id,
                                                    isActive: false);
                                            Navigator.pop(context);
                                          })
                                    ]));
                      },
                      child: const Text("Close Loan"))
            ],
          ),
          _loanCard(widget.loan),
          const Row(
            children: [
              Header(title: "Transactions"),
            ],
          ),
          Expanded(
            child: _transactions(),
          ),
        ],
      ),
    );
  }

  Widget _loanCard(LoanModel loan) {
    double principleLeft = loan.amount;

    double interest = principleLeft * loan.interestRate / 100;

    return CustomCard(
      isActive: loan.isActive,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Header(
                    title: formatAmount(loan.amount),
                    fontSize: 30.0,
                    color: Colors.white),
                Header(
                    title: loan.date.toIso8601String().split("T")[0],
                    fontSize: 15.0,
                    color: Colors.white),
              ],
            ),
            // const Header(
            //     title: "₹ 1,00,000", fontSize: 30.0, color: Colors.white),
            _loanDetailRow(
                "Principal Left", formatAmount(principleLeft), () {}),
            _loanDetailRow("Intrest rate", "${loan.interestRate}%", () {}),
            _loanDetailRow("Intrest Amount", formatAmount(interest), () {}),
            _loanDetailRow("Collateral", " see collateral", () {
              showCollateralDialog(loan.collaterals);
            }),
          ],
        ),
      ),
    );
  }

  Widget _transactions() {
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
            // physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              TransactionModel transaction = TransactionModel.fromJson(
                  snapshot.data!.docs[index].data() as Map<String, dynamic>);
                  print('transaction ${transaction.rawAmount}');
              return ListTile(
                leading: InkWell(
                  onTap: () {
                    // FirestoreService().deleteTransaction(transaction.id);
                  },
                  child: const CircleAvatar(
                    backgroundImage: NetworkImage(
                        "https://avatars.githubusercontent.com/u/61448739?v=4"),
                  ),
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(formatAmount(transaction.amount),
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black)),
                        Container(
                          margin: const EdgeInsets.only(left: 5.0),
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            color: transaction.transactionType == "principal"
                                ? Colors.green.shade200
                                : Colors.blue.shade200,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Text(transaction.transactionType,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black)),
                        )
                      ],
                    ),
                    Text(transaction.dueDate.toIso8601String().split("T")[0],
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("Orignal Amount: ${transaction.id}",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                subtitle: Text(transaction.description ?? "",
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(transaction.date.toIso8601String().split("T")[0],
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                        DateFormat('h:mm a').format(transaction.date),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              );
            },
          );
        });
  }

  Widget _loanDetailRow(String title, String value, Function() onTap) {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Header(title: title, fontSize: 15.0, color: Colors.white),
          InkWell(
              onTap: onTap,
              child: Header(title: value, fontSize: 14.0, color: Colors.white)),
        ],
      ),
    );
  }

  // make a dialog to see colateral list
  void showCollateralDialog(List<Collateral> collaterals) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Collateral"),

                // close button
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: collaterals.map((collateral) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0), // Adjust margin as needed
                  padding:
                      const EdgeInsets.all(8.0), // Adjust padding as needed
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey, // Set border color
                      width: 1.0, // Set border width
                    ),
                    borderRadius:
                        BorderRadius.circular(8.0), // Set border radius
                  ),
                  child: ListTile(
                    // show image with url
                    leading: collateral.imageUrl.isEmpty
                        ? const Icon(Icons.ac_unit_rounded)
                        : CircleAvatar(
                            backgroundImage: NetworkImage(
                            collateral.imageUrl,
                          )),
                    title: Text(collateral.description),
                  ),
                );
              }).toList(),
            ),
          );
        });
  }
}
