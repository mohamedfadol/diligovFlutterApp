
import 'dart:convert';

UserModel  userFromJson(String user) => UserModel.formJsonToObject(json.decode(user));
class UserModel {
  User user;
  String token;

  UserModel({ required this.user,required this.token});
  factory UserModel.formJsonToObject(Map<String, dynamic> json) =>
      UserModel(
            user: User.fromJson(json['user']),
            token: json['token']
      );

  Map<String,dynamic> toJson() => {
    // return form User  toJson function
    "user": user.toJson(),
    "token": token
  };

}
// to create constructor of UserModel use below code
// user = UserModel(String user, String token);

class User{
 final int? userId;
 final String? name;
 final String? profileImage;
 final String? email;
 final String? firstName;
 final String? lastName;
 final String? userType;
 final String? mobile;
 final String? biography;
 final int? businessId;

  User({this.userId, this.name, this.email,this.firstName, this.lastName, this.userType ,this.mobile,this.biography,this.profileImage,this.businessId});

  // create new converter
  factory User.fromJson(Map<String, dynamic> json) =>
      User(
        userId: json['id'],
        name: json['name'],
        email: json['email'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        userType: json['user_type'],
        mobile: json['contact_number'],
        biography: json['biography'],
        profileImage: json['profile_image'],
        businessId: json['business_id']
      );

  Map<String,dynamic> toJson() => {
    "id": userId,
    "name": name,
    "email": email,
    "first_name": firstName,
    "last_name": lastName,
    "user_type": userType,
    "contact_number": mobile,
    "biography": biography,
    "profile_image": profileImage,
    "business_id": businessId
  };

}