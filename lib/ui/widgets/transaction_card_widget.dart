
  import 'package:flutter/material.dart';
import 'package:loan_app/models/transaction.dart';
import 'package:loan_app/ui/widgets/formate_amount.dart';

Column transactionCard(TransactionModel transaction) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(formatAmount(transaction.amount),
                style: const TextStyle(fontSize: 15, color: Colors.black)),
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
                  style: const TextStyle(fontSize: 10, color: Colors.black)),
            )
          ],
        ),
        Text(transaction.dueDate.toIso8601String().split("T")[0],
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
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

  // return first letter of the string in capital
  // Shubham Kumar => SK
  // Text User => TU
  String getInitials(String name) {
    List<String> nameSplit = name.split(" ");
    String initials = "";
    for (var i = 0; i < nameSplit.length; i++) {
      initials += nameSplit[i][0];
    }
    return initials.toUpperCase().trim();
  }