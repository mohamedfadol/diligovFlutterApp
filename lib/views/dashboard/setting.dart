import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/actions_icon_bar_widget.dart';
import '../../widgets/custom_icon.dart';
import '../../widgets/global_search_box.dart';
import '../../widgets/notification_header_list.dart';
import '../../widgets/search_text_form_field.dart';
import '../calenders/calendar_page.dart';
import '../tab_bar_view/member_and_committees.dart';
import '../tab_bar_view/members_view/members_list.dart';
import '../user/profile.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);
  static const routeName = '/setting';

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> with SingleTickerProviderStateMixin {

  final insertBoardFormGlobalKey = GlobalKey<FormState>();
  TabController? defaultTabBarViewController;
  @override
  void initState() {
    // TODO: implement initState
    defaultTabBarViewController = TabController(length: 6, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        titleSpacing: 0,
        // leadingWidth: 25,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          iconSize: 20.0,
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboardHome');
          },
        ),
        title: Container(
          width: 600,
          child: GlobalSearchBox(),
        ),
        actions: [
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
          SizedBox(
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
          SizedBox(
            width: 10,
          ),
          NotificationHeaderList(),
          SizedBox(
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
          SizedBox(
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
          SizedBox(
            width: 10,
          ),
        ],
        bottom: TabBar(
          indicatorWeight: 5,
          enableFeedback: true,
          controller: defaultTabBarViewController,
          // isScrollable: true,
          indicatorColor: Colors.red,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.grey,
          labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.red),
          onTap: (index) {
            print(index);
          },
          tabs: [
            Tab(child: Text("Members & Committees")),
            Tab(child: Text("Settings")),
            Tab(child: Text("Subscriptions")),
            Tab(child: Text("Stats")),
            Tab(child: Text("User Management")),
            Tab(child: Text("Votes & Survey")),

          ],
        ),
      ),
      body: TabBarView(
        controller: defaultTabBarViewController,
        children: [
          MemberAndCommittees(),
          Center(
              child: Container(
                  color: Colors.yellow,
                  child: Text(
                    "hi one",
                    style: TextStyle(color: Colors.green),
                  ))),
          Center(
              child: Container(
                  color: Colors.blueAccent,
                  child: Text(
                    "hi one",
                    style: TextStyle(color: Colors.green),
                  ))),
          Center(
              child: Container(
                  color: Colors.grey,
                  child: Text(
                    "hi one",
                    style: TextStyle(color: Colors.green),
                  ))),
          Center(
              child: Container(

                  color: Colors.black12,
                  child: MembersList(),
              )
          ),
          Center(
              child: Container(
                  color: Colors.brown,
                  child: Text(
                    "state",
                    style: TextStyle(color: Colors.green),
                  ))),
        ],
      ),
    );
  }

}
