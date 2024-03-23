import 'dart:convert';

import 'package:diligov/core/domains/app_uri.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import 'package:http/http.dart' as http;
import '../models/board_model.dart';
import '../models/boards_model.dart';
import '../models/searchable.dart';
import '../models/user.dart';
import 'package:diligov/models/committee_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
class GlobalSearchProvider  extends ChangeNotifier{

  var log = Logger();
  static FlutterSecureStorage storage = const FlutterSecureStorage();
  static String baseApi = "${AppUri.baseApi}";
  static User user = User();
  static NetworkHandler networkHandler = NetworkHandler();
  bool isLoading = false;
  SearchableData? searchableData;


  final  TextEditingController controller = TextEditingController();

  // Method to clear the text field
  void clearText() {
    controller.clear();
    notifyListeners(); // Notify listeners to rebuild the relevant UI parts
  }

  // Getter to determine which icon to show
  Icon get icon => controller.text.isEmpty
      ? const Icon(Icons.search)
      : const Icon(Icons.clear);

  // Dispose controller when provider is disposed
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  static Future<List<Committee>> getListOfSearchTextSuggestions(String query) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    print(user.businessId);
    final response = await networkHandler.get('/get-list-committees/${user.businessId.toString()}');
    if(response.statusCode == 200){
      var responseData = jsonDecode(response.body);
      var committeesData = responseData['data'];
      final List committees = committeesData['committees'] ;
      return committees!.map((committee) => Committee.fromJson(committee)).where((committee){
        final committeeNameLowerCase = committee.committeeName!.toLowerCase();
        final queryLowerCase = query!.toLowerCase();
        print(query);
        return committeeNameLowerCase!.contains(queryLowerCase!) ;
      }).toList();
    }else{
      throw Exception();
    }
  }

  static Future<List<SearchableModel>?> extractTextsWithinAllFilesDocuments(String query) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    Map<String, dynamic> data = {"searchText":query.trim()};
    if( !isWhitespace(query)){
      final response = await networkHandler.post1('/get-all-extract-text', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("get-all-extract-text response statusCode == 200");
        var responseData = json.decode(response.body) ;
        var searchableResponseData = responseData['data'] ;
        final List searchableData = searchableResponseData['files'] ;
        // print(searchableData);
        return searchableData!.map((searchable) => SearchableModel.fromJson(searchable)).where((searchable){
          final TextStringLowerCase = searchable.textString?.toLowerCase() ?? searchable.fileDir!;
          final queryLowerCase = query!.toLowerCase();
          // print(searchable.fileDir);
          // print(query);
          searchable.textString  = query;
          print('searchable textString searchable textString ${searchable.textString}');
          return TextStringLowerCase!.contains(searchable.fileDir!) ;
        }).toList();
      } else {
        print(json.decode(response.body)['message']);
        throw Exception(DiagnosticsNode.message(json.decode(response.body)['message']));
      }
    }
      return null;
  }

  static bool isWhitespace(String str) {
    // Trim the string to remove leading and trailing whitespace
    // and check if the resulting string is empty
    return str.trim().isEmpty;
  }


}















