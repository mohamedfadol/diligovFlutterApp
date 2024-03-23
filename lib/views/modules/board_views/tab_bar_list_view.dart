import 'package:diligov/views/user/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/search_text_form_field.dart';
import '../../boards_views/boards_list_views.dart';
import '../../calenders/calendar_page.dart';
import '../../committee_views/committee_list.dart';
import '../../dashboard/setting.dart';
class BoardListView extends StatefulWidget {
  const BoardListView({Key? key}) : super(key: key);
  static const routeName = '/BoardListView';

  @override
  State<BoardListView> createState() => _BoardListViewState();
}

class _BoardListViewState extends State<BoardListView>  with SingleTickerProviderStateMixin {
  TabController? defaultTabBarViewController;
  @override
  void initState() {
    // TODO: implement initState
    defaultTabBarViewController = TabController(length: 5, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        // elevation: 0.0,
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
          child: Row(
            children: [
              Expanded(child: SearchTextFormField(hintText: "Search")),
              SizedBox(
                width: 15,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 2.0,
                          spreadRadius: 0.4)
                    ]),
                child: IconButton(
                  icon: CustomIcon(
                    icon: Icons.arrow_forward_ios,
                    size: 20,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    // ...
                  },
                ),
              ),
            ],
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
            child: IconButton(
              icon: CustomIcon(
                icon: Icons.calendar_month_outlined,
                size: 30,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                print("calendar");
                Navigator.pushReplacementNamed(context, CalendarPage.routeName);
              },
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey, blurRadius: 2.0, spreadRadius: 0.4)
                ]),
            child: IconButton(
              icon: CustomIcon(
                icon: Icons.brightness_medium,
                size: 30,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                bool value = themeProvider.isDarkMode ? false : true;
                final provider =
                Provider.of<ThemeProvider>(context, listen: false);
                provider.toggleTheme(value);
              },
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey, blurRadius: 2.0, spreadRadius: 0.4)
                ]),
            child: IconButton(
              icon: CustomIcon(
                icon: Icons.notifications_active_outlined,
                size: 30,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                // ...
              },
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey, blurRadius: 2.0, spreadRadius: 0.4)
                ]),
            child: IconButton(
              icon: CustomIcon(
                icon: Icons.manage_accounts_outlined,
                size: 30,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                Navigator.pushNamed(context, ProfileUser.routeName);
              },
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black, blurRadius: 2.0, spreadRadius: 0.4)
                ]),
            child: IconButton(
              icon: CustomIcon(
                icon: Icons.brightness_low,
                size: 30,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                Navigator.pushNamed(context, Setting.routeName);
              },
            ),
          ),
          SizedBox(width: 10,),
        ],
        bottom: TabBar(
          indicatorWeight: 5,
          enableFeedback: true,
          controller: defaultTabBarViewController,
          // isScrollable: true,
          indicatorColor: Colors.red,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.red),
          onTap: (index) {
            print(index);
          },
          tabs: [
            Tab(child: Text("Board")),
            Tab(child: Text("Committees")),
            Tab(child: Text("Management reports")),
            Tab(child: Text("External Auditor")),
            Tab(child: Text("Others")),
          ],
        ),
      ),
      body: TabBarView(
        controller: defaultTabBarViewController,
        children: [
           BoardsListViews(),
           CommitteeList(),
            Center(
                child: Container(
                  color: Colors.black12,
                  child: Text(
                    "state",
                    style: TextStyle(color: Colors.green),
                  ),
                )
            ),
            Center(
                child: Container(
                    color: Colors.brown,
                    child: Text(
                      "state",
                      style: TextStyle(color: Colors.green),
                    )
                )
            ),
            Center(
                child: Container(
                    color: Colors.brown,
                    child: Text(
                      "state",
                      style: TextStyle(color: Colors.green),
                    )
                )
            ),
        ],
      ),
    );
  }

}
