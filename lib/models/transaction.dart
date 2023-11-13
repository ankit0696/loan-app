class TransactionModel {
  final String id;
  final double amount;
  final DateTime date;
  final DateTime createdDate;
  final DateTime dueDate;
  final String borrowerId;
  final String loanId;
  final String lenderId;
  final String? description;
  final String transactionType;
  final String rawAmount;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.createdDate,
    required this.dueDate,
    required this.borrowerId,
    required this.loanId,
    required this.lenderId,
    required this.description,
    required this.transactionType,
    required this.rawAmount,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      createdDate: DateTime.parse(json['createdDate']),
      dueDate: DateTime.parse(json['dueDate']),
      borrowerId: json['borrowerId'],
      loanId: json['loanId'],
      lenderId: json['lenderId'],
      description: json['description'],
      transactionType: json['transactionType'],
      rawAmount: json['rawAmount'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'borrowerId': borrowerId,
      'loanId': loanId,
      'lenderId': lenderId,
      'description': description,
      'transactionType': transactionType,
      'rawAmount': rawAmount,
    };
  }
}
