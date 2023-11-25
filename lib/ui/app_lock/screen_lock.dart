import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_sqflite/config/shared_store.dart';
import 'package:notes_sqflite/language/localisation.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/ui/app_lock/reset_password_screen.dart';
import 'package:notes_sqflite/widget/custom_password_button.dart';

class ScreenLock extends StatefulWidget {
  const ScreenLock({super.key});

  @override
  State<ScreenLock> createState() => _ScreenLockState();
}

class _ScreenLockState extends State<ScreenLock> {
  late TextEditingController oneCtr, twoCtr, threeCtr, fourCtr;
  bool one = false, two = false, three = false, four = false;
  String? originalPass;
  void initState() {
    super.initState();
    isDialogOpen = true;
    oneCtr = TextEditingController();
    twoCtr = TextEditingController();
    threeCtr = TextEditingController();
    fourCtr = TextEditingController();
   
  }

 

  void dispose() {
    super.dispose();
    oneCtr.clear();
    twoCtr.clear();
    threeCtr.clear();
    fourCtr.clear();
  }

  Widget _buildPasswordDot(bool isFilled) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        border: Border.all(
          color: isFilled ? Theme.of(context).highlightColor : Colors.grey,
          width: 1,
        ),
        color: isFilled ? Theme.of(context).highlightColor : Colors.transparent,
        shape: BoxShape.circle,
      ),
    );
  }

  String enteredPassword = '';

  void fillPassword(String digit) {
    setState(() {
      if (enteredPassword.length < 4) {
        enteredPassword += digit;
      }
      if (enteredPassword.length == 4) {
        Timer(Duration(milliseconds: 100), () {
          checkPassword(enteredPassword);
        });
      }
    });
  }

  void deleteLastPasswordDigit() {
    setState(() {
      if (enteredPassword.isNotEmpty) {
        enteredPassword =
            enteredPassword.substring(0, enteredPassword.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        setState(() {
          isDialogOpen = true;
        });
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              Text(
                "${AppLocalization.of(context)?.getTranslatedValue('enter_password')}",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => _buildPasswordDot(enteredPassword.length > index),
                ),
              ),

              // Wrap(
              //   alignment: WrapAlignment.center,
              //   spacing: 1,
              //   direction: Axis.horizontal,
              //   runSpacing: 10,
              //   children: [
              //     Container(
              //       height: 13,
              //       width: 13,
              //       decoration: BoxDecoration(
              //         color: one == true
              //             ? Theme.of(context).highlightColor
              //             : Theme.of(context).highlightColor.withOpacity(0.1),
              //         shape: BoxShape.circle,
              //       ),
              //     ),
              //     SizedBox(
              //       width: 10,
              //     ),
              //     Container(
              //       height: 13,
              //       width: 13,
              //       decoration: BoxDecoration(
              //         color: two == true
              //             ? Theme.of(context).highlightColor
              //             : Theme.of(context).highlightColor.withOpacity(0.1),
              //         shape: BoxShape.circle,
              //       ),
              //     ),
              //     SizedBox(
              //       width: 10,
              //     ),
              //     Container(
              //       height: 13,
              //       width: 13,
              //       decoration: BoxDecoration(
              //         color: three == true
              //             ? Theme.of(context).highlightColor
              //             : Theme.of(context).highlightColor.withOpacity(0.1),
              //         shape: BoxShape.circle,
              //       ),
              //     ),
              //     SizedBox(
              //       width: 10,
              //     ),
              //     Container(
              //       height: 13,
              //       width: 13,
              //       decoration: BoxDecoration(
              //         color: four == true
              //             ? Theme.of(context).highlightColor
              //             : Theme.of(context).highlightColor.withOpacity(0.1),
              //         shape: BoxShape.circle,
              //       ),
              //     )
              //   ],
              // ),
              Expanded(
                flex: 2,
                child: SizedBox(),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomPasswordButton(
                    onTap: () {
                      fillPassword("1");
                    },
                    text: "${AppLocalization.of(context)?.getTranslatedValue('1')}",
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  CustomPasswordButton(
                    onTap: () {
                      fillPassword("2");
                    },
                    text: "${AppLocalization.of(context)?.getTranslatedValue('2')}",
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  CustomPasswordButton(
                    onTap: () {
                      fillPassword("3");
                    },
                    text: "${AppLocalization.of(context)?.getTranslatedValue('3')}",
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomPasswordButton(
                    onTap: () {
                      fillPassword("4");
                    },
                    text: "${AppLocalization.of(context)?.getTranslatedValue('4')}",
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  CustomPasswordButton(
                    onTap: () {
                      fillPassword("5");
                    },
                    text: "${AppLocalization.of(context)?.getTranslatedValue('5')}",
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  CustomPasswordButton(
                    onTap: () {
                      fillPassword("6");
                    },
                    text: "${AppLocalization.of(context)?.getTranslatedValue('6')}",
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomPasswordButton(
                    onTap: () {
                      fillPassword("7");
                    },
                    text: "${AppLocalization.of(context)?.getTranslatedValue('7')}",
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  CustomPasswordButton(
                    onTap: () {
                      fillPassword("8");
                    },
                    text: "${AppLocalization.of(context)?.getTranslatedValue('8')}",
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  CustomPasswordButton(
                    onTap: () {
                      fillPassword("9");
                    },
                    text: "${AppLocalization.of(context)?.getTranslatedValue('9')}",
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 65,
                    width: 65,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  CustomPasswordButton(
                    onTap: () {
                      fillPassword("0");
                    },
                    text: "${AppLocalization.of(context)?.getTranslatedValue('0')}",
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  SizedBox(
                    height: 65,
                    width: 65,
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResetPasswordScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Center(
                          child: Text(
                            "${AppLocalization.of(context)?.getTranslatedValue('reset_password')}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: InkWell(
                      onTap: () {
                        deleteLastPasswordDigit();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Center(
                          child: Text(
                            "${AppLocalization.of(context)?.getTranslatedValue('delete')}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  checkPassword(String password)async {
    originalPass = await sharedStore.getAppLockPassword();
    if (password == originalPass) {
      setState(() {
        isDialogOpen = false;
        isAppActive = true;
      });
      
      enteredPassword = '';
      Navigator.pop(context);
    } else {
      setState(() {
        enteredPassword = '';
      });
    }
  }

  // void fillPassword(String text) {
  //   if (oneCtr.text.isEmpty) {
  //     setState(() {
  //       oneCtr.text = text;
  //       one = true;
  //       log(oneCtr.text);
  //     });
  //   } else if (oneCtr.text.isNotEmpty && twoCtr.text.isEmpty) {
  //     setState(() {
  //       twoCtr.text = text;
  //       two = true;
  //       log(twoCtr.text);
  //     });
  //   } else if (oneCtr.text.isNotEmpty &&
  //       twoCtr.text.isNotEmpty &&
  //       threeCtr.text.isEmpty) {
  //     setState(() {
  //       threeCtr.text = text;
  //       three = true;
  //       log(threeCtr.text);
  //     });
  //   } else if (oneCtr.text.isNotEmpty &&
  //       twoCtr.text.isNotEmpty &&
  //       threeCtr.text.isNotEmpty &&
  //       fourCtr.text.isEmpty) {
  //     setState(() {
  //       fourCtr.text = text;
  //       four = true;
  //       log(fourCtr.text);
  //       // print(
  //       //     "The Password is :: => ${oneCtr.text}${twoCtr.text}${threeCtr.text}${fourCtr.text}");
  //       Timer(Duration(milliseconds: 130), () {
  //         checkPassword(
  //             "${oneCtr.text}${twoCtr.text}${threeCtr.text}${fourCtr.text}");
  //       });
  //     });
  //   }
  // }

  // void deleteLastPasswordDigit() {
  //   if (fourCtr.text.isNotEmpty) {
  //     fourCtr.clear();
  //     setState(() {
  //       four = false;
  //     });
  //   } else if (fourCtr.text.isEmpty && threeCtr.text.isNotEmpty) {
  //     threeCtr.clear();
  //     setState(() {
  //       three = false;
  //     });
  //   } else if (fourCtr.text.isEmpty &&
  //       threeCtr.text.isEmpty &&
  //       twoCtr.text.isNotEmpty) {
  //     twoCtr.clear();
  //     setState(() {
  //       two = false;
  //     });
  //   } else if (fourCtr.text.isEmpty &&
  //       threeCtr.text.isEmpty &&
  //       twoCtr.text.isEmpty &&
  //       oneCtr.text.isNotEmpty) {
  //     oneCtr.clear();
  //     setState(() {
  //       one = false;
  //     });
  //   }
  // }
}
