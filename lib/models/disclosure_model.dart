import 'package:diligov/models/member.dart';
import 'package:diligov/models/user.dart';

import 'business_model.dart';

class Disclosures {
  List<DisclosureModel>? disclosures;
  Disclosures.fromJson(Map<String, dynamic> json) {
    if (json['disclosures'] != null) {
      disclosures = <DisclosureModel>[];
      json['disclosures'].forEach((v) {
        disclosures!.add(DisclosureModel.fromJson(v));
      });
    }
  }
}

class DisclosureModel{
  int? disclosureId;
  String? disclosureName;
  String? disclosureType;
  String? disclosureFile;
  String? disclosureDate;
  User? user;
  Business? business;
  Member? member;


  DisclosureModel(
      {this.disclosureId,
        this.disclosureName,
        this.disclosureType,
        this.disclosureFile,
        this.disclosureDate,
        this.user,
        this.business,
        this.member,
      });

  // create new converter
  DisclosureModel.fromJson(Map<String, dynamic> json) {
    disclosureId = json['id'];
    disclosureName = json['disclosure_name'];
    disclosureType = json['disclosure_type'];
    disclosureFile = json['disclosure_file'];
    disclosureDate = json['disclosure_date'];
    user = User?.fromJson(json['user']);
    business = Business?.fromJson(json['business']);
    // member = Member?.fromJson(json['member']);

  }


}