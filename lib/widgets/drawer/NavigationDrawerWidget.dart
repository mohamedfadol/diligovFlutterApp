import 'package:diligov/views/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../colors.dart';
import '../../models/data/drawer_items.dart';
import '../../models/drawer_item.dart';
import '../../providers/navigator_provider.dart';
import '../../utility/shared_preference.dart';
import '../../views/dashboard/dashboard_home_screen.dart';
import '../../views/modules/note_views/note_list_views.dart';
import '../assets_widgets/login_image.dart';
class NavigationDrawerWidget extends StatelessWidget {
 final padding = EdgeInsets.symmetric(horizontal: 24);

  @override
  Widget build(BuildContext context) {
    final safeArea = EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top);
    final provider = Provider.of<NavigatorProvider>(context);
    final isCollapsed = provider.isCollapsed;

    return Container(
      width: isCollapsed ? MediaQuery.of(context).size.width * 0.06 : null,
      child: Drawer(
        child: Container(
          color: Colour().lightBackgroundColor,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10).add(safeArea),
                    color: Colour().lightBackgroundColor,
                    width: double.infinity,
                    child: buildHeader(context,isCollapsed)
                ),
              ),
              const SizedBox(height: 5,),
              buildList(items: itemsFirst, isCollapsed: isCollapsed),
              // Spacer(),
              buildList(
                  indexOffset: itemsFirst.length,
                  items: itemsLast,
                  isCollapsed: isCollapsed
              ),
              buildCollapseIcon(context,isCollapsed),
              const SizedBox(height: 6,)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context, bool isCollapsed) => isCollapsed ? LoginImage(height: 100,) :  LoginImage(height: 170,);

 Widget buildCollapseIcon(BuildContext context, bool isCollapsed) {
    const double size = 52;
    final icon = isCollapsed ?  Icons.arrow_forward_ios : Icons.arrow_back_ios;
    final alignment = isCollapsed ? Alignment.center : Alignment.centerRight;
    final margin = isCollapsed ? null : EdgeInsets.only(right: 16);
    final width = isCollapsed ? double.infinity :  size;
    return Container(
      alignment: alignment,
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          child: SizedBox(
            height: size,
            width: width,
            child: Icon(icon, color: Colors.redAccent,),
          ),
          onTap: (){
            final provider = Provider.of<NavigatorProvider>(context,listen: false);
            provider.togglisCollapsed();
          },
        ),
      ),
    );
  }

 Widget buildList({
  required bool isCollapsed,
  required List<DrawerItem> items,
   int indexOffset = 0,
}) => ListView.separated(scrollDirection: Axis.vertical,
      padding: isCollapsed ? EdgeInsets.zero : padding ,
      shrinkWrap: true,
      primary: false,
      itemCount: items.length,
      separatorBuilder: (context, index)  => SizedBox(height: 5,),
      itemBuilder: (context,index){
      final item = items[index];
      return buildMenuItem(
          isCollapsed: isCollapsed,
          text: item.title,
          icon: item.icon,
          size: 30,
          onClick: () => selectItem(context, indexOffset + index),
      );
     },
 );

 void selectItem (BuildContext context,int index){
   final navigateTo = (page) => Navigator.of(context).push(MaterialPageRoute(
     builder: (context) => page,
   ));
   Navigator.of(context).pop();
   switch(index){
     case 0:
      navigateTo(const DashboardHomeScreen());
     break;
     case 1:
       navigateTo(LoginScreen());
       break;
     case 2:
       navigateTo(NoteListViews());
       break;
     case 3:
       navigateTo(LoginScreen());
       break;
     case 4:
       navigateTo(LoginScreen());
       break;
     case 5:
       navigateTo(LoginScreen());
       break;
     case 6:
       navigateTo(
           TextButton(
           onPressed: (){
              UserPreferences().removeUser();
              Navigator.pushReplacementNamed(context, '/login');},
               child: LoginScreen()));
       break;
   }
 }


 Widget buildMenuItem({
    required bool isCollapsed,
    required String text,
    required IconData icon,
   required double size,
    VoidCallback?  onClick,
}){
    const color = Colors.black;
    final leading = Icon(icon,color: color,size: size,);
     return Container(
       decoration: BoxDecoration(
         border: Border(bottom: BorderSide(color: Colors.black12,width: 2,)),
       ),
       child: Material(
         color: Colour().buildMenuItemColor,
         child: isCollapsed ?  ListTile(
           leading: leading,
           onTap: onClick,
         ) : ListTile(
           leading: leading,
           title: Text(text,style: const TextStyle(color: color,fontSize: 18,fontWeight: FontWeight.bold),),
           onTap: onClick,
         ),
       ),
     );
 }
}
