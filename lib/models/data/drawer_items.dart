import 'package:diligov/models/drawer_item.dart';
import 'package:flutter/material.dart';

    final itemsFirst = [
      DrawerItem(title: "Home",icon: Icons.home_filled),
      DrawerItem(title: "Dashboard",icon: Icons.list_alt_rounded),
      DrawerItem(title: "My Notes",icon: Icons.assignment),
      DrawerItem(title: "My Singed Docs",icon: Icons.file_open_rounded),
      DrawerItem(title: "Votes & Surveys",icon: Icons.back_hand_rounded),
      DrawerItem(title: "Statistics",icon: Icons.bar_chart_outlined),
      // DrawerItem(title: "Company Information",icon: Icons.error_outline_sharp),
      DrawerItem(title: "Support",icon: Icons.link_outlined),
    ];

final itemsLast = [
  // DrawerItem(title: "Support",icon: Icons.logout_outlined),
  DrawerItem(title: "Logout",icon: Icons.logout_outlined),
];
