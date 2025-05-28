import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loan_app/models/borrower.dart';
import 'package:loan_app/models/loan.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/views/borrower_form.dart';
import 'package:loan_app/ui/views/loan_detail.dart';
import 'package:loan_app/ui/views/new_loan.dart';
import 'package:loan_app/ui/widgets/app_background.dart';
import 'package:loan_app/ui/widgets/card_view.dart';
import 'package:loan_app/ui/widgets/circular_avatar.dart';
import 'package:loan_app/ui/widgets/custom_back_button.dart';
import 'package:loan_app/ui/widgets/custom_snackbar.dart';
import 'package:loan_app/ui/widgets/formate_amount.dart';
import 'package:loan_app/ui/widgets/header.dart';
import 'package:loan_app/ui/widgets/textfield.dart';
import 'package:loan_app/ui/widgets/transaction_card_widget.dart';

class AccountPage extends StatelessWidget {
  final String borrowerId;
  const AccountPage({Key? key, required this.borrowerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: bodyWidget(),
      ),
    );
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

class Account extends StatefulWidget {
  final BorrowerModel borrower;
  const Account({super.key, required this.borrower});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7CF18),
        body: bodyWidget(context),
      ),
    );
  }

  Stream<QuerySnapshot> get stream => getLoans();

  Stream<QuerySnapshot> getLoans() {
    return FirestoreService().getLoans(widget.borrower.id);
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomBackButton(),
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        border: Border.all(
                          color: Colors.white,
                        )),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BorrowForm(id: widget.borrower.id),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                  )
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
                      // child: const CircularAvatar(
                      //   imageUrl:
                      //       "https://avatars.githubusercontent.com/u/61448739?v=4",
                      //   radius: 80.0,
                      // ),
                      child: CircleAvatar(
                        radius: 45.0,
                        backgroundColor: const Color(0xFFF7CF18),
                          child: Text(
                        getInitials(widget.borrower.name),
                        style: const TextStyle(color: Colors.white),
                      )),
                    ),
                    const SizedBox(height: 20.0),
                    Header(
                      title: widget.borrower.name,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: widget.borrower.phone));
                        customSnackbar(
                            message: "Copied to Clipboard", context: context);
                      },
                      child: Header(
                        title: widget.borrower.phone,
                        color: Colors.white,
                        fontSize: 16,
                      ),
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
                        height: MediaQuery.of(context).size.height * 0.90,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18.0, vertical: 10.0),
                          child: extraDetails(context),
                        ),
                      ),
                    ],
                  ),
                ),
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
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        color: Color(0xFFC78E07),
      ),
    );
  }

  Widget extraDetails(BuildContext context) {
    return Column(children: [
      ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              this.isExpanded = !this.isExpanded;
            });
          },
          children: [
            ExpansionPanel(
                canTapOnHeader: true,
                backgroundColor:
                    isExpanded ? Colors.white : const Color(0xFFE7B60B),
                isExpanded: isExpanded,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return const Center(
                    child: Header(
                      title: "Personal Details",
                    ),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      textField(
                        keyboardType: TextInputType.none,
                        label: "Aadhar Number",
                        hint: widget.borrower.aadharNumber,
                        disabled: true,
                        icon: Icons.copy,
                        onIconTap: () {
                          Clipboard.setData(ClipboardData(
                              text: widget.borrower.aadharNumber));
                          customSnackbar(
                              message: "Aadhar Copied", context: context);
                        },
                      ),
                      textField(
                        keyboardType: TextInputType.none,
                        label: "Address",
                        hint: widget.borrower.address,
                        disabled: true,
                        icon: Icons.location_on_outlined,
                        onIconTap: () {
                          Clipboard.setData(
                              ClipboardData(text: widget.borrower.address));
                          customSnackbar(
                              message: "Address copied", context: context);
                        },
                      ),
                    ],
                  ),
                ))
          ]),

      // const SizedBox(height: 30.0),
      // const Header(title: "Loans", fontSize: 20.0),
      // Header(title: "Loans (Total Interest: ₹${totalInterest.toStringAsFixed(2)})", fontSize: 20.0),

      Expanded(
        child: _loans(context),
      ),
      // for (int i = 0; i < 10; i++) loanCard(context),
    ]);
  }

  _loans(BuildContext context) {
    // return StreamBuilder<QuerySnapshot>(
    //   stream: stream,
    //   builder: (context, snapshot) {
    //     if (snapshot.hasError) {
    //       return const Center(child: Text("Something went wrong"));
    //     }
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(child: CircularProgressIndicator());
    //     }
    //     // if (snapshot.data!.docs.isEmpty) {
    //     //   return const Center(child: Text("No Data Found"));
    //     // }


    //     List<DocumentSnapshot> docs = snapshot.data!.docs;

  
    //     // Calculate total interest
    //     double total = 0.0;
    //     for (var doc in docs) {
    //       LoanModel loan =
    //           LoanModel.fromJson(doc.data() as Map<String, dynamic>);
    //       total += loan.amount * loan.interestRate / 100;
    //     }

    //     // Update state
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       setState(() {
    //         totalInterest = total;
    //       });
    //     });



    //     return ListView.builder(
    //       shrinkWrap: true,
    //       // physics: const BouncingScrollPhysics(),
    //       itemCount: snapshot.data!.docs.length + 1,
    //       itemBuilder: (context, index) {
    //         if (index == snapshot.data!.docs.length) {
    //           return _addNewLoan(context);
    //         } else {
    //           LoanModel loan = LoanModel.fromJson(
    //               snapshot.data!.docs[index].data() as Map<String, dynamic>);

    //           return loanCard(context, loan);
    //         }
    //       },
    //     );
    //   },
    // );

    return StreamBuilder<QuerySnapshot>(
  stream: stream,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(child: Text("No Data Found"));
    }

    List<DocumentSnapshot> docs = snapshot.data!.docs;

    // Calculate total interest locally
    double totalInterest = 0.0;
    double totalAmount = 0.0;
    final loans = docs.map((doc) {
      final loan = LoanModel.fromJson(doc.data() as Map<String, dynamic>);
      // if loan is active add to totalInterest
      if (loan.isActive) {
        totalInterest += loan.amount * loan.interestRate / 100;
        totalAmount += loan.amount;
      }


      // totalInterest += loan.amount * loan.interestRate / 100;
      return loan;
    }).toList();

    // Now display the totalInterest inside the UI
    // return Column(
    //   children: [
    //     Padding(
    //       padding: const EdgeInsets.all(8.0),
    //       child: Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
    //           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    //     ),
    //     Padding(
    //       padding: const EdgeInsets.all(8.0),
    //       child: Text('Total Interest: ₹${totalInterest.toStringAsFixed(2)}',
    //           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    //     ),
    //     Expanded(
    //       child: ListView.builder(
    //         itemCount: loans.length,
    //         itemBuilder: (context, index) => loanCard(context, loans[index]),
    //       ),
    //     ),
    //   ],
    // );
    return Column(
  children: [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Total Interest: ₹${totalInterest.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
    Expanded(
      child: ListView.builder(
        itemCount: loans.length + 1, // +1 for the add button
        itemBuilder: (context, index) {
          if (index == loans.length) {
            return _addNewLoan(context); // Add new loan at the end
          } else {
            return loanCard(context, loans[index]);
          }
        },
      ),
    ),
  ],
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
        // padding: const EdgeInsets.all(15.0),
        width: double.infinity,
        height: 200,
        child: CustomCard(
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
                            title: "Interest rate",
                            fontSize: 15.0,
                            color: Colors.white),
                        Header(
                            title: loan.id,
                            fontSize: 15.0,
                            color: Colors.white),
                        Header(
                            title: "${loan.interestRate}%",
                            fontSize: 14.0,
                            color: Colors.white),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            loan.isActive ? Icons.check_circle : Icons.close,
                            color: loan.isActive ? Colors.green : Colors.black,
                          ),
                          Header(
                              title: loan.isActive ? "Active" : "Done",
                              fontSize: 14.0,
                              color:
                                  loan.isActive ? Colors.green : Colors.black),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                      borrowerId: widget.borrower.id,
                      borrowerName: widget.borrower.name,
                    )));
      },
      child: Container(
        margin: const EdgeInsets.all(15.0),
        // padding: const EdgeInsets.all(15.0),
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
              Color(0xFFC78E07),
              Color(0xFFE7B60B),
            ],
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: -80,
              right: 20,
              child: ClipRect(
                child: Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(80.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF7CF18).withOpacity(0.37),
                        const Color(0xFFE7B60B).withOpacity(0.37)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -80,
              left: -10,
              child: ClipRect(
                child: Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(80.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF7CF18).withOpacity(0.67),
                        const Color(0xFFE7B60B).withOpacity(0.67)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
              ),
            ),
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 50.0,
                  ),
                  SizedBox(height: 10.0),
                  Header(
                      title: "Add New Loan",
                      fontSize: 15.0,
                      color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
