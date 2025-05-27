class LoanModel {
  final String id;
  final double amount;
  final double interestRate;
  final DateTime date;
  final String borrowerId;
  final String lenderId;
  final List<Collateral> collaterals;
  final bool isActive;

  LoanModel({
    required this.id,
    required this.amount,
    required this.interestRate,
    required this.date,
    required this.borrowerId,
    required this.lenderId,
    required this.collaterals,
    required this.isActive,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> collateralsJson = json['collaterals'];
    final List<Collateral> collaterals = collateralsJson.map((c) {
      return Collateral(
        description: c['description'],
        imageUrl: c['imageUrl'],
      );
    }).toList();

    return LoanModel(
      id: json['id'],
      amount: json['amount'].toDouble(),
      interestRate: json['interestRate'].toDouble(),
      date: DateTime.parse(json['date']),
      borrowerId: json['borrowerId'],
      lenderId: json['lenderId'],
      collaterals: collaterals,
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> collateralsJson = collaterals.map((c) {
      return c.toJson();
    }).toList();

    return {
      'id': id,
      'amount': amount,
      'interestRate': interestRate,
      'date': date.toIso8601String(),
      'borrowerId': borrowerId,
      'lenderId': lenderId,
      'collaterals': collateralsJson,
      'isActive': isActive,
    };
  }
}

class Collateral {
  final String description;
  String imageUrl;

  Collateral({
    required this.description,
    this.imageUrl = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
