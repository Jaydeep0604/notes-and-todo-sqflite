import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:notes_sqflite/config/constant.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/language/localisation.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/model/note_model.dart';
import 'package:notes_sqflite/ui/archive_screen/archive_note_screen.dart';
import 'package:notes_sqflite/ui/delete_note_screen/delete_screen.dart';
import 'package:notes_sqflite/ui/note_screen/notes_screen.dart';
import 'package:notes_sqflite/ui/setting_screen/setting_screen.dart';
import 'package:notes_sqflite/ui/todo_screen/todo_done_screen.dart';
import 'package:notes_sqflite/ui/todo_screen/todo_screen.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:notes_sqflite/widget/custom_password_button.dart';

class Base extends StatefulWidget {
  const Base({super.key});
  static openDrawer(BuildContext context) {
    _BaseState? state = context.findAncestorStateOfType<_BaseState>();
    state?.openDrawer();
  }

  @override
  State<Base> createState() => _BaseState();
}

class _BaseState extends State<Base> with WidgetsBindingObserver {
  DBHelper? dbHelper;
  final LocalAuthentication auth = LocalAuthentication();

  // bool? _canCheckBiometrics;
  // List<BiometricType>? _availableBiometrics;

  // ignore: unused_field
  String _authorized = 'Not Authorized';
  // ignore: unused_field
  SupportState _supportState = SupportState.unknown;

  bool isNotes = true, isTodos = false;

  bool isAppResume = false;

  bool isDialogOpen = false;

  bool one = false, two = false, three = false, four = false;

  late GlobalKey<ScaffoldState> globalScaffoldKey;

  late Future<List<NotesModel>> noteList;

  late TextEditingController titleCtr, ageCtr, descriptionCtr, emailCtr;
  late TextEditingController oneCtr, twoCtr, threeCtr, fourCtr;
  bool _isAuthenticating = false;

  void initState() {
    super.initState();
    globalScaffoldKey = GlobalKey<ScaffoldState>();
    WidgetsBinding.instance.addObserver(this);
    oneCtr = TextEditingController();
    twoCtr = TextEditingController();
    threeCtr = TextEditingController();
    fourCtr = TextEditingController();
    if (isBioMetricLock) {
      auth.isDeviceSupported().then(
            (bool isSupported) => setState(() => _supportState = isSupported
                ? SupportState.supported
                : SupportState.unsupported),
          );
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth
          .authenticate(
        localizedReason: 'Scan your fingerprint or face to authenticate',
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          // useErrorDialogs: false,
        ),
      )
          .then((value) {
        if (value == false) {
          setState(() {
            _isAuthenticating = true;
          });
        }
        if (value == true) {
          setState(() {
            _isAuthenticating = false;
          });
        }
        return _isAuthenticating;
      });
      setState(() {
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
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

  

  Dialog? _dialog;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        if (isBioMetricLock) {
          if (_isAuthenticating == true) {
            _authenticateWithBiometrics();
          }
        } else {
          if (state == AppLifecycleState.resumed && isAppResume == true) {
            checkPassword(
                oneCtr: oneCtr,
                twoCtr: twoCtr,
                threeCtr: threeCtr,
                fourCtr: fourCtr,
                one: one,
                two: two,
                three: three,
                four: four);
          }
        }
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        setState(() {
          isAppResume = true;
          _isAuthenticating = true;
        });
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
      case AppLifecycleState.hidden:
        print("app in hidden");
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
    return Scaffold(
      key: globalScaffoldKey,
      appBar: AppBar(
        // backgroundColor: AppColors.whiteColor,
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
        width: MediaQuery.of(context).size.width * 0.65,
        child: Drawer(
          backgroundColor: AppColors.drawerBackgroundColor.withOpacity(0.9),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return TodoDoneScreen();
                  }));
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArchiveNoteScreen(),
                    ),
                  );
                },
                title: Text(
                  "${AppLocalization.of(context)?.getTranslatedValue('archive')}",
                  style: TextStyle(color: AppColors.whiteColor),
                ),
                leading:
                    Icon(Icons.archive_outlined, color: AppColors.whiteColor),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeleteNoteScreen(),
                    ),
                  );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingScreen(),
                    ),
                  );
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          // color: Colors.black87,
          // color: AppColors.whiteColor,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
        ),
        height: 60,
        child: Row(
          children: [
            Expanded(
              flex: isNotes == true ? 1 : 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      isNotes = true;
                      isTodos = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.bottomNavigationBarFirstColor,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.4))),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.pencil_ellipsis_rectangle,
                        color: Theme.of(context).iconTheme.color,
                        size: isNotes ? 25 : 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: isTodos ? 1 : 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      isNotes = false;
                      isTodos = true;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bottomNavigationBarSecondColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.list_bullet_indent,
                        color: Theme.of(context).iconTheme.color,
                        size: isTodos ? 25 : 20,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      body: isNotes ? NotesScreen() : TodoScreen(),
    );
  }

  void checkPassword(
      {required TextEditingController oneCtr,
      required TextEditingController twoCtr,
      required TextEditingController threeCtr,
      required TextEditingController fourCtr,
      required bool one,
      required bool two,
      required bool three,
      required bool four}) async {
    _dialog = await showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext dialogContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return WillPopScope(
          onWillPop: () async {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            return false;
          },
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: StatefulBuilder(builder: (context, setState) {
              isDialogOpen = true;

              reSetPassword() {
                setState(() {
                  one = false;
                  two = false;
                  three = false;
                  four = false;
                });
                oneCtr.clear();
                twoCtr.clear();
                threeCtr.clear();
                fourCtr.clear();
              }

              checkPassword(String password) {
                String defaultPassword = "1245";
                if (password == defaultPassword) {
                  reSetPassword();
                  Navigator.pop(context);
                } else {
                  reSetPassword();
                }
              }

              void fillPassword(String text) {
                if (oneCtr.text.isEmpty) {
                  setState(() {
                    oneCtr.text = text;
                    one = true;
                    log(oneCtr.text);
                  });
                } else if (oneCtr.text.isNotEmpty && twoCtr.text.isEmpty) {
                  setState(() {
                    twoCtr.text = text;
                    two = true;
                    log(twoCtr.text);
                  });
                } else if (oneCtr.text.isNotEmpty &&
                    twoCtr.text.isNotEmpty &&
                    threeCtr.text.isEmpty) {
                  setState(() {
                    threeCtr.text = text;
                    three = true;
                    log(threeCtr.text);
                  });
                } else if (oneCtr.text.isNotEmpty &&
                    twoCtr.text.isNotEmpty &&
                    threeCtr.text.isNotEmpty &&
                    fourCtr.text.isEmpty) {
                  setState(() {
                    fourCtr.text = text;
                    four = true;
                    log(fourCtr.text);
                    print(
                        "The Password is :: => ${oneCtr.text}${twoCtr.text}${threeCtr.text}${fourCtr.text}");
                    Timer(Duration(milliseconds: 120), () {
                      checkPassword(
                          "${oneCtr.text}${twoCtr.text}${threeCtr.text}${fourCtr.text}");
                    });
                  });
                }
              }

              void deleteLastPasswordDigit() {
                if (fourCtr.text.isNotEmpty) {
                  fourCtr.clear();
                  setState(() {
                    four = false;
                  });
                } else if (fourCtr.text.isEmpty && threeCtr.text.isNotEmpty) {
                  threeCtr.clear();
                  setState(() {
                    three = false;
                  });
                } else if (fourCtr.text.isEmpty &&
                    threeCtr.text.isEmpty &&
                    twoCtr.text.isNotEmpty) {
                  twoCtr.clear();
                  setState(() {
                    two = false;
                  });
                } else if (fourCtr.text.isEmpty &&
                    threeCtr.text.isEmpty &&
                    twoCtr.text.isEmpty &&
                    oneCtr.text.isNotEmpty) {
                  oneCtr.clear();
                  setState(() {
                    one = false;
                  });
                }
              }

              return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Enter Password",
                    style: TextStyle(fontSize: 28),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 4,
                    direction: Axis.horizontal,
                    runSpacing: 10,
                    children: [
                      Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).highlightColor,
                            width: 1,
                          ),
                          color: one == true
                              ? Theme.of(context).highlightColor
                              : Colors.white12,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).highlightColor,
                            width: 1,
                          ),
                          color: two == true
                              ? Theme.of(context).highlightColor
                              : Colors.white12,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).highlightColor,
                              width: 1),
                          color: three == true
                              ? Theme.of(context).highlightColor
                              : Colors.white12,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).highlightColor,
                              width: 1),
                          color: four == true
                              ? Theme.of(context).highlightColor
                              : Colors.white12,
                          shape: BoxShape.circle,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 40,
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
                        text: "1",
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      CustomPasswordButton(
                        onTap: () {
                          fillPassword("2");
                        },
                        text: "2",
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      CustomPasswordButton(
                        onTap: () {
                          fillPassword("3");
                        },
                        text: "3",
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomPasswordButton(
                        onTap: () {
                          fillPassword("4");
                        },
                        text: "4",
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      CustomPasswordButton(
                        onTap: () {
                          fillPassword("5");
                        },
                        text: "5",
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      CustomPasswordButton(
                        onTap: () {
                          fillPassword("6");
                        },
                        text: "6",
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomPasswordButton(
                        onTap: () {
                          fillPassword("7");
                        },
                        text: "7",
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      CustomPasswordButton(
                        onTap: () {
                          fillPassword("8");
                        },
                        text: "8",
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      CustomPasswordButton(
                        onTap: () {
                          fillPassword("9");
                        },
                        text: "9",
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      CustomPasswordButton(
                        onTap: () {
                          fillPassword("0");
                        },
                        text: "0",
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: GestureDetector(
                          onTap: () {
                            deleteLastPasswordDigit();
                          },
                          child: Center(
                            child: Text(
                              "Delete",
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  )
                ],
              );
            }),
          ),
        );
      },
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 200),
    ).then((value) {
      setState(() {
        isAppResume = false;
      });
      return null;
    });
  }
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
