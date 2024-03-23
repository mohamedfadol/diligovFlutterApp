import 'package:flutter/material.dart';

import '../../models/notification_model.dart';

class NotificationPage extends StatelessWidget {
  final NotificationModel notification;

  const NotificationPage({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(notification.notificationTitle!),
        ),
        body: Padding(
        padding: EdgeInsets.all(16.0),
    child: Text(notification.notificationBody!),
        ),
    );
  }
}

