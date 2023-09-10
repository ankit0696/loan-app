// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:loan_app/models/loan.dart';
// import 'package:loan_app/services/auth_service.dart';
// import 'package:loan_app/services/firestore_service.dart';
// import 'package:loan_app/ui/widgets/custom_back_button.dart';
// import 'package:loan_app/ui/widgets/custom_button.dart';
// import 'package:loan_app/ui/widgets/custom_snackbar.dart';
// import 'package:loan_app/ui/widgets/header.dart';
// import 'package:loan_app/ui/widgets/textfield.dart';

// class LoanForm extends StatefulWidget {
//   final String borrowerId;
//   final String borrowerName;

//   const LoanForm(
//       {Key? key, required this.borrowerId, required this.borrowerName})
//       : super(key: key);

//   @override
//   State<LoanForm> createState() => _LoanFormState();
// }

// class _LoanFormState extends State<LoanForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _amountController = TextEditingController();
//   final _interestRateController = TextEditingController();
//   final _dateController = TextEditingController();
//   final _collateralController = TextEditingController();
//   final bool _isActive = true;

//   String lenderId = '';

//   @override
//   void initState() {
//     super.initState();
//     _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     getLenderId();
//   }

//   getLenderId() async {
//     lenderId = await AuthService().user!.uid;
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _interestRateController.dispose();
//     _dateController.dispose();
//     _collateralController.dispose();
//     super.dispose();
//   }

//   Future<void> _submitForm() async {
//     try {
//       if (_formKey.currentState!.validate()) {
//         // Extract form values and create new loan
//         final double amount = double.parse(_amountController.text);
//         final double interestRate = double.parse(_interestRateController.text);
//         final DateTime date = DateTime.parse(_dateController.text);
//         final String collateral = _collateralController.text;
//         final LoanModel newLoan = LoanModel(
//           id: '',
//           amount: amount,
//           interestRate: interestRate,
//           date: date,
//           borrowerId: widget.borrowerId,
//           lenderId: lenderId,
//           collateral: collateral,
//           isActive: _isActive,
//         );

//         _saveData(newLoan);
//       } else {
//         customSnackbar(message: 'Please fill all the fields', context: context);
//       }
//     } catch (e) {
//       customSnackbar(message: e.toString(), context: context);
//     }
//   }

//   _saveData(LoanModel newLoan) {
//     FirestoreService().addLoan(newLoan).then((value) {
//       if (value != 'success') {
//         customSnackbar(message: value, context: context);
//       }
//       if (value == 'success') {
//         customSnackbar(message: 'Loan added successfully', context: context);
//       }
//     }).catchError((e) {
//       customSnackbar(message: e.toString(), context: context);
//     });
//     // Navigate back to borrower detail page
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sizeHeight = MediaQuery.of(context).size.height * 0.15;

//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF7CF18),
//         body: SingleChildScrollView(
//           child: Center(
//             child: Stack(
//               alignment: Alignment.topCenter,
//               children: [
//                 background(context, sizeHeight),
//                 Padding(
//                   padding: EdgeInsets.only(top: sizeHeight),
//                   child: const Row(
//                     children: [
//                       CustomBackButton(),
//                       Header(
//                           title: "New Loan", fontSize: 20, color: Colors.white),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   children: [
//                     Column(
//                       children: [
//                         Container(
//                           margin: EdgeInsets.only(top: sizeHeight / 2),
//                           child: const SizedBox(
//                             height: 100,
//                             width: 100,
//                           ),
//                         ),
//                         const SizedBox(height: 20.0),
//                       ],
//                     ),
//                     Container(
//                       height: MediaQuery.of(context).size.height * 0.7,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20.0, vertical: 20.0),
//                       margin: const EdgeInsets.only(top: 30.0),
//                       decoration: const BoxDecoration(
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(30.0),
//                           topRight: Radius.circular(30.0),
//                         ),
//                         color: Colors.white,
//                       ),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 Header(
//                                     title: "Borrower: ${widget.borrowerName}",
//                                     fontSize: 20,
//                                     color: const Color(0xFF505050)),
//                               ],
//                             ),
//                             textField(
//                               icon: Icons.attach_money,
//                               controller: _amountController,
//                               keyboardType: TextInputType.number,
//                               hint: 'Enter amount',
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter an amount';
//                                 }
//                                 final amount = double.tryParse(value);
//                                 if (amount == null) {
//                                   return 'Please enter a valid amount';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             textField(
//                               icon: Icons.percent,
//                               controller: _interestRateController,
//                               keyboardType: TextInputType.number,
//                               hint: 'Enter interest rate',
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter an interest rate';
//                                 }
//                                 final interestRate = double.tryParse(value);
//                                 if (interestRate == null) {
//                                   return 'Please enter a valid interest rate';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             textField(
//                               icon: Icons.calendar_today,
//                               controller: _dateController,
//                               keyboardType: TextInputType.datetime,
//                               hint: 'Date',
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter a date';
//                                 }
//                                 final date = DateTime.tryParse(value);
//                                 if (date == null) {
//                                   return 'Please enter a valid date';
//                                 }
//                                 return null;
//                               },
//                               onTap: () async {
//                                 final date = await showDatePicker(
//                                   context: context,
//                                   initialDate: DateTime.now(),
//                                   firstDate: DateTime(1900),
//                                   lastDate: DateTime.now(),
//                                 );
//                                 if (date != null) {
//                                   _dateController.text =
//                                       DateFormat('yyyy-MM-dd').format(date);
//                                 }
//                               },
//                             ),
//                             textField(
//                               icon: Icons.description,
//                               controller: _collateralController,
//                               hint: 'Collateral',
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter a collateral';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 32),
//                             // Container(
//                             //   padding:
//                             //       const EdgeInsets.symmetric(horizontal: 16),
//                             //   width: double.infinity,
//                             //   child: ElevatedButton(
//                             //     onPressed: () {
//                             //       _submitForm();
//                             //     },
//                             //     child: _loading
//                             //         ? const CircularProgressIndicator()
//                             //         : const Text('Save'),
//                             //   ),
//                             // ),
//                             CustomButton(
//                                 onPressed: _submitForm, buttonText: "Save")
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Container background(BuildContext context, double sizeHeight) {
//     return Container(
//       margin: EdgeInsets.only(
//         top: sizeHeight,
//       ),
//       height: MediaQuery.of(context).size.height * 0.7,
//       decoration: const BoxDecoration(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(30.0),
//           topRight: Radius.circular(30.0),
//         ),
//         color: Color(0xFFC78E07),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/models/loan.dart';
import 'package:loan_app/services/auth_service.dart';
import 'package:loan_app/services/firestore_service.dart';
import 'package:loan_app/ui/widgets/custom_back_button.dart';
import 'package:loan_app/ui/widgets/custom_button.dart';
import 'package:loan_app/ui/widgets/custom_snackbar.dart';
import 'package:loan_app/ui/widgets/header.dart';
import 'package:loan_app/ui/widgets/show_image_details.dart';
import 'package:loan_app/ui/widgets/textfield.dart';
import 'package:image_picker/image_picker.dart'; // Import the image_picker package

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

  bool _backgroundWorking = false;

  String lenderId = '';
  List<Collateral> collaterals = [];

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

  // Future<void> _addColatoral() async {
  //   try {
  //     final String collateralDescription = _collateralController.text;

  //     if (collateralDescription.isNotEmpty) {
  //       final Collateral newCollateral = Collateral(
  //         description: collateralDescription,
  //         // You can handle the image upload here.
  //         // For simplicity, I'm not including image upload code.
  //         // You can use a package like image_picker to allow users to pick images.
  //         // You would then store the image URL in the Collateral object.
  //         imageUrl: '',
  //       );

  //       setState(() {
  //         collaterals.add(newCollateral);
  //         _collateralController.clear();
  //       });

  //       _formKey.currentState!.reset();
  //     } else {
  //       customSnackbar(
  //         message: 'Please enter a collateral',
  //         context: context,
  //         color: Colors.red,
  //       );
  //     }
  //   } catch (e) {
  //     customSnackbar(message: e.toString(), context: context);
  //   }
  // }

  // Future<void> _addCollateral() async {
  //   final ImagePicker _picker = ImagePicker();
  //   try {
  //     final String collateralDescription = _collateralController.text;

  //     if (collateralDescription.isNotEmpty) {
  //       final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

  //       if (pickedFile != null) {
  //         // final imageUrl = await _uploadImageToFirebase(pickedFile.path);

  //         final newCollateral = Collateral(
  //           description: collateralDescription,
  //           imageUrl: "imageUrl",
  //         );

  //         setState(() {
  //           collaterals.add(newCollateral);
  //           _collateralController.clear();
  //         });

  //         _formKey.currentState!.reset();
  //       } else {
  //         customSnackbar(
  //           message: 'Please select an image',
  //           context: context,
  //           color: Colors.red,
  //         );
  //       }
  //     } else {
  //       customSnackbar(
  //         message: 'Please enter a collateral',
  //         context: context,
  //         color: Colors.red,
  //       );
  //     }
  //   } catch (e) {
  //     customSnackbar(message: e.toString(), context: context);
  //   }
  // }

  Future<void> _addCollateral() async {
    _backgroundWorking = true;
    final ImagePicker picker = ImagePicker();
    try {
      final String collateralDescription = _collateralController.text;

      if (collateralDescription.isNotEmpty) {
        final pickedFile = await showDialog<XFile?>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Choose Image Source"),
              actions: <Widget>[
                TextButton(
                  child: const Text("Camera"),
                  onPressed: () async {
                    Navigator.of(context).pop(
                        await picker.pickImage(source: ImageSource.camera));
                  },
                ),
                TextButton(
                  child: const Text("Gallery"),
                  onPressed: () async {
                    Navigator.of(context).pop(
                        await picker.pickImage(source: ImageSource.gallery));
                  },
                ),
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                ),
              ],
            );
          },
        );

        if (pickedFile != null) {
          final imageUrl = await FirestoreService().uploadImageToFirebase(
              pickedFile, lenderId, widget.borrowerId, collateralDescription);

          final newCollateral = Collateral(
            description: collateralDescription,
            imageUrl: imageUrl,
          );

          setState(() {
            collaterals.add(newCollateral);
            _collateralController.clear();
          });
          _collateralController.clear();
          _backgroundWorking = false;
          _formKey.currentState!.reset();
        } else {
          final newCollateral = Collateral(
            description: collateralDescription,
            imageUrl: "",
          );
          _backgroundWorking = false;
          setState(() {
            collaterals.add(newCollateral);
            _collateralController.clear();
          });
          _collateralController.clear();

          _formKey.currentState!.reset();
        }
      } else {
        customSnackbar(
          message: 'Please enter a collateral',
          context: context,
          color: Colors.red,
        );
        _backgroundWorking = false;
      }
    } catch (e) {
      customSnackbar(message: e.toString(), context: context);
      _backgroundWorking = false;
    }
  }

  // Future<String> _uploadImageToFirebase(String filePath) async {
  //   final fileName = DateTime.now().millisecondsSinceEpoch.toString();
  //   final ref = firebase_storage.FirebaseStorage.instance.ref().child(fileName);
  //   final uploadTask = ref.putFile(File(filePath));

  //   await uploadTask.whenComplete(() {});

  //   return await ref.getDownloadURL();
  // }

  _saveData() {
    if (_backgroundWorking) {
      customSnackbar(
          message: "Background working", context: context, color: Colors.red);
      return;
    }
    try {
      // Extract form values and create new loan
      final double amount = double.parse(_amountController.text);
      final double interestRate = double.parse(_interestRateController.text);
      final DateTime date = DateTime.parse(_dateController.text);

      final LoanModel newLoan = LoanModel(
        id: '', // You can set this to an empty string for a new loan
        amount: amount,
        interestRate: interestRate,
        date: date,
        borrowerId: widget.borrowerId,
        lenderId: lenderId,
        collaterals: collaterals,
        isActive: _isActive,
      );

      _saveLoanData(newLoan);
    } catch (e) {
      customSnackbar(message: e.toString(), context: context);
    }
  }

  _saveLoanData(LoanModel newLoan) {
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
                  child: const Row(
                    children: [
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
                      height: MediaQuery.of(context).size.height * 0.7,
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
                      child: SingleChildScrollView(
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
                              // Display added collaterals
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: collaterals.map((collateral) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical:
                                            8.0), // Adjust margin as needed
                                    padding: const EdgeInsets.all(
                                        8.0), // Adjust padding as needed
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey, // Set border color
                                        width: 1.0, // Set border width
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          8.0), // Set border radius
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
                                      
                                      onTap: (() {
                                        showImageDialog(
                                            context,
                                            collateral.description,
                                            collateral.imageUrl);
                                      }),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 32),
                              CustomButton(
                                onPressed: _addCollateral,
                                buttonText: "Add Collateral",
                              ),
                              const SizedBox(height: 32),
                              CustomButton(
                                onPressed: _saveData,
                                buttonText: "Save Loan",
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
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
