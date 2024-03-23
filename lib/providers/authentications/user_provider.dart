import 'dart:convert';

import 'package:diligov/core/domains/app_uri.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../../models/user.dart';
import '../../utility/shared_preference.dart';
import '../../../NetworkHandler.dart';

class UserProfilePageProvider extends ChangeNotifier {
  var logger = Logger();
  // logger.d('Log message with 2 methods');
  // logger.i('Info message');
  String baseApi = AppUri.baseApi;
  var client = http.Client();

  User _user = User();
  User get user => _user;
  void setUser(User user) async {
    _user = user;
    // notifyListeners();
  }

  Future getUserProfile() async {
    String token = await UserPreferences().getToken();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    NetworkHandler networkHandler = NetworkHandler();
    int? userId = prefs.getInt("id")!;
    String id = userId.toString();
    var response = await networkHandler.get("/get-user-profile/user/$id");
    if (response.statusCode == 200 || response.statusCode == 201) {
      logger.d("get User Profile response statusCode == 200");
      var responseData = json.decode(response.body);
      var userData = responseData['data'];
      _user = User.fromJson(userData['user']);
      setUser(_user);
      notifyListeners();
    } else {
      notifyListeners();
      logger.d(json.decode(response.body)['message']);
    }
  }
}
