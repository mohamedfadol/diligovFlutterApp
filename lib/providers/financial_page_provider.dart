import 'dart:convert';

import 'package:diligov/NetworkHandler.dart';
import 'package:diligov/models/financial_model.dart';
import 'package:diligov/models/user.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class FinancialPageProvider extends ChangeNotifier{

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

  FinancialData? financialData;
  FinancialModel _financial = FinancialModel();
  FinancialModel get financial => _financial;
  void setFinancial(FinancialModel financial) async {
    _financial =  financial;
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

  Future getListOfFinancials(data)async{
    var response = await networkHandler.post1('/get-list-financials',data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-financials response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var financialsResponseData = responseData['data'];
      financialData = FinancialData.fromJson(financialsResponseData);
      notifyListeners();
    } else {
      log.d("get-list-financials response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> insertFinancial(Map<String, dynamic> data)async{
    setLoading(true);
    var response = await networkHandler.post1('/create-new-financial', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("create-new-financial response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseFinancialData = responseData['data'];
      _financial = FinancialModel.fromJson(responseFinancialData['financial']);
      financialData!.financials!.add(_financial);
      log.d(financialData!.financials!.length);
      setIsBack(true);
    } else {
      log.d("create-new-financial response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
    setLoading(false);
  }

  Future<void> removeFinancial(FinancialModel deleteFinancial)async{
    final index = financialData!.financials!.indexOf(deleteFinancial);
    FinancialModel financial = financialData!.financials![index];
    String financialId =  financial.financialId.toString();
    Map<String, dynamic> data = {"financial_id": financialId};
    var response = await networkHandler.post1('/delete-financial-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("deleted minute response statusCode == 200");
      financialData!.financials!.remove(financial);
      log.d(financialData!.financials!.length);
      setIsBack(true);
    } else {
      log.d(json.decode(response.body)['message']);
      log.d(response.statusCode);
      setLoading(false);
      setIsBack(false);
    }
    setLoading(false);
  }

  Future<Map<String, dynamic>>  makeSignedFinancial(Map<String, dynamic> data)async{
    var result;
    setLoading(true);
    var response = await networkHandler.post1('/make-sign-financial', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("sign financial response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseFinancialData = responseData['data'];
      _financial = FinancialModel.fromJson(responseFinancialData['financial']);
      setFinancial(_financial);
      setIsBack(true);
      result = {'status': true, 'message': 'Successful', 'financial': _financial};
    } else {
      log.d("sign financial response statusCode unknown");
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