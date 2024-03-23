import 'package:flutter/material.dart';

class LightDarkMode with ChangeNotifier {
  bool darkEnabled = false;

  bool get darkModeIsEnabled => darkEnabled;

  void toggleDarkMode(){
    darkEnabled = !darkEnabled;
    print(darkEnabled);
    notifyListeners();
  }

}