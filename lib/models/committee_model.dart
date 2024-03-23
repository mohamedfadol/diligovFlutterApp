import 'board_model.dart';
import 'business_model.dart';
import 'meeting_model.dart';
import 'member.dart';



class DataComm {
  List<Committee>? committees;

  DataComm.fromJson(Map<String, dynamic> json) {
    if (json['committees'] != null) {
      committees = <Committee>[];
      json['committees'].forEach((v) {
        committees!.add(Committee.fromJson(v));
      });
    }
  }

}

class Committee {
  int? id;
  String? committeeName;
  String? charterCommittee;
  String? charterName;
  String? serialNumber;
  int? boardId;
  Business? business;
  int? isActive;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;
  Board? board;
  List<Member>? members;
  bool  isExpanded= false;
  List<Meeting>? meetings;


  Committee(
      {this.id,
        this.committeeName,
        this.charterCommittee,
        this.charterName,
        this.serialNumber,
        this.boardId,
        this.business,
        this.isActive,
        this.deletedAt,
        this.createdAt,
        this.updatedAt,
        this.board,
        this.members,
        this.meetings});

  Committee.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    committeeName = json['committee_name'];
    charterCommittee = json['charter_committee'];
    charterName = json['charter_name'];
    serialNumber = json['serial_number'];
    boardId = json['board_id'];
    isActive = json['is_active'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    board = json['board'] != null ? Board.fromJson(json['board']) : null;
    business = json['business'] != null ? Business.fromJson(json['business']) : null;
    if (json['members'] != null) {
      members = <Member>[];
      json['members'].forEach((v) {
        members!.add(Member.fromJson(v));
      });
    }
    if (json['meetings'] != null) {
      meetings = <Meeting>[];
      json['meetings'].forEach((v) {
        meetings!.add(Meeting.fromJson(v));
      });
    }
  }




}

