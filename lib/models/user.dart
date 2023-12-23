class UserModel {
  String id;
  String name;
  String email;
  String fcmToken;
  int? mpin;

  UserModel(
      {required this.id, required this.name, required this.email, required this.fcmToken, this.mpin});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'fcmToken': fcmToken,
        'mpin': mpin ?? 0,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        fcmToken: json['fcmToken'],
        mpin: json['mpin'],
      );
}
