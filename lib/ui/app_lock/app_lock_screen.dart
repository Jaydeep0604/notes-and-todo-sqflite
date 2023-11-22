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
  late TextEditingController passCtr, c_passCtr, movieNameCtr, teacherNameCtr;

  final _questionKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();

  final FocusNode focusMovie = FocusNode();
  final FocusNode focuseTeacherName = FocusNode();
  final FocusNode focusePassword = FocusNode();
  final FocusNode focuseConfirmPassword = FocusNode();

  String movieName = '', teacherName = '', password = '';

  bool pass_obscureText = true,
      conf_pass_obscureText = true,
      teacher_name_obscureText = true,
      movie_name_obscureText = true;

  bool isAppLockEnable = false;

  bool isResetQuestions = false;
  bool isResetPassword = false;

  // bool _isAuthenticating = false;
  bool _isAuthenticated = false;
  void initState() {
    super.initState();
    movieNameCtr = TextEditingController();
    teacherNameCtr = TextEditingController();
    passCtr = TextEditingController();
    c_passCtr = TextEditingController();
    getData();
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
      c_passCtr.clear();
      isResetPassword = true;
    });
  }

  void getData() async {
    movieName = await sharedStore.getSecurityPassWordMovieName() ?? '';
    teacherName = await sharedStore.getSecurityPassWordTeacherName() ?? '';
    password = await sharedStore.getAppLockPassword() ?? '';
    setState(() {
      movieNameCtr = TextEditingController(text: movieName);
      teacherNameCtr = TextEditingController(text: teacherName);
      passCtr = TextEditingController(text: password);
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
                            "${AppLocalization.of(context)?.getTranslatedValue('Enable Biometric Lock')}"),
                        trailing: SwitchWidget(
                          value: isBioMetricLock,
                          onTap: () {
                            _authenticateWithBiometrics().then((value) {
                              if (value == true) {
                                setState(() {
                                  setState(() {
                                    isBioMetricLock = !isBioMetricLock;
                                  });
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
                            "${AppLocalization.of(context)?.getTranslatedValue('Enable Pin Lock')}"),
                        trailing: SwitchWidget(
                          value: isAppLockEnable,
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
                                isAppLockEnable = !isAppLockEnable;
                              });
                            } else {
                              if (movieNameCtr.text.isEmpty) {
                                focusMovie.requestFocus();
                              } else if (teacherNameCtr.text.isEmpty) {
                                focuseTeacherName.requestFocus();
                              } else if (passCtr.text.isEmpty) {
                                focusePassword.requestFocus();
                              } else if (c_passCtr.text.isEmpty) {
                                focuseConfirmPassword.requestFocus();
                              } else {
                                saveQuestions(
                                    teacherName: teacherName,
                                    movieName: movieName);
                                savePassword(password: password);
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
                            "Security Questions",
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
                                child: Icon(Icons.done, size: 14),
                              ),
                            ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              resetQuestions();
                            },
                            child: Text(
                              "Reset",
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
                                "• What’s your favorite movie?",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: TextFormField(
                                  // enabled: widget.enabled,
                                  autofocus: true,
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
                                      return "Please fill your favorite movie name";
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
                                      hintText: "Movie name",
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
                                "• What was your favorite school teacher’s name?",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: TextFormField(
                                  // enabled: widget.enabled,
                                  focusNode: focuseTeacherName,
                                  autofocus: true,
                                  readOnly: teacherName == ""
                                      ? false
                                      : isResetQuestions == false
                                          ? true
                                          : false,
                                  obscureText: teacher_name_obscureText,
                                  controller: teacherNameCtr,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please fill your favorite school teacher’s name";
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
                                      hintText: "Teacher’s name",
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
                                        "Submit Answer",
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
                            "Screen Lock Password",
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
                                child: Icon(Icons.done, size: 14),
                              ),
                            ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              resetPassword();
                            },
                            child: Text(
                              "Reset",
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
                            if (password != "" && passCtr.text.isNotEmpty)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "• Password",
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    child: TextFormField(
                                      readOnly: true,
                                      controller: passCtr,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Please fill password";
                                        } else if (value.length < 4) {
                                          return "Password length must be atleast 4 digit";
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
                                                if (pass_obscureText == true) {
                                                  _authenticateWithBiometrics()
                                                      .then((value) {
                                                    if (value == true) {
                                                      setState(() {
                                                        pass_obscureText =
                                                            false;
                                                      });
                                                    }
                                                  });
                                                } else {
                                                  setState(() {
                                                    pass_obscureText = true;
                                                  });
                                                }
                                              },
                                              child: pass_obscureText
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
                                      "• Password",
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
                                            return "Please fill password";
                                          } else if (value.length < 4) {
                                            return "Password length must be atleast 4 digit";
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
                                      "• Confirm password",
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
                                        controller: c_passCtr,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Please fill confirm password";
                                          } else if (value.length < 4) {
                                            return "Confirm password length must be atleast 4 digit";
                                          } else if (passCtr.text !=
                                              c_passCtr.text) {
                                            return "Confirm password must be same as password";
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
                                            hintText: "Confirm password",
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
                                            password: c_passCtr.text,
                                          );
                                        }
                                      },
                                      child: Text(
                                        "Set Password",
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
            AppMessage.showToast(
                context, "Security questions saved successfully");
          }
        });
      }
    });
  }

  void savePassword({required String password}) {
    sharedStore.setAppLockPassword(password).then((value) {
      if (value == true) {
        AppMessage.showToast(context, "Screen lock seted successfully");
      }
    });
  }
}
