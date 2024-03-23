import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../models/resolutions_model.dart';
import '../models/user.dart';
class ResolutionsPageProvider extends ChangeNotifier{
  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

  Resolutions? resolutionsData;
  Resolution _resolution = Resolution();
  Resolution get resolution => _resolution;
  void setResolution(Resolution resolution) async {
    _resolution =  resolution;
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

  Future getListOfBoardsResolutions(context) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!));
    var response = await networkHandler.post1('/get-list-board-resolutions',context);
    log.d(response.statusCode);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-board-resolutions form provider response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseResolutionsData = responseData['data'];
      log.d(responseResolutionsData);
      resolutionsData = Resolutions.fromJson(responseResolutionsData);
      log.d(resolutionsData!.resolutions!.length);
      notifyListeners();

    } else {
      log.d("get-list-board-resolutions form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }

  Future getListOfCommitteesResolutions(context) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!));
    var response = await networkHandler.post1('/get-list-committee-resolutions',context);
    log.d(response.statusCode);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-committee-resolutions form provider response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseResolutionsData = responseData['data'];
      log.d(responseResolutionsData);
      resolutionsData = Resolutions.fromJson(responseResolutionsData);
      log.d(resolutionsData!.resolutions!.length);
      notifyListeners();

    } else {
      log.d("get-list-committee-resolutions form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }

  Future<void> insertResolution(Map<String, dynamic> data)async{
    setLoading(true);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/insert-new-resolution', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setIsBack(true);
      notifyListeners();
      log.d("insert new resolution response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseResolutionData = responseData['data'];
      _resolution = Resolution.fromJson(responseResolutionData['resolution']);
      resolutionsData!.resolutions!.add(_resolution);
      log.d(resolutionsData!.resolutions!.length);
      setIsBack(true);
      setLoading(true);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("insert new resolution response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<Map<String, dynamic>>  makeSignedResolution(Map<String, dynamic> data)async{
    var result;
    setLoading(true);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/make-sign-resolution', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setIsBack(true);
      notifyListeners();
      log.d("sign resolution response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseResolutionData = responseData['data'];
      _resolution = Resolution.fromJson(responseResolutionData['resolution']);
      setResolution(_resolution);
      // resolutionsData!.resolutions!.add(_resolution);
      // log.d(resolutionsData!.resolutions!.length);
      setIsBack(true);
      setLoading(true);
      notifyListeners();
      result = {'status': true, 'message': 'Successful', 'resolution': _resolution};
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("sign resolution response statusCode unknown");
      log.d(response.statusCode);
      log.i(json.decode(response.body)['message']);
      result = {'status': false,'message': json.decode(response.body)['message']
      };

    }
    return result;
  }

  Future<void>  removeResolution(Resolution deleteResolution)async{
    final index = resolutionsData!.resolutions!.indexOf(deleteResolution);
    Resolution resolution = resolutionsData!.resolutions![index];
    String resolutionId =  resolution.resoultionId.toString();
    Map<String, dynamic> data = {"resolution_id": resolutionId};
    log.d(data);
    notifyListeners();
    var response = await networkHandler.post1('/delete-resolution-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("deleted resolution response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseMinuteData = responseData['data'];
      // _resolution = Resolution.fromJson(responseMinuteData['resolution']);
      resolutionsData!.resolutions!.remove(resolution);
      log.d(resolutionsData!.resolutions!.length);
      setIsBack(true);
      setLoading(true);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d(json.decode(response.body)['message']);
      log.d(response.statusCode);
    }
  }
}