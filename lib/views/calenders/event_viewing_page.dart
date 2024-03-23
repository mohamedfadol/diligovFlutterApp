import 'package:diligov/views/calenders/event_editing_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/meeting_model.dart';
import '../../providers/meeting_page_provider.dart';
class EventViewingPage extends StatelessWidget {
  final Meeting event;
  const EventViewingPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: CloseButton(),
      actions: buildViewingActions(context, event),
    ),
    body: ListView(
      padding: EdgeInsets.all(32),
      children: [

        Text(event.meetingTitle!,style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
        SizedBox(height: 20,),
        Text(event.meetingDescription!,style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
        SizedBox(height: 20,),
        buildDateTime(event),

      ],
    ),
  );

  Widget buildDateTime(Meeting event){
    return Column(
      children: [
          buildDate(event.isActive! ? 'All-day active' : 'From', event.meetingStart!),
        if(!event.isActive!) buildDate('To', event.meetingEnd!)
      ],
    );
  }

  Widget buildDate(String meetingTitle, DateTime date){
      return  Row(
          children: [
            Text(meetingTitle),
            const SizedBox(width: 20,),
            Text(date.toString()),
          ],
      );
  }

  List<Widget> buildViewingActions(BuildContext context,Meeting event) => [
      IconButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      onPressed: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => CommitteeEventEditingPage(event: event)
          )
      ) ,
      icon: const Icon(Icons.edit,color: Colors.green,size:25)
    ),

    IconButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: () {
          final provider = Provider.of<MeetingPageProvider>(context,listen: false);
          provider.deleteMeeting(event);
          Navigator.of(context).pop();
        } ,
        icon: const Icon(Icons.delete,color: Colors.red,size:25)
    ),
  ];

}
