import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:loan_app/models/transaction.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/widgets/formate_amount.dart';
import 'package:loan_app/ui/widgets/header.dart';

class AllTransactions extends StatefulWidget {
  const AllTransactions({super.key});

  @override
  State<AllTransactions> createState() => _AllTransactionsState();
}

Stream<QuerySnapshot> get stream => getTransactions();

Stream<QuerySnapshot> getTransactions() {
  return FirestoreService().getAllTransactions();
}

class _AllTransactionsState extends State<AllTransactions> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("All Transactions"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: transactions()),
          ],
        ),
      ),
    ));
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
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Data Found"));
          }

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
}
