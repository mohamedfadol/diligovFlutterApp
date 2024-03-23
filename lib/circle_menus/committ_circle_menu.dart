import 'dart:convert';
import 'dart:math';
import 'package:diligov/NetworkHandler.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/constant_name.dart';
import '../models/user.dart';
import '../widgets/menu_button.dart';

class CommitteeCircleMenu extends StatefulWidget {

  @override
  State<CommitteeCircleMenu> createState() => _CommitteeCircleMenuState();
}

Map<String,String> iconsMap = {
  "Committees": "icons/committee_circle_menu_icons/committee_icon.png"
};

class _CommitteeCircleMenuState extends State<CommitteeCircleMenu> {
  var log = Logger();
  NetworkHandler networkHandler = NetworkHandler();
  User user = User();
  late List<dynamic> listOfCommitteesData = [];
  Future<List<dynamic>> getListCommittees() async {
    var listOfCommitteesData;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    var response = await networkHandler
        .get('/get-all-committees/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-committees response statusCode == 200");
      var responseData = json.decode(response.body);
      var CommitteesData = responseData['data'];
      setState(() {
        listOfCommitteesData = CommitteesData['committees'];
        log.d(listOfCommitteesData);
      });
    } else {
      log.d("get-list-committees response statusCode unknown");
      print(json.decode(response.body)['message']);
    }
    return listOfCommitteesData;
  }
  @override
  void initState() {
    // TODO: implement initState
    getListCommittees();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Flow(
      delegate: FlowMenuDelegate(),
      //you can change the buttons icons or name and name from here
      children: <List<dynamic>>[
        ["icons/committee_circle_menu_icons/action_tracker_icon.png","Action Tracker",ConstantName.actionsTrackerList],
        ["icons/committee_circle_menu_icons/board_evaluation_icon.png","Evaluation",ConstantName.evaluationListViews],
        ["icons/committee_circle_menu_icons/annual_calendar_icon.png","Annual Calendar",ConstantName.committeeCalendarPage],
        ["icons/committee_circle_menu_icons/resolutions_icon.png","Resolutions",ConstantName.committeeResolutionsListViews],
        ["icons/committee_circle_menu_icons/agenda_minutes_icon.png","Minutes",ConstantName.minutesMeetingList],
        ["icons/homepage_circle_menu_icons/reports_icon.png","Annual Report",ConstantName.annualReportListView],
        ["icons/homepage_circle_menu_icons/financials_icon.png","Financials",ConstantName.financialListViews],
        ["icons/homepage_circle_menu_icons/company_information_icon.png","Committee Information",ConstantName.calendarListView],
        ["icons/homepage_circle_menu_icons/kpi_icon.png","KPI",ConstantName.calendarListView],
        //Center Icon

      ].map<Widget>(buildFAB).toList(),
    );
  }

  Widget buildFAB(List<dynamic> list) => SizedBox(
    height: 100,
    width: 100,
    child: GestureDetector(
      onTap: (){
        Navigator.pushReplacementNamed(context, list[2],arguments: 'committees');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0,top: 10),
        // color: Colors.green,
        child: Column(
          children: [
            // index 0 => The icon or img name from line 22
            // index 1 => the name of the button
            Image.asset(list[0],height: 40.0,),
            MenuButton(text: list[1],fontSize:10.0,fontWeight: FontWeight.bold),
          ],
        ),
      ),
    ),
  );

}


class FlowMenuDelegate extends FlowDelegate {
  @override
  void paintChildren(FlowPaintingContext context){
    final size = context.size;
    final xStart = size.width/2 - 45;
    final yStart = size.height/2 - 30;
    final n = context.childCount;
    for(int i = 0 ; i < n ; i++) {
      const radius = 250;
      final theta = i * pi * 0.5/ (n - 2);
      //to change the circle size you can change the theta inside the Cos and Sin but its limited based on qunantity of buttons
      final x = xStart - (radius) * cos(3.4*theta);
      final y = yStart - (radius) * sin(3.4*theta);
      context.paintChild(
        i,
        transform: Matrix4.identity()
          ..translate(x,y,0),
      );
    }
  }
  @override
  bool shouldRepaint(FlowMenuDelegate oldDelegate) => false;
}


