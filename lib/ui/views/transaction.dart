import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/models/loan.dart';
import 'package:loan_app/models/transaction.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/widgets/custom_snackbar.dart';
import 'package:loan_app/ui/widgets/textfield.dart';
import 'package:intl/intl.dart';

class TransactionForm extends StatelessWidget {
  final LoanModel loan;
  const TransactionForm({Key? key, required this.loan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bodyWidget(),
    );
  }

  Future<QuerySnapshot> get future => getTransactions();

  Future<QuerySnapshot> getTransactions() async {
    return await FirestoreService()
        .getTransactionsFuture(loan.id, loan.borrowerId);
  }

  Widget bodyWidget() {
    return Builder(builder: ((context) {
      return SafeArea(
          child: FutureBuilder<QuerySnapshot>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Transaction(loan: loan);
                }
                // calculate for last transaction with type intrest and return the last transaction with loan
                TransactionModel? lastTransaction =
                    _calculateLastTransaction(snapshot.data!.docs);
                return Transaction(
                    loan: loan, lastTransaction: lastTransaction);
              }));
    }));
  }

  TransactionModel? _calculateLastTransaction(
      List<QueryDocumentSnapshot<Object?>> docs) {
    TransactionModel? lastTransaction;
    for (var doc in docs) {
      TransactionModel transaction =
          TransactionModel.fromJson(doc.data() as Map<String, dynamic>);
      print('transaction ${transaction.amount}');
      if (transaction.transactionType == 'interest') {
        print('transaction iiiii ${transaction.amount}');
        if (lastTransaction == null) {
          lastTransaction = transaction;
        } else {
          if (transaction.dueDate.isAfter(lastTransaction.dueDate)) {
            lastTransaction = transaction;
          }
        }
      }
    }
    return lastTransaction;
  }
}

class Transaction extends StatefulWidget {
  final LoanModel loan;
  final TransactionModel? lastTransaction;
  const Transaction({Key? key, required this.loan, this.lastTransaction})
      : super(key: key);

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  late DateTime _dueDate;
  late String _transactionType;

  @override
  void initState() {
    super.initState();
    _transactionType = 'interest'; // set the default transaction type
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    print('last transaction ${widget.lastTransaction?.amount}');
    // _dueDate = widget.loan.date.month < 12
    //     ? DateTime(widget.loan.date.year, widget.loan.date.month + 1,
    //         widget.loan.date.day)
    //     : DateTime(widget.loan.date.year + 1, 1, widget.loan.date.day);

    // use the last transaction due date as the due date for the new transaction
    if (widget.lastTransaction != null) {
      _dueDate = widget.lastTransaction!.dueDate;
    } else {
      _dueDate = widget.loan.date.month < 12
          ? DateTime(widget.loan.date.year, widget.loan.date.month + 1,
              widget.loan.date.day)
          : DateTime(widget.loan.date.year + 1, 1, widget.loan.date.day);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      List<TransactionModel> transactions = _calculateTransaction();

      FirestoreService().addTransaction(transactions).then((value) {
        if (value == 'success') {
          customSnackbar(
              message: 'Transaction added successfully', context: context);
        } else {
          customSnackbar(message: 'Something went wrong', context: context);
        }
      }).catchError(
        (error) => customSnackbar(message: error.toString(), context: context),
      );

      Navigator.pop(context);
    } else {
      customSnackbar(
          message: 'Please fill all the required fields', context: context);
    }
  }

  List<TransactionModel> _calculateTransaction() {
    List<TransactionModel> transactions = [];
    double amount = double.parse(_amountController.text);
    double principal = widget.loan.amount;
    double interest = widget.loan.interestRate;
    double interestAmount = principal * (interest / 100);

    if (_transactionType == 'interest') {
      double amountLeft = amount;
      // if the last transaction interest is less than the interest amount then add the difference to the new transaction and then add the new transaction
      if (widget.lastTransaction != null &&
          widget.lastTransaction!.amount < interestAmount) {
        double difference = interestAmount - widget.lastTransaction!.amount;
        // check if the amountLeft is greater than the difference
        if (amountLeft > difference) {
          amountLeft -= difference;

          transactions.add(TransactionModel(
            id: '',
            amount: difference,
            date: DateTime.now(),
            createdDate: DateTime.now(),
            dueDate: _dueDate,
            borrowerId: widget.loan.borrowerId,
            loanId: widget.loan.id,
            lenderId: widget.loan.lenderId,
            description: _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
            transactionType: _transactionType,
          ));
          // increate due date by 1 month
          _dueDate = _dueDate.month < 12
              ? DateTime(_dueDate.year, _dueDate.month + 1, _dueDate.day)
              : DateTime(_dueDate.year + 1, 1, _dueDate.day);
        }
      }

      while (amountLeft > interestAmount) {
        amountLeft -= interestAmount;
        transactions.add(
          TransactionModel(
            id: '',
            amount: interestAmount,
            date: DateTime.now(),
            createdDate: DateTime.now(),
            dueDate: _dueDate,
            borrowerId: widget.loan.borrowerId,
            loanId: widget.loan.id,
            lenderId: widget.loan.lenderId,
            description: _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
            transactionType: _transactionType,
          ),
        );
        // increate due date by 1 month
        _dueDate = _dueDate.month < 12
            ? DateTime(_dueDate.year, _dueDate.month + 1, _dueDate.day)
            : DateTime(_dueDate.year + 1, 1, _dueDate.day);
      }
      transactions.add(TransactionModel(
        id: '',
        amount: amountLeft,
        date: DateTime.now(),
        createdDate: DateTime.now(),
        dueDate: _dueDate,
        borrowerId: widget.loan.borrowerId,
        loanId: widget.loan.id,
        lenderId: widget.loan.lenderId,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        transactionType: _transactionType,
      ));
    } else {
      transactions.add(TransactionModel(
        id: '',
        amount: amount,
        date: DateTime.now(),
        createdDate: DateTime.now(),
        dueDate: DateTime.now(),
        borrowerId: widget.loan.borrowerId,
        loanId: widget.loan.id,
        lenderId: widget.loan.lenderId,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        transactionType: _transactionType,
      ));
    }
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              textField(
                controller: _dateController,
                hint: 'Enter your date of birth',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  final date = DateTime.tryParse(value);
                  if (date == null) {
                    return 'Please enter a valid date';
                  }
                  return null;
                },
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _dateController.text =
                        DateFormat('yyyy-MM-dd').format(date);
                  }
                },
              ),
              DropdownButtonFormField<String>(
                value: _transactionType,
                onChanged: (newValue) {
                  setState(() {
                    _transactionType = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Transaction Type',
                ),
                items: <String>[
                  'interest',
                  'principal',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitForm,
        child: const Icon(Icons.check),
      ),
    );
  }
}


// Issue last month trasaction complete but not in case if i only take last transaction it will lbe always less from intrest and create issue

// eg: intrest 2000 1st payment 1000 2nd payment 1000 it will check last as 1000 and store it in that month 
//but next time when i chcek last transaction its 1000 whcih is less then 2000 and so it will again try to divide 
//the nest intrest to fulfill last one 

// month intrest complete in transaction model an idea!!