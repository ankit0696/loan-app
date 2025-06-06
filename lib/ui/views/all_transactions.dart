import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/models/borrower.dart';
import 'package:loan_app/models/transaction.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/shimmer_screens/transaction_card.dart';
import 'package:loan_app/ui/widgets/app_background.dart';
import 'package:loan_app/ui/widgets/custom_back_button.dart';
// import 'package:loan_app/ui/widgets/formate_amount.dart';
import 'package:loan_app/ui/widgets/header.dart';
import 'package:loan_app/ui/widgets/transaction_card_widget.dart';

class AllTransactions extends StatefulWidget {
  const AllTransactions({super.key});

  @override
  State<AllTransactions> createState() => _AllTransactionsState();
}

Stream<QuerySnapshot> get stream => getTransactions();

Stream<QuerySnapshot> getTransactions() {
  return FirestoreService().getAllTransactions();
}

// Future<QuerySnapshot> get future => getBorrowersDetails();

Future<QuerySnapshot> getBorrowersDetails(String borrowerId) async {
  return await FirestoreService().getBorrowerDetailsById(borrowerId);
}

class _AllTransactionsState extends State<AllTransactions> {
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
                      title: "All Transactions", //widget.user.name,
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
                        child: transactions(),
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

  Widget transactions() {
    return StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text("Something went wrong",
                    style: TextStyle(color: Colors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: TransactionCardShimmer());
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

}
