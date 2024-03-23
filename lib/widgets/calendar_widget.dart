import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../NetworkHandler.dart';
import '../models/events_data_source.dart';
import '../models/meeting_model.dart';
import '../models/user.dart';
import '../providers/meeting_page_provider.dart';
import '../views/calenders/task_widget.dart';
class CalendarWidget extends StatefulWidget {
  const CalendarWidget({Key? key}) : super(key: key);
  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  CalendarController calendarController = CalendarController();
  CalendarView calendarView = CalendarView.month;
  @override
  Widget build(BuildContext context) {
    return Consumer<MeetingPageProvider>(
        builder: (context, provider, child) {
          if (provider.dataOfMeetings?.meetings == null) {
            provider.getListOfMeetings(context);

            // return buildLoadingSniper();
          }
           return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.red,
                          // side: BorderSide(width: 5.0, color: Colors.white70),
                        ),
                        onPressed: () =>
                            setState(() {
                              calendarView = CalendarView.month;
                              calendarController.view = calendarView;
                            }),
                        child: const Text('Month View', style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),)
                    ),
                    const SizedBox(width: 8.0,),
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.red,
                          // side: BorderSide(width: 5.0, color: Colors.white70),
                        ),
                        onPressed: () =>
                            setState(() {
                              calendarView = CalendarView.week;
                              calendarController.view = calendarView;
                            }),
                        child: const Text('Week View', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white),)),
                    const SizedBox(width: 8.0,),
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.red,
                          // side: BorderSide(width: 5.0, color: Colors.white70),
                        ),
                        onPressed: () =>
                            setState(() {
                              calendarView = CalendarView.day;
                              calendarController.view = calendarView;
                            }),
                        child: const Text('Day View', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white),)),
                  ],
                ),
                Expanded(
                  child: SfCalendar(
                    headerStyle: CalendarHeaderStyle(
                      backgroundColor: Colors.white70,
                    ),
                    controller: calendarController,
                    view: calendarView,
                    dataSource: provider?.dataOfMeetings?.meetings == null
                        ? null
                        : EventsDataSource(provider.dataOfMeetings!.meetings!),
                    todayHighlightColor: Colors.red,
                    monthViewSettings: const MonthViewSettings(
                        appointmentDisplayMode: MonthAppointmentDisplayMode
                            .appointment, showAgenda: false),
                    initialSelectedDate: DateTime.now(),
                    backgroundColor: Colors.white70,
                    showNavigationArrow: true,
                    onLongPress: (details) {
                      provider.setDate(details.date!);
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => const TaskWidget(),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}
