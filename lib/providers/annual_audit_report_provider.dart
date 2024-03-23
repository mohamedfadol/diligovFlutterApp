import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../NetworkHandler.dart';
import '../models/annual_audit_report_model.dart';
import '../models/user.dart';

class AnnualAuditReportProvider extends ChangeNotifier{

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

  AnnualAuditReportData? annual_audit_reports_data;
  AnnualAuditReportModel _annual_audit_report = AnnualAuditReportModel();
  AnnualAuditReportModel get annual_audit_report => _annual_audit_report;
  void setAnnualAuditReport(AnnualAuditReportModel annual_audit_report) async {
    _annual_audit_report =  annual_audit_report;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  void setLoading(value) async {
    _loading =  value;
    notifyListeners();
  }

  bool _isBack = false;
  bool get isBack => _isBack;
  void setIsBack(value) async {
    _isBack =  value;
    notifyListeners();
  }

  Future getListOfAnnualAuditReports(data)async{
    var response = await networkHandler.post1('/get-list-annual-audit-reports',data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-annual_audit_reports response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var annualReportsResponseData = responseData['data'];
      annual_audit_reports_data = AnnualAuditReportData.fromJson(annualReportsResponseData);
      notifyListeners();
    } else {
      log.d("get-list-annual_audit_reports response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> insertAnnualAuditReport(Map<String, dynamic> data)async{
    setLoading(true);
    var response = await networkHandler.post1('/create-new-annual-report', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("create-new-annual-audit_report response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseAnnualReportsData = responseData['data'];
      _annual_audit_report = AnnualAuditReportModel.fromJson(responseAnnualReportsData['annual_report']);
      annual_audit_reports_data!.annual_audit_reports_data!.add(_annual_audit_report);
      log.d(annual_audit_reports_data!.annual_audit_reports_data!.length);
      setIsBack(true);
    } else {
      log.d("create-new-annual-audit_report response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
    setLoading(false);
  }

  Future<void> removeAnnualAuditReport(AnnualAuditReportModel deleteAnnualReport)async{
    final index = annual_audit_reports_data!.annual_audit_reports_data!.indexOf(deleteAnnualReport);
    AnnualAuditReportModel annual_audit_report = annual_audit_reports_data!.annual_audit_reports_data![index];
    String annualAuditReportId =  annual_audit_report.annualAuditReportId.toString();
    Map<String, dynamic> data = {"annual_audit_report_id": annualAuditReportId};
    var response = await networkHandler.post1('/delete-annual-report-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("deleted annual-audit_report-by-id response statusCode == 200");
      annual_audit_reports_data!.annual_audit_reports_data!.remove(annual_audit_report);
      log.d(annual_audit_reports_data!.annual_audit_reports_data!.length);
      setIsBack(true);
    } else {
      log.d(json.decode(response.body)['message']);
      log.d(response.statusCode);
      setLoading(false);
      setIsBack(false);
    }
    setLoading(false);
  }

  Future<Map<String, dynamic>>  makeSignedAnnualReport(Map<String, dynamic> data)async{
    var result;
    setLoading(true);
    var response = await networkHandler.post1('/make-sign-annual-report', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("sign annual-audit-report response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseAnnualReportData = responseData['data'];
      _annual_audit_report = AnnualAuditReportModel.fromJson(responseAnnualReportData['annual_report']);
      setAnnualAuditReport(_annual_audit_report);
      setIsBack(true);
      result = {'status': true, 'message': 'Successful', 'annual_audit_report': _annual_audit_report};
    } else {
      log.d("sign annual_audit-report response statusCode unknown");
      log.d(response.statusCode);
      log.i(json.decode(response.body)['message']);
      setLoading(false);
      setIsBack(false);
      result = {'status': false,'message': json.decode(response.body)['message']};
    }
    setLoading(false);
    return result;
  }




}