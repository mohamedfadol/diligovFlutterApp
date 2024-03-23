import 'dart:convert';

import 'package:diligov/circle_menus/board_circle_menu.dart';
import 'package:diligov/circle_menus/committ_circle_menu.dart';
import 'package:diligov/models/user.dart';
import 'package:diligov/providers/committee_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenusProvider with ChangeNotifier {

  var menu = null;
  String iconName = "Home";

  dynamic get getCurrentMenu => menu;
  String get getIconName => iconName;

  void backToHomeMenu(){
    menu = null;
    notifyListeners();
  }

  Map<String,Widget> menusMap = {
    "Board" : BoardCircleMenu(),
    "Committees" : CommitteeCircleMenu(),
  };




  void changeMenu(String chosenMenu){
    menu = menusMap[chosenMenu];
    notifyListeners();
  }

  void changeIconName(String newIconName){
    iconName = newIconName;
    notifyListeners();
  }


}