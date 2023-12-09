import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notes_sqflite/config/shared_store.dart';
import 'package:notes_sqflite/language/localisation.dart';
import 'package:notes_sqflite/provider/theme_provider.dart';
import 'package:notes_sqflite/services/notification_controller.dart';
import 'package:notes_sqflite/ui/base/base_screen.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:timezone/data/latest_10y.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

bool isUpdateNoteScreen = false;
bool isUpdateTodoScreen = false;

bool? isBiometricLock;
bool? isPinLock;

bool isDialogOpen = false;
bool isAppActive = false;

FlutterLocalNotificationsPlugin localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeTimeZones();
  isPinLock = await sharedStore.getPin();
  isBiometricLock = await sharedStore.getBiometric();
  if (isPinLock == null) {
    await sharedStore.enablePinLock(false);
    isPinLock = false;
  }
  if (isBiometricLock == null) {
    await sharedStore.enableBiometricLock(false);
    isBiometricLock = false;
  }
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  final themeModeString = await sharedStore.getThememode();
  if (themeModeString == "" || themeModeString == null) {
    sharedStore.setThemeMode("system");
  }
  await NotificationController.initializeNoteLocalNotifications();
  await NotificationController.initializeTodoLocalNotifications();
  await NotificationController.initializeIsolateReceivePort();
  await NotificationController.startListeningNotificationEvents();
  // AppFunctions.flutterLocalNotificationInit();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void setLocale(BuildContext context, Locale newLocale) {
    sharedStore.setLanguage(newLocale.languageCode);
    _MyAppState? state = context.findRootAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  static Locale? getLocale(BuildContext context) {
    _MyAppState? state = context.findRootAncestorStateOfType<_MyAppState>();
    return state?._locale;
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.light;
  Locale? _locale;

  @override
  void initState() {
    NotificationController.startListeningNotificationEvents();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sharedStore.getLanguage().then((locale) {
      if (locale != null) {
        setState(() {
          _locale = Locale(locale);
        });
      } else {
        _locale = Locale("en");
      }
    });
  }

  void setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      return MaterialApp(
        navigatorKey: MyApp.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        darkTheme: ThemeData(
            brightness: Brightness.dark,
            highlightColor: AppColors.whiteColor,
            scaffoldBackgroundColor: Colors.black,
            iconTheme: IconThemeData(color: AppColors.whiteColor),
            canvasColor: AppColors.canvasColor,
            cardColor: AppColors.blackColor,
            bottomSheetTheme:
                BottomSheetThemeData(backgroundColor: Colors.amber),
            textTheme: TextTheme(
              bodySmall: TextStyle(
                color: Color.fromARGB(255, 241, 241, 239),
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
        localizationsDelegates: [
          AppLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [
          Locale("hi", 'IN'),
          Locale("en", 'US'),
          Locale("gu", 'IN'),
        ],
        locale: _locale,
        home: Base(),
      );
    });
  }
}