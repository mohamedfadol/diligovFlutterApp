import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../NetworkHandler.dart';
import '../models/notification_model.dart';
import '../models/user.dart';

class NotificationPageProvider with ChangeNotifier {

  Notifications? notificationsData;

  bool _loading = false;
  bool get loading => _loading;
  void setLoading(value) async {
    _loading =  value;
    notifyListeners();
  }

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();



  List<NotificationModel>? get notifications => notificationsData?.notifications;

  int? get notificationCount => notifications?.length ?? 0;


  Future fetchNotifications()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-notifications');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-notifications response statusCode == 200");
      var responseData = json.decode(response.body);
      var notificationsDataResponse = responseData['data'];
      notificationsData = Notifications.fromJson(notificationsDataResponse);
      print(notificationsData!.notifications!.length);
      notifyListeners();
    } else {
      log.d("get-list-notifications response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  // Method to fetch last 10 notifications
  List<NotificationModel> get lastTenNotifications => notifications!.reversed.take(10).toList();
}