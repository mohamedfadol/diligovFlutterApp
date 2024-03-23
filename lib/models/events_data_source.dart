import 'package:diligov/models/meeting_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventsDataSource extends CalendarDataSource{

  EventsDataSource(List<Meeting> appointments){
    this.appointments = appointments;
  }

  Meeting getMeeting(int index) => appointments![index] as Meeting;

  @override
  DateTime getStartTime(int index) => getMeeting(index).meetingStart!;

  @override
  DateTime getEndTime(int index) => getMeeting(index).meetingEnd!;

  @override
  String getSubject(int index) => getMeeting(index).meetingTitle!;

  @override
  Color getColor(int index) => getMeeting(index).backGroundColor!;

  @override
  int isAllDays(int index) => getMeeting(index).isAllDays!;

  @override
  bool isActive(int index) => getMeeting(index).isActive!;
}