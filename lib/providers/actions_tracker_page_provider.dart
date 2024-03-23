import 'dart:convert';

import 'package:diligov/providers/member_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../models/action_tracker_model.dart';
import '../models/resolutions_model.dart';
import '../models/user.dart';
class ActionsTrackerPageProvider extends ChangeNotifier {
  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();
  ActionsTrackers? actionsData;
  ActionTracker _action_track = ActionTracker();
  ActionTracker get action_track => _action_track;
  void setActionTracker(ActionTracker action_track) async {
    _action_track = action_track;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  bool load=false;
  void setLoading(value) async {
    _loading = value;
    load = value;
    notifyListeners();
  }

  bool _isBack = false;
  bool get isBack => _isBack;
  void setIsBack(value) async {
    _isBack = value;
    notifyListeners();
  }
  int currentSortColumn = 0;
  bool isAscending = true;

  void sortByStatus(int index){
    if (isAscending == true) {
      currentSortColumn = index;
      isAscending = false;
      actionsData!.actions!.sort((a, b)=> a!.actionStatus!.compareTo(b!.actionStatus!));
    } else {
      isAscending = true;
     actionsData!.actions!.sort((a, b)=> b!.actionStatus!.compareTo(a!.actionStatus!));
    }
    notifyListeners();
  }

  void sortByTaskName(int index){
    if (isAscending == true) {
      currentSortColumn = index;
      isAscending = false;
      actionsData!.actions!.sort((a, b)=> a!.actionsTasks!.compareTo(b!.actionsTasks!));
    } else {
      isAscending = true;
      actionsData!.actions!.sort((a, b)=> b!.actionsTasks!.compareTo(a!.actionsTasks!));
    }
    notifyListeners();
  }

  void sortByActionDateAssigned(int index){
    if (isAscending == true) {
      currentSortColumn = index;
      isAscending = false;
      actionsData!.actions!.sort((a, b)=> a!.actionsDateAssigned!.compareTo(b!.actionsDateAssigned!));
    } else {
      isAscending = true;
      actionsData!.actions!.sort((a, b)=> b!.actionsDateAssigned!.compareTo(a!.actionsDateAssigned!));
    }
    notifyListeners();
  }

  void sortByActionMeetingName(int index){
    if (isAscending == true) {
      currentSortColumn = index;
      isAscending = false;
      actionsData!.actions!.sort((a, b)=> a!.meeting!.meetingTitle!.compareTo(b!.meeting!.meetingTitle!));
    } else {
      isAscending = true;
      actionsData!.actions!.sort((a, b)=> b!.meeting!.meetingTitle!.compareTo(a!.meeting!.meetingTitle!));
    }
    notifyListeners();
  }


  void sortByActionDateDue(int index){
    if (isAscending == true) {
      currentSortColumn = index;
      isAscending = false;
      actionsData!.actions!.sort((a, b)=> a!.actionsDateDue!.compareTo(b!.actionsDateDue!));
    } else {
      isAscending = true;
      actionsData!.actions!.sort((a, b)=> b!.actionsDateDue!.compareTo(a!.actionsDateDue!));
    }
    notifyListeners();
  }

  // sort alphabetically if names are the same or different
  void sortByOwner(String specificName){
    print(specificName);
    actionsData!.actions!.sort((a, b) {
      if (a.member?.position?.positionName == specificName && b.member?.position?.positionName != specificName) {
        return -1; // a should come first
      } else if (a.member?.position?.positionName!= specificName && b.member?.position?.positionName == specificName) {
        return 1; // b should come first
      } else {
        return (a.member?.position?.positionName??'').compareTo(b.member?.position?.positionName??'');
      }
    });
    notifyListeners();
  }

  Future getListOfActionTrackersWhereLike(context) async {
    // log.d(context);
    var response = await networkHandler.post1('/get-list-actions-trackers-where-like', context);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-actions-trackers-where-like form provider response statusCode == 200");
      var responseData = json.decode(response.body);
      var responseActionTrackerData = responseData['data'];
      // log.d(responseActionTrackerData);
      actionsData = ActionsTrackers.fromJson(responseActionTrackerData);
      log.d(actionsData!.actions!.length);
      notifyListeners();
    } else {
      log.d("get-list-actions-trackers-where-like form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }


  Future getListOfActionTrackers(context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    var response = await networkHandler.post1('/get-list-actions-trackers', context);
    log.d(response.statusCode);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-actions-trackers form provider response statusCode == 200");
      var responseData = json.decode(response.body);
      var responseActionTrackerData = responseData['data'];
      // log.d(responseActionTrackerData);
      actionsData = ActionsTrackers.fromJson(responseActionTrackerData);
      log.d(actionsData!.actions!.length);
      notifyListeners();
    } else {
      log.d("get-list-actions-trackers form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }


  Future<void> updateActionTracker(Map<String, dynamic> data, ActionTracker oldAction) async {
    final index = actionsData!.actions!.indexOf(actionsData!.actions!.where((element) => element.actionsId==oldAction!.actionsId).first);
    ActionTracker action = actionsData!.actions![index];
    String actionsId =  action.actionsId.toString();
    setLoading(true);
    var response = await networkHandler.post1('/edit-actions-tracker/$actionsId', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("update action response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseBoardData = responseData['data'];
      actionsData!.actions![index] = ActionTracker.fromJson(responseBoardData['action']);
      setActionTracker(_action_track);
      log.d(actionsData!.actions!.length);
      setIsBack(true);
    } else {
      log.d("update action response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
      setIsBack(false);
    }
    setLoading(false);
  }

}