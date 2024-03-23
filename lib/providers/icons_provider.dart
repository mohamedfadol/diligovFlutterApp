import 'package:flutter/material.dart';

class IconsProvider with ChangeNotifier{
  String path = "images/diligov_icon.png";
  String get getIconPath => path;

  void changePath(String newPath) {
    path = newPath;
    notifyListeners();
  }

}

