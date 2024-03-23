import 'package:diligov/models/board_model.dart';
import 'package:diligov/models/committee_model.dart';
import 'package:diligov/models/user.dart';
import 'package:flutter/material.dart';

import 'agenda_model.dart';

class Meetings {
  List<Meeting>? meetings;
  Meetings.fromJson(Map<String, dynamic> json) {
    if (json['meetings'] != null) {
      meetings = <Meeting>[];
      json['meetings'].forEach((v) {
        meetings!.add(Meeting.fromJson(v));
      });
    }
  }

}

class Meeting {
  int? meetingId;
  String? meetingTitle;
  String? meetingDescription;
  DateTime? meetingStart;
  DateTime? meetingEnd;
  String? meetingBy;
  String? meetingMediaName;
  String? meetingStatus;
  String? meetingSerialNumber;
  String? meetingFile;
  bool? isActive;
  int? isAllDays;
  int? createdBy;
  bool? hasNextMeeting;
  int? previousMeetingId;
  Color backGroundColor = Colors.red;
  Board? board;
  User? user;
  bool? isExpanded = false;
  bool isClicked = false;
  Committee? committee;
  List<Agenda>? agendas;
  String? meetingStartDate;
  String? meetingEndDate;

  Meeting(
      {this.meetingId,
        this.meetingStartDate,
        this.meetingEndDate,
        this.meetingTitle,
        required this.backGroundColor,
        this.meetingDescription,
        this.meetingStart,
        this.meetingEnd,
        this.meetingBy,
        this.meetingMediaName,
        this.meetingStatus,
        this.meetingSerialNumber,
        this.meetingFile,
        this.isActive,
        this.isAllDays,
        this.createdBy,
        this.board,
        this.committee,
        this.agendas,
        this.user,
        this.hasNextMeeting,
        this.previousMeetingId});

  Meeting.fromJson(Map<String, dynamic> json) {
    meetingId = json['id'];
    meetingTitle = json['meeting_title'];
    meetingDescription = json['meeting_description'];
    meetingStart =  DateTime.tryParse(json['meeting_start']) ;
    meetingEnd = DateTime.tryParse(json['meeting_end']);
    meetingStartDate = json['meeting_start_date'];
    meetingEndDate = json['meeting_end_date'];
    meetingBy = json['meeting_by'];
    meetingMediaName = json['meeting_media_name'];
    meetingStatus = json['meeting_status'];
    meetingSerialNumber = json['meeting_serial_number'];
    meetingFile = json['meeting_file'];
    isAllDays = json['is_all_days'];
    isActive = json['is_active'];
    createdBy = json['created_by'];
    hasNextMeeting = json['hasNextMeeting'];
    previousMeetingId = json['previous_meeting_id'];
    board = json['board'] != null ? Board.fromJson(json['board']) : null;
    committee = json['committee'] != null ? Committee.fromJson(json['committee']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['agendas'] != null) {
      agendas = <Agenda>[];
      json['agendas'].forEach((v) {
        agendas!.add(Agenda.fromJson(v));
      });
    }
  }

}
