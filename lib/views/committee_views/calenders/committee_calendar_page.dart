import 'package:diligov/views/committee_views/calenders/committee_calendar_widget.dart';
import 'package:diligov/views/committee_views/calenders/committee_event_editing_page.dart';
import 'package:flutter/material.dart';
import '../../../widgets/appBar.dart';
class CommitteeCalendarPage extends StatefulWidget {
  const CommitteeCalendarPage({Key? key}) : super(key: key);
  static const routeName = '/CommitteeCalendarPage';


  @override
  State<CommitteeCalendarPage> createState() => _CommitteeCalendarPageState();
}

class _CommitteeCalendarPageState extends State<CommitteeCalendarPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: Header(context),
    body: const CalendarWidget(),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.red,
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const CommitteeEventEditingPage(),)
      ),
      child: const Icon(Icons.add,color: Colors.white,),
    ),
  );
}
