import 'dart:math';
import 'package:diligov/providers/menus_provider.dart';
import 'package:diligov/widgets/menu_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../circle_menus/committ_circle_menu.dart';
import '../core/constants/constant_name.dart';

class CircularCommitteeWidget extends StatefulWidget {
  const CircularCommitteeWidget({super.key});

  @override
  State<CircularCommitteeWidget> createState() => _CircularCommitteeWidgetState();
}
Map<String,String> iconsMap = {
  "Committee": "icons/committee_circle_menu_icons/committee_icon.png"
};
class _CircularCommitteeWidgetState extends State<CircularCommitteeWidget> {
  Map<String,Widget> circleMenusMap = {
    "Committee": CommitteeCircleMenu(),
  };

  @override
  Widget build(BuildContext context) {
    var currentWidget = context.watch<MenusProvider>().getCurrentMenu;

    return currentWidget != null ? context.watch<MenusProvider>().getCurrentMenu : Flow(
      delegate: FlowMenuDelegate(),
      //you can change the buttons icons and name from here
      children: <List<dynamic>>[
        ["icons/homepage_circle_menu_icons/risk_icon.png","Committee","/Risk"],
        ["icons/homepage_circle_menu_icons/shareholders_icon.png","Committee","/Shareholders"],
        ["icons/homepage_circle_menu_icons/entities_icon.png","Committee","/Entities"],
        ["icons/homepage_circle_menu_icons/board_icon.png","Committee","/Committee"],
        ["icons/homepage_circle_menu_icons/reports_icon.png","Committee",ConstantName.reportsListViews],
        ["icons/homepage_circle_menu_icons/minutes_icon.png","Committee",ConstantName.minutesMeetingList],
        ["icons/homepage_circle_menu_icons/compliance_icon.png","Committee","/Compliance"],
        ["icons/homepage_circle_menu_icons/legal_contracts_icon.png","Committee","/LegalContracts"],
        ["icons/homepage_circle_menu_icons/company_information_icon.png","Company Information","/CompanyInformation"],
        ["icons/homepage_circle_menu_icons/environment_governance_icon.png","Committee","/EnvironmentSustainabilityGovernance"],
        ["icons/homepage_circle_menu_icons/financials_icon.png","Financials","Financials"],
        ["icons/homepage_circle_menu_icons/kpi_icon.png","KPI","KPI"],
        ["icons/homepage_circle_menu_icons/delegation_authority_icon.png","Delegate Of Author","/DelegationOfAuthority"],
        ["icons/homepage_circle_menu_icons/audit_icon.png","Audit","Audit"],

      ].map<Widget>(buildFAB).toList(),
    );
  }
  Widget buildFAB(List<dynamic> list) => SizedBox(
    height: 100,
    width: 100,
    child: GestureDetector(
      onTap: () {
          Navigator.pushReplacementNamed(context, list[2]);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0,top: 10),
        // color: Colors.red,
        child: Column(
          children: [
            Image.asset(list[0],height: 40.0,),
            MenuButton(text: list[1],fontSize:10.0,fontWeight: FontWeight.bold)
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
    final yStart = size.height/2 - 45;
    final n = context.childCount;
    for(int i = 0 ; i < n ; i++) {
      const radius = 260;
      final theta = i * pi * 0.5/ (n - 2);
      //to change the circle size you can change the theta inside the Cos and Sin but its limited based on qunantity of buttons
      final x = xStart - (radius) * cos(3.5*theta);
      final y = yStart - (radius) * sin(3.5*theta);
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

