import 'package:flutter/material.dart';
import 'package:notes_sqflite/language/localisation.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:notes_sqflite/widget/theme_container.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return ThemedContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          // backgroundColor: AppColors.whiteColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon:
                Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          ),
          title: Text(
            "${AppLocalization.of(context)?.getTranslatedValue('privacy_policy')}",
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
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            decoration: BoxDecoration(
              // color: AppColors.canvasColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Theme.of(context).highlightColor.withOpacity(0.7)),
            ),
            child: RichText(
              text: TextSpan(
                text:
                    "${AppLocalization.of(context)?.getTranslatedValue("our_note_and_to-do_app_respects_your_privacy_we_don't_collect_personal_information_or_store_data_outside_the_app_your_notes_and_to-dos_are_stored_exclusively_on_your_device's_local_storage_we_prioritize_data_security_although_no_method_is_entirely_foolproof_we_may_update_this_policy_and_any_changes_will_be_posted_here_if_you_have_questions_please_contact_us_your_use_of_the_app_indicates_your_consent_to_these_terms")}",
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
      ),
    );
  }
}
