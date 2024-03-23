import 'package:diligov/models/board_model.dart';
import 'package:diligov/models/committee_model.dart';
import 'package:diligov/models/member_sign_minutes.dart';
import 'package:diligov/models/position_model.dart';
import 'package:diligov/models/signature_model.dart';
import 'dart:typed_data';
import 'criteria_model.dart';
import 'minute_signature_model.dart';

class MyData {
  List<Member>? members;

  MyData.fromJson(Map<String, dynamic> json) {
    if (json['members'] != null) {
      members = <Member>[];
      json['members'].forEach((v) {
        members!.add(Member.fromJson(v));
      });
    }
  }
}

class Member{
   int? memberId;
   String? memberProfileImage;
   String? memberEmail;
   String? memberFirstName;
   String? memberMiddelName;
   String? memberLastName;
   String? memberMobile;
   String? memberSignature;
   String? memberBiography;
   String? memberPassword;
   int? businessId;
   bool? isActive;
   Signature? signature;
   MinuteSignature? minuteSignature;
   MemberSignMinutes? memberSignMinutes;
   bool? hasVote;
   Position? position;
   List<Committee>? committees;
   List<Board>? boards;
   List<Criteria>? criterias;


  Member(
      {this.memberId,
      this.memberProfileImage,
      this.memberEmail,
      this.memberFirstName,
      this.memberMiddelName,
      this.memberLastName,
      this.memberMobile,
      this.memberSignature,
      this.memberPassword,
      this.memberBiography,
      this.businessId,
      this.isActive,
      this.signature,
      this.minuteSignature,
      this.memberSignMinutes,
      this.hasVote,
      this.position,
      this.committees,
      this.boards,
      this.criterias
      });
 // create new converter
  Member.fromJson(Map<String, dynamic> json) {
    memberId = json['id'];
    memberEmail = json['member_email'];
    memberFirstName = json['member_first_name'];
    memberMiddelName = json['member_middel_name'];
    memberLastName = json['member_last_name'];
    memberMobile = json['member_mobile'];
    memberSignature = json['signature'];
    memberPassword = json['member_password'];
    memberBiography = json['member_biography'];
    memberProfileImage = json['member_profile_image'];
    businessId = json['business_id'];
    isActive = json['is_active'];
    signature = json['signature_member'] != null ? Signature.fromJson(json['signature_member']) : null;
    minuteSignature = json['minute_signature'] != null ? MinuteSignature.fromJson(json['minute_signature']) : null;
    memberSignMinutes = json['minute_signature_member'] != null ? MemberSignMinutes.fromJson(json['minute_signature_member']) : null;
    hasVote = json['has_vote'];
    // position =  Position?.fromJson(json['position']);
    position = json['position'] != null ? Position.fromJson(json['position']) : null;
    if (json['committees'] != null) {
      committees = <Committee>[];
      json['committees'].forEach((v) {
        committees!.add(Committee.fromJson(v));
      });
    }

    if (json['boards'] != null) {
      boards = <Board>[];
      json['boards'].forEach((v) {
        boards!.add(Board.fromJson(v));
      });
    }

    if (json['criterias'] != null) {
      criterias = <Criteria>[];
      json['criterias'].forEach((v) {
        criterias!.add(Criteria.fromJson(v));
      });
    }
  }


}