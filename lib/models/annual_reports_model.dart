import 'package:diligov/models/business_model.dart';
import 'package:diligov/models/meeting_model.dart';
import 'package:diligov/models/member.dart';
import 'package:diligov/models/user.dart';

class AnnualReportData {
  List<AnnualReportsModel>? annual_reports_data;
  AnnualReportData.fromJson(Map<String, dynamic> json) {
    if (json['annual_reports'] != null) {
      annual_reports_data = <AnnualReportsModel>[];
      json['annual_reports'].forEach((v) {
        annual_reports_data!.add(AnnualReportsModel.fromJson(v));
      });
    }
  }
}

class AnnualReportsModel {
  int? annualReportId;
  String? annualReportName;
  String? annualReportDate;
  String? annualReportFile;
  User? user;
  Business? business;
  Meeting? meeting;
  List<Member>? members;

  AnnualReportsModel({this.members,this.annualReportId,this.annualReportName,this.annualReportDate,this.annualReportFile,this.user,this.business,this.meeting});

  // create new converter
  AnnualReportsModel.fromJson(Map<String, dynamic> json) {
    annualReportId = json['id'];
    annualReportFile = json['annual_report_file'];
    annualReportName = json['annual_report_name'];
    annualReportDate = json['annual_report_date'];
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