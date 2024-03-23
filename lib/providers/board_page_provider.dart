import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../models/board_model.dart';
import '../models/boards_model.dart';
import '../models/user.dart';
class BoardPageProvider extends ChangeNotifier{

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

  FlutterSecureStorage storage = const FlutterSecureStorage();
  Boards? boardsData;
  Board _board = Board();
  Board get board => _board;
  void setBoard (Board board) async {
    _board =  board;
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

  Future getListOfBoards(context) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    print(user.businessId);
    var response = await networkHandler.get('/get-list-boards/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-boards form provider response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseBoardsData = responseData['data'];
      boardsData = Boards.fromJson(responseBoardsData);
      log.d(boardsData!.boards!.length);
      notifyListeners();
    } else {
      log.d("get-list-boards form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }

  Future<void> insertBoard(Map<String, dynamic> data)async{
    setLoading(true);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/insert-new-board', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setIsBack(true);
      notifyListeners();
      log.d("insert new board response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseBoardData = responseData['data'];
      _board = Board.fromJson(responseBoardData['board']);
      boardsData!.boards!.add(_board);
      log.d(boardsData!.boards!.length);
      setIsBack(true);
      setLoading(true);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("insert new board response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future getBoardById(int id) async{
    var response = await networkHandler.get('/get-board-byId/$id');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-board-byId form provider response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var boardsData = responseData['data'];
     final Board board = Board.fromJson(boardsData);
     setBoard(board);
      log.d(board!);
      notifyListeners();

    } else {
      log.d("get-board-byId form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }
}