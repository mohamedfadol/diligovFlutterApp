import 'package:diligov/models/notification_model.dart';
import 'package:diligov/views/calenders/calendar_page.dart';
import 'package:diligov/views/dashboard/setting.dart';
import 'package:diligov/widgets/footer_home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../colors.dart';
import '../../providers/global_search_provider.dart';
import '../../providers/icons_provider.dart';
import '../../providers/light_dark_mode_provider.dart';
import '../../providers/menus_provider.dart';
import '../../providers/notification_page_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/actions_icon_bar_widget.dart';
import '../../widgets/circularFabWidget.dart';
import '../../widgets/custom_icon.dart';
import '../../widgets/custom_message.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/drawer/NavigationDrawerWidget.dart';
import '../../widgets/drowpdown_list_languages_widget.dart';
import '../../widgets/global_search_box.dart';
import '../../widgets/loading_sniper.dart';
import '../../widgets/notification_header_list.dart';
import '../../widgets/search_text_form_field.dart';
import '../notification_views/NotificationPage.dart';
import '../user/profile.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({Key? key}) : super(key: key);

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  bool menuPressed = false;
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    String iconPath = context.watch<IconsProvider>().getIconPath;
    String iconName = context.watch<MenusProvider>().getIconName;
    bool darkModeEnabled = context.watch<LightDarkMode>().darkModeIsEnabled;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        titleSpacing: 20,
        // leadingWidth: 25,
        leading:  ActionsIconBarWidget(
          onPressed: () {
            _scaffoldState.currentState?.openDrawer();
          },
          buttonIcon: Icons.chrome_reader_mode_outlined,
          buttonIconColor: Theme.of(context).iconTheme.color,
          buttonIconSize: 40,
          boxShadowColor: Colors.grey,
          boxShadowBlurRadius: 2.0,
          boxShadowSpreadRadius: 0.4,
          containerBorderRadius: 50.0,
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
          const DropdownListLanguagesWidget(),
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
          const SizedBox(width: 10,),
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
          const SizedBox(width: 10,),
          NotificationHeaderList(),
          const SizedBox(width: 10,),
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
          const SizedBox(width: 10,),
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
          const SizedBox(width: 10,),
        ],
      ),
      resizeToAvoidBottomInset: false,
      key: _scaffoldState,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: NavigationDrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                      const SizedBox(height: 50,),
                Center(
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        if( iconPath == "images/diligov_icon.png" || iconPath == "images/diligov_darkmode_icon.png"){
                            menuPressed = !menuPressed;
                        }else{
                          if(darkModeEnabled){
                            context.read<IconsProvider>().changePath("images/diligov_darkmode_icon.png");
                          }else{
                            context.read<IconsProvider>().changePath("images/diligov_icon.png");
                          }
                          context.read<MenusProvider>().changeIconName("Home");
                          context.read<MenusProvider>().backToHomeMenu();
                        }
                      });
                    },
                    child: Center(
                      child: Column(
                        children: [
                          Image.asset(
                            context.watch<IconsProvider>().getIconPath,
                            scale: 0.8,
                          ),
                          if(iconName != "Home")
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: CustomText(text: iconName,fontSize: 15,fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkMode == true ? Colors.white : Colors.black,),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                FooterHomePage()
              ],
            ),
            Visibility(
                visible: menuPressed,
                child: CircularFabWidget()
            ),
          ],
        ),
      ),
    );
  }





}


class TopHomepageIcon extends StatelessWidget {
  final IconData iconName;
  final VoidCallback onPressed;
  TopHomepageIcon(this.iconName, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onPressed,
        icon: Icon(
          iconName,
          size: 30,
          color: Colour().iconsColor,
        ));
  }
}