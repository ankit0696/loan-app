import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:loan_app/models/borrower.dart';
import 'package:loan_app/services/auth_service.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/widgets/custom_back_button.dart';
import 'package:loan_app/ui/widgets/custom_button.dart';
import 'package:loan_app/ui/widgets/custom_snackbar.dart';
import 'package:loan_app/ui/widgets/header.dart';
import 'package:loan_app/ui/widgets/textfield.dart';

class BorrowForm extends StatefulWidget {
  final String? id;
  const BorrowForm({super.key, this.id});

  @override
  State<BorrowForm> createState() => _BorrowFormState();
}

class _BorrowFormState extends State<BorrowForm> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aadharNumberController = TextEditingController();

  String lenderId = '';
  String borrowerId = '';

  @override
  void initState() {
    super.initState();
    lenderId = AuthService().user.uid;
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (widget.id != null) {
      borrowerId = widget.id!;
      populateData(borrowerId);
    }
  }

  populateData(String borrowerId) async {
    final borrower = await FirestoreService().getBorrowerById(borrowerId);
    if (borrower != null) {
      setState(() {
        // Populate the form fields with data
        _nameController.text = borrower.name;
        _phoneController.text = borrower.phone;
        _addressController.text = borrower.address;
        _aadharNumberController.text = borrower.aadharNumber;
        // You can populate other fields similarly if needed
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _aadharNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    _loading = true;
    try {
      if (_formKey.currentState!.validate()) {
        final BorrowerModel borrowerModel = BorrowerModel(
          id: borrowerId, // Use the existing borrower's ID if editing
          name: _nameController.text,
          phone: _phoneController.text,
          date: DateTime.now(),
          address: _addressController.text,
          aadharNumber: _aadharNumberController.text,
          lenderId: lenderId,
        );

        if (widget.id != null) {
          // Editing an existing borrower
          _updateBorrower(borrowerModel);
        } else {
          // Adding a new borrower
          _addBorrower(borrowerModel);
        }
      } else {
        _loading = false;
      }
    } catch (e) {
      customSnackbar(
        context: context,
        message: e.toString(),
      );
    }
  }

  _updateBorrower(BorrowerModel borrowerModel) {
    FirestoreService().updateBorrower(borrowerModel).then((value) {
      if (value == 'success') {
        _loading = false;
        customSnackbar(
            context: context, message: 'Borrower updated successfully');
      } else {
        _loading = false;
        customSnackbar(context: context, message: value);
      }
    }).catchError((e) {
      _loading = false;
      customSnackbar(context: context, message: e.toString());
    });
    Navigator.pop(context);
  }

  _addBorrower(BorrowerModel borrowerModel) {
    FirestoreService().addBorrower(borrowerModel).then((value) {
      if (value == 'success') {
        _loading = false;
        customSnackbar(
            context: context, message: 'Borrower added successfully');
      } else {
        _loading = false;
        customSnackbar(context: context, message: value);
      }
    }).catchError((e) {
      _loading = false;
      customSnackbar(context: context, message: e.toString());
    });
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
                      child: const Row(
                        children: [
                          CustomBackButton(),
                          Header(
                            title: "Borrower Form",
                            fontSize: 20,
                            color: Colors.white,
                          ),
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
                          height: MediaQuery.of(context).size.height * 0.75,
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
                                textField(
                                  controller: _nameController,
                                  hint: 'Enter your name',
                                  icon: Icons.person,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                textField(
                                  controller: _phoneController,
                                  hint: 'Enter your phone number',
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    if (value.length != 10) {
                                      return 'Please enter a valid phone number';
                                    }
                                    return null;
                                  },
                                ),
                                // textField(
                                //   controller: _dateController,
                                //   hint: 'Enter your date of birth',
                                //   icon: Icons.calendar_today,
                                //   keyboardType: TextInputType.datetime,
                                //   validator: (value) {
                                //     if (value == null || value.isEmpty) {
                                //       return 'Please enter a date';
                                //     }
                                //     final date = DateTime.tryParse(value);
                                //     if (date == null) {
                                //       return 'Please enter a valid date';
                                //     }
                                //     return null;
                                //   },
                                //   onTap: () async {
                                //     final date = await showDatePicker(
                                //       context: context,
                                //       initialDate: DateTime.now(),
                                //       firstDate: DateTime(1900),
                                //       lastDate: DateTime.now(),
                                //     );
                                //     if (date != null) {
                                //       _dateController.text =
                                //           DateFormat('yyyy-MM-dd').format(date);
                                //     }
                                //   },
                                // ),
                                textField(
                                  controller: _addressController,
                                  hint: 'Enter your address',
                                  icon: Icons.location_on,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your address';
                                    }
                                    return null;
                                  },
                                ),
                                textField(
                                  controller: _aadharNumberController,
                                  hint: 'Enter your aadhar number',
                                  icon: Icons.credit_card,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your aadhar number';
                                    }
                                    if (value.length != 12) {
                                      return 'Please enter a valid aadhar number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20.0),
                                // Container(
                                //   height: 50.0,
                                //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                //   width: double.infinity,
                                //   child: ElevatedButton(
                                //     onPressed: () {
                                //       _handleSubmit();
                                //     },
                                //     child: _loading
                                //         ? const CircularProgressIndicator()
                                //         : const Text('Submit'),
                                //   ),
                                // ),
                                const Spacer(),
                                _loading
                                    ? const CircularProgressIndicator()
                                    : CustomButton(
                                        onPressed: _handleSubmit,
                                        buttonText: "Submit",
                                      ),

                                const SizedBox(height: 20.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )));
  }

  Container background(BuildContext context, double sizeHeight) {
    return Container(
      margin: EdgeInsets.only(
        top: sizeHeight,
      ),
      height: MediaQuery.of(context).size.height * 0.7,
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
