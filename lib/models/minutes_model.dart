import 'package:diligov/models/board_model.dart';
import 'package:diligov/models/business_model.dart';
import 'package:diligov/models/committee_model.dart';
import 'package:diligov/models/member_sign_minutes.dart';
import 'package:diligov/models/user.dart';
import 'package:diligov/models/attandence_board.dart';

import 'meeting_model.dart';

class Minutes{
  List<Minute>? minutes;

  Minutes.fromJson(Map<String, dynamic> json) {
    if (json['minutes'] != null) {
      minutes = <Minute>[];
      json['minutes'].forEach((v) {
        minutes!.add(Minute.fromJson(v));
      });
    }
  }
}

class Minute {
  int? minuteId;
  String? minuteName;
  String? minuteDecision;
  String? minuteDate;
  String? minuteNumbers;
  String? minuteStatus ;
  int? addBy;
  int? businessId;
  Business? business;
  Committee? committee;
  Board? board;
  User? user;
  Meeting? meeting;
  List<AttendanceBoard>? attendanceBoards;
  List<MemberSignMinutes>? memberSignMinutes;

  Minute(
      {this.minuteId,
        this.minuteName,
        this.minuteDecision,
        this.minuteDate,
        this.minuteNumbers,
        this.minuteStatus,
        this.addBy,
        this.businessId,
        this.business,
        this.user,
        this.board,
        this.committee,
        this.meeting,
        this.attendanceBoards,
        this.memberSignMinutes,
      });
  // create new converter
  Minute.fromJson(Map<String, dynamic> json) {
    minuteId = json['id'];
    minuteName = json['minute_name'];
    minuteDecision = json['minute_decision'];
    minuteDate = json['minute_date'];
    minuteNumbers = json['minute_numbers'];
    minuteStatus = json['minute_status'];
    addBy = json['add_by'];
    businessId = json['business_id'];
    business = json['business'] != null ? Business?.fromJson(json['business']) : null;
    user = json['user'] != null ? User?.fromJson(json['user']) : null;
    committee = json['committee'] != null ? Committee?.fromJson(json['committee']) : null;
    meeting = json['meeting'] != null ? Meeting.fromJson(json['meeting']) : null;
    board = json['board'] != null ? Board.fromJson(json['board']) : null;
    if (json['attendance_boards'] != null) {
      attendanceBoards = <AttendanceBoard>[];
      json['attendance_boards'].forEach((v) {
        attendanceBoards!.add(AttendanceBoard.fromJson(v));
      });
    }
    if (json['members_signatures'] != null) {
      memberSignMinutes = <MemberSignMinutes>[];
      json['members_signatures'].forEach((v) {
        memberSignMinutes!.add(MemberSignMinutes.fromJson(v));
      });
    }
  }


}