import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loan_app/models/borrower.dart';
import 'package:loan_app/models/loan.dart';
import 'package:loan_app/models/transaction.dart';
import 'package:loan_app/models/user.dart';
import 'package:loan_app/services/auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _userCollection = 'users';
  final String _losnCollection = 'loans';
  final String _borrowerCollection = 'borrowers';
  final String _transactionCollection = 'transactions';

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
      return Stream.empty();
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
      return Stream.empty();
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
      return Stream.empty();
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
      return 'success';
    } catch (e) {
      print(e);
      return e.toString();
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
      return Stream.empty();
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

  Stream<QuerySnapshot> getBorrowers(String lenderId) {
    try {
      return _db
          .collection(_borrowerCollection)
          .where('lenderId', isEqualTo: lenderId)
          .snapshots();
    } catch (e) {
      print(e);
      return Stream.empty();
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
