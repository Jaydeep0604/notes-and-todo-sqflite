import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:notes_sqflite/config/shared_store.dart';
import 'package:notes_sqflite/language/localisation.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:notes_sqflite/utils/app_message.dart';
import 'package:notes_sqflite/widget/switch_widget.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  late TextEditingController passCtr,
      confirm_passCtr,
      current_passCtr,
      movieNameCtr,
      teacherNameCtr;

  final _questionKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();

  final FocusNode focusMovie = FocusNode();
  final FocusNode focuseTeacherName = FocusNode();
  final FocusNode focusePassword = FocusNode();
  final FocusNode focuseConfirmPassword = FocusNode();

  String movieName = '', teacherName = '', password = '';

  bool pass_obscureText = true,
      current_pass_obscureText = true,
      conf_pass_obscureText = true,
      teacher_name_obscureText = true,
      movie_name_obscureText = true;

  bool isResetQuestions = false;
  bool isResetPassword = false;

  // bool _isAuthenticating = false;
  bool _isAuthenticated = false;
  void initState() {
    super.initState();
    movieNameCtr = TextEditingController();
    teacherNameCtr = TextEditingController();
    passCtr = TextEditingController();
    confirm_passCtr = TextEditingController();
    current_passCtr = TextEditingController();
    // checkLocks();
    getData();
  }

  void getData() async {
    movieName = await sharedStore.getSecurityPassWordMovieName() ?? '';
    teacherName = await sharedStore.getSecurityPassWordTeacherName() ?? '';
    password = await sharedStore.getAppLockPassword() ?? '';
    setState(() {
      movieNameCtr = TextEditingController(text: movieName);
      teacherNameCtr = TextEditingController(text: teacherName);
      current_passCtr = TextEditingController(text: password);
    });
  }

  // checkLocks() async {
  //   isBiometricLock = await sharedStore.getBiometric() ?? false;
  //   isPinLock = await sharedStore.getBiometric() ?? false;
  // }

  enablePinLock(bool isPinLockStatus) async {
    sharedStore.enablePinLock(isPinLockStatus);
    sharedStore.enableBiometricLock(false);
  }

  enableBiometric(bool isBiometricLockStatus) async {
    sharedStore.enableBiometricLock(isBiometricLockStatus);
    sharedStore.enablePinLock(false);
  }

  resetQuestions() {
    setState(() {
      movieNameCtr.clear();
      teacherNameCtr.clear();
      isResetQuestions = true;
    });
  }

  resetPassword() {
    setState(() {
      passCtr.clear();
      confirm_passCtr.clear();
      isResetPassword = true;
    });
  }

  final LocalAuthentication auth = LocalAuthentication();

  Future<bool?> _authenticateWithBiometrics() async {
    bool authenticated = false;
    String _authorized = 'Not Authorized';
    try {
      setState(() {
        // _isAuthenticating = true;
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
            // _isAuthenticating = true;
            _isAuthenticated = false;
          });
        }
        if (value == true) {
          setState(() {
            // _isAuthenticating = false;
            _isAuthenticated = true;
          });
        }
        return _isAuthenticated;
      });
      setState(() {
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticated = false;
        // _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return _isAuthenticated;
    }
    return _isAuthenticated;
    // if (!mounted) {
    //   return _isAuthenticated;
    // }
    // final String message = authenticated ? 'Authorized' : 'Not Authorized';
    // setState(() {
    //   _authorized = message;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).iconTheme.color),
          ),
          title: Text(
            "${AppLocalization.of(context)?.getTranslatedValue('app_lock')}",
            style: TextStyle(
                // color: Colors.black,
                ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Theme.of(context).cardColor,
                    child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.fingerprint_sharp,
                        ),
                        title: Text(
                            "${AppLocalization.of(context)?.getTranslatedValue('enable_biometric_lock')}"),
                        trailing: SwitchWidget(
                          value: isBiometricLock!,
                          onTap: () {
                            _authenticateWithBiometrics().then((value) {
                              if (value == true) {
                                setState(() {
                                  setState(() {
                                    isBiometricLock = !isBiometricLock!;
                                    isPinLock = false;
                                  });
                                  enableBiometric(isBiometricLock!);
                                });
                              }
                            });
                          },
                        )),
                  ),
                  Container(
                    color: Theme.of(context).cardColor,
                    child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          CupertinoIcons.lock_shield,
                        ),
                        title: Text(
                            "${AppLocalization.of(context)?.getTranslatedValue('enable_pin_lock')}"),
                        trailing: SwitchWidget(
                          value: isPinLock!,
                          onTap: () async {
                            movieName = await sharedStore
                                    .getSecurityPassWordMovieName() ??
                                '';
                            teacherName = await sharedStore
                                    .getSecurityPassWordTeacherName() ??
                                '';
                            password =
                                await sharedStore.getAppLockPassword() ?? '';
                            if (movieName.isNotEmpty &&
                                teacherName.isNotEmpty &&
                                password.isNotEmpty) {
                              setState(() {
                                isPinLock = !isPinLock!;
                                isBiometricLock = false;
                              });
                              enablePinLock(isPinLock!);
                            } else {
                              if (movieNameCtr.text.isEmpty) {
                                focusMovie.requestFocus();
                              } else if (teacherNameCtr.text.isEmpty) {
                                focuseTeacherName.requestFocus();
                              } else if (passCtr.text.isEmpty) {
                                focusePassword.requestFocus();
                              } else if (confirm_passCtr.text.isEmpty) {
                                focuseConfirmPassword.requestFocus();
                              } else {
                                final movieName = await sharedStore
                                    .getSecurityPassWordMovieName();
                                final teacherName = await sharedStore
                                    .getSecurityPassWordTeacherName();
                                final password =
                                    await sharedStore.getAppLockPassword();
                                if (movieName == null || movieName == '') {
                                  AppMessage.showToast(context,
                                      "${AppLocalization.of(context)?.getTranslatedValue('please_submit_questions')}");
                                } else if (teacherName == null ||
                                    teacherName == '') {
                                  AppMessage.showToast(context,
                                      "${AppLocalization.of(context)?.getTranslatedValue('please_submit_questions')}");
                                } else if (password == null || password == '') {
                                  AppMessage.showToast(context,
                                      "${AppLocalization.of(context)?.getTranslatedValue('please_set_password')}");
                                } else {
                                  enablePinLock(isPinLock!);
                                  setState(() {
                                    isPinLock = !isPinLock!;
                                    isBiometricLock = false;
                                  });
                                }
                                // saveQuestions(
                                //     teacherName: teacherName,
                                //     movieName: movieName);
                                // savePassword(password: password);
                              }
                            }
                          },
                        )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${AppLocalization.of(context)?.getTranslatedValue('security_questions')}",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: AppColors.blueColor),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          if (teacherName != '' && movieName != '')
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
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              resetQuestions();
                            },
                            child: Text(
                              "${AppLocalization.of(context)?.getTranslatedValue('reset')}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                      color: AppColors.redColor, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Form(
                        key: _questionKey,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "• ${AppLocalization.of(context)?.getTranslatedValue('what_s_your_favorite_movie')}?",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: TextFormField(
                                  // enabled: widget.enabled,
                                  focusNode: focusMovie,
                                  readOnly: movieName == ""
                                      ? false
                                      : isResetQuestions == false
                                          ? true
                                          : false,
                                  obscureText: movie_name_obscureText,
                                  controller: movieNameCtr,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "${AppLocalization.of(context)?.getTranslatedValue('please_fill_your_favorite_movie_name')}";
                                    }
                                    return null;
                                  },
                                  maxLines: 1,
                                  minLines: 1,
                                  style: TextStyle(
                                    fontSize:
                                        14, //fontFamily: KSMFontFamily.robotoRgular
                                  ),
                                  decoration: InputDecoration(
                                      suffixIcon: Transform.scale(
                                        scale: 0.9,
                                        child: InkWell(
                                            onTap: () {
                                              if (movieName.isNotEmpty) {
                                                if (isResetQuestions) {
                                                  setState(() {
                                                    movie_name_obscureText =
                                                        !movie_name_obscureText;
                                                  });
                                                } else {
                                                  if (movie_name_obscureText ==
                                                      true) {
                                                    _authenticateWithBiometrics()
                                                        .then((value) {
                                                      if (value == true) {
                                                        setState(() {
                                                          movie_name_obscureText =
                                                              false;
                                                        });
                                                      }
                                                    });
                                                  } else {
                                                    setState(() {
                                                      movie_name_obscureText =
                                                          true;
                                                    });
                                                  }
                                                }
                                              } else {
                                                setState(() {
                                                  movie_name_obscureText =
                                                      !movie_name_obscureText;
                                                });
                                              }
                                            },
                                            child: movie_name_obscureText
                                                ? Icon(Icons
                                                    .visibility_off_outlined)
                                                : Icon(
                                                    Icons.visibility_outlined)),
                                      ),
                                      errorStyle: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(color: Colors.red),
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
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
                              Text(
                                "• ${AppLocalization.of(context)?.getTranslatedValue('what_was_your_favorite_school_teacher_s_name')}?",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: TextFormField(
                                  // enabled: widget.enabled,
                                  focusNode: focuseTeacherName,
                                  readOnly: teacherName == ""
                                      ? false
                                      : isResetQuestions == false
                                          ? true
                                          : false,
                                  obscureText: teacher_name_obscureText,
                                  controller: teacherNameCtr,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "${AppLocalization.of(context)?.getTranslatedValue('please_fill_your_favorite_school_teacher_s_name')}";
                                    }
                                    return null;
                                  },
                                  maxLines: 1,
                                  minLines: 1,

                                  style: TextStyle(
                                    fontSize:
                                        14, //fontFamily: KSMFontFamily.robotoRgular
                                  ),
                                  decoration: InputDecoration(
                                      suffixIcon: Transform.scale(
                                        scale: 0.9,
                                        child: InkWell(
                                            onTap: () {
                                              if (teacherName.isNotEmpty) {
                                                if (isResetQuestions) {
                                                  setState(() {
                                                    teacher_name_obscureText =
                                                        !teacher_name_obscureText;
                                                  });
                                                } else {
                                                  if (teacher_name_obscureText ==
                                                      true) {
                                                    _authenticateWithBiometrics()
                                                        .then((value) {
                                                      if (value == true) {
                                                        setState(() {
                                                          teacher_name_obscureText =
                                                              false;
                                                        });
                                                      }
                                                    });
                                                  } else {
                                                    setState(() {
                                                      teacher_name_obscureText =
                                                          true;
                                                    });
                                                  }
                                                }
                                              } else {
                                                setState(() {
                                                  teacher_name_obscureText =
                                                      !teacher_name_obscureText;
                                                });
                                              }
                                            },
                                            child: teacher_name_obscureText
                                                ? Icon(Icons
                                                    .visibility_off_outlined)
                                                : Icon(
                                                    Icons.visibility_outlined)),
                                      ),
                                      errorStyle: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(color: Colors.red),
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                      hintText:
                                          "${AppLocalization.of(context)?.getTranslatedValue('teacher_s_name')}",
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
                              if (movieName.isEmpty ||
                                  teacherName.isEmpty ||
                                  isResetQuestions == true)
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 30,
                                    ),
                                    MaterialButton(
                                      height: 45,
                                      elevation: 0,
                                      minWidth:
                                          MediaQuery.of(context).size.width,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      color: AppColors.greenSplashColor,
                                      onPressed: () {
                                        if (_questionKey.currentState!
                                            .validate()) {
                                          saveQuestions(
                                              movieName: movieNameCtr.text,
                                              teacherName: teacherNameCtr.text);
                                        }
                                      },
                                      child: Text(
                                        "${AppLocalization.of(context)?.getTranslatedValue('submit_answer')}",
                                        style: TextStyle(
                                            color: AppColors.blackColor),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: Center(
                          child: Divider(),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "${AppLocalization.of(context)?.getTranslatedValue('screen_lock_password')}",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: AppColors.blueColor),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          if (password != '')
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
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              resetPassword();
                            },
                            child: Text(
                              "${AppLocalization.of(context)?.getTranslatedValue('reset')}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                      color: AppColors.redColor, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isResetPassword && password.isNotEmpty)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "• ${AppLocalization.of(context)?.getTranslatedValue('password')}",
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    child: TextFormField(
                                      readOnly: true,
                                      controller: current_passCtr,
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
                                      style: TextStyle(fontSize: 14),
                                      obscureText: current_pass_obscureText,
                                      decoration: InputDecoration(
                                        suffixIcon: Transform.scale(
                                          scale: 0.9,
                                          child: InkWell(
                                              onTap: () {
                                                if (current_pass_obscureText ==
                                                    true) {
                                                  _authenticateWithBiometrics()
                                                      .then((value) {
                                                    if (value == true) {
                                                      setState(() {
                                                        current_pass_obscureText =
                                                            false;
                                                      });
                                                    }
                                                  });
                                                } else {
                                                  setState(() {
                                                    current_pass_obscureText =
                                                        true;
                                                  });
                                                }
                                              },
                                              child: current_pass_obscureText
                                                  ? Icon(Icons
                                                      .visibility_off_outlined)
                                                  : Icon(Icons
                                                      .visibility_outlined)),
                                        ),
                                        errorStyle: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(color: Colors.red),
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        hintText:
                                            "${AppLocalization.of(context)?.getTranslatedValue('password')}",
                                        filled: true,
                                        contentPadding: EdgeInsets.only(
                                            left: 10, right: 10, top: 10),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            if (password.isEmpty || isResetPassword)
                              Form(
                                key: _passwordKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "• ${AppLocalization.of(context)?.getTranslatedValue('password')}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      child: TextFormField(
                                        focusNode: focusePassword,
                                        controller: passCtr,
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
                                        style: TextStyle(fontSize: 14),
                                        obscureText: pass_obscureText,
                                        decoration: InputDecoration(
                                            suffixIcon: Transform.scale(
                                              scale: 0.9,
                                              child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      pass_obscureText =
                                                          !pass_obscureText;
                                                    });
                                                  },
                                                  child: pass_obscureText
                                                      ? Icon(Icons
                                                          .visibility_off_outlined)
                                                      : Icon(Icons
                                                          .visibility_outlined)),
                                            ),
                                            errorStyle: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(color: Colors.red),
                                            hintStyle: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                            hintText: "Password",
                                            filled: true,
                                            contentPadding: EdgeInsets.only(
                                                left: 10, right: 10, top: 10),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            )),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "• ${AppLocalization.of(context)?.getTranslatedValue('confirm_password')}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      child: TextFormField(
                                        // enabled: widget.enabled,
                                        focusNode: focuseConfirmPassword,
                                        obscureText: conf_pass_obscureText,
                                        keyboardType: TextInputType.number,
                                        controller: confirm_passCtr,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "${AppLocalization.of(context)?.getTranslatedValue('please_fill_confirm_password')}";
                                          } else if (value.length < 4) {
                                            return "${AppLocalization.of(context)?.getTranslatedValue('confirm_password_length_must_be_atleast_4_digit')}";
                                          } else if (passCtr.text !=
                                              confirm_passCtr.text) {
                                            return "${AppLocalization.of(context)?.getTranslatedValue('confirm_password_must_be_same_as_password')}";
                                          }
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
                                            suffixIcon: Transform.scale(
                                              scale: 0.9,
                                              child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      conf_pass_obscureText =
                                                          !conf_pass_obscureText;
                                                    });
                                                  },
                                                  child: conf_pass_obscureText
                                                      ? Icon(Icons
                                                          .visibility_off_outlined)
                                                      : Icon(Icons
                                                          .visibility_outlined)),
                                            ),
                                            errorStyle: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(color: Colors.red),
                                            hintStyle: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                            hintText:
                                                "${AppLocalization.of(context)?.getTranslatedValue('confirm_password')}",
                                            filled: true,
                                            contentPadding: EdgeInsets.only(
                                                left: 10, right: 10, top: 10),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            )),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    MaterialButton(
                                      height: 45,
                                      elevation: 0,
                                      minWidth:
                                          MediaQuery.of(context).size.width,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      color: AppColors.greenSplashColor,
                                      onPressed: () {
                                        if (_passwordKey.currentState!
                                            .validate()) {
                                          savePassword(
                                            password: confirm_passCtr.text,
                                          );
                                        }
                                      },
                                      child: Text(
                                        "${AppLocalization.of(context)?.getTranslatedValue('set_password')}",
                                        style: TextStyle(
                                            color: AppColors.blackColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void saveQuestions({required String teacherName, required String movieName}) {
    sharedStore.setSecurityPassWordMovieName(movieName).then((value) {
      if (value == true) {
        sharedStore.setSecurityPassWordTeacherName(teacherName).then((value) {
          if (value == true) {
            AppMessage.showToast(context,
                "${AppLocalization.of(context)?.getTranslatedValue('security_questions_saved_successfully')}");
          }
        });
      }
    });
  }

  void savePassword({required String password}) {
    sharedStore.setAppLockPassword(password).then((value) {
      if (value == true) {
        AppMessage.showToast(context,
            "${AppLocalization.of(context)?.getTranslatedValue('screen_lock_seted_successfully')}");
      }
    }).then((value) {
      if (value == true) {
        setState(() {
          confirm_passCtr.text = password;
        });
      }
    });
  }
}
