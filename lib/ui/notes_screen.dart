import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/model/note_model.dart';
import 'package:notes_sqflite/widget/note_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  DBHelper? dbHelper;

  late Future<List<NotesModel>> noteList;

  late TextEditingController titleCtr;
  late TextEditingController ageCtr;
  late TextEditingController noteCtr;
  late TextEditingController emailCtr;

  bool isPined = false;
  bool isArchived = false;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    titleCtr = TextEditingController();
    ageCtr = TextEditingController();
    noteCtr = TextEditingController();
    emailCtr = TextEditingController();
    loadData();
  }

  void loadData() async {
    noteList = dbHelper!.getNotesList();
  }

  void clear() {
    titleCtr.clear();
    ageCtr.clear();
    noteCtr.clear();
    emailCtr.clear();
    setState(() {
      isPined = false;
      isArchived = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        SafeArea(
          child: RefreshIndicator(
            onRefresh: () => Future.delayed(Duration(seconds: 1), loadData),
            child: SingleChildScrollView(
              child: Container(
                color: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: FutureBuilder(
                  future: noteList,
                  builder: (context, AsyncSnapshot<List<NotesModel>> snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder(
                            future: noteList,
                            builder: (context,
                                AsyncSnapshot<List<NotesModel>> snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!.isEmpty) {
                                  return SizedBox(
                                    height: height * 0.70,
                                    child: Center(
                                      child: Text(
                                        "No Data",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                                return MasonryGridView.count(
                                  padding: EdgeInsets.zero,
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  itemCount: snapshot.data?.length,
                                  primary: false,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        if (snapshot.data![index].pin == 1)
                                          NoteWidget(
                                            dbHelper: dbHelper!,
                                            keyvalue: ValueKey<int>(
                                                snapshot.data![index].id!),
                                            id: snapshot.data![index].id!,
                                            title: snapshot.data![index].title
                                                .toString(),
                                            note: snapshot.data![index].note
                                                .toString(),
                                            pin: snapshot.data![index].pin!,
                                            archive: 0,
                                            email: snapshot.data![index].email
                                                .toString(),
                                            deleted: 0,
                                            createDate: '',
                                            editedDate: '',
                                            onUpdateComplete: () {
                                              setState(() {
                                                noteList =
                                                    dbHelper!.getNotesList();
                                              });
                                            },
                                            onDismissed: () {
                                              setState(() {
                                                dbHelper!.delete(
                                                    snapshot.data![index].id!);
                                                noteList =
                                                    dbHelper!.getNotesList();
                                                snapshot.data!.remove(
                                                    snapshot.data![index]);
                                              });
                                            },
                                          )
                                      ],
                                    );
                                  },
                                );
                              } else {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          MasonryGridView.count(
                            padding: EdgeInsets.zero,
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            itemCount: snapshot.data?.length,
                            primary: false,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return snapshot.data![index].archive != 1
                                  ? snapshot.data![index].deleted != 1
                                      ? snapshot.data![index].deleted != 1
                                          ? snapshot.data![index].pin != 1
                                              ? NoteWidget(
                                                  dbHelper: dbHelper!,
                                                  keyvalue: ValueKey<int>(
                                                      snapshot
                                                          .data![index].id!),
                                                  id: snapshot.data![index].id!,
                                                  title: snapshot
                                                      .data![index].title
                                                      .toString(),
                                                  note: snapshot
                                                      .data![index].note
                                                      .toString(),
                                                  pin: snapshot
                                                      .data![index].pin!,
                                                  archive: snapshot
                                                      .data![index].deleted!,
                                                  email: snapshot
                                                      .data![index].email
                                                      .toString(),
                                                  deleted: snapshot
                                                      .data![index].deleted!,
                                                  createDate: snapshot
                                                      .data![index].create_date
                                                      .toString(),
                                                  editedDate: snapshot
                                                      .data![index].edited_date
                                                      .toString(),
                                                  onUpdateComplete: () {
                                                    setState(() {
                                                      noteList = dbHelper!
                                                          .getNotesList();
                                                    });
                                                  },
                                                  onDismissed: () {
                                                    setState(() {
                                                      dbHelper!.delete(snapshot
                                                          .data![index].id!);
                                                      noteList = dbHelper!
                                                          .getNotesList();
                                                      snapshot.data!.remove(
                                                          snapshot
                                                              .data![index]);
                                                    });
                                                  })
                                              : SizedBox()
                                          : SizedBox()
                                      : SizedBox()
                                  : Container();
                            },
                          ),
                        ],
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 10),
            child: InkWell(
              splashColor: Colors.blueGrey,
              borderRadius: BorderRadius.circular(50),
              radius: 10,
              onTap: () {
                
                showGeneralDialog(
                  context: context,
                  transitionDuration: Duration(milliseconds: 300),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return Material(
                      type: MaterialType.card,
                      color: Colors.black,
                      child: StatefulBuilder(builder: (context, setState) {
                        void isPinedChange() {
                          setState(() {
                            isPined = !isPined;
                          });
                        }

                        void isArchivedChange() {
                          setState(() {
                            isArchived = !isArchived;
                            setState;
                          });
                        }

                        return Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 40,
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      IconButton(
                                        tooltip: "Navigate up",
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Spacer(),
                                      IconButton(
                                        tooltip: "Pin",
                                        onPressed: () {
                                          isPinedChange();
                                          // Navigator.pop(context);
                                        },
                                        icon: Transform.scale(
                                          scale: 1,
                                          child: isPined
                                              ? Icon(
                                                  Icons.push_pin,
                                                  color: Colors.white,
                                                )
                                              : Icon(
                                                  Icons.push_pin_outlined,
                                                  color: Colors.white,
                                                ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: "Archive",
                                        onPressed: () {
                                          isArchivedChange();
                                          // Navigator.pop(context);
                                        },
                                        icon: Transform.scale(
                                          scale: 1,
                                          child: isArchived
                                              ? Icon(
                                                  Icons.archive,
                                                  color: Colors.white,
                                                )
                                              : Icon(
                                                  Icons.archive_outlined,
                                                  color: Colors.white,
                                                ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: TextFormField(
                                    controller: titleCtr,
                                    maxLines: null,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                        hintText: "Title",
                                        hintStyle: TextStyle(
                                            color: Colors.white60,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 20),
                                        enabledBorder: InputBorder.none,
                                        border: InputBorder.none,
                                        disabledBorder: InputBorder.none),
                                    inputFormatters: [],
                                  ),
                                ),
                                Expanded(
                                    child: SingleChildScrollView(
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                          controller: noteCtr,
                                          minLines: 1,
                                          maxLines: null,
                                          style: TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            hintText: "Note",
                                            hintStyle: TextStyle(
                                                color: Colors.white60,
                                                fontSize: 16),
                                            enabledBorder: InputBorder.none,
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                              ],
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 20, right: 20),
                                child: InkWell(
                                  splashColor: Colors.blueGrey,
                                  borderRadius: BorderRadius.circular(50),
                                  radius: 10,
                                  onTap: () {
                                    final date = DateFormat('EEEEEEEEE,d MMM y')
                                        .format(DateTime.now());
                                    final time = DateFormat('kk:mm a')
                                        .format(DateTime.now());
                                    print("$date, $time");
                                    dbHelper!
                                        .insert(
                                      NotesModel(
                                        title: titleCtr.text.toString(),
                                        note: noteCtr.text.toString(),
                                        pin: isPined == true ? 1 : 0,
                                        archive: isArchived == true ? 1 : 0,
                                        email: '',
                                        deleted: 1,
                                        create_date: date.toString(),
                                        edited_date:
                                            time.toLowerCase().toString(),
                                      ),
                                    )
                                        .then((value) {
                                      print("data added");
                                      clear();
                                      setState(() {
                                        noteList = dbHelper!.getNotesList();
                                      });
                                      Navigator.pop(context);
                                    }).onError((error, stackTrace) {
                                      print(error.toString());
                                      print(stackTrace.toString());
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.yellow,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.4))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.black,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    );
                  },
                );
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.4))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 30,
                    ),
                  )),
            ),
          ),
        ),
      ],
    );
  }
}
