import 'dart:convert';

import 'package:diligov/models/agenda_model.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../models/meeting_model.dart';
import '../models/user.dart';
class MeetingPageProvider extends ChangeNotifier{

  Meetings? dataOfMeetings;
  Agendas? listAgenda;

  Meeting _meeting = Meeting(backGroundColor: Colors.lightGreen);
  Meeting get meeting => _meeting;
  void setMeeting(Meeting meeting) async {
    _meeting =  meeting;
    notifyListeners();
  }

  Future getListAgendas(String meetingId) async{
    Map<String,String> data = {"meeting_id": meetingId};
    var response = await networkHandler.get('/get-list-agenda-by-meetingId/${data["meeting_id"]}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-agendas response statusCode == 200");
      var responseData = json.decode(response.body);
      var agendasData = responseData['data'];
      listAgenda = Agendas.fromJson(agendasData);
      notifyListeners();
    } else {
      log.d("get-list-agendas response statusCode unknown");
      print(json.decode(response.body)['message']);
    }
    //
  }

  void addAgendaDetails(Agenda agenda){
    final element = listAgenda!.agendas!.firstWhere((ag) => ag.agendaId==agenda.agendaId);
    final indexOfAgenda = listAgenda!.agendas!.indexOf(element);
  listAgenda!.agendas![indexOfAgenda] = agenda;
    print('add success---------------------------------------');
    notifyListeners();
  }

  DateTime _selectedDate  = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  void setDate(DateTime date) => _selectedDate = date;
  List<Meeting> get eventsOfSelectedDate => dataOfMeetings!.meetings!;

  bool _isBack = false;
  bool get isBack => _isBack;
  void setIsBack(value) async {
    _isBack =  value;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  void setLoading(value) async {
    _loading =  value;
    notifyListeners();
  }

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

  Future getListOfMeetings(context)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-meetings/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-meetings response statusCode == 200");
      var responseData = json.decode(response.body);
      var meetingsData = responseData['data'];
      dataOfMeetings = Meetings.fromJson(meetingsData);
      print(dataOfMeetings!.meetings!.length);
      notifyListeners();
    } else {
      log.d("get-list-meetings response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future getListOfMeetingsBoards(context)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/get-list-meetings-belongsTo-board',context);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-meetings response statusCode == 200");
      var responseData = json.decode(response.body);
      log.d(responseData);
      var meetingsData = responseData['data'];
      dataOfMeetings = Meetings.fromJson(meetingsData);
      print(dataOfMeetings!.meetings!.length);
      notifyListeners();

    } else {
      log.d("get-list-meetings response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future getListOfMeetingsCommittees(context)async{
    log.d(context);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/get-list-meetings-belongsTo-committee',context);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-meetings response statusCode == 200");
      var responseData = json.decode(response.body);
      print(responseData);
      var meetingsData = responseData['data'];
      dataOfMeetings = Meetings.fromJson(meetingsData);
      print(dataOfMeetings!.meetings!.length);
      notifyListeners();

    } else {
      log.d("get-list-meetings response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> insertMeeting(Map<String, dynamic> data)async{
    setLoading(true);
    var response = await networkHandler.post1('/insert-new-meeting', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("insert new meeting response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var meetingsData = responseData['data'];
      _meeting = Meeting.fromJson(meetingsData['meeting']);
      log.d(_meeting);
      dataOfMeetings!.meetings!.add(_meeting);
      setMeeting(_meeting);
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("insert new meeting response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> editingMeeting(Map<String, dynamic> data, Meeting oldMeeting)async{
    final index = dataOfMeetings!.meetings!.indexOf(oldMeeting);
    Meeting meeting = dataOfMeetings!.meetings![index];
    String meetingId =  meeting.meetingId.toString();
    setLoading(true);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/update-meeting-by-id/$meetingId', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setIsBack(true);
      notifyListeners();
      log.d("update-meeting-by-id response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var membersData = responseData['data'];
      dataOfMeetings!.meetings![index] = Meeting.fromJson(membersData['meeting']);
      setMeeting(_meeting);
      dataOfMeetings!.meetings!.add(_meeting);
      setIsBack(true);
      setLoading(true);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("update-meeting-by-id meeting response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> deleteMeeting(Meeting deletingMeeting)async{
    final index = dataOfMeetings!.meetings!.indexOf(deletingMeeting);
    Meeting meeting = dataOfMeetings!.meetings![index];
    String meetingId =  meeting.meetingId.toString();
    setLoading(true);
    notifyListeners();
  }


}