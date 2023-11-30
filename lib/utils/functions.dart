import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:notes_sqflite/services/notification_services.dart';

class AppFunctions {
  static void setNotification(
      {required DateTime scheduledTime,
      required String title,
      required String body}) async {
    final schedule = await NotificationCalendar.fromDate(date: scheduledTime);
    notificationServices.createNewNotification(
        schedule: schedule, title: title, body: body);
  }

  static void setNextMorningNotification({required String noteTitle}) async {
    DateTime now = DateTime.now();
    DateTime tomorrowMorning = DateTime(now.year, now.month, now.day + 1, 7, 0);
    final schedule = await NotificationCalendar.fromDate(date: tomorrowMorning);
    notificationServices.createNewNotification(
        schedule: schedule, title: noteTitle, body: "");
  }

  static void setNextEveningNotification({required String noteTitle}) async {
    DateTime now = DateTime.now();
    DateTime nextEvening = DateTime(now.year, now.month, now.day + 1, 18, 0);
    final schedule = await NotificationCalendar.fromDate(date: nextEvening);
    notificationServices.createNewNotification(
        schedule: schedule, title: noteTitle, body: "");
  }

  static void setTodayEveningNotification({required String noteTitle}) async {
    DateTime now = DateTime.now();
    DateTime todayEvening = DateTime(now.year, now.month, now.day, 18, 0);
    print(todayEvening);
    final schedule = await NotificationCalendar.fromDate(date: todayEvening);
    notificationServices.createNewNotification(
        schedule: schedule, title: noteTitle, body: "");
  }

  
}
