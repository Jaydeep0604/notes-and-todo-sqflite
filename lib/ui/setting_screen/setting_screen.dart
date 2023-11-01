import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_sqflite/config/shared_store.dart';
import 'package:notes_sqflite/provider/theme_provider.dart';
import 'package:notes_sqflite/ui/privacy_policy_screen/privacy_policy_screen.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:notes_sqflite/widget/switch_widget.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  SystemThemeMode? theme;

  bool isNotification = false;
  bool isAppMode = false;
  bool isOn = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
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
          "Settings",
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
                      "App Mode",
                      // style: Theme.of(context).textTheme.titleMedium,
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
                      _buildThemeOption(SystemThemeMode.light, "Light"),
                      _buildThemeOption(SystemThemeMode.dark, "Dark"),
                      _buildThemeOption(SystemThemeMode.system, "System"),
                    ],
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
                  title: Text("Privacy Policy"),
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
