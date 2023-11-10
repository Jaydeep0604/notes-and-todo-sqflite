import 'package:notes_sqflite/services/notification_services.dart';

class AppFunctions {
 static void setNextMorningNotification(String noteTitle) {
    DateTime now = DateTime.now();
    DateTime tomorrowMorning = DateTime(now.year, now.month, now.day + 1, 7, 0);
    notificationServices.showNextMorningNotification(
        tomorrowMorning, noteTitle);
  }
}
