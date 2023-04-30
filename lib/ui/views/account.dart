import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loan_app/models/borrower.dart';
import 'package:loan_app/models/loan.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/views/loan_detail.dart';
import 'package:loan_app/ui/views/new_loan.dart';
import 'package:loan_app/ui/widgets/circular_avatar.dart';
import 'package:loan_app/ui/widgets/custom_snackbar.dart';
import 'package:loan_app/ui/widgets/formate_amount.dart';
import 'package:loan_app/ui/widgets/header.dart';
import 'package:loan_app/ui/widgets/textfield.dart';

class AccountPage extends StatelessWidget {
  final String borrowerId;
  const AccountPage({Key? key, required this.borrowerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: bodyWidget());
  }

  Stream<QuerySnapshot> get stream => getBorrower(borrowerId);

  Stream<QuerySnapshot> getBorrower(String borrowerId) {
    return FirestoreService().getBorrower(borrowerId);
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
          BorrowerModel borrower = BorrowerModel.fromJson(
              snapshot.data!.docs.first.data() as Map<String, dynamic>);
          return Account(borrower: borrower);
        },
      ));
    }));
  }
}

class Account extends StatelessWidget {
  final BorrowerModel borrower;
  const Account({super.key, required this.borrower});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child:
            Scaffold(backgroundColor: Colors.white, body: bodyWidget(context)));
  }

  Stream<QuerySnapshot> get stream => getLoans();

  Stream<QuerySnapshot> getLoans() {
    return FirestoreService().getLoans(borrower.id);
  }

  SingleChildScrollView bodyWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            const CircularAvatar(
              imageUrl: "https://avatars.githubusercontent.com/u/61448739?v=4",
              radius: 80.0,
            ),
            const SizedBox(height: 20.0),
            Header(title: borrower.name),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: borrower.phone));
                customSnackbar(
                    message: "Copied to Clipboard", context: context);
              },
              child: Header(
                title: borrower.phone,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: extraDetails(context),
            ),
            const SizedBox(height: 20.0),
            const Header(title: "Loans", fontSize: 20.0),
            _loans(context),
            // for (int i = 0; i < 10; i++) loanCard(context),
            _addNewLoan(context),
          ],
        ),
      ),
    );
  }

  Widget extraDetails(BuildContext context) {
    return Column(children: [
      textField(
        keyboardType: TextInputType.none,
        label: "Aadhar Number",
        hint: borrower.aadharNumber,
        disabled: true,
        icon: Icons.copy,
        onIconTap: () {
          Clipboard.setData(ClipboardData(text: borrower.aadharNumber));
          customSnackbar(message: "Aadhar Copied", context: context);
        },
      ),
      textField(
        keyboardType: TextInputType.none,
        label: "Address",
        hint: borrower.address,
        disabled: true,
        icon: Icons.copy,
        onIconTap: () {
          Clipboard.setData(ClipboardData(text: borrower.address));
          customSnackbar(message: "Address copied", context: context);
        },
      ),
      const SizedBox(height: 10.0),
    ]);
  }

  _loans(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            LoanModel loan = LoanModel.fromJson(
                snapshot.data!.docs[index].data() as Map<String, dynamic>);
            return loanCard(context, loan);
          },
        );
      },
    );
  }

  Widget loanCard(BuildContext context, LoanModel loan) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    LoanDetails(borrowerId: loan.borrowerId, loanId: loan.id)));
      },
      child: Container(
        margin: const EdgeInsets.all(15.0),
        padding: const EdgeInsets.all(15.0),
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5.0,
              spreadRadius: 1.0,
              offset: Offset(0.0, 0.0),
            ),
          ],
          // color gradient
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              loan.isActive ? Colors.black87 : Colors.red.shade600,
              loan.isActive ? Colors.black38 : Colors.red.shade200,
              loan.isActive ? Colors.black87 : Colors.red.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
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
            // Header(
            //     title: loan.amount.toString(),
            //     fontSize: 15.0,
            //     color: Colors.white),
            const Spacer(),
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Header(
                        title: "Intrest rate",
                        fontSize: 15.0,
                        color: Colors.white),
                    Header(
                        title: "${loan.interestRate}%",
                        fontSize: 14.0,
                        color: Colors.white),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      loan.isActive ? Icons.check_circle : Icons.close,
                      color: loan.isActive ? Colors.green : Colors.black,
                    ),
                    Header(
                        title: loan.isActive ? "Active" : "Done",
                        fontSize: 14.0,
                        color: loan.isActive ? Colors.green : Colors.black),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _addNewLoan(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LoanForm(
                      borrowerId: borrower.id,
                      borrowerName: borrower.name,
                    )));
      },
      child: Container(
        margin: const EdgeInsets.all(15.0),
        padding: const EdgeInsets.all(15.0),
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5.0,
              spreadRadius: 1.0,
              offset: Offset(0.0, 0.0),
            ),
          ],
          // color gradient
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black87,
              Colors.black54,
              Colors.black87,
            ],
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(
              Icons.add,
              color: Colors.white,
              size: 50.0,
            ),
            SizedBox(height: 10.0),
            Header(title: "Add New Loan", fontSize: 15.0, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
