class BorrowerModel {
  final String id;
  final String name;
  final String phone;
  final DateTime date;
  final String address;
  final String aadharNumber;
  final String lenderId;
  // String? imageUrl;

  BorrowerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.date,
    required this.address,
    required this.aadharNumber,
    required this.lenderId,
    // this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'date': date.toIso8601String(),
        'address': address,
        'aadharNumber': aadharNumber,
        'lenderId': lenderId,
        // 'imageUrl': imageUrl
      };

  factory BorrowerModel.fromJson(Map<String, dynamic> json) => BorrowerModel(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        date: DateTime.parse(json['date']),
        address: json['address'],
        aadharNumber: json['aadharNumber'],
        lenderId: json['lenderId'],
        // imageUrl: json['imageUrl'],
      );
}
