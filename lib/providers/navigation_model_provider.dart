import 'package:flutter/cupertino.dart';

class NavigationModelProvider with ChangeNotifier {
  String _lastPage = '/dashboardHome';

  String get lastPage => _lastPage;

  void visitPage(String routeName) {
    _lastPage = routeName;
    notifyListeners();
  }
}