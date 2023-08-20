import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/models/loan.dart';
import 'package:loan_app/services/auth_service.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/widgets/custom_back_button.dart';
import 'package:loan_app/ui/widgets/custom_button.dart';
import 'package:loan_app/ui/widgets/custom_snackbar.dart';
import 'package:loan_app/ui/widgets/header.dart';
import 'package:loan_app/ui/widgets/textfield.dart';

class LoanForm extends StatefulWidget {
  final String borrowerId;
  final String borrowerName;

  const LoanForm(
      {Key? key, required this.borrowerId, required this.borrowerName})
      : super(key: key);

  @override
  State<LoanForm> createState() => _LoanFormState();
}

class _LoanFormState extends State<LoanForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _dateController = TextEditingController();
  final _collateralController = TextEditingController();
  final bool _isActive = true;

  String lenderId = '';

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    getLenderId();
  }

  getLenderId() async {
    lenderId = await AuthService().user!.uid;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _interestRateController.dispose();
    _dateController.dispose();
    _collateralController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    try {
      if (_formKey.currentState!.validate()) {
        // Extract form values and create new loan
        final double amount = double.parse(_amountController.text);
        final double interestRate = double.parse(_interestRateController.text);
        final DateTime date = DateTime.parse(_dateController.text);
        final String collateral = _collateralController.text;
        final LoanModel newLoan = LoanModel(
          id: '',
          amount: amount,
          interestRate: interestRate,
          date: date,
          borrowerId: widget.borrowerId,
          lenderId: lenderId,
          collateral: collateral,
          isActive: _isActive,
        );

        _saveData(newLoan);
      } else {
        customSnackbar(message: 'Please fill all the fields', context: context);
      }
    } catch (e) {
      customSnackbar(message: e.toString(), context: context);
    }
  }

  _saveData(LoanModel newLoan) {
    FirestoreService().addLoan(newLoan).then((value) {
      if (value != 'success') {
        customSnackbar(message: value, context: context);
      }
      if (value == 'success') {
        customSnackbar(message: 'Loan added successfully', context: context);
      }
    }).catchError((e) {
      customSnackbar(message: e.toString(), context: context);
    });
    // Navigate back to borrower detail page
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final sizeHeight = MediaQuery.of(context).size.height * 0.15;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7CF18),
        body: SingleChildScrollView(
          child: Center(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                background(context, sizeHeight),
                Padding(
                  padding: EdgeInsets.only(top: sizeHeight),
                  child: Row(
                    children: const [
                      CustomBackButton(),
                      Header(
                          title: "New Loan", fontSize: 20, color: Colors.white),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: sizeHeight / 2),
                          child: const SizedBox(
                            height: 100,
                            width: 100,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 20.0),
                      margin: const EdgeInsets.only(top: 30.0),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                        color: Colors.white,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Header(
                                    title: "Borrower: ${widget.borrowerName}",
                                    fontSize: 20,
                                    color: const Color(0xFF505050)),
                              ],
                            ),
                            textField(
                              icon: Icons.attach_money,
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              hint: 'Enter amount',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an amount';
                                }
                                final amount = double.tryParse(value);
                                if (amount == null) {
                                  return 'Please enter a valid amount';
                                }
                                return null;
                              },
                            ),
                            textField(
                              icon: Icons.percent,
                              controller: _interestRateController,
                              keyboardType: TextInputType.number,
                              hint: 'Enter interest rate',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an interest rate';
                                }
                                final interestRate = double.tryParse(value);
                                if (interestRate == null) {
                                  return 'Please enter a valid interest rate';
                                }
                                return null;
                              },
                            ),
                            textField(
                              icon: Icons.calendar_today,
                              controller: _dateController,
                              keyboardType: TextInputType.datetime,
                              hint: 'Date',
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
                            textField(
                              icon: Icons.description,
                              controller: _collateralController,
                              hint: 'Collateral',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a collateral';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),
                            // Container(
                            //   padding:
                            //       const EdgeInsets.symmetric(horizontal: 16),
                            //   width: double.infinity,
                            //   child: ElevatedButton(
                            //     onPressed: () {
                            //       _submitForm();
                            //     },
                            //     child: _loading
                            //         ? const CircularProgressIndicator()
                            //         : const Text('Save'),
                            //   ),
                            // ),
                            CustomButton(
                                onPressed: _submitForm, buttonText: "Save")
                          ],
                        ),
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

  Container background(BuildContext context, double sizeHeight) {
    return Container(
      margin: EdgeInsets.only(
        top: sizeHeight,
      ),
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        color: Color(0xFFC78E07),
      ),
    );
  }
}
