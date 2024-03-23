import 'package:diligov/models/member.dart';
class MinuteSignature {
  final int signatureId;
  final bool hasSigned;
  final Member member;

  MinuteSignature({required this.signatureId,required this.member,required this.hasSigned});

  // create new converter
 factory MinuteSignature.fromJson(Map<String, dynamic> json) => MinuteSignature(signatureId: json['id'], member: Member?.fromJson(json['member']), hasSigned: json['has_signed']);
}