import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/models/loan.dart';
import 'package:loan_app/models/transaction.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/views/transaction.dart';
import 'package:loan_app/ui/widgets/card_view.dart';
import 'package:loan_app/ui/widgets/custom_back_button.dart';
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
        backgroundColor: const Color(0xFFF7CF18),
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   leading: BackButton(
        //     color: Colors.black,
        //     onPressed: () => Navigator.pop(context),
        //   ),
        // ),
        body: bodyWidget());
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
      floatingActionButton: _floatingActionButton(),
      backgroundColor: const Color(0xFFF7CF18),
      body: bodyWidget(),
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
            children: const [
              CustomBackButton(),
            ],
          ),
          _loanCard(widget.loan),
          Row(
            children: const [
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
            _loanDetailRow("Principal Left", formatAmount(principleLeft)),
            _loanDetailRow("Intrest rate", "${loan.interestRate}%"),
            _loanDetailRow("Collateral", loan.collateral),
            _loanDetailRow("Intrest Amount", formatAmount(interest)),
          ],
        ),
      ),
    );
    // return Container(
    //   margin: const EdgeInsets.only(bottom: 15.0),
    //   // padding: const EdgeInsets.all(15.0),
    //   width: double.infinity,
    //   decoration: BoxDecoration(
    //     boxShadow: const [
    //       BoxShadow(
    //         color: Colors.grey,
    //         blurRadius: 5.0,
    //         spreadRadius: 1.0,
    //         offset: Offset(0.0, 0.0),
    //       ),
    //     ],
    //     // color gradient
    //     gradient: LinearGradient(
    //       begin: Alignment.topLeft,
    //       end: Alignment.bottomRight,
    //       colors: [
    //         loan.isActive ? const Color(0xFFC78E07) : Colors.red.shade600,
    //         loan.isActive ? const Color(0xFFE7B60B) : Colors.red.shade200,
    //       ],
    //     ),
    //     borderRadius: BorderRadius.circular(10.0),
    //   ),
    //   child: Stack(
    //     children: [
    //       Positioned(
    //         bottom: -80,
    //         right: 20,
    //         child: ClipRect(
    //           child: Container(
    //             margin: const EdgeInsets.all(15.0),
    //             padding: const EdgeInsets.all(80.0),
    //             decoration: BoxDecoration(
    //               gradient: LinearGradient(
    //                 begin: Alignment.topLeft,
    //                 end: Alignment.bottomRight,
    //                 colors: [
    //                   loan.isActive
    //                       ? const Color(0xFFF7CF18).withOpacity(0.37)
    //                       : Colors.red.shade600.withOpacity(0.37),
    //                   loan.isActive
    //                       ? const Color(0xFFE7B60B).withOpacity(0.37)
    //                       : Colors.red.shade200.withOpacity(0.37),
    //                 ],
    //               ),
    //               borderRadius: BorderRadius.circular(100.0),
    //             ),
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //         top: -80,
    //         left: -10,
    //         child: ClipRect(
    //           child: Container(
    //             margin: const EdgeInsets.all(15.0),
    //             padding: const EdgeInsets.all(80.0),
    //             decoration: BoxDecoration(
    //               gradient: LinearGradient(
    //                 begin: Alignment.topLeft,
    //                 end: Alignment.bottomRight,
    //                 colors: [
    //                   loan.isActive
    //                       ? const Color(0xFFF7CF18).withOpacity(0.67)
    //                       : Colors.red.shade600.withOpacity(0.67),
    //                   loan.isActive
    //                       ? const Color(0xFFE7B60B).withOpacity(0.67)
    //                       : Colors.red.shade200.withOpacity(0.67),
    //                 ],
    //               ),
    //               borderRadius: BorderRadius.circular(100.0),
    //             ),
    //           ),
    //         ),
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.all(15.0),
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.start,
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: [
    //                 Header(
    //                     title: formatAmount(loan.amount),
    //                     fontSize: 30.0,
    //                     color: Colors.white),
    //                 Header(
    //                     title: loan.date.toIso8601String().split("T")[0],
    //                     fontSize: 15.0,
    //                     color: Colors.white),
    //               ],
    //             ),
    //             // const Header(
    //             //     title: "₹ 1,00,000", fontSize: 30.0, color: Colors.white),
    //             _loanDetailRow("Principal Left", formatAmount(principleLeft)),
    //             _loanDetailRow("Intrest rate", "${loan.interestRate}%"),
    //             _loanDetailRow("Collateral", loan.collateral),
    //             _loanDetailRow("Intrest Amount", formatAmount(interest)),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
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
          // return ListView.builder(
          //   physics: const BouncingScrollPhysics(),
          //   itemCount: snapshot.data!.docs.length,
          //   itemBuilder: (context, index) {
          //     return Center(
          //       child: Text(
          //         snapshot.data!.docs[index].data().toString(),
          //       ),
          //     );
          //   },
          // );
          // return ListView.builder(
          //   physics: const BouncingScrollPhysics(),
          //   itemCount: snapshot.data!.docs.length,
          //   itemBuilder: (context, index) {
          //     return ListTile(
          //       leading: const CircleAvatar(
          //         backgroundImage: NetworkImage(
          //             "https://avatars.githubusercontent.com/u/61448739?v=4"),
          //       ),
          //       title: const Text("Alina",
          //           style: TextStyle(fontSize: 15, color: Colors.black)),
          //       subtitle: const Text("Paid you 1000",
          //           style: TextStyle(fontSize: 12, color: Colors.grey)),
          //       trailing: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         crossAxisAlignment: CrossAxisAlignment.end,
          //         children: const [
          //           Text("10/10/2021",
          //               style: TextStyle(color: Colors.grey, fontSize: 12)),
          //           Text("10:00 AM",
          //               style: TextStyle(color: Colors.grey, fontSize: 12)),
          //         ],
          //       ),
          //     );
          //   },
          // );

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              TransactionModel transaction = TransactionModel.fromJson(
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
                        transaction.date
                            .toIso8601String()
                            .split("T")[1]
                            .split(".")[0],
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              );
            },
          );
        });
  }

  Widget _loanDetailRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Header(title: title, fontSize: 15.0, color: Colors.white),
          Header(title: value, fontSize: 14.0, color: Colors.white),
        ],
      ),
    );
  }

  _floatingActionButton() {
    // add new transaction
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TransactionForm(loan: widget.loan)));
      },
      child: const Icon(Icons.add),
    );
  }
}
