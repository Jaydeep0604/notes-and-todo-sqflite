import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notes_sqflite/main.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationServices {
  void showNotification(
      DateTime scheduledTime, String todo, String time) async {
    initializeTimeZone();
    print(scheduledTime);
    print(tz.local);
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'notification_todo',
      "todo notification",
      priority: Priority.max,
      importance: Importance.max,
      largeIcon: DrawableResourceAndroidBitmap("todo_large_icon"),
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
        '$todo',
        '$time',
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

  void showNotificationNow(String todo, String time) async {
    initializeTimeZone();
    print(tz.local);
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'notification_todo',
      "todo notification",
      priority: Priority.max,
      importance: Importance.max,
      largeIcon: DrawableResourceAndroidBitmap("todo_large_icon"),
      //   styleInformation: BigPictureStyleInformation(
      //   DrawableResourceAndroidBitmap('todo_large_icon'),
      //   hideExpandedLargeIcon: false,
      // ),
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
      await localNotificationsPlugin.show(
        0,
        '$todo',
        '$time',
        notificationDetails,
      );
    } catch (e) {
      log("Error at zonedScheduleNotification----------------------------$e");
      if (e ==
          "Invalid argument (): Must be a date in the future: Instance of 'TZDateTime'") {}
    }
  }

  

  // void showBigPictureNotification() async {
  //   initializeTimeZone();
  //   print(tz.local);
  //   // final String filePath = '${directory.path}/$fileName';
  //   final BigPictureStyleInformation bigPictureStyleInformation =
  //       BigPictureStyleInformation(FilePathAndroidBitmap('todo_large_icon'),
  //           largeIcon: FilePathAndroidBitmap('todo_large_icon'));
  //   final AndroidNotificationDetails androidDetails =
  //       AndroidNotificationDetails(
  //     'notification_todo',
  //     "todo notification",
  //     priority: Priority.max,
  //     importance: Importance.max,
  //     largeIcon: DrawableResourceAndroidBitmap("todo_large_icon"),
  //   );
  //   final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
  //     presentAlert: true,
  //     presentBadge: true,
  //     presentSound: true,
  //   );
  //   final NotificationDetails notificationDetails = NotificationDetails(
  //     iOS: iosDetails,
  //     android: androidDetails,
  //   );
  //   try {
  //     await localNotificationsPlugin.show(
  //       0,
  //       'big picture notification',
  //       'this is demo of big picture notification',
  //       notificationDetails,
  //     );
  //   } catch (e) {
  //     log("Error at zonedScheduleNotification----------------------------$e");
  //     if (e ==
  //         "Invalid argument (): Must be a date in the future: Instance of 'TZDateTime'") {}
  //   }
  // }
}

NotificationServices notificationServices = NotificationServices();
