import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../models/criteria_model.dart';
import '../models/member.dart';
import '../models/user.dart';

class EvaluationPageProvider extends ChangeNotifier{
  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

  MyData? dataOfMembers;
  Member _member = Member();
  Member get member => _member;
  void setMember(Member member) async {
    _member =  member;
    notifyListeners();
  }


  Criterias? dataOfCriteria;
  Criteria _criteria = Criteria();
  Criteria get criteria => _criteria;
  void setCriteria(Criteria criteria) async {
    _criteria =  criteria;
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


  Future getListOfEvaluationsMember(context)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-members/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-members response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var membersResponseData = responseData['data'];
      dataOfMembers = MyData.fromJson(membersResponseData);
      notifyListeners();

    } else {
      log.d("get-list-members response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }


  Future insertNewCriteria(Map<String, dynamic> data) async{
    setLoading(true);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/insert-new-criteria', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setIsBack(true);
      notifyListeners();
      log.d("insert new criteria response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseCriteriaData = responseData['data'];
      // print(responseCriteriaData['criteria']);
      _criteria = Criteria.fromJson(responseCriteriaData['criteria']);
      dataOfCriteria!.criterias!.add(_criteria);
      log.d(dataOfCriteria!.criterias!.length);
      setIsBack(true);
      setLoading(true);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("insert new criteria response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }


  Future insertNewEvaluationsMember(Map<String, dynamic> data) async{
    setLoading(true);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/insert-new-criteria-evaluations-member', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setIsBack(true);
      notifyListeners();
      log.d("insert new criteria response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseCriteriaData = responseData['data'];
      // print(responseCriteriaData['criteria']);
      // _criteria = Criteria.fromJson(responseCriteriaData['criteria']);
      // dataOfCriteria!.criterias!.add(_criteria);
      // log.d(dataOfCriteria!.criterias!.length);
      setIsBack(true);
      setLoading(true);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("insert new criteria response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future getListOfEvaluationsMemberCriterias(context)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-criterias/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-criterias response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var criteriasResponseData = responseData['data'];
      dataOfCriteria = Criterias.fromJson(criteriasResponseData);
      notifyListeners();
    } else {
      log.d("get-list-criterias response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

}