class UserModel {
  String id;
  String name;
  String email;
  int? mpin;

  UserModel(
      {required this.id, required this.name, required this.email, this.mpin});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'mpin': mpin ?? 0,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        mpin: json['mpin'],
      );
}
