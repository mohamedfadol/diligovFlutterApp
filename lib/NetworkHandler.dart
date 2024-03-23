import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'core/domains/app_uri.dart';

class NetworkHandler {
  String baseurl = '${AppUri.baseApi}';
  var log = Logger();
  FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<http.Response> get(String url) async {
    String token = (await storage.read(key: "token"))!;
    url = formater(url);
    var response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-type": "application/json",
        "Authorization": "Bearer $token",
        "Connection": "Keep-Alive"
      },
    );
    // print(json.decode(response.body));
    log.i(response.statusCode);
    return response;
  }

  Future<http.Response> post(String url, Map<String, String> body) async {
    String token = (await storage.read(key: "token"))!;
    url = formater(url);
    var response = await http.post(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-type": "application/json",
        "Authorization": "Bearer $token",
        "Connection": "Keep-Alive"
      },
      body: json.encode(body),
    );
    // log.d(json.decode(response.body));
    return response;
  }

  Future<http.Response> patch(String url, Map<String, String> body) async {
    String token = (await storage.read(key: "token"))!;
    url = formater(url);
    log.d(body);
    var response = await http.patch(
      Uri.parse(url),
      headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token",
          "Connection": "Keep-Alive"
      },
      body: json.encode(body),
    );
    return response;
  }

  Future<http.Response> post1(String url, var body) async {
    String token = (await storage.read(key: "token"))!;
    url = formater(url);
    log.d(body);
    var response = await http.post(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-type": "application/json",
        "Authorization": "Bearer $token",
        "Connection": "Keep-Alive"
      },
      body: json.encode(body),
    );
    return response;
  }

  Future<http.StreamedResponse> patchImage(String url,String fielding, String filepath) async {
    url = formater(url);
    String token = (await storage.read(key: "token"))!;
    // var stream = new http.ByteStream(fielding!.openRead());
    // stream.cast();
    var length = await fielding!.length;
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['fielding'] = "fielding";
    request.fields['field_name'] = "field_value";
    request.fields['folder'] = "folder";
    var folder = await http.MultipartFile.fromPath("folder", filepath, filename: fielding);
    request.files.add(folder);
    request.headers.addAll({
      "Content-type": "multipart/form-data",
      "Authorization": "Bearer $token",
      "Connection": "Keep-Alive"
    });
    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var result = String.fromCharCodes(responseData);
    print(result);
    return response;
  }

  String formater(String url) {
    return baseurl + url;
  }

  NetworkImage getImage(String imageName) {
    String url = formater("/uploads//$imageName.jpg");
    return NetworkImage(url);
  }
}