import 'package:flutter/material.dart';
import 'package:notes_sqflite/utils/app_colors.dart';

class AppMessage {
  static showToast(BuildContext context, String text) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.yellowColor,
      duration: Duration(milliseconds: 1800),
      elevation: 10,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      content: Text(
        "${text}",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.blackColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    ));
  }
}
