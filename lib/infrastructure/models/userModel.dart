class UserModel {
  String? username;
  String? firstname;
  String? lastname;
  String? email;
  String? phone;

  UserModel({
    this.username,
    this.firstname,
    this.lastname,
    this.email,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    username: json["username"]?.toString() ?? json["phoneNumber"]?.toString(),
    firstname: json["firstname"]?.toString() ?? json["firstName"]?.toString(),
    lastname: json["lastname"]?.toString() ?? json["lastName"]?.toString(),
    email: json["email"]?.toString(),
    phone: json["phone"]?.toString() ?? json["phoneNumber"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "username": username,
    "firstname": firstname,
    "lastname": lastname,
    "email": email,
    "phone": phone,
  };
}