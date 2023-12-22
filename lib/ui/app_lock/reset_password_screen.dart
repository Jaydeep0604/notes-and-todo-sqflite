import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_sqflite/config/shared_store.dart';
import 'package:notes_sqflite/language/localisation.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:notes_sqflite/utils/app_message.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool seqQuestionOneDone = false;
  bool seqQuestiontwoDone = false;
  bool setPasswordDone = false;

  TextEditingController queOneCtr = TextEditingController();
  TextEditingController queTwoCtr = TextEditingController();
  TextEditingController passwordCtr = TextEditingController();
  TextEditingController c_passwordCtr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: AppColors.whiteColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon:
              Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "${AppLocalization.of(context)?.getTranslatedValue('reset_password')}",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: AppColors.canvasColor.withOpacity(0.3),
                      border: Border.all(
                        color:
                            Theme.of(context).highlightColor.withOpacity(0.4),
                      ),
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "• ${AppLocalization.of(context)?.getTranslatedValue('what_s_your_favorite_movie')}?",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (seqQuestionOneDone)
                            SizedBox(
                              width: 10,
                            ),
                          if (seqQuestionOneDone)
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.greenSplashColor),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Icon(Icons.done,
                                    color: Theme.of(context).iconTheme.color,
                                    size: 14),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        child: TextFormField(
                          controller: queOneCtr,
                          readOnly: seqQuestionOneDone,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "${AppLocalization.of(context)?.getTranslatedValue('please_fill_your_favorite_movie_name')}";
                            }
                            return null;
                          },
                          maxLines: 1,
                          minLines: 1,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                          decoration: InputDecoration(
                              fillColor: AppColors.blueGrayColor,
                              errorStyle: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(color: Colors.red),
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor),
                              hintText:
                                  "${AppLocalization.of(context)?.getTranslatedValue('movie_name')}",
                              filled: true,
                              contentPadding:
                                  EdgeInsets.only(left: 10, right: 10, top: 10),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      if (!seqQuestionOneDone)
                        MaterialButton(
                          height: 45,
                          elevation: 0,
                          minWidth: MediaQuery.of(context).size.width,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: AppColors.greenSplashColor,
                          onPressed: () {
                            checkSeqQuestionOne(queOneCtr.text);
                          },
                          child: Text(
                            "${AppLocalization.of(context)?.getTranslatedValue('submit_answer')}",
                            style: TextStyle(color: AppColors.blackColor),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              if (seqQuestionOneDone)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: AppColors.canvasColor.withOpacity(0.3),
                        border: Border.all(
                          color:
                              Theme.of(context).highlightColor.withOpacity(0.4),
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "• ${AppLocalization.of(context)?.getTranslatedValue('what_was_your_favorite_school_teacher_s_name')}?",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (seqQuestiontwoDone)
                              SizedBox(
                                width: 10,
                              ),
                            if (seqQuestiontwoDone)
                              Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.greenSplashColor),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(Icons.done,
                                      color: Theme.of(context).iconTheme.color,
                                      size: 14),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          child: TextFormField(
                            controller: queTwoCtr,
                            readOnly: seqQuestiontwoDone,
                            maxLines: 1,
                            minLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor),
                            decoration: InputDecoration(
                                fillColor: AppColors.blueGrayColor,
                                errorStyle: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(color: Colors.red),
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor),
                                hintText:
                                    "${AppLocalization.of(context)?.getTranslatedValue('movie_name')}",
                                filled: true,
                                contentPadding: EdgeInsets.only(
                                    left: 10, right: 10, top: 10),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        if (!seqQuestiontwoDone)
                          MaterialButton(
                            height: 45,
                            elevation: 0,
                            minWidth: MediaQuery.of(context).size.width,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            color: AppColors.greenSplashColor,
                            onPressed: () {
                              checkSeqQuestionTwo(queTwoCtr.text);
                            },
                            child: Text(
                              "${AppLocalization.of(context)?.getTranslatedValue('submit_answer')}",
                              style: TextStyle(color: AppColors.blackColor),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              SizedBox(
                height: 20,
              ),
              if (seqQuestiontwoDone)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: AppColors.canvasColor.withOpacity(0.3),
                        border: Border.all(
                          color:
                              Theme.of(context).highlightColor.withOpacity(0.4),
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "• ${AppLocalization.of(context)?.getTranslatedValue('password')}",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (setPasswordDone)
                              SizedBox(
                                width: 10,
                              ),
                            if (setPasswordDone)
                              Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.greenSplashColor),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(Icons.done,
                                      color: Theme.of(context).iconTheme.color,
                                      size: 14),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: TextFormField(
                            controller: passwordCtr,
                            readOnly: setPasswordDone,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "${AppLocalization.of(context)?.getTranslatedValue('please_fill_password')}";
                              } else if (value.length < 4) {
                                return "${AppLocalization.of(context)?.getTranslatedValue('password_length_must_be_atleast_4_digit')}";
                              }
                              return null;
                            },
                            maxLines: 1,
                            minLines: 1,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(4)
                            ],
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor),
                            decoration: InputDecoration(
                                fillColor: AppColors.blueGrayColor,
                                errorStyle: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(color: Colors.red),
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor),
                                hintText:
                                    "${AppLocalization.of(context)?.getTranslatedValue('password')}",
                                filled: true,
                                contentPadding: EdgeInsets.only(
                                    left: 10, right: 10, top: 10),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),
                        ),
                        if (!setPasswordDone)
                          SizedBox(
                            height: 20,
                          ),
                        if (!setPasswordDone)
                          Text(
                            "• ${AppLocalization.of(context)?.getTranslatedValue('confirm_password')}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        if (!setPasswordDone)
                          SizedBox(
                            height: 10,
                          ),
                        if (!setPasswordDone)
                          Container(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: c_passwordCtr,
                              readOnly: setPasswordDone,
                              validator: (value) {
                                // if (value!.isEmpty) {
                                //   return "Please fill confirm password";
                                // } else if (value.length < 4) {
                                //   return "Confirm password length must be atleast 4 digit";
                                // } else if (passCtr.text !=
                                //     confirm_passCtr.text) {
                                //   return "Confirm password must be same as password";
                                // }
                                return null;
                              },
                              maxLines: 1,
                              minLines: 1,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(4)
                              ],
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                  fillColor: AppColors.blueGrayColor,
                                  errorStyle: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(color: Colors.red),
                                  hintStyle:
                                      Theme.of(context).textTheme.titleSmall,
                                  hintText:
                                      "${AppLocalization.of(context)?.getTranslatedValue('confirm_password')}",
                                  filled: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 10, right: 10, top: 10),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                        SizedBox(
                          height: 30,
                        ),
                        if (!setPasswordDone)
                          MaterialButton(
                            height: 45,
                            elevation: 0,
                            minWidth: MediaQuery.of(context).size.width,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            color: AppColors.greenSplashColor,
                            onPressed: () {
                              setNewPassword();
                            },
                            child: Text(
                              "${AppLocalization.of(context)?.getTranslatedValue('set_password')}",
                              style: TextStyle(color: AppColors.blackColor),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  checkSeqQuestionOne(String queOne) async {
    if (queOneCtr.text.isEmpty) {
      AppMessage.showToast(context,
          "${AppLocalization.of(context)?.getTranslatedValue('please_fill_your_favorite_movie_name')}");
    } else {
      String movieName = await sharedStore.getSecurityPassWordMovieName();
      if (queOne == movieName) {
        setState(() {
          seqQuestionOneDone = true;
        });
      } else {
        queOneCtr.clear();
      }
    }
  }

  checkSeqQuestionTwo(String quetwo) async {
    if (queTwoCtr.text.isEmpty) {
      AppMessage.showToast(context,
          "${AppLocalization.of(context)?.getTranslatedValue('please_fill_your_favorite_teacher_s_name')}");
    } else {
      String teacherName = await sharedStore.getSecurityPassWordTeacherName();
      if (quetwo == teacherName) {
        setState(() {
          seqQuestiontwoDone = true;
        });
      } else {
        queTwoCtr.clear();
      }
    }
  }

  setNewPassword() async {
    if (passwordCtr.text.isEmpty) {
      AppMessage.showToast(context,
          "${AppLocalization.of(context)?.getTranslatedValue('please_fill_password')}");
    } else if (c_passwordCtr.text.isEmpty) {
      AppMessage.showToast(context,
          "${AppLocalization.of(context)?.getTranslatedValue('please_fill_password')}");
    } else if (passwordCtr.text.length < 4) {
      AppMessage.showToast(context,
          "${AppLocalization.of(context)?.getTranslatedValue('password_length_must_be_atleast_4_digit')}");
    } else if (c_passwordCtr.text.length < 4) {
      AppMessage.showToast(context,
          "${AppLocalization.of(context)?.getTranslatedValue('confirm_password_length_must_be_atleast_4_digit')}");
    } else if (passwordCtr.text != c_passwordCtr.text) {
      AppMessage.showToast(context,
          "${AppLocalization.of(context)?.getTranslatedValue('confirm_password_must_be_same_as_password')}");
    } else {
      if (seqQuestionOneDone && seqQuestiontwoDone) {
        sharedStore.setAppLockPassword(c_passwordCtr.text).then((value) {
          if (value == true) {
            AppMessage.showToast(context,
                "${AppLocalization.of(context)?.getTranslatedValue('new_password_set_successfull')}");
            setState(() {
              setPasswordDone = true;
            });
          } else {
            AppMessage.showToast(context,
                "${AppLocalization.of(context)?.getTranslatedValue('new_password_not_set_please_try_again_latter')}");
          }
        });
      }
    }
  }
}
