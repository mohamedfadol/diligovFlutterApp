import 'dart:convert';

import 'package:diligov/models/agenda_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../models/meeting_model.dart';
import '../models/user.dart';
class AgendaPageProvider extends ChangeNotifier{

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();
  FlutterSecureStorage storage = const FlutterSecureStorage();

  Agendas? listAgenda;

  Agenda _agenda = Agenda();
  Agenda get agenda => _agenda;
  void setAgenda(Agenda agenda) async {
    _agenda =  agenda;
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



}