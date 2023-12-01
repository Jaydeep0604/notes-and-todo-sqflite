import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/utils/app_colors.dart';

class NotificationServices {
  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = MyApp.navigatorKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/images/animated-bell.gif',
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                    'Allow Awesome Notifications to send you beautiful notifications!'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Deny',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Allow',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // use awesome notification

  void testNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'alerts',
        title:
            'hey test notification\nhey test notification\nhey test notification\nhey test notification',
        body: "hey test notification body",
        bigPicture: '',
        largeIcon: 'resource://drawable/todo_large_icon',
        notificationLayout: NotificationLayout.BigPicture,
        hideLargeIconOnExpand: true,
        roundedLargeIcon: true,
        summary: "",
        wakeUpScreen: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'start',
          label: 'start',
          color: AppColors.blueColor,
        ),
        NotificationActionButton(
          key: 'done',
          label: 'done',
          actionType: ActionType.DisabledAction,
          color: AppColors.blueColor,
        ),
      ],
    );
  }

  // void createNewNotification(
  //     {required NotificationCalendar schedule,
  //     required String title,
  //     required String body}) async {
  //   bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  //   if (!isAllowed) isAllowed = await displayNotificationRationale();
  //   if (!isAllowed) return;
  //   await AwesomeNotifications().createNotification(
  //     schedule: schedule,
  //     content: NotificationContent(
  //       id: -1,
  //       channelKey: 'alerts',
  //       title: '$title',
  //       body: "$body",
  //       bigPicture: '',
  //       largeIcon: 'resource://drawable/todo_large_icon',
  //       notificationLayout: NotificationLayout.BigPicture,
  //       payload: {'notificationId': '1234567890'},
  //     ),
  //     actionButtons: [
  //       NotificationActionButton(key: 'EDIT', label: 'EDIT'),
  //       NotificationActionButton(
  //           key: 'FINISH',
  //           label: 'FINiSH',
  //           actionType: ActionType.SilentAction),
  //     ],
  //   );
  // }

  void createNewNoteNotification(
      {required int id,
      required NotificationCalendar schedule,
      required String title,
      required String body}) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
      schedule: schedule,
      content: NotificationContent(
        id: -1,
        channelKey: 'alerts',
        title: '$title',
        body: '$body',
        bigPicture: '',
        largeIcon: 'resource://drawable/todo_large_icon',
        notificationLayout: NotificationLayout.BigPicture,
        hideLargeIconOnExpand: true,
        payload: {
          'id': '$id',
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'open',
          label: 'Open',
          color: AppColors.blueColor,
        ),
      ],
    );
  }

  void createNewTodoNotification(
      {required int id,
      required NotificationCalendar schedule,
      required String title,
      required String body}) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
      schedule: schedule,
      content: NotificationContent(
        id: -1,
        channelKey: 'alert',
        title: '$title',
        body: '$body',
        bigPicture: '',
        largeIcon: 'resource://drawable/todo_large_icon',
        notificationLayout: NotificationLayout.BigPicture,
        payload: {
          'id': '$id',
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'edit',
          label: 'edit',
          color: AppColors.blueColor,
        ),
        NotificationActionButton(
          key: 'finish',
          label: 'finish',
          color: AppColors.blueColor,
          actionType: ActionType.SilentAction 
        ),
      ],
    );
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  // use flutter local notificatin

  // void showNotification(
  //     DateTime scheduledTime, String todo, String time) async {
  //   initializeTimeZone();
  //   print(scheduledTime);
  //   print(tz.local);
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
  //     await localNotificationsPlugin.zonedSchedule(
  //       0,
  //       '$todo',
  //       '$time',
  //       tz.TZDateTime.from(scheduledTime, tz.local),
  //       notificationDetails,
  //       androidAllowWhileIdle: true,
  //       uiLocalNotificationDateInterpretation:
  //           UILocalNotificationDateInterpretation.absoluteTime,
  //     );
  //   } catch (e) {
  //     log("Error at zonedScheduleNotificatione");
  //     if (e ==
  //         "Invalid argument ($scheduledTime): Must be a date in the future: Instance of 'TZDateTime'") {}
  //   }
  // }

  // void showNextMorningNotification(DateTime scheduledTime, String todo) async {
  //   initializeTimeZone();
  //   print(scheduledTime);
  //   print(tz.local);
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
  //     await localNotificationsPlugin.zonedSchedule(
  //       0,
  //       '$todo',
  //       '7:00 AM',
  //       tz.TZDateTime.from(scheduledTime, tz.local),
  //       notificationDetails,
  //       androidAllowWhileIdle: true,
  //       uiLocalNotificationDateInterpretation:
  //           UILocalNotificationDateInterpretation.absoluteTime,
  //     );
  //   } catch (e) {
  //     log("Error at zonedScheduleNotification $e");
  //     if (e ==
  //         "Invalid argument ($scheduledTime): Must be a date in the future: Instance of 'TZDateTime'") {}
  //   }

  //   void showTodayEveningNotification(
  //       DateTime scheduledTime, String todo) async {
  //     initializeTimeZone();
  //     print(scheduledTime);
  //     print(tz.local);
  //     final AndroidNotificationDetails androidDetails =
  //         AndroidNotificationDetails(
  //       'notification_todo',
  //       "todo notification",
  //       priority: Priority.max,
  //       importance: Importance.max,
  //       largeIcon: DrawableResourceAndroidBitmap("todo_large_icon"),
  //     );
  //     final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
  //       presentAlert: true,
  //       presentBadge: true,
  //       presentSound: true,
  //     );
  //     final NotificationDetails notificationDetails = NotificationDetails(
  //       iOS: iosDetails,
  //       android: androidDetails,
  //     );
  //     try {
  //       await localNotificationsPlugin.zonedSchedule(
  //         0,
  //         '$todo',
  //         '6:00 pm',
  //         tz.TZDateTime.from(scheduledTime, tz.local),
  //         notificationDetails,
  //         androidAllowWhileIdle: true,
  //         uiLocalNotificationDateInterpretation:
  //             UILocalNotificationDateInterpretation.absoluteTime,
  //       );
  //     } catch (e) {
  //       log("Error at zonedScheduleNotification $e");
  //       if (e ==
  //           "Invalid argument ($scheduledTime): Must be a date in the future: Instance of 'TZDateTime'") {}
  //     }
  //   }
  // }

  // void showNotificationNow(String todo, String time) async {
  //   initializeTimeZone();
  //   print(tz.local);
  //   final AndroidNotificationDetails androidDetails =
  //       AndroidNotificationDetails(
  //     'notification_todo',
  //     "todo notification",
  //     priority: Priority.max,
  //     importance: Importance.max,
  //     largeIcon: DrawableResourceAndroidBitmap("todo_large_icon"),
  //     //   styleInformation: BigPictureStyleInformation(
  //     //   DrawableResourceAndroidBitmap('todo_large_icon'),
  //     //   hideExpandedLargeIcon: false,
  //     // ),
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
  //       '$todo',
  //       '$time',
  //       notificationDetails,
  //     );
  //   } catch (e) {
  //     log("Error at zonedScheduleNotification $e");
  //     if (e ==
  //         "Invalid argument (): Must be a date in the future: Instance of 'TZDateTime'") {}
  //   }
  // }
}

NotificationServices notificationServices = NotificationServices();
