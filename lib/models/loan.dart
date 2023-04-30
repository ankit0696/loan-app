class LoanModel {
  final String id;
  final double amount;
  final double interestRate;
  final DateTime date;
  final String borrowerId;
  final String lenderId;
  final String collateral;
  final bool isActive;

  LoanModel({
    required this.id,
    required this.amount,
    required this.interestRate,
    required this.date,
    required this.borrowerId,
    required this.lenderId,
    required this.collateral,
    required this.isActive,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'],
      amount: json['amount'],
      interestRate: json['interestRate'],
      date: DateTime.parse(json['date']),
      borrowerId: json['borrowerId'],
      lenderId: json['lenderId'],
      collateral: json['collateral'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'interestRate': interestRate,
      'date': date.toIso8601String(),
      'borrowerId': borrowerId,
      'lenderId': lenderId,
      'collateral': collateral,
      'isActive': isActive,
    };
  }
}
