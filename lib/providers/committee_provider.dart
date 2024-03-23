import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/committee_model.dart';
import '../NetworkHandler.dart';
import '../models/user.dart';

class CommitteeProvider extends ChangeNotifier{

  var logger = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();
  bool isLoading = false;

  DataComm? committeesData;
  Committee _committee = Committee();
  Committee get committee => _committee;
  void setCommittee (Committee committee) async {
    _committee = committee;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  void setLoading(value) async {
    _loading =  value;
    notifyListeners();
  }

  bool _isBack = false;
  bool get isBack => _isBack;
  void setIsBack(value) async {
    _isBack =  value;
    notifyListeners();
  }

  Future getListOfCommittees (context) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    print(user.businessId);
    var response = await networkHandler.get('/get-list-committees/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      logger.d("get-list-committees form provider response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var boardsData = responseData['data'];
      committeesData = DataComm.fromJson(boardsData);
      logger.d(committeesData!.committees!.length);
      notifyListeners();
    } else {
      logger.d("get-list-committees form provider response statusCode unknown");
      logger.d(response.statusCode);
      logger.d(json.decode(response.body)['message']);
    }
  }


  Future<void> insertCommittee(Map<String, dynamic> data)async{
    setLoading(true);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/insert-new-committee', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setIsBack(true);
      notifyListeners();
      logger.d("insert new committee response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseCommitteeData = responseData['data'];
      _committee = Committee.fromJson(responseCommitteeData['committee']);
      Future.delayed(Duration.zero, () {
        committeesData!.committees!.add(_committee);
        logger.d(committeesData!.committees!.length!);
      });
      setIsBack(true);
      setLoading(true);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      logger.d("insert new committee response statusCode unknown");
      logger.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }




}