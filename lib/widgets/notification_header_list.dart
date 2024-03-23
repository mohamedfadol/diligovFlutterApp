import 'package:diligov/widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../providers/notification_page_provider.dart';
import '../views/notification_views/NotificationPage.dart';

class NotificationHeaderList extends StatelessWidget {
    NotificationHeaderList({super.key});
  final GlobalKey _iconKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return  Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: const [
              BoxShadow(color: Colors.grey, blurRadius: 2.0, spreadRadius: 0.4)
            ]),
        child: IconButton(
          key: _iconKey,
          icon: Stack(
            children: <Widget>[
              CustomIcon(icon: Icons.notifications_active_outlined,size: 40,color: Theme.of(context).iconTheme.color,),
              Positioned(
                right: 0,
                bottom: 19,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 20,
                    minHeight: 12,
                  ),
                  child: Consumer<NotificationPageProvider>(
                    builder: (context, provider, child) {
                      if (provider?.notificationCount == 0) {
                        provider!.notificationCount!;
                        return Text('0',style: TextStyle(color: Colors.white,fontSize: 12,),textAlign: TextAlign.center,);
                      }
                      return provider!.notificationCount! > 0  ? Text(provider.notificationCount.toString(),style: TextStyle(color: Colors.white,fontSize: 12,),textAlign: TextAlign.center,) : Text('0',style: TextStyle(color: Colors.white,fontSize: 12,),textAlign: TextAlign.center,);
                    },
                  ),
                ),
              ),
            ],
          ),
          onPressed: () => showNotificationsMenu(context),
        )

    );
  }

    void showNotificationsMenu(BuildContext context) {
      final lastTen = context.read<NotificationPageProvider>().lastTenNotifications;
      final RenderBox renderBox = _iconKey.currentContext!.findRenderObject() as RenderBox;
      final offset = renderBox.localToGlobal(Offset.zero);
      final appBarHeight = Scaffold.of(_iconKey.currentContext!).appBarMaxHeight ?? 0;
      showMenu(
        color: Colors.grey[100],
        elevation: 1.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
        context: context,
        position: RelativeRect.fromLTRB(
          offset.dx, // Left side of the icon
          offset.dy + appBarHeight - 30.0, // Top side of the icon
          offset.dx, // Left side again, might need adjustment based on your needs
          offset.dy, // Top side again, might need adjustment based on your needs
        ),
        items: lastTen.map((notification) =>
            PopupMenuItem(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              value: notification.notificationId,
              child: Container(
                margin: EdgeInsets.only(bottom: 1.5,top: 1.5),
                padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.black,
                      width: 0.5,
                    ),
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(5.0) ),
                ),
                height: 60.0,
                width: 350,
                // color: Colors.red,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(notification.notificationTitle!,style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.0),overflow: TextOverflow.clip,
                        maxLines: 1,
                        softWrap: false,),
                    ),
                    Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_clock,),
                            SizedBox(width: 5.0,),
                            Text(notification.notificationTime!,overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.grey),),
                          ],
                        )
                    ),

                  ],
                ),
              ),
              onTap:() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage(notification: notification!)),
                );
              },
            )
        ).toList(),
      ).then((value) {
        // Handle the action when the menu is dismissed
        if (value != null) {
          print('Selected notification ID: $value');
          // Here, you can navigate to the notification page or perform any other actions
        }
      });
    }
}
