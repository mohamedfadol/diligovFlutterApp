import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../NetworkHandler.dart';
import '../models/annual_reports_model.dart';
import '../models/user.dart';

class AnnualReportsProviderPage extends ChangeNotifier{
  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

  AnnualReportData? annual_reports_data;
  AnnualReportsModel _annual_report = AnnualReportsModel();
  AnnualReportsModel get annual_report => _annual_report;
  void setAnnualReport(AnnualReportsModel annual_report) async {
    _annual_report =  annual_report;
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


  Future getListOfAnnualReports(data)async{
    var response = await networkHandler.post1('/get-list-annual-reports',data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-annual-reports response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var annualReportsResponseData = responseData['data'];
      annual_reports_data = AnnualReportData.fromJson(annualReportsResponseData);
      notifyListeners();
    } else {
      log.d("get-list-annual-reports response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> insertAnnualReport(Map<String, dynamic> data)async{
    setLoading(true);
    var response = await networkHandler.post1('/create-new-annual-report', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("create-new-annual-report response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseAnnualReportsData = responseData['data'];
      _annual_report = AnnualReportsModel.fromJson(responseAnnualReportsData['annual_report']);
      annual_reports_data!.annual_reports_data!.add(_annual_report);
      log.d(annual_reports_data!.annual_reports_data!.length);
      setIsBack(true);
    } else {
      log.d("create-new-annual-report response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
    setLoading(false);
  }

  Future<void> removeAnnualReport(AnnualReportsModel deleteAnnualReport)async{
    final index = annual_reports_data!.annual_reports_data!.indexOf(deleteAnnualReport);
    AnnualReportsModel annual_report = annual_reports_data!.annual_reports_data![index];
    String annualReportId =  annual_report.annualReportId.toString();
    Map<String, dynamic> data = {"annual_report_id": annualReportId};
    var response = await networkHandler.post1('/delete-annual-report-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("deleted annual-report-by-id response statusCode == 200");
      annual_reports_data!.annual_reports_data!.remove(annual_report);
      log.d(annual_reports_data!.annual_reports_data!.length);
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
      log.d("sign annual-report response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseAnnualReportData = responseData['data'];
      _annual_report = AnnualReportsModel.fromJson(responseAnnualReportData['annual_report']);
      setAnnualReport(_annual_report);
      setIsBack(true);
      result = {'status': true, 'message': 'Successful', 'annual_report': _annual_report};
    } else {
      log.d("sign annual_report response statusCode unknown");
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