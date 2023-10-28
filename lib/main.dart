import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notes_sqflite/ui/base/base_screen.dart';
import 'package:timezone/data/latest_10y.dart';

bool isUpdateNoteScreen = false;
bool isUpdateTodoScreen = false;

FlutterLocalNotificationsPlugin localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeTimeZones();
  final AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings("@mipmap/todo_main");
  final DarwinInitializationSettings IosSettings = DarwinInitializationSettings(
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          systemNavigationBarColor: Colors.grey[900]),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 84, 130, 190)),
        useMaterial3: true,
      ),
      home: Base(),
    );
  }
}
