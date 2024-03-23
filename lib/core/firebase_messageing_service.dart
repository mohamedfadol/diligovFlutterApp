import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> initialize() async {
    // Request permission to receive notifications
    await _firebaseMessaging.requestPermission();
    // Configure the app to receive messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
      print('Received message title: ${message.notification?.title}');
      print('Received message body : ${message.notification?.body}');
      print('Received message data : ${message.data}');
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      10,
      'Title : ${message.notification?.title}',
      'Body : ${message.notification?.body}',
      platformChannelSpecifics,
    );
  }

}
