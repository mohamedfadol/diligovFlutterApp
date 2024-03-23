import 'package:diligov/views/dashboard/dashboard_home_screen.dart';
import 'package:flutter/material.dart';
class ButtonActionsDropdownList extends StatelessWidget {
  const ButtonActionsDropdownList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PopupMenuButton<int>(icon: Icon(Icons.settings),
        onSelected: (item) => onSelected(context, item),
          itemBuilder: (context) => [
        PopupMenuItem<int>(value: 0,child: Text('Setting')),
        PopupMenuItem<int>(value: 1,child: Text('LogOut')),
        PopupMenuItem<int>(value: 2,child: Text('Home')),
        PopupMenuItem<int>(value: 3,child: Text('Notification')),
      ]),
    );
  }

 void onSelected(BuildContext context, int item) {
    switch(item){
      case 0:
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => DashboardHomeScreen()));
      break;

      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DashboardHomeScreen()));
        break;

      case 2:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DashboardHomeScreen()));
        break;

      case 3:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DashboardHomeScreen()));
        break;
    }
  }
}
