import 'package:diligov/models/minutes_model.dart';

class AttendanceBoard {
  int? attendanceBoardId;
  String? attendedName;
  String? position;
  Minute? minute;
  AttendanceBoard({this.attendanceBoardId, this.attendedName, this.position, this.minute,});

  AttendanceBoard.fromJson(Map<String, dynamic> json) {
    attendanceBoardId= json['id'];
    attendedName= json['attended_name'];
    position= json['position'];
    minute = json['minute'] != null ? Minute.fromJson(json['minute']) : null;
  }
}