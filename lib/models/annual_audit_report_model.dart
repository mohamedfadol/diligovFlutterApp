import 'package:diligov/models/business_model.dart';
import 'package:diligov/models/member.dart';
import 'package:diligov/models/user.dart';

class AnnualAuditReportData {
  List<AnnualAuditReportModel>? annual_audit_reports_data;
  AnnualAuditReportData.fromJson(Map<String, dynamic> json) {
    if (json['annual_audit_reports'] != null) {
      annual_audit_reports_data = <AnnualAuditReportModel>[];
      json['annual_audit_reports'].forEach((v) {
        annual_audit_reports_data!.add(AnnualAuditReportModel.fromJson(v));
      });
    }
  }
}

class AnnualAuditReportModel {
  int? annualAuditReportId;
  String? annualAuditReportTitle;
  String? annualAuditReportText;
  User? user;
  Business? business;
  List<Member>? members;

  AnnualAuditReportModel({this.members,this.annualAuditReportId,this.annualAuditReportTitle,this.annualAuditReportText,this.user,this.business});

  // create new converter
  AnnualAuditReportModel.fromJson(Map<String, dynamic> json) {
    annualAuditReportId = json['id'];
    annualAuditReportText	 = json['annual_audit_report_text'];
    annualAuditReportTitle = json['annual_audit_report_title'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    business = json['business'] != null ? Business.fromJson(json['business']) : null;
    if (json['members'] != null) {
      members = <Member>[];
      json['members'].forEach((v) {
        members!.add(Member.fromJson(v));
      });
    }

  }

}