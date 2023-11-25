import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_sqflite/config/shared_store.dart';
import 'package:notes_sqflite/language/localisation.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/provider/theme_provider.dart';
import 'package:notes_sqflite/ui/app_lock/app_lock_screen.dart';
import 'package:notes_sqflite/ui/export_data/export_pdf_view_screen.dart';
import 'package:notes_sqflite/ui/privacy_policy_screen/privacy_policy_screen.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  SystemThemeMode? theme;
  // SystemLanguageMode? lang;

  bool isNotification = false;
  bool isAppMode = false;
  bool islangOpen = false;
  bool isExportDataOpen = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Locale? _locale;

  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = MyApp.getLocale(context) ?? Locale('en');
  }

  Future<void> _loadTheme() async {
    final themeModeString = await sharedStore.getThememode();
    final themeMode = _stringToThemeMode(themeModeString);
    final systemThemeMode = _themeModeToSystemThemeMode(themeMode);
    setState(() {
      theme = systemThemeMode;
    });
  }

  ThemeMode? _stringToThemeMode(String? themeModeString) {
    if (themeModeString == 'light') {
      return ThemeMode.light;
    } else if (themeModeString == 'dark') {
      return ThemeMode.dark;
    } else if (themeModeString == 'system') {
      return ThemeMode.system;
    } else {
      print("Something want wrong in code please contact developer");
    }
  }

  SystemThemeMode _themeModeToSystemThemeMode(ThemeMode? themeMode) {
    if (themeMode!.name.toString() == "light") {
      return SystemThemeMode.light;
    } else if (themeMode.name.toString() == "dark") {
      return SystemThemeMode.dark;
    } else {
      return SystemThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Row _buildThemeOption(SystemThemeMode themeOption, String label) {
      return Row(
        children: [
          SizedBox(width: 10),
          Radio<SystemThemeMode>(
            activeColor: AppColors.bottomNavigationBarSecondColor,
            value: themeOption,
            groupValue: theme,
            onChanged: (value) {
              setState(() {
                theme = value;
                if (value == SystemThemeMode.light) {
                  themeProvider.setTheme(ThemeMode.light);
                  sharedStore.setThemeMode(value!.name.toString());
                } else if (value == SystemThemeMode.dark) {
                  themeProvider.setTheme(ThemeMode.dark);
                  sharedStore.setThemeMode(value!.name.toString());
                } else if (value == SystemThemeMode.system) {
                  themeProvider.setTheme(ThemeMode.system);
                  sharedStore.setThemeMode(value!.name.toString());
                }
              });
            },
          ),
          SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      );
    }

    // Row _buildLanguageOption(SystemLanguageMode languageOption, String label) {
    //   return Row(
    //     children: [
    //       SizedBox(width: 10),
    //       Radio<Locale>(
    //         activeColor: AppColors.bottomNavigationBarSecondColor,
    //         value: Locale('${languageOption.name}'),
    //         groupValue: _locale,
    //         onChanged: (language) {
    //           setState(() {
    //             _locale = language;
    //           });
    //           if (language == SystemLanguageMode.en) {
    //             if (language != null) {
    //               MyApp.setLocale(context, _locale as Locale);
    //             }
    //             setState(() {
    //               _locale = language as Locale;
    //             });
    //           } else if (language == SystemLanguageMode.hi) {
    //             setState(() {
    //               _locale = language as Locale;
    //             });
    //             if (language != null) {
    //               MyApp.setLocale(context, _locale as Locale);
    //             }
    //           } else if (language == SystemLanguageMode.gu) {
    //             setState(() {
    //               _locale = language as Locale;
    //             });
    //             if (language != null) {
    //               MyApp.setLocale(context, _locale as Locale);
    //             }
    //           }
    //         },
    //       ),
    //       SizedBox(width: 10),
    //       Text(
    //         label,
    //         style: Theme.of(context).textTheme.titleMedium,
    //       ),
    //     ],
    //   );
    // }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon:
              Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
        ),
        title: Text(
          "${AppLocalization.of(context)?.getTranslatedValue('settings')}",
          style: TextStyle(
              // color: AppColors.whiteColor
              ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              // Container(
              //   color: Theme.of(context).cardColor,
              //   child: ListTile(
              //     contentPadding: EdgeInsets.zero,
              //     leading: Icon(
              //       Icons.notifications,
              //     ),
              //     title: Text("Notifications"),
              //     onTap: () {
              //       setState(() {
              //         isNotification = !isNotification;
              //       });
              //     },
              //     trailing: Transform.scale(
              //       scale: 1,
              //       child: isNotification
              //           ? Icon(
              //               Icons.keyboard_arrow_down,
              //             )
              //           : Icon(
              //               Icons.keyboard_arrow_up,
              //             ),
              //     ),
              //   ),
              // ),
              // Visibility(
              //   visible: isNotification,
              //   child: Container(
              //     width: MediaQuery.of(context).size.width,
              //     decoration: BoxDecoration(
              //       color: Theme.of(context).canvasColor.withOpacity(0.2),
              //       borderRadius: BorderRadius.circular(10),
              //       border: Border.all(
              //         color: Theme.of(context).canvasColor,
              //       ),
              //     ),
              //     child: Padding(
              //       padding: const EdgeInsets.symmetric(
              //           horizontal: 10, vertical: 10),
              //       child: Column(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Row(
              //             children: [
              //               Text(
              //                 "Allow Push Notifications",
              //                 style: Theme.of(context).textTheme.titleMedium,
              //               ),
              //               Spacer(),
              //               SwitchWidget(
              //                 value: isOn,
              //                 onTap: () {
              //                   setState(() {
              //                     isOn = !isOn;
              //                   });
              //                 },
              //               )
              //             ],
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              Container(
                color: Theme.of(context).cardColor,
                child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.light_mode_sharp,
                    ),
                    title: Text(
                      "${AppLocalization.of(context)?.getTranslatedValue('app_mode')}",
                    ),
                    onTap: () {
                      setState(() {
                        isAppMode = !isAppMode;
                      });
                    },
                    trailing: Transform.scale(
                      scale: 1,
                      child: isAppMode
                          ? Icon(
                              Icons.keyboard_arrow_down,
                            )
                          : Icon(
                              Icons.keyboard_arrow_up,
                            ),
                    )),
              ),
              Visibility(
                visible: isAppMode,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).canvasColor,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildThemeOption(SystemThemeMode.light, "${AppLocalization.of(context)?.getTranslatedValue("light")}"),
                      _buildThemeOption(SystemThemeMode.dark, "${AppLocalization.of(context)?.getTranslatedValue("dark")}"),
                      _buildThemeOption(SystemThemeMode.system, "${AppLocalization.of(context)?.getTranslatedValue("system")}"),
                    ],
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).cardColor,
                child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.translate,
                    ),
                    title: Text(
                      "${AppLocalization.of(context)?.getTranslatedValue('app_language')}",
                      // style: Theme.of(context).textTheme.titleMedium,
                    ),
                    onTap: () {
                      setState(() {
                        islangOpen = !islangOpen;
                      });
                    },
                    trailing: Transform.scale(
                      scale: 1,
                      child: islangOpen
                          ? Icon(
                              Icons.keyboard_arrow_down,
                            )
                          : Icon(
                              Icons.keyboard_arrow_up,
                            ),
                    )),
              ),
              Visibility(
                visible: islangOpen,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).canvasColor,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        SizedBox(width: 10),
                        Radio<Locale>(
                          activeColor: AppColors.bottomNavigationBarSecondColor,
                          value: Locale("hi"),
                          groupValue: _locale,
                          onChanged: (language) {
                            setState(() {
                              _locale = language as Locale;
                            });
                            if (language != null) {
                              MyApp.setLocale(context, _locale as Locale);
                            }
                          },
                        ),
                        SizedBox(width: 10),
                        Text(
                          "${AppLocalization.of(context)?.getTranslatedValue("hindi")}",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ]),
                      Row(children: [
                        SizedBox(width: 10),
                        Radio<Locale>(
                          activeColor: AppColors.bottomNavigationBarSecondColor,
                          value: Locale("gu"),
                          groupValue: _locale,
                          onChanged: (language) {
                            setState(() {
                              _locale = language as Locale;
                            });
                            if (language != null) {
                              MyApp.setLocale(context, _locale as Locale);
                            }
                          },
                        ),
                        SizedBox(width: 10),
                        Text(
                          "${AppLocalization.of(context)?.getTranslatedValue("gujarati")}",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ]),
                      Row(children: [
                        SizedBox(width: 10),
                        Radio<Locale>(
                          activeColor: AppColors.bottomNavigationBarSecondColor,
                          value: Locale("en"),
                          groupValue: _locale,
                          onChanged: (language) {
                            setState(() {
                              _locale = language as Locale;
                            });
                            if (language != null) {
                              MyApp.setLocale(context, _locale as Locale);
                            }
                          },
                        ),
                        SizedBox(width: 10),
                        Text(
                          "${AppLocalization.of(context)?.getTranslatedValue("english")}",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).cardColor,
                child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.downloading_rounded,
                    ),
                    title: Text(
                        "${AppLocalization.of(context)?.getTranslatedValue('export_data')}"),
                    onTap: () {
                      setState(() {
                        isExportDataOpen = !isExportDataOpen;
                      });
                    },
                    trailing: Transform.scale(
                      scale: 1,
                      child: isExportDataOpen
                          ? Icon(
                              Icons.keyboard_arrow_down,
                            )
                          : Icon(
                              Icons.keyboard_arrow_up,
                            ),
                    )),
              ),
              Visibility(
                visible: isExportDataOpen,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).canvasColor,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExportPdfViewScreen(
                                  isNoteView: true, title: "note's preview"),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)),
                            color:
                                Theme.of(context).canvasColor.withOpacity(0.2),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_download_outlined,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "${AppLocalization.of(context)?.getTranslatedValue('export_note_s')}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(fontWeight: FontWeight.normal),
                              ),
                              Expanded(child: SizedBox()),
                              Icon(
                                Icons.touch_app_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExportPdfViewScreen(
                                  isNoteView: false, title: "to-do's preview"),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            color:
                                Theme.of(context).canvasColor.withOpacity(0.2),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_download_outlined,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "${AppLocalization.of(context)?.getTranslatedValue("export_schedules")}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(fontWeight: FontWeight.normal),
                              ),
                              Spacer(),
                              Icon(
                                Icons.touch_app_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).cardColor,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                Icons.lock_person_rounded,
                  ),
                  title: Text(
                      "${AppLocalization.of(context)?.getTranslatedValue('app_lock')}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppLockScreen(),
                      ),
                    );
                  },
                  trailing: Icon(
                    Icons.keyboard_arrow_right,
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).cardColor,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    CupertinoIcons.doc_append,
                  ),
                  title: Text(
                      "${AppLocalization.of(context)?.getTranslatedValue('privacy_policy')}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacyPolicyScreen(),
                      ),
                    );
                  },
                  trailing: Icon(
                    Icons.keyboard_arrow_right,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
