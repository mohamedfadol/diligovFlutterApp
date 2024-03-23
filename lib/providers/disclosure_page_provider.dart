import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../NetworkHandler.dart';
import '../models/disclosure_model.dart';
import '../models/user.dart';

class DisclosurePageProvider extends ChangeNotifier {
  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();
  Disclosures? disclosuresData;
  DisclosureModel _disclosure = DisclosureModel();
  DisclosureModel get disclosure => _disclosure;
  void setDisclosure(DisclosureModel disclosure) async {
    _disclosure = disclosure;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  void setLoading(value) async {
    _loading = value;
    notifyListeners();
  }
  bool _isBack = false;
  bool get isBack => _isBack;
  void setIsBack(value) async {
    _isBack = value;
    notifyListeners();
  }

  Future getListOfDisclosures(context) async {
    var response = await networkHandler.post1('/get-list-disclosures', context);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-disclosures form provider response statusCode == 200");
      var responseData = json.decode(response.body);
      var responseDisclosureData = responseData['data'];
      disclosuresData = Disclosures.fromJson(responseDisclosureData);
      log.d(disclosuresData!.disclosures!.length);
      notifyListeners();
    } else {
      log.d("get-list-disclosures form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }


  Future<void> insertDisclosure(Map<String, dynamic> data)async{
    setLoading(true);
    var response = await networkHandler.post1('/create-new-disclosure', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("create-new-disclosures response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseDisclosureData = responseData['data'];
      _disclosure = DisclosureModel.fromJson(responseDisclosureData['disclosure']);
      disclosuresData!.disclosures!.add(_disclosure);
      log.d(disclosuresData!.disclosures!.length);
      setIsBack(true);
    } else {
      log.d("create-new-disclosures response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
    setLoading(false);
  }

  Future<void> removeDisclosure(DisclosureModel deleteDisclosure)async{
    final index = disclosuresData!.disclosures!.indexOf(deleteDisclosure);
    DisclosureModel disclosure = disclosuresData!.disclosures![index];
    String disclosureId =  disclosure.disclosureId.toString();
    Map<String, dynamic> data = {"disclosure_id": disclosureId};
    var response = await networkHandler.post1('/delete-disclosure-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("deleted disclosures-by-id response statusCode == 200");
      disclosuresData!.disclosures!.remove(disclosure);
      log.d(disclosuresData!.disclosures!.length);
      setIsBack(true);
    } else {
      log.d(json.decode(response.body)['message']);
      log.d(response.statusCode);
      setLoading(false);
      setIsBack(false);
    }
    setLoading(false);
  }

  Future<Map<String, dynamic>>  makeSignedDisclosure(Map<String, dynamic> data)async{
    var result;
    setLoading(true);
    var response = await networkHandler.post1('/make-sign-disclosure', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("sign disclosure response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseDisclosure = responseData['data'];
      _disclosure = DisclosureModel.fromJson(responseDisclosure['disclosure']);
      setDisclosure(_disclosure);
      setIsBack(true);
      result = {'status': true, 'message': 'Successful', 'disclosure': _disclosure};
    } else {
      log.d("sign disclosure response statusCode unknown");
      log.d(response.statusCode);
      log.i(json.decode(response.body)['message']);
      setLoading(false);
      setIsBack(false);
      result = {'status': false,'message': json.decode(response.body)['message']};
    }
    setLoading(false);
    return result;
  }


}