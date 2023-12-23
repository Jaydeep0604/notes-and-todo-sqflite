import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:notes_sqflite/animations/slide_animation.dart';
import 'package:notes_sqflite/config/constant.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/language/localisation.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/ui/app_lock/screen_lock.dart';
import 'package:notes_sqflite/ui/archive_screen/archive_note_screen.dart';
import 'package:notes_sqflite/ui/delete_note_screen/delete_screen.dart';
import 'package:notes_sqflite/ui/note_screen/note_detail_screen.dart';
import 'package:notes_sqflite/ui/note_screen/notes_screen.dart';
import 'package:notes_sqflite/ui/setting_screen/setting_screen.dart';
import 'package:notes_sqflite/ui/finished_screen/todo_done_screen.dart';
import 'package:notes_sqflite/ui/text_recognizer/text_recognizer_screen.dart';
import 'package:notes_sqflite/ui/todo_screen/todo_detail_screen.dart';
import 'package:notes_sqflite/ui/todo_screen/todo_screen.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:animations/animations.dart';
import 'package:notes_sqflite/widget/theme_container.dart';

class Base extends StatefulWidget {
  const Base({super.key});

  static openDrawer(BuildContext context) {
    _BaseState? state = context.findAncestorStateOfType<_BaseState>();
    state?.openDrawer();
  }

  @override
  State<Base> createState() => _BaseState();
}

class _BaseState extends State<Base>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  DBHelper? dbHelper;

  final LocalAuthentication auth = LocalAuthentication();

  // ignore: unused_field
  String _authorized = 'Not Authorized';
  // ignore: unused_field
  SupportState _supportState = SupportState.unknown;

  bool isNotes = true, isTodos = false, isAdd = false;
  bool isNotesTextShow = true, isTodosTextShow = false, isAddTextShow = false;

  late GlobalKey<ScaffoldState> globalScaffoldKey;

  late TextEditingController titleCtr, ageCtr, descriptionCtr, emailCtr;

  ContainerTransitionType _containerTransitionType =
      ContainerTransitionType.fade;

  void initState() {
    super.initState();
    globalScaffoldKey = GlobalKey<ScaffoldState>();
    WidgetsBinding.instance.addObserver(this);

    if (isBiometricLock!) {
      auth.isDeviceSupported().then(
            (bool isSupported) => setState(() => _supportState = isSupported
                ? SupportState.supported
                : SupportState.unsupported),
          );
      _authenticateWithBiometrics();
    }
    if (isPinLock == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        isDialogOpen == false
            ? showGeneralDialog(
                context: context,
                transitionBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return Opacity(
                    opacity: animation.value,
                    child: ScreenLock(),
                  );
                },
                pageBuilder: (buildContext, animation, secondaryAnimation) {
                  // ignore: null_check_always_fails
                  return null!;
                },
                barrierDismissible: true,
                barrierLabel: "",
                barrierColor: Colors.black.withOpacity(0.5),
                transitionDuration: Duration(milliseconds: 250),
              )
            : null;
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _authorized = 'Authenticating';
      });
      authenticated = await auth
          .authenticate(
        localizedReason:
            "${AppLocalization.of(context)?.getTranslatedValue('scan_your_fingerprint_or_face_to_authenticate')}",
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      )
          .then((value) {
        if (value == false) {
          setState(() {
            isAppActive = false;
          });
        }
        if (value == true) {
          setState(() {
            isAppActive = true;
          });
        }
        return authenticated;
      });
      setState(() {
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }
    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
    });
  }

  void openDrawer() {
    globalScaffoldKey.currentState?.openEndDrawer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (isBiometricLock!) {
          if (!isAppActive) {
            if (state == AppLifecycleState.resumed) {
              _authenticateWithBiometrics();
            }
          }
        }
        if (isPinLock!) {
          if (!isAppActive) {
            isDialogOpen == false
                ? showGeneralDialog(
                    context: context,
                    transitionBuilder:
                        (context, animation, secondaryAnimation, child) {
                      // final curvedValue =
                      //     Curves.easeInOutBack.transform(animation.value) - 1.0;
                      return Opacity(
                        opacity: animation.value,
                        child: ScreenLock(),
                      );
                      // Transform(
                      //   transform: Matrix4.translationValues(
                      //       0.0, curvedValue * 200, 0.0),
                      //   child: Opacity(
                      //     opacity: animation.value,
                      //     child: ScreenLock(),
                      //   ),
                      // );
                    },
                    pageBuilder: (buildContext, animation, secondaryAnimation) {
                      // ignore: null_check_always_fails
                      return null!;
                    },
                    barrierDismissible: true,
                    barrierLabel: "",
                    barrierColor: Colors.black.withOpacity(0.5),
                    transitionDuration: Duration(milliseconds: 250),
                  )
                : null;
          }
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        setState(() {
          isAppActive = false;
        });
        break;
      case AppLifecycleState.hidden:
        print("app in hidden");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: globalScaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: isNotes
              ? Icon(
                  CupertinoIcons.pencil_outline,
                  color: Theme.of(context).iconTheme.color,
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      isNotes = true;
                      isTodos = false;
                    });
                  },
                  icon: Icon(Icons.arrow_back,
                      color: Theme.of(context).iconTheme.color),
                ),
          title: Text(
            isNotes
                ? "${AppLocalization.of(context)?.getTranslatedValue('notes')}"
                : "${AppLocalization.of(context)?.getTranslatedValue('schedules')}",
            style: TextStyle(
                // color: AppColors.blackColor
                ),
          ),
          actions: [
            SizedBox(
              width: 10,
            ),
            IconButton(
                onPressed: () {
                  openDrawer();
                },
                icon: Icon(CupertinoIcons.text_alignright,
                    color: Theme.of(context).iconTheme.color))
          ],
          centerTitle: true,
        ),
        endDrawer: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Drawer(
            backgroundColor: AppColors.drawerBackgroundColor.withOpacity(0.9),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 150,
                    child: Center(
                        child: Icon(
                      CupertinoIcons.pencil_outline,
                      color: AppColors.whiteColor,
                      size: 35,
                    )),
                  ),
                  Divider(
                    color: AppColors.whiteColor.withOpacity(0.7),
                  ),
                  ListTile(
                    splashColor: AppColors.greenSplashColor,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        SlideAnimation.createRightRoute(
                          TodoDoneScreen(),
                        ),
                      );
                    },
                    title: Text(
                      "${AppLocalization.of(context)?.getTranslatedValue('finished')}",
                      style: TextStyle(color: AppColors.whiteColor),
                    ),
                    leading: Icon(Icons.done_all, color: AppColors.whiteColor),
                  ),
                  Divider(
                    endIndent: 10,
                    indent: 10,
                    color: Colors.white38,
                  ),
                  ListTile(
                    splashColor: AppColors.orangeSplashColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          SlideAnimation.createRightRoute(ArchiveNoteScreen()));
                    },
                    title: Text(
                      "${AppLocalization.of(context)?.getTranslatedValue('archive')}",
                      style: TextStyle(color: AppColors.whiteColor),
                    ),
                    leading: Icon(Icons.archive_outlined,
                        color: AppColors.whiteColor),
                  ),
                  Divider(
                    endIndent: 10,
                    indent: 10,
                    color: Colors.white38,
                  ),
                  ListTile(
                    splashColor: AppColors.redColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          SlideAnimation.createRightRoute(DeleteNoteScreen()));
                    },
                    title: Text(
                      "${AppLocalization.of(context)?.getTranslatedValue('deleted')}",
                      style: TextStyle(color: AppColors.whiteColor),
                    ),
                    leading:
                        Icon(Icons.delete_forever, color: AppColors.whiteColor),
                  ),
                  Divider(
                    endIndent: 10,
                    indent: 10,
                    color: Colors.white38,
                  ),
                  ListTile(
                    splashColor: Colors.grey[400],
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          SlideAnimation.createRightRoute(SettingScreen()));
                    },
                    title: Text(
                      "${AppLocalization.of(context)?.getTranslatedValue('settings')}",
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: Icon(Icons.settings, color: AppColors.whiteColor),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Material(
          elevation: 20,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Theme.of(context).scaffoldBackgroundColor,
            height: 60,
            child: Row(
              children: [
                AnimatedContainer(
                  width: isNotes
                      ? isAdd
                          ? MediaQuery.of(context).size.width * 0.2
                          : MediaQuery.of(context).size.width * 0.5
                      : MediaQuery.of(context).size.width * 0.2,
                  duration: Duration(milliseconds: 200),
                  // curve: Curves.bounceOut,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        isNotes = true;
                        isTodos = false;
                        isAdd = false;
                      });
                      Future.delayed(
                        Duration(milliseconds: 70),
                        () {
                          setState(() {
                            isNotesTextShow = true;
                            isAddTextShow = false;
                            isTodosTextShow = false;
                          });
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          border: isNotes && !isAdd
                              ? Border.all(color: AppColors.blueGrayColor)
                              : null,
                          borderRadius: BorderRadius.circular(50)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.pencil_ellipsis_rectangle,
                              color: Theme.of(context).highlightColor,
                              size: isNotes ? 25 : 20,
                            ),
                            if (isNotes && !isAdd && isNotesTextShow)
                              SizedBox(
                                width: 10,
                              ),
                            if (isNotes && !isAdd && isNotesTextShow)
                              Text(
                                  "${AppLocalization.of(context)?.getTranslatedValue('notes')}")
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                AnimatedContainer(
                  width: isAdd
                      ? MediaQuery.of(context).size.width * 0.5
                      : MediaQuery.of(context).size.width * 0.2,
                  duration: Duration(milliseconds: 200),
                  // curve: Curves.bounceOut,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        isAdd = true;
                      });
                      Future.delayed(
                        Duration(milliseconds: 70),
                        () {
                          setState(() {
                            isNotesTextShow = false;
                            isAddTextShow = true;
                            isTodosTextShow = false;
                          });
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          border: isAdd
                              ? Border.all(color: AppColors.blueColor)
                              : null,
                          borderRadius: BorderRadius.circular(50)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.add,
                              color: Theme.of(context).highlightColor,
                              size: isAdd ? 25 : 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                AnimatedContainer(
                  width: isTodos
                      ? isAdd
                          ? MediaQuery.of(context).size.width * 0.2
                          : MediaQuery.of(context).size.width * 0.5
                      : MediaQuery.of(context).size.width * 0.2,
                  duration: Duration(milliseconds: 200),
                  // curve: Curves.easeIn,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        isNotes = false;
                        isTodos = true;
                        isAdd = false;
                      });
                      Future.delayed(
                        Duration(milliseconds: 120),
                        () {
                          setState(() {
                            isNotesTextShow = false;
                            isAddTextShow = false;
                            isTodosTextShow = true;
                          });
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          border: isTodos && !isAdd
                              ? Border.all(color: AppColors.blueGrayColor)
                              : null,
                          borderRadius: BorderRadius.circular(50)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.list_bullet_indent,
                              color: Theme.of(context).highlightColor,
                              size: isTodos ? 25 : 20,
                            ),
                            if (isTodos && !isAdd && isTodosTextShow)
                              SizedBox(
                                width: 10,
                              ),
                            if (isTodos && !isAdd && isTodosTextShow)
                              Text(
                                "${AppLocalization.of(context)?.getTranslatedValue('schedules')}",
                                style:
                                    TextStyle(overflow: TextOverflow.ellipsis),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            isNotes ? NotesScreen() : TodoScreen(),
            if (isAdd)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Container(
                    height: 35,
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Theme.of(context).scaffoldBackgroundColor,
                          Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.1),
                          Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0),
                          Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.1),
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 3),
                      scrollDirection: Axis.horizontal,
                      children: [
                        OpenContainer(
                          transitionType: _containerTransitionType,
                          transitionDuration: Duration(milliseconds: 400),
                          openBuilder: (context, closedContainer) =>
                              NoteDetailScreen(
                            isUpdateNote: false,
                          ),
                          openColor: Theme.of(context).cardColor,
                          closedElevation: 0,
                          openElevation: 0,
                          closedColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          closedBuilder: (context, openContainer) => Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.blueColor),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              child: Center(
                                child: Text(
                                  "${AppLocalization.of(context)?.getTranslatedValue('add_note')}",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        OpenContainer(
                          transitionType: _containerTransitionType,
                          transitionDuration: Duration(milliseconds: 400),
                          closedElevation: 0,
                          openElevation: 0,
                          openColor: Theme.of(context).cardColor,
                          closedColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          openBuilder: (context, _) {
                            return TodoDetailscreen(
                              isUpdateTodo: false,
                            );
                          },
                          closedBuilder: (context, _) => Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.blueColor),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              child: Center(
                                child: Text(
                                  "${AppLocalization.of(context)?.getTranslatedValue('add_schedule')}",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        OpenContainer(
                          transitionType: _containerTransitionType,
                          transitionDuration: Duration(milliseconds: 400),
                          closedElevation: 0,
                          openElevation: 0,
                          closedColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          openColor: Theme.of(context).cardColor,
                          openBuilder: (context, _) => TextRecognizerScreen(),
                          closedBuilder: (context, _) => Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.blueColor),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              child: Center(
                                child: Text(
                                  "${AppLocalization.of(context)?.getTranslatedValue('scane_note')}",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // checkPassword(
  //     {required TextEditingController oneCtr,
  //     required TextEditingController twoCtr,
  //     required TextEditingController threeCtr,
  //     required TextEditingController fourCtr,
  //     required bool one,
  //     required bool two,
  //     required bool three,
  //     required bool four}) async {
  //   showGeneralDialog(
  //     context: context,
  //     pageBuilder: (BuildContext dialogContext, Animation<double> animation,
  //         Animation<double> secondaryAnimation) {
  //       return WillPopScope(
  //         onWillPop: () async {
  //           SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  //           return false;
  //         },
  //         child: Material(
  //           color: Theme.of(context).scaffoldBackgroundColor,
  //           child: StatefulBuilder(builder: (context, setState) {
  //             reSetPassword() {
  //               setState(() {
  //                 one = false;
  //                 two = false;
  //                 three = false;
  //                 four = false;
  //               });
  //               oneCtr.clear();
  //               twoCtr.clear();
  //               threeCtr.clear();
  //               fourCtr.clear();
  //             }
  //             checkPassword(String password) {
  //               if (password == originalPass) {
  //                 reSetPassword();
  //                 Navigator.pop(context);
  //               } else {
  //                 reSetPassword();
  //               }
  //             }
  //             void fillPassword(String text) {
  //               if (oneCtr.text.isEmpty) {
  //                 setState(() {
  //                   oneCtr.text = text;
  //                   one = true;
  //                   log(oneCtr.text);
  //                 });
  //               } else if (oneCtr.text.isNotEmpty && twoCtr.text.isEmpty) {
  //                 setState(() {
  //                   twoCtr.text = text;
  //                   two = true;
  //                   log(twoCtr.text);
  //                 });
  //               } else if (oneCtr.text.isNotEmpty &&
  //                   twoCtr.text.isNotEmpty &&
  //                   threeCtr.text.isEmpty) {
  //                 setState(() {
  //                   threeCtr.text = text;
  //                   three = true;
  //                   log(threeCtr.text);
  //                 });
  //               } else if (oneCtr.text.isNotEmpty &&
  //                   twoCtr.text.isNotEmpty &&
  //                   threeCtr.text.isNotEmpty &&
  //                   fourCtr.text.isEmpty) {
  //                 setState(() {
  //                   fourCtr.text = text;
  //                   four = true;
  //                   log(fourCtr.text);
  //                   // print(
  //                   //     "The Password is :: => ${oneCtr.text}${twoCtr.text}${threeCtr.text}${fourCtr.text}");
  //                   Timer(Duration(milliseconds: 120), () {
  //                     checkPassword(
  //                         "${oneCtr.text}${twoCtr.text}${threeCtr.text}${fourCtr.text}");
  //                   });
  //                 });
  //               }
  //             }
  //             void deleteLastPasswordDigit() {
  //               if (fourCtr.text.isNotEmpty) {
  //                 fourCtr.clear();
  //                 setState(() {
  //                   four = false;
  //                 });
  //               } else if (fourCtr.text.isEmpty && threeCtr.text.isNotEmpty) {
  //                 threeCtr.clear();
  //                 setState(() {
  //                   three = false;
  //                 });
  //               } else if (fourCtr.text.isEmpty &&
  //                   threeCtr.text.isEmpty &&
  //                   twoCtr.text.isNotEmpty) {
  //                 twoCtr.clear();
  //                 setState(() {
  //                   two = false;
  //                 });
  //               } else if (fourCtr.text.isEmpty &&
  //                   threeCtr.text.isEmpty &&
  //                   twoCtr.text.isEmpty &&
  //                   oneCtr.text.isNotEmpty) {
  //                 oneCtr.clear();
  //                 setState(() {
  //                   one = false;
  //                 });
  //               }
  //             }
  //             return Column(
  //               mainAxisSize: MainAxisSize.max,
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               children: [
  //                 Text(
  //                   "Enter Password",
  //                   style: TextStyle(fontSize: 28),
  //                 ),
  //                 SizedBox(
  //                   height: 40,
  //                 ),
  //                 Wrap(
  //                   alignment: WrapAlignment.start,
  //                   spacing: 4,
  //                   direction: Axis.horizontal,
  //                   runSpacing: 10,
  //                   children: [
  //                     Container(
  //                       height: 15,
  //                       width: 15,
  //                       decoration: BoxDecoration(
  //                         border: Border.all(
  //                           color: Theme.of(context).highlightColor,
  //                           width: 1,
  //                         ),
  //                         color: one == true
  //                             ? Theme.of(context).highlightColor
  //                             : Colors.white12,
  //                         shape: BoxShape.circle,
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       width: 10,
  //                     ),
  //                     Container(
  //                       height: 15,
  //                       width: 15,
  //                       decoration: BoxDecoration(
  //                         border: Border.all(
  //                           color: Theme.of(context).highlightColor,
  //                           width: 1,
  //                         ),
  //                         color: two == true
  //                             ? Theme.of(context).highlightColor
  //                             : Colors.white12,
  //                         shape: BoxShape.circle,
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       width: 10,
  //                     ),
  //                     Container(
  //                       height: 15,
  //                       width: 15,
  //                       decoration: BoxDecoration(
  //                         border: Border.all(
  //                             color: Theme.of(context).highlightColor,
  //                             width: 1),
  //                         color: three == true
  //                             ? Theme.of(context).highlightColor
  //                             : Colors.white12,
  //                         shape: BoxShape.circle,
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       width: 10,
  //                     ),
  //                     Container(
  //                       height: 15,
  //                       width: 15,
  //                       decoration: BoxDecoration(
  //                         border: Border.all(
  //                             color: Theme.of(context).highlightColor,
  //                             width: 1),
  //                         color: four == true
  //                             ? Theme.of(context).highlightColor
  //                             : Colors.white12,
  //                         shape: BoxShape.circle,
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //                 SizedBox(
  //                   height: 40,
  //                 ),
  //                 Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     CustomPasswordButton(
  //                       onTap: () {
  //                         fillPassword("1");
  //                       },
  //                       text: "1",
  //                     ),
  //                     SizedBox(
  //                       width: 30,
  //                     ),
  //                     CustomPasswordButton(
  //                       onTap: () {
  //                         fillPassword("2");
  //                       },
  //                       text: "2",
  //                     ),
  //                     SizedBox(
  //                       width: 30,
  //                     ),
  //                     CustomPasswordButton(
  //                       onTap: () {
  //                         fillPassword("3");
  //                       },
  //                       text: "3",
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(
  //                   height: 30,
  //                 ),
  //                 Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     CustomPasswordButton(
  //                       onTap: () {
  //                         fillPassword("4");
  //                       },
  //                       text: "4",
  //                     ),
  //                     SizedBox(
  //                       width: 30,
  //                     ),
  //                     CustomPasswordButton(
  //                       onTap: () {
  //                         fillPassword("5");
  //                       },
  //                       text: "5",
  //                     ),
  //                     SizedBox(
  //                       width: 30,
  //                     ),
  //                     CustomPasswordButton(
  //                       onTap: () {
  //                         fillPassword("6");
  //                       },
  //                       text: "6",
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(
  //                   height: 30,
  //                 ),
  //                 Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     CustomPasswordButton(
  //                       onTap: () {
  //                         fillPassword("7");
  //                       },
  //                       text: "7",
  //                     ),
  //                     SizedBox(
  //                       width: 30,
  //                     ),
  //                     CustomPasswordButton(
  //                       onTap: () {
  //                         fillPassword("8");
  //                       },
  //                       text: "8",
  //                     ),
  //                     SizedBox(
  //                       width: 30,
  //                     ),
  //                     CustomPasswordButton(
  //                       onTap: () {
  //                         fillPassword("9");
  //                       },
  //                       text: "9",
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(
  //                   height: 30,
  //                 ),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Container(
  //                       height: 80,
  //                       width: 80,
  //                     ),
  //                     SizedBox(
  //                       width: 30,
  //                     ),
  //                     CustomPasswordButton(
  //                       onTap: () {
  //                         fillPassword("0");
  //                       },
  //                       text: "0",
  //                     ),
  //                     SizedBox(
  //                       width: 30,
  //                     ),
  //                     SizedBox(
  //                       height: 80,
  //                       width: 80,
  //                       child: GestureDetector(
  //                         onTap: () {
  //                           deleteLastPasswordDigit();
  //                         },
  //                         child: Center(
  //                           child: Text(
  //                             "Delete",
  //                             style: TextStyle(fontSize: 22),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(
  //                   height: 30,
  //                 )
  //               ],
  //             );
  //           }),
  //         ),
  //       );
  //     },
  //     barrierDismissible: true,
  //     barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  //     barrierColor: Colors.black,
  //     transitionDuration: const Duration(milliseconds: 200),
  //   ).then((value) {
  //     setState(() {
  //       isAppResume = false;
  //       print("$isDialogOpen-----------------------");
  //     });
  //   });
  // }
  // for fingerprint only
  // Future<void> _authenticate() async {
  //   // Check if already authenticating, return if true
  //   if (_isAuthenticating) return;
  //   setState(() {
  //     _isAuthenticating = true;
  //     _authorized = 'Authenticating';
  //   });
  //   bool authenticated = false;
  //   try {
  //     authenticated = await auth.authenticate(
  //       localizedReason: 'Let OS determine authentication method',
  //       options: const AuthenticationOptions(
  //         stickyAuth: true,
  //       ),
  //     );
  //   } on PlatformException catch (e) {
  //     print(e);
  //     setState(() {
  //       _authorized = 'Error - ${e.message}';
  //     });
  //   } finally {
  //     setState(() {
  //       _isAuthenticating = false;
  //       _authorized = authenticated ? 'Authorized' : 'Not Authorized';
  //     });
  //   }
  // }
}
//  flex: isNotes
//                   ? isAdd
//                       ? 1
//                       : 2
//                   : 1,
//               flex: isAdd ? 2 : 1,
//               flex: isTodos
//                   ? isAdd
//                       ? 1
//                       : 2
//                   : 1,