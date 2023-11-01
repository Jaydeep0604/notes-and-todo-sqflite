import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notes_sqflite/provider/theme_provider.dart';
import 'package:notes_sqflite/ui/base/base_screen.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:timezone/data/latest_10y.dart';
import 'package:provider/provider.dart';

bool isUpdateNoteScreen = false;
bool isUpdateTodoScreen = false;

FlutterLocalNotificationsPlugin localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeTimeZones();
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
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
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        darkTheme: ThemeData(
            brightness: Brightness.dark,
            highlightColor: AppColors.whiteColor,
            scaffoldBackgroundColor: Colors.black,
            iconTheme: IconThemeData(color: AppColors.whiteColor),
            canvasColor: AppColors.canvasColor,
            cardColor: AppColors.blackColor,
            textTheme: TextTheme(
              bodySmall: TextStyle(
                color: Colors.white70,
              ),
              titleMedium: TextStyle(
                color: Colors.white,
              ),
              labelMedium: TextStyle(
                color: Colors.black,
              ),
            ),
            appBarTheme: AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.black,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.black,
            ),
            useMaterial3: true
            /* dark theme settings */
            ),
        themeMode: themeProvider.themeMode, // Use theme from provider
        theme: ThemeData(
          brightness: Brightness.light,
          highlightColor: AppColors.blackColor,
          scaffoldBackgroundColor: Colors.white,
          iconTheme: IconThemeData(color: AppColors.blackColor),
          canvasColor: AppColors.canvasColor,
          cardColor: AppColors.whiteColor,
          textTheme: TextTheme(
            bodySmall: TextStyle(
              color: Colors.black87,
            ),
            titleMedium: TextStyle(
              color: Colors.black,
            ),
            labelMedium: TextStyle(
              color: Colors.white,
            ),
          ),
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 22,
            ),
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
          ),
          useMaterial3: true,
        ),
        home: Base(),
      );
    });
  }
}