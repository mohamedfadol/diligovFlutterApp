import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/user.dart';

class UserPreferences {

  Future<bool> saveUser(UserModel user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('id',user.user.userId!);
    prefs.setString('name',user.user.name!);
    prefs.setString('email',user.user.email!);
    prefs.setString('first_name',user.user.firstName!);
    prefs.setString('last_name',user.user.lastName!);
    prefs.setString('user_type',user.user.userType!);
    // prefs.setString('mobile',user.user.mobile!);
    // prefs.setString('profile_image',user.user.profileImage!);
    // prefs.setString('biography',user.user.biography!);
    prefs.setInt('business_id',user.user.businessId!);
    prefs.setString('token',user.token!);
    prefs.setString('user',( json.encode(user.user) ) );
    return prefs.commit();

  }


  Future<bool> updateUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('id',user.userId!);
    prefs.setString('name',user.name!);
    prefs.setString('email',user.email!);
    prefs.setString('first_name',user.firstName!);
    prefs.setString('last_name',user.lastName!);
    prefs.setString('user_type',user.userType!);
    prefs.setString('mobile',user.mobile!);
    prefs.setString('profile_image',user.profileImage!);
    prefs.setString('biography',user.biography!);
    prefs.setInt('business_id',user.businessId!);
    prefs.setString('user',( json.encode(user) ) );
    return prefs.commit();

  }


  Future<UserModel> getUser ()  async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    User user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    return UserModel (user: user,token: token);
  }

  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('id');
    prefs.remove('user');
    prefs.remove('token');
    prefs.remove('name');
    prefs.remove('email');
    prefs.remove('first_name');
    prefs.remove('last_name');
    prefs.remove('user_type');
    prefs.remove('mobile');
    prefs.remove('profile_image');
    prefs.remove('biography');

  }

  Future<String> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    return token;
  }

  Future<User> getInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    User user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    return user;
  }
}