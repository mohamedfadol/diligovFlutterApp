import 'package:diligov/widgets/actions_icon_bar_widget.dart';
import 'package:diligov/widgets/custom_icon.dart';
import 'package:diligov/widgets/drowpdown_list_languages_widget.dart';
import 'package:diligov/widgets/global_search_box.dart';
import 'package:diligov/widgets/notification_header_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../views/calenders/calendar_page.dart';
import '../views/dashboard/setting.dart';
import '../views/user/profile.dart';

TabController? defaultTabBarViewController;

PreferredSize Header(context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  return PreferredSize(
    preferredSize: const Size.fromHeight(70),
    child: AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0.0,
      titleSpacing: 20,
      // leadingWidth: 25,
      leading:  ActionsIconBarWidget(
        onPressed: () { Navigator.pushReplacementNamed(context, '/dashboardHome'); },
        buttonIcon: Icons.arrow_back_ios,
        buttonIconColor: Theme.of(context).iconTheme.color,
        buttonIconSize: 20,
        boxShadowColor: Colors.grey,
        boxShadowBlurRadius: 2.0,
        boxShadowSpreadRadius: 0.4,
        containerBorderRadius: 30.0,
        containerBackgroundColor: Colors.white,
      ),
      title: SizedBox(
        width: 600,
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey,
                      blurRadius: 2.0,
                      spreadRadius: 0.4)
                ]),
            child: GlobalSearchBox()
        ),
      ),
      actions: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: const [
                BoxShadow(
                    color: Colors.grey, blurRadius: 2.0, spreadRadius: 0.4)
              ]),
          child: Center(child: const DropdownListLanguagesWidget()),
        ),
        const SizedBox(
          width: 10,
        ),
        ActionsIconBarWidget(
          onPressed: () { print("calendar");Navigator.pushReplacementNamed(context, CalendarPage.routeName); },
          buttonIcon: Icons.calendar_month_outlined,
          buttonIconColor: Theme.of(context).iconTheme.color,
          buttonIconSize: 30,
          boxShadowColor: Colors.grey,
          boxShadowBlurRadius: 2.0,
          boxShadowSpreadRadius: 0.4,
          containerBorderRadius: 30.0,
          containerBackgroundColor: Colors.white,
        ),
        const SizedBox(
          width: 10,
        ),
        ActionsIconBarWidget(
          onPressed: () {
            bool value = themeProvider.isDarkMode ? false : true;
            final provider = Provider.of<ThemeProvider>(context, listen: false);
            provider.toggleTheme(value);
          },
          buttonIcon: Icons.brightness_medium,
          buttonIconColor: Theme.of(context).iconTheme.color,
          buttonIconSize: 30,
          boxShadowColor: Colors.grey,
          boxShadowBlurRadius: 2.0,
          boxShadowSpreadRadius: 0.4,
          containerBorderRadius: 30.0,
          containerBackgroundColor: Colors.white,
        ),
        const SizedBox(
          width: 10,
        ),
        NotificationHeaderList(),
        const SizedBox(
          width: 10,
        ),
        ActionsIconBarWidget(
          onPressed: () {
            Navigator.pushReplacementNamed(context, ProfileUser.routeName);
          },
          buttonIcon: Icons.manage_accounts_outlined,
          buttonIconColor: Theme.of(context).iconTheme.color,
          buttonIconSize: 30,
          boxShadowColor: Colors.grey,
          boxShadowBlurRadius: 2.0,
          boxShadowSpreadRadius: 0.4,
          containerBorderRadius: 30.0,
          containerBackgroundColor: Colors.white,
        ),
        const SizedBox(
          width: 10,
        ),
        ActionsIconBarWidget(
          onPressed: () {
            Navigator.pushReplacementNamed(context, Setting.routeName);
          },
          buttonIcon: Icons.brightness_low,
          buttonIconColor: Theme.of(context).iconTheme.color,
          buttonIconSize: 30,
          boxShadowColor: Colors.grey,
          boxShadowBlurRadius: 2.0,
          boxShadowSpreadRadius: 0.4,
          containerBorderRadius: 30.0,
          containerBackgroundColor: Colors.white,
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    ),
  );

}
