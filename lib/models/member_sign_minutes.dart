import 'package:diligov/models/member.dart';
class MemberSignMinutes {
  int? signatureId;
  bool? hasSigned;
  Member? member;

  MemberSignMinutes({this.signatureId,this.member,this.hasSigned});

  // create new converter
  MemberSignMinutes.fromJson(Map<String, dynamic> json) {
    signatureId = json['id'];
    hasSigned = json['has_signed'];
    member =  Member?.fromJson(json['member']);
  }
}