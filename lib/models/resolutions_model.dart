import 'package:diligov/models/board_model.dart';
import 'package:diligov/models/business_model.dart';
import 'package:diligov/models/committee_model.dart';
import 'package:diligov/models/user.dart';

import 'meeting_model.dart';

class Resolutions{
  List<Resolution>? resolutions;

  Resolutions.fromJson(Map<String, dynamic> json) {
    if (json['resolutions'] != null) {
      resolutions = <Resolution>[];
      json['resolutions'].forEach((v) {
        resolutions!.add(Resolution.fromJson(v));
      });
    }
  }
}

class Resolution{
  int? resoultionId;
  String? resoultionName;
  String? resoultionDecision;
  String? resoultionDate;
  String? resoultionNumbers ;
  String? resoultionCharter;
  String? resoultionStatus ;
  int? addBy;
  int? businessId;
  Business? business;
  Committee? committee;
  Board? board;
  User? user;
  Meeting? meeting;

  Resolution(
      {this.resoultionId,
        this.resoultionName,
        this.resoultionDecision,
        this.resoultionDate,
        this.resoultionNumbers,
        this.resoultionCharter,
        this.resoultionStatus,
        this.addBy,
        this.businessId,
        this.business,
        this.user,
        this.board,
        this.committee,
        this.meeting,
      });
  // create new converter
  Resolution.fromJson(Map<String, dynamic> json) {
    resoultionId = json['id'];
    resoultionName = json['resoultion_name'];
    resoultionDecision = json['resolution_decision'];
    resoultionDate = json['date'];
    resoultionNumbers = json['resoultion_numbers'];
    resoultionCharter = json['resoultion_charter'];
    resoultionStatus = json['resoultion_status'];
    addBy = json['add_by'];
    businessId = json['business_id'];
    business = json['business'] != null ? Business?.fromJson(json['business']) : null;
    user = json['user'] != null ? User?.fromJson(json['user']) : null;
    committee = json['committee'] != null ? Committee?.fromJson(json['committee']) : null;
    meeting = json['meeting'] != null ? Meeting.fromJson(json['meeting']) : null;
    board = json['board'] != null ? Board.fromJson(json['board']) : null;

  }


}