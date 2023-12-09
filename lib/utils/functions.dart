import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/services/notification_services.dart';

class AppFunctions {
  static setNoteNotification(
      {required int id,
      required DateTime scheduledTime,
      required String title,
      required String body}) async {
    final schedule = await NotificationCalendar.fromDate(date: scheduledTime);
    DateTime now = DateTime.now();
    String _addLeadingZero(int value) {
      return value.toString().padLeft(2, '0');
    }

    String formateDate = await _addLeadingZero(now.month) +
        _addLeadingZero(now.day) +
        _addLeadingZero(now.hour) +
        _addLeadingZero(now.minute) +
        _addLeadingZero(now.second);

    int notificationId = int.parse(formateDate);
    print(notificationId);
    await notificationServices.createNewNoteNotification(
        notificationId: notificationId,
        id: id,
        schedule: schedule,
        title: title,
        body: body);
  }

  static setNewSheduleNotification(
      {required int id,
      required DateTime scheduledTime,
      required String title,
      required String body}) async {
    final schedule = await NotificationCalendar.fromDate(date: scheduledTime);
    DateTime now = DateTime.now();
    String _addLeadingZero(int value) {
      return value.toString().padLeft(2, '0');
    }

    String formateDate = await _addLeadingZero(now.month) +
        _addLeadingZero(now.day) +
        _addLeadingZero(now.hour) +
        _addLeadingZero(now.minute) +
        _addLeadingZero(now.second);
    int notificationId = int.parse(formateDate);
    print(notificationId);
    await notificationServices.createNewTodoNotification(
        notificationId: notificationId,
        id: id,
        schedule: schedule,
        title: title,
        body: body);
  }

  static setNextMorningNotification(
      {required int id, required String noteTitle}) async {
    DateTime now = DateTime.now();
    String _addLeadingZero(int value) {
      return value.toString().padLeft(2, '0');
    }

    String formateDate = await _addLeadingZero(now.month) +
        _addLeadingZero(now.day) +
        _addLeadingZero(now.hour) +
        _addLeadingZero(now.minute) +
        _addLeadingZero(now.second);
    int notificationId = int.parse(formateDate);
    print(notificationId);
    DateTime tomorrowMorning = DateTime(now.year, now.month, now.day + 1, 7, 0);
    final schedule = await NotificationCalendar.fromDate(date: tomorrowMorning);
    await notificationServices.createNewNoteNotification(
        notificationId: notificationId,
        id: id,
        schedule: schedule,
        title: noteTitle,
        body: "7:00 am");
  }

  static setNextEveningNotification(
      {required int id, required String noteTitle}) async {
    DateTime now = DateTime.now();
    String _addLeadingZero(int value) {
      return value.toString().padLeft(2, '0');
    }

    String formateDate = await _addLeadingZero(now.month) +
        _addLeadingZero(now.day) +
        _addLeadingZero(now.hour) +
        _addLeadingZero(now.minute) +
        _addLeadingZero(now.second);

    int notificationId = int.parse(formateDate);
    print(notificationId);
    DateTime nextEvening = DateTime(now.year, now.month, now.day + 1, 18, 0);
    final schedule = await NotificationCalendar.fromDate(date: nextEvening);
    await notificationServices.createNewNoteNotification(
        notificationId: notificationId,
        id: id,
        schedule: schedule,
        title: noteTitle,
        body: "6:00 pm");
  }

  static setTodayEveningNotification(
      {required int id, required String noteTitle}) async {
    DateTime now = DateTime.now();
    String _addLeadingZero(int value) {
      return value.toString().padLeft(2, '0');
    }

    String formateDate = await _addLeadingZero(now.month) +
        _addLeadingZero(now.day) +
        _addLeadingZero(now.hour) +
        _addLeadingZero(now.minute) +
        _addLeadingZero(now.second);

    int notificationId = int.parse(formateDate);
    print(notificationId);
    DateTime todayEvening = DateTime(now.year, now.month, now.day, 18, 0);
    print(todayEvening);
    final schedule = await NotificationCalendar.fromDate(date: todayEvening);
    await notificationServices.createNewNoteNotification(
        notificationId: notificationId,
        id: id,
        schedule: schedule,
        title: noteTitle,
        body: "6:00 pm");
  }

  static DateTime convertNotificationCalendarToDateTime(
      NotificationCalendar notificationCalendar) {
    int year = notificationCalendar.year ?? 0;
    int month = notificationCalendar.month ?? 1;
    int day = notificationCalendar.day ?? 1;
    int hour = notificationCalendar.hour ?? 0;
    int minute = notificationCalendar.minute ?? 0;
    int second = notificationCalendar.second ?? 0;

    return DateTime(year, month, day, hour, minute, second);
  }

  static String notificationFormatDateShow(DateTime date) {
    return DateFormat('EEE, dd MMM yyyy, h:mm a').format(date);
  }

  static DateTime convertStringToDateTime(String dateTimeString) {
    DateFormat format = DateFormat('EEE, dd MMM yyyy, h:mm a');
    return format.parse(dateTimeString);
  }

  static DateTime covertDateTimeToDate(DateTime dateTime) {
    String formattedDateString = DateFormat('dd MMM yyyy').format(dateTime);
    return DateFormat('dd MMM yyyy').parse(formattedDateString);
  }

  static DateTime covertDateTimeToTime(DateTime dateTime) {
    String formattedTimeString = DateFormat('hh:mm a').format(dateTime);
    return DateFormat('hh:mm a').parse(formattedTimeString);
  }

  static resetNotification(int notificationID)async {
    DBHelper dbHelper = DBHelper();
   await notificationServices.cancelNotificationById(notificationID);
    // dbHelper!.
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
    print("Notifications: $initialize");
  }
}
