import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/services/notification_services.dart';

class AppFunctions {
  static void setNoteNotification(
      {required int id,
      required DateTime scheduledTime,
      required String title,
      required String body}) async {
    final schedule = await NotificationCalendar.fromDate(date: scheduledTime);
    notificationServices.createNewNoteNotification(
        id: id, schedule: schedule, title: title, body: body);
  }

  static void setNewSheduleNotification(
      {required int id,
      required DateTime scheduledTime,
      required String title,
      required String body}) async {
    final schedule = await NotificationCalendar.fromDate(date: scheduledTime);
    notificationServices.createNewTodoNotification(
        id: id, schedule: schedule, title: title, body: body);
  }

  static void setNextMorningNotification(
      {required int id, required String noteTitle}) async {
    DateTime now = DateTime.now();
    DateTime tomorrowMorning = DateTime(now.year, now.month, now.day + 1, 7, 0);
    final schedule = await NotificationCalendar.fromDate(date: tomorrowMorning);
    notificationServices.createNewNoteNotification(
        id: id, schedule: schedule, title: noteTitle, body: "");
  }

  static void setNextEveningNotification(
      {required int id, required String noteTitle}) async {
    DateTime now = DateTime.now();
    DateTime nextEvening = DateTime(now.year, now.month, now.day + 1, 18, 0);
    final schedule = await NotificationCalendar.fromDate(date: nextEvening);
    notificationServices.createNewNoteNotification(
        id: id, schedule: schedule, title: noteTitle, body: "");
  }

  static void setTodayEveningNotification(
      {required int id, required String noteTitle}) async {
    DateTime now = DateTime.now();
    DateTime todayEvening = DateTime(now.year, now.month, now.day, 18, 0);
    print(todayEvening);
    final schedule = await NotificationCalendar.fromDate(date: todayEvening);
    notificationServices.createNewNoteNotification(
        id: id, schedule: schedule, title: noteTitle, body: "");
  }


  static void flutterLocalNotificationInit() async {
    final AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings("@mipmap/todo_main");
    final DarwinInitializationSettings IosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true,
    );
    InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: IosSettings,
    );
    bool? initialize = await localNotificationsPlugin.initialize(
      initializationSettings,
    );
    log("Notifications: $initialize");
  }
}
