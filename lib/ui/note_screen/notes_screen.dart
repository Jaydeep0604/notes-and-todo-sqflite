import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/model/note_model.dart';
import 'package:notes_sqflite/ui/note_screen/note_detail_screen.dart';
import 'package:notes_sqflite/widget/note_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NotesScreen extends StatefulWidget {
  NotesScreen({super.key, required this.refreshPage});
  void Function() refreshPage;

  @override
  State<NotesScreen> createState() => _NotesScreenState(
        refreshPage: refreshPage,
      );
}

class _NotesScreenState extends State<NotesScreen> {
  _NotesScreenState({required this.refreshPage});

  void Function() refreshPage;

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
    checkData();
  }

  checkData() {
    Timer.periodic(Duration(microseconds: 500), (timer) {
      if (isUpdateNoteScreen)
        setState(() {
          loadData();
          print("data updated $isUpdateNoteScreen");
          isUpdateNoteScreen = false;
        });
    });
  }

  void loadData() async {
    noteList = dbHelper!.getNotesList();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        SafeArea(
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
                                              noteList =
                                                  dbHelper!.getNotesList();
                                            });
                                          },
                                        )
                                    ],
                                  );
                                },
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
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
                                                    snapshot.data![index].id!),
                                                id: snapshot.data![index].id!,
                                                title: snapshot
                                                    .data![index].title
                                                    .toString(),
                                                note: snapshot.data![index].note
                                                    .toString(),
                                                pin: snapshot.data![index].pin!,
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
                                                    // dbHelper!.delete(snapshot
                                                    //     .data![index].id!);
                                                    noteList = dbHelper!
                                                        .getNotesList();
                                                    snapshot.data!.remove(
                                                        snapshot.data![index]);
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
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 10),
            child: InkWell(
              splashColor: Colors.blueGrey,
              borderRadius: BorderRadius.circular(50),
              radius: 10,
              onTap: () {
                // addNoteDialoge();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return NoteDetailScreen(
                        isUpdateNote: false,
                      );
                    },
                  ),
                ).then((value) {
                  if (value == true) {
                    setState(() {
                      noteList = dbHelper!.getNotesList();
                    });
                  }
                });
              },
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
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

  // void addNoteDialoge() {
  //   showGeneralDialog(
  //     context: context,
  //     transitionDuration: Duration(milliseconds: 300),
  //     pageBuilder: (context, animation, secondaryAnimation) {
  //       return Material(
  //         type: MaterialType.card,
  //         color: Colors.black,
  //         child: StatefulBuilder(builder: (context, setState) {
  //           void isPinedChange() {
  //             setState(() {
  //               isPined = !isPined;
  //             });
  //           }

  //           void isArchivedChange() {
  //             setState(() {
  //               isArchived = !isArchived;
  //               setState;
  //             });
  //           }

  //           return Stack(
  //             children: [
  //               Column(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: <Widget>[
  //                   SizedBox(
  //                     height: 40,
  //                   ),
  //                   Container(
  //                     child: Row(
  //                       children: [
  //                         IconButton(
  //                           tooltip: "Navigate up",
  //                           onPressed: () {
  //                             Navigator.pop(context);
  //                           },
  //                           icon: Icon(
  //                             Icons.arrow_back,
  //                             color: Colors.white,
  //                           ),
  //                         ),
  //                         Spacer(),
  //                         IconButton(
  //                           tooltip: "Pin",
  //                           onPressed: () {
  //                             isPinedChange();
  //                             // Navigator.pop(context);
  //                           },
  //                           icon: Transform.scale(
  //                             scale: 1,
  //                             child: isPined
  //                                 ? Icon(
  //                                     Icons.push_pin,
  //                                     color: Colors.white,
  //                                   )
  //                                 : Icon(
  //                                     Icons.push_pin_outlined,
  //                                     color: Colors.white,
  //                                   ),
  //                           ),
  //                         ),
  //                         IconButton(
  //                           tooltip: "Archive",
  //                           onPressed: () {
  //                             isArchivedChange();
  //                             // Navigator.pop(context);
  //                           },
  //                           icon: Transform.scale(
  //                             scale: 1,
  //                             child: isArchived
  //                                 ? Icon(
  //                                     Icons.archive,
  //                                     color: Colors.white,
  //                                   )
  //                                 : Icon(
  //                                     Icons.archive_outlined,
  //                                     color: Colors.white,
  //                                   ),
  //                           ),
  //                         ),
  //                         SizedBox(
  //                           width: 10,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 15,
  //                     ),
  //                     child: TextFormField(
  //                       controller: titleCtr,
  //                       maxLines: null,
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.w400,
  //                         fontSize: 20,
  //                         color: Colors.white,
  //                       ),
  //                       decoration: InputDecoration(
  //                           hintText: "Title",
  //                           hintStyle: TextStyle(
  //                               color: Colors.white60,
  //                               fontWeight: FontWeight.w400,
  //                               fontSize: 20),
  //                           enabledBorder: InputBorder.none,
  //                           border: InputBorder.none,
  //                           disabledBorder: InputBorder.none),
  //                       inputFormatters: [],
  //                     ),
  //                   ),
  //                   Expanded(
  //                       child: SingleChildScrollView(
  //                     child: Container(
  //                       padding: EdgeInsets.symmetric(horizontal: 15),
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           TextFormField(
  //                             controller: noteCtr,
  //                             minLines: 1,
  //                             maxLines: null,
  //                             style: TextStyle(color: Colors.white),
  //                             decoration: InputDecoration(
  //                               hintText: "Note",
  //                               hintStyle: TextStyle(
  //                                   color: Colors.white60, fontSize: 16),
  //                               enabledBorder: InputBorder.none,
  //                               border: InputBorder.none,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ))
  //                 ],
  //               ),
  //               Align(
  //                 alignment: Alignment.bottomRight,
  //                 child: Padding(
  //                   padding: const EdgeInsets.only(bottom: 20, right: 20),
  //                   child: InkWell(
  //                     splashColor: Colors.blueGrey,
  //                     borderRadius: BorderRadius.circular(50),
  //                     radius: 10,
  //                     onTap: () {
  //                       addNote();
  //                     },
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                           color: Colors.yellow,
  //                           shape: BoxShape.circle,
  //                           border: Border.all(
  //                               color: Colors.white.withOpacity(0.4))),
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Icon(
  //                           Icons.check,
  //                           color: Colors.black,
  //                           size: 30,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           );
  //         }),
  //       );
  //     },
  //   );
  // }
}
