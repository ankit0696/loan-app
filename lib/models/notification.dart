class NotificationModel {
  final String id;
  final String borrowerId;
  final String lenderId;
  final String loanId;
  final DateTime date;
  int notificationId;

  NotificationModel({
    required this.id,
    required this.borrowerId,
    required this.lenderId,
    required this.loanId,
    required this.date,
    required this.notificationId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'borrowerId': borrowerId,
        'lenderId': lenderId,
        'loanId': loanId,
        'date': date.toIso8601String(),
        'notificationId': notificationId,
      };

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'],
        borrowerId: json['borrowerId'],
        lenderId: json['lenderId'],
        loanId: json['loanId'],
        date: DateTime.parse(json['date']),
        notificationId: json['notificationId'],
      );
}
