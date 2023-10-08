import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loan_app/models/borrower.dart';
import 'package:loan_app/models/loan.dart';
import 'package:loan_app/models/notification.dart';
import 'package:loan_app/models/transaction.dart';
import 'package:loan_app/models/user.dart';
import 'package:loan_app/services/auth_service.dart';
import 'package:loan_app/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreService {
  final NotificationService _notificationService = NotificationService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _userCollection = 'users';
  final String _losnCollection = 'loans';
  final String _borrowerCollection = 'borrowers';
  final String _transactionCollection = 'transactions';
  final String _notificationCollection = 'notifications';
  UploadTask? uploadTask;

  // get current user data
  Stream<QuerySnapshot> getCurrentUser(String uid) {
    try {
      print('uid: $uid');
      return _db
          .collection(_userCollection)
          .where('id', isEqualTo: uid)
          .snapshots();
    } catch (e) {
      print(e);
      return const Stream.empty();
    }
  }

  // check if current user has MPIN
  Future<bool> hasMPIN() async {
    try {
      String uid = AuthService().user.uid;
      QuerySnapshot snapshot = await _db
          .collection(_userCollection)
          .where('id', isEqualTo: uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs[0].get('mpin') != 0;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // get loans data
  Stream<QuerySnapshot> getLoans(String borrowerId) {
    try {
      return _db
          .collection(_losnCollection)
          .where('borrowerId', isEqualTo: borrowerId)
          .where('lenderId', isEqualTo: AuthService().user.uid)
          .snapshots();
    } catch (e) {
      print(e);
      return const Stream.empty();
    }
  }

  Stream<QuerySnapshot> getLoan(String borrowerId, String loanId) {
    try {
      return _db
          .collection(_losnCollection)
          .where('borrowerId', isEqualTo: borrowerId)
          .where('id', isEqualTo: loanId)
          .snapshots();
    } catch (e) {
      print(e);
      return const Stream.empty();
    }
  }

  Future addUser(UserModel data) async {
    try {
      await _db.collection(_userCollection).doc(data.id).set(data.toJson());
    } catch (e) {
      print(e);
    }
  }

  Future<String> addLoan(LoanModel data) async {
    try {
      DocumentReference loanRef =
          await _db.collection(_losnCollection).add(data.toJson());
      String loanId = loanRef.id;
      await loanRef.update({'id': loanId});

      // create notification
      NotificationModel notification = NotificationModel(
        id: '',
        loanId: loanId,
        borrowerId: data.borrowerId,
        lenderId: data.lenderId,
        date: data.date,
        notificationId: -1,
      );

      createLocalNotification(notification, data);
      return 'success';
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  void updateActiveOfLoan(String id, {required bool isActive}) {
    try {
      _db.collection(_losnCollection).doc(id).update({'isActive': isActive});
    } catch (e) {
      print(e);
    }
  }

  // get borrower data
  Stream<QuerySnapshot> getBorrower(String borrowerId) {
    try {
      return _db
          .collection(_borrowerCollection)
          .where('id', isEqualTo: borrowerId)
          .snapshots();
    } catch (e) {
      print(e);
      return const Stream.empty();
    }
  }

  Future<String> addBorrower(BorrowerModel data) async {
    try {
      DocumentReference borrowerRef =
          await _db.collection(_borrowerCollection).add(data.toJson());
      String borrowerId = borrowerRef.id;
      await borrowerRef.update({'id': borrowerId});
      return 'success';
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  Future<String> updateBorrower(BorrowerModel borrowerModel) async {
    try {
      // Get the borrower's document reference by ID
      DocumentReference borrowerRef =
          _db.collection(_borrowerCollection).doc(borrowerModel.id);

      // Update the borrower's data
      await borrowerRef.update(borrowerModel.toJson());

      return 'success';
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  Future<BorrowerModel?> getBorrowerById(String borrowerId) async {
    try {
      final DocumentSnapshot borrowerDoc =
          await _db.collection(_borrowerCollection).doc(borrowerId).get();
      if (borrowerDoc.exists) {
        return BorrowerModel.fromJson(
            borrowerDoc.data() as Map<String, dynamic>);
      }
      return null; // Return null if borrower not found
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<QuerySnapshot> getBorrowers(String lenderId, {int? limit}) {
    try {
      // make it descending order bu date
      Query query = _db
          .collection(_borrowerCollection)
          .where('lenderId', isEqualTo: lenderId)
          .orderBy('date', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }
      return query.snapshots();
    } catch (e) {
      print(e);
      return const Stream.empty();
    }
  }

  // add transaction
  Future<String> addTransaction(List<TransactionModel> data) async {
    try {
      for (var i = 0; i < data.length; i++) {
        DocumentReference transactionRef =
            await _db.collection(_transactionCollection).add(data[i].toJson());
        String transactionId = transactionRef.id;
        await transactionRef.update({'id': transactionId});
      }
      return 'success';
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  // get transaction data
  Stream<QuerySnapshot> getTransactions(String loanId, String borrowerId) {
    try {
      return _db
          .collection(_transactionCollection)
          .where('loanId', isEqualTo: loanId)
          .where('borrowerId', isEqualTo: borrowerId)
          .where('lenderId', isEqualTo: AuthService().user.uid)
          .orderBy('createdDate', descending: true)
          .snapshots();
    } catch (e) {
      print(e);
      return const Stream.empty();
    }
  }

  // getTransactionsfuture
  Future<QuerySnapshot> getTransactionsFuture(
      String loanId, String borrowerId) async {
    try {
      return await _db
          .collection(_transactionCollection)
          .where('loanId', isEqualTo: loanId)
          .where('borrowerId', isEqualTo: borrowerId)
          .where('lenderId', isEqualTo: AuthService().user.uid)
          .get();
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }

  Stream<QuerySnapshot<Object?>> getAllTransactions({int? limit}) {
    // get only last 10 transactions
    try {
      Query query = _db
          .collection(_transactionCollection)
          .where('lenderId', isEqualTo: AuthService().user.uid)
          .orderBy('createdDate', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }
      return query.snapshots();
    } catch (e) {
      print(e);
      return const Stream.empty();
    }
  }

  Future<QuerySnapshot<Object?>> getBorrowerDetailsById(
      String borrowerId) async {
    try {
      return await _db
          .collection(_borrowerCollection)
          .where('id', isEqualTo: borrowerId)
          .get();
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }

  Future<String> fetchMPINFromFirestoreAndMatch(int mpin) async {
    // if mpin null, return 'Enter MPIN' if mpin does not match return 'Invalid MPIN' else return 'MPIN verified!'
    try {
      String uid = AuthService().user.uid;
      QuerySnapshot snapshot = await _db
          .collection(_userCollection)
          .where('id', isEqualTo: uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        if (snapshot.docs[0].get('mpin') != null) {
          if (snapshot.docs[0].get('mpin') == mpin) {
            return 'MPIN verified!';
          } else {
            return 'Invalid MPIN';
          }
        } else {
          return 'Enter MPIN';
        }
      }
      return 'Enter MPIN';
    } catch (e) {
      print(e);
      return 'Enter MPIN';
    }
  }

  void updateMPIN({required int mpin, required BuildContext context}) {
    try {
      String uid = AuthService().user.uid;
      _db.collection(_userCollection).doc(uid).update({'mpin': mpin});
    } catch (e) {
      print(e);
    }
  }

  uploadImageToFirebase(XFile pickedFile, String lenderId, String borrowwerId,
      String collateralDescription) async {
    try {
      final path =
          'images/collateral/$lenderId/$borrowwerId/$collateralDescription';
      final File file = File(pickedFile.path);
      final ref = FirebaseStorage.instance.ref().child(path);
      uploadTask = ref.putFile(file);

      final snapshot = await uploadTask!.whenComplete(() => {});

      final downloadUrl = await snapshot.ref.getDownloadURL();
      print("downloadUrl$downloadUrl");
      return downloadUrl;
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  // delete image from firebase storage from image link
  Future<void> deleteImageFromFirebase(String imageUrl) async {
    try {
      // Parse the download URL to a reference
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);

      // Delete the file
      await ref.delete();

      print("Image deleted successfully");
    } catch (e) {
      print("Error deleting image: $e");
      throw e;
    }
  }

  // count the notification for this lender
  Future<int> countNotification() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(_notificationCollection)
          .where('lenderId', isEqualTo: AuthService().user.uid)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  // add notification
  Future<void> addNotification(
      NotificationModel notificationModel, LoanModel data) async {
    try {
      DocumentReference notificationRef = await _db
          .collection(_notificationCollection)
          .add(notificationModel.toJson());
      String id = notificationRef.id;
      await notificationRef.update({'id': id});
    } catch (e) {
      print(e);
    }
  }

  // create local notification
  createLocalNotification(
      NotificationModel notificationModel, LoanModel data) async {
    // get lender name
    BorrowerModel? lenderName = await getBorrowerById(data.borrowerId);

    // calculate intrest
    double intrest = (data.amount * data.interestRate) / 100;

    try {
      _notificationService.scheduleMonthlyRepeatingNotification(
        title: "Loan Reminder",
        body: "Borrower: ${lenderName!.name} has amount due of $intrest today",
        initialScheduledDate: DateTime.now(),
        notificationModel: notificationModel,
        data: data,
      );
    } catch (e) {
      print(e);
    }
  }

  // delete loan
  Future<void> deleteLoan(String id) async {
    try {
      await _db.collection(_losnCollection).doc(id).delete();
    } catch (e) {
      print(e);
    }
  }

  // Future<String> uploadImage(XFile image, String lenderId, String loanId, String colateral) async {
  //   try {
  //       final ref =
  //   } catch (e) {
  //     print(e);
  //     return e.toString();
  //   }
  // }

//   Future<void> setData(String path, Map<String, dynamic> data) async {
//     final DocumentReference ref = _db.doc(path);
//     await ref.set(data);
//   }

//   Future<void> deleteData(String path) async {
//     final DocumentReference ref = _db.doc(path);
//     await ref.delete();
//   }

//   Future<DocumentSnapshot> getData(String path) async {
//     final DocumentReference ref = _db.doc(path);
//     return await ref.get();
//   }

//   Future<QuerySnapshot> getCollection(String path) async {
//     final CollectionReference ref = _db.collection(path);
//     return await ref.get();
//   }

//   Stream<QuerySnapshot> streamCollection(String path) {
//     final CollectionReference ref = _db.collection(path);
//     return ref.snapshots();
//   }

//   Stream<DocumentSnapshot> streamData(String path) {
//     final DocumentReference ref = _db.doc(path);
//     return ref.snapshots();
//   }
}
