import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../NetworkHandler.dart';
import '../../../models/user.dart';
import '../models/member.dart';

class MemberPageProvider extends ChangeNotifier{

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();
    Member? selectedMember;
  void setSelectedMember(Member?  value){
    selectedMember=value;
  }
  MyData? dataOfMembers;
  Member _member = Member();
  Member get member => _member;

  void setMember (Member member) async {
    _member =  member;
    notifyListeners();
  }
  bool _isBack = false;
  bool get isBack => _isBack;
  void setIsBack(value) async {
    _isBack =  value;
    notifyListeners();
  }

  bool get loading => _loading;
  bool _loading = false;
  void setLoading(value) async {
    _loading =  value;
    notifyListeners();
  }

  Future getListOfMember(context)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-members/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-members response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var membersData = responseData['data'];
      dataOfMembers = MyData.fromJson(membersData);
      notifyListeners();

    } else {
      log.d("get-list-members response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> insertMember(Map<String, dynamic> data)async{
    setLoading(true);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/insert-new-member', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("insert new member response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var membersData = responseData['data'];
      _member = Member.fromJson(membersData['member']);
      dataOfMembers!.members!.add(_member);
      setIsBack(true);
      setLoading(true);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("insert new member response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }



}