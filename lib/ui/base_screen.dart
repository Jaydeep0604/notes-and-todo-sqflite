import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/model/note_model.dart';
import 'package:notes_sqflite/ui/archive_note_screen.dart';
import 'package:notes_sqflite/ui/delete_screen.dart';
import 'package:notes_sqflite/ui/notes_screen.dart';
import 'package:notes_sqflite/ui/setting_screen.dart';
import 'package:notes_sqflite/ui/todo_done_screen.dart';
import 'package:notes_sqflite/ui/todo_screen.dart';

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
  bool isNotes = true, isTodos = false;
  // bool isChange = false;

  DBHelper? dbHelper;
  late GlobalKey<ScaffoldState> globalScaffoldKey;
  late Future<List<NotesModel>> noteList;
  late TextEditingController titleCtr;
  late TextEditingController ageCtr;
  late TextEditingController descriptionCtr;
  late TextEditingController emailCtr;
  void initState() {
    super.initState();
    globalScaffoldKey = GlobalKey<ScaffoldState>();
  }

  void openDrawer() {
    globalScaffoldKey.currentState?.openEndDrawer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      key: globalScaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: isNotes
            ? Icon(
                CupertinoIcons.pencil_outline,
                color: Colors.white,
              )
            : IconButton(
                onPressed: () {
                  setState(() {
                    isNotes = true;
                    isTodos = false;
                  });
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
        title: Text(
          isNotes ? "Notes" : "schedules",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          SizedBox(
            width: 10,
          ),
          IconButton(
              onPressed: () {
                openDrawer();
              },
              icon: Icon(
                CupertinoIcons.text_alignright,
                color: Colors.white,
              ))
        ],
        centerTitle: true,
      ),
      endDrawer: Container(
        width: MediaQuery.of(context).size.width * 0.65,
        child: Drawer(
          backgroundColor: Colors.blueGrey.shade700.withOpacity(0.9),
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
                  color: Colors.white,
                  size: 35,
                )),
              ),
              Divider(
                color: Colors.white,
              ),
              // ListTile(
              //   splashColor: Colors.blue[400],
              //   onTap: () {
              //     Navigator.pushReplacement(
              //         context, MaterialPageRoute(builder: (context) => Base()));
              //   },
              //   title: Text(
              //     "Home",
              //     style: TextStyle(color: Colors.white),
              //   ),
              //   leading: Icon(
              //     CupertinoIcons.pencil_ellipsis_rectangle,
              //     color: Colors.white,
              //   ),
              // ),
              // Divider(
              //   endIndent: 10,
              //   indent: 10,
              //   color: Colors.white38,
              // ),
              ListTile(
                splashColor: Colors.green[400],
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return TodoDoneScreen();
                  }));
                },
                title: Text(
                  "Finished",
                  style: TextStyle(color: Colors.white),
                ),
                leading: Icon(
                  Icons.done_all,
                  color: Colors.white,
                ),
              ),
              Divider(
                endIndent: 10,
                indent: 10,
                color: Colors.white38,
              ),
              // ListTile(
              //   splashColor: Colors.deepPurple[400],
              //   onTap: () {
              //     Navigator.pop(context);
              //   },
              //   title: Text(
              //     "Category",
              //     style: TextStyle(color: Colors.white),
              //   ),
              //   leading: Icon(
              //     Icons.archive_outlined,
              //     color: Colors.white,
              //   ),
              // ),
              // Divider(
              //   endIndent: 10,
              //   indent: 10,
              //   color: Colors.white38,
              // ),
              ListTile(
                splashColor: Colors.deepOrange[400],
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
                  "Archive",
                  style: TextStyle(color: Colors.white),
                ),
                leading: Icon(
                  Icons.archive_outlined,
                  color: Colors.white,
                ),
              ),
              Divider(
                endIndent: 10,
                indent: 10,
                color: Colors.white38,
              ),
              ListTile(
                splashColor: Colors.red[400],
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeleteScreen(),
                    ),
                  );
                },
                title: Text(
                  "Deleted",
                  style: TextStyle(color: Colors.white),
                ),
                leading: Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                ),
              ),
              Divider(
                endIndent: 10,
                indent: 10,
                color: Colors.white38,
              ),
              // ListTile(
              //   splashColor: Colors.grey[400],
              //   onTap: () {
              //     Navigator.pop(context);
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => SettingScreen(),
              //       ),
              //     );
              //   },
              //   title: Text(
              //     "Settings",
              //     style: TextStyle(color: Colors.white),
              //   ),
              //   leading: Icon(
              //     Icons.settings,
              //     color: Colors.white,
              //   ),
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black87,
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
                        color: Color.fromARGB(255, 57, 149, 199),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.4))),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.pencil_ellipsis_rectangle,
                        color: Colors.white,
                        size: isNotes ? 25 : 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // VerticalDivider(
            //   endIndent: 5,
            //   indent: 5,
            // ),
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
                        color: Colors.blueGrey.shade900.withGreen(180),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.4))),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.list_bullet_indent,
                        color: Colors.white,
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
      body: isNotes
          ? NotesScreen(
              refreshPage: () {},
            )
          : TodoScreen(),
    );
  }
}
