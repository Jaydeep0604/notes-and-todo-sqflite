import 'package:flutter/material.dart';
import 'package:notes_sqflite/utils/app_colors.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: AppColors.whiteColor,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).iconTheme.color)),
        title: Text(
          "Privacy Policy",
          style: TextStyle(
              // color: Colors.black,
              ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.canvasColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).highlightColor.withOpacity(0.7)),
          ),
          child: RichText(
            text: TextSpan(
              text:
                  "Our note and to-do app respects your privacy. We don't collect personal information or store data outside the app. Your notes and to-dos are stored exclusively on your device's local storage. We prioritize data security, although no method is entirely foolproof. We may update this policy, and any changes will be posted here. If you have questions, please contact us. Your use of the app indicates your consent to these terms.",
              style: TextStyle(
                color: Theme.of(context).highlightColor,
                fontStyle: FontStyle.normal,
                wordSpacing: 1,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      )),
    );
  }
}
