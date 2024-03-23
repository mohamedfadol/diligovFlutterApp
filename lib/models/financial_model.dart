
import 'package:diligov/models/business_model.dart';
import 'package:diligov/models/meeting_model.dart';
import 'package:diligov/models/member.dart';
import 'package:diligov/models/user.dart';

class FinancialData {
  List<FinancialModel>? financials;

  FinancialData.fromJson(Map<String, dynamic> json) {
    if (json['financials'] != null) {
      financials = <FinancialModel>[];
      json['financials'].forEach((v) {
        financials!.add(FinancialModel.fromJson(v));
      });
    }
  }
}

class FinancialModel {
  int? financialId;
  String? financialName;
  String? financialDate;
  String? financialFile;
  User? user;
  Business? business;
  Meeting? meeting;
  List<Member>? members;

  FinancialModel({this.members,this.financialId,this.financialName,this.financialDate,this.financialFile,this.user,this.business,this.meeting});

  // create new converter
  FinancialModel.fromJson(Map<String, dynamic> json) {
    financialId = json['id'];
    financialFile = json['financial_file'];
    financialName = json['financial_name'];
    financialDate = json['financial_date'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    business = json['business'] != null ? Business.fromJson(json['business']) : null;
    meeting = json['meeting'] != null ? Meeting.fromJson(json['meeting']) : null;
    if (json['members'] != null) {
      members = <Member>[];
      json['members'].forEach((v) {
        members!.add(Member.fromJson(v));
      });
    }

  }

}