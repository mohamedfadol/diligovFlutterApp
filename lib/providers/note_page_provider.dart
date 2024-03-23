import 'dart:convert';

import 'package:diligov/models/agenda_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

import '../NetworkHandler.dart';
import '../models/board_model.dart';
import '../models/boards_model.dart';
import '../models/committee_model.dart';
import '../models/meeting_model.dart';
import '../models/note_model.dart';
import '../models/user.dart';

class NotePageProvider extends ChangeNotifier{

  Notes? notesData;
  Meetings? dataOfMeetings;
  Boards? boardsData;
  DataComm? committeesData;

  Note _note = Note();
  Note get note => _note;

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

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

  void setNote (Note note) async {
    _note =  note;
    notifyListeners();
  }

  List<Meeting>? get meetings => dataOfMeetings?.meetings;
  void toggleMeetingParentMenu(int index) {
    meetings![index].isExpanded = !meetings![index]!.isExpanded!;
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  List<Board>? get boards => boardsData?.boards;
  void toggleBoardParentMenu(int index) {
    boards![index].isExpanded = !boards![index]!.isExpanded!;
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  List<Committee>? get committees => committeesData?.committees;
  void toggleCommitteeParentMenu(int index) {
    committees![index].isExpanded = !committees![index]!.isExpanded!;
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  List<Agenda> getAllAgendas() {
    List<Agenda> allAgendas = [];
    // Assuming dataOfMeetings?.meetings returns a List<Meeting>?
    List<Meeting>? meetings = dataOfMeetings?.meetings;
    if (meetings != null) {
      // Iterate through each meeting
      for (Meeting meeting in meetings) {
        // If the meeting has agendas, add them all to the allAgendas list
        if (meeting.agendas != null) {
          allAgendas.addAll(meeting.agendas!);
        }
      }
    }
    return allAgendas;
  }


  Future getListOfBoardNotes(context) async{
    var response = await networkHandler.post1('/get-list-board-notes',context);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-board-notes form provider response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseBoardsData = responseData['data'];
      log.d(responseBoardsData);
      boardsData = Boards.fromJson(responseBoardsData);
      log.d(boardsData!.boards!.length);
      notifyListeners();
    } else {
      log.d("get-list-board-notes dataOfMeetings form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }

  Future getListOfCommitteeNotes(context) async{
    var response = await networkHandler.post1('/get-list-committee-notes',context);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-committee-notes form provider response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseCommitteesData = responseData['data'];
      log.d(responseCommitteesData);
      committeesData = DataComm.fromJson(responseCommitteesData);
      log.d(committeesData!.committees!.length);
      notifyListeners();
    } else {
      log.d("get-list-committee-notes dataOfMeetings form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }

  Future<void> insertNewNote(Map<String, dynamic> data)async{
    var response = await networkHandler.post1('/insert-new-note', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("insert new note response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseMinuteData = responseData['data'];
      _note = Note.fromJson(responseMinuteData['note']);
      setIsBack(true);
      notesData!.notes!.add(_note);
      log.d(notesData!.notes!.length);
      notifyListeners();
    } else {
      setIsBack(false);
      notifyListeners();
      log.d("insert new note response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }



}