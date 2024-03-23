import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
class Utils{
  static String toDateTime(DateTime dateTime){
    final date = DateFormat.yMMMEd().format(dateTime);
    final time = DateFormat.Hm().format(dateTime);
    return '$date $time';
  }

  static String toDate(DateTime dateTime){
    final date = DateFormat.yMMMEd().format(dateTime);
    return '$date';
  }

  static String toTime(DateTime dateTime){
    final time = DateFormat.Hm().format(dateTime);
    return '$time';
  }

  static DateTime removeTime(DateTime dateTime) =>
     DateTime(dateTime.year, dateTime.month,dateTime.day);


  static String base64String(Uint8List data) {
    return base64Encode(data);
  }

  static  imageFrom64BaseString(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.contain,
    );
  }

  static String convertStringToDateFunction(String date){
    DateTime parseDate =
    new DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(date);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat('yyyy-MM-dd hh:mm a');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  }
}