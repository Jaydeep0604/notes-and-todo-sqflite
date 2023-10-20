import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notes_sqflite/main.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationServices {
  void showNotification() async {
    DateTime scheduledTime = DateTime.now().add(
      Duration(seconds: 20),
    );
    initializeTimeZone();
    print(scheduledTime);
    print(tz.local);
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'notification_todo',
      "todo notification",
      priority: Priority.high,
      importance: Importance.max,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      iOS: iosDetails,
      android: androidDetails,
    );

    try {
      await localNotificationsPlugin.zonedSchedule(
        0,
        'first notification',
        'this is the first notification',
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      log("Error at zonedScheduleNotification----------------------------$e");
      if (e ==
          "Invalid argument ($scheduledTime): Must be a date in the future: Instance of 'TZDateTime'") {}
    }
  }
}

NotificationServices notificationServices = NotificationServices();
