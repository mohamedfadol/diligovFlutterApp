import 'package:flutter/material.dart';
class NavigatorProvider extends ChangeNotifier{
  bool _isCollapsed  = false;

  bool get isCollapsed => _isCollapsed;

  void togglisCollapsed(){
    _isCollapsed = !_isCollapsed;
    notifyListeners();
  }
}