import 'dart:ffi';

import 'package:notes_sqflite/services/notification_services.dart';

class AppFunctions {
  static void setNextMorningNotification(String noteTitle) {
    DateTime now = DateTime.now();
    DateTime tomorrowMorning = DateTime(now.year, now.month, now.day + 1, 7, 0);
    notificationServices.showNextMorningNotification(
        tomorrowMorning, noteTitle);
  }
  static void setNextEveningNotification(String noteTitle) {
    DateTime now = DateTime.now();
    DateTime tomorrowMorning = DateTime(now.year, now.month, now.day + 1, 18, 0);
    notificationServices.showNextMorningNotification(
        tomorrowMorning, noteTitle);
  }

  static void setTodayEveningNotification(String noteTitle) {
    DateTime now = DateTime.now();
    DateTime todayEvening = DateTime(now.year, now.month, now.day, 18, 0);
    print(todayEvening);
    notificationServices.showNextMorningNotification(todayEvening, noteTitle);
  }

  
}


