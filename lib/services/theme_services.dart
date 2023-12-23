import 'package:flutter/material.dart';
import 'package:notes_sqflite/utils/app_colors.dart';

class ThemeServices {
  static ThemeData lightMode = ThemeData(
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
  );

  static ThemeData darkMode = ThemeData(
      brightness: Brightness.dark,
      highlightColor: AppColors.whiteColor,
      scaffoldBackgroundColor: Colors.black,
      iconTheme: IconThemeData(color: AppColors.whiteColor),
      canvasColor: AppColors.canvasColor,
      cardColor: AppColors.blackColor,
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.amber),
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
      );
  static ThemeData systemMode = ThemeData(
      brightness: Brightness.dark,
      highlightColor: AppColors.whiteColor,
      scaffoldBackgroundColor: Colors.black,
      iconTheme: IconThemeData(color: AppColors.whiteColor),
      canvasColor: AppColors.canvasColor,
      cardColor: AppColors.blackColor,
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.amber),
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
      );
}
