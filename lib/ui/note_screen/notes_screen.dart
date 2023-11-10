import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/model/note_model.dart';
import 'package:notes_sqflite/ui/note_screen/note_detail_screen.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:notes_sqflite/widget/note_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NotesScreen extends StatefulWidget {
  NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  DBHelper? dbHelper;
  bool isEmpty = false;

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
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: FutureBuilder(
                future: noteList,
                builder: (context, AsyncSnapshot<List<NotesModel>> snapshot) {
                  int otherCount = snapshot.data != null &&
                          snapshot.data!.any((item) =>
                              item.archive != 1 &&
                              item.deleted != 1 &&
                              item.pin != 1)
                      ? snapshot.data!.length
                      : 0;
                  if (snapshot.hasData) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder(
                          future: noteList,
                          builder: (context,
                              AsyncSnapshot<List<NotesModel>> snapshot) {
                            int pinCount = snapshot.data != null &&
                                    snapshot.data!.any((item) => item.pin == 1)
                                ? snapshot.data!.length
                                : 0;
                            if (snapshot.hasData) {
                              if (snapshot.data==null) {
                                // Add your dummy data here
                                return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    // color: AppColors.blackColor,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 10),
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      // constraints: BoxConstraints(maxHeight: 270, minHeight: 0),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color!),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "Dummy Title",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          RichText(
                                            maxLines: 14,
                                            overflow: TextOverflow.ellipsis,
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "This is a sample note with dummy data.",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        fontSize: 13,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ));
                              }
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  MasonryGridView.count(
                                    padding: EdgeInsets.zero,
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 0,
                                    itemCount: pinCount,
                                    primary: false,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (snapshot.data![index].pin == 1)
                                            Container(
                                              padding: EdgeInsets.only(
                                                  right: 4, top: 4),
                                              child: NoteWidget(
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
                                                archive: 0,
                                                email: snapshot
                                                    .data![index].email
                                                    .toString(),
                                                deleted: 0,
                                                createDate: snapshot
                                                    .data![index].create_date!,
                                                editedDate: snapshot
                                                    .data![index].edited_date!,
                                                imageList: snapshot
                                                    .data![index].image_list,
                                                onUpdateComplete: () {
                                                  setState(() {
                                                    noteList = dbHelper!
                                                        .getNotesList();
                                                  });
                                                },
                                                onDismissed: (id,
                                                    title,
                                                    note,
                                                    email,
                                                    createDate,
                                                    editedDate,
                                                    pin,
                                                    archive,
                                                    deleted) {
                                                  setState(() {
                                                    noteList = dbHelper!
                                                        .getNotesList();
                                                  });
                                                },
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                  if (pinCount >= 1 && otherCount >= 1)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      child: Text("Others"),
                                    ),
                                ],
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                        MasonryGridView.count(
                          padding: EdgeInsets.zero,
                          crossAxisCount: 2,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                          itemCount: otherCount,
                          primary: false,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return snapshot.data![index].archive != 1
                                ? snapshot.data![index].deleted != 1
                                    ? snapshot.data![index].pin != 1
                                        ? NoteWidget(
                                            dbHelper: dbHelper!,
                                            keyvalue: ValueKey<int>(
                                                snapshot.data![index].id!),
                                            id: snapshot.data![index].id!,
                                            title: snapshot.data![index].title
                                                .toString(),
                                            note: snapshot.data![index].note
                                                .toString(),
                                            pin: snapshot.data![index].pin!,
                                            archive:
                                                snapshot.data![index].deleted!,
                                            email: snapshot.data![index].email
                                                .toString(),
                                            deleted:
                                                snapshot.data![index].deleted!,
                                            createDate: snapshot
                                                .data![index].create_date
                                                .toString(),
                                            editedDate: snapshot
                                                .data![index].edited_date
                                                .toString(),
                                            imageList: snapshot
                                                .data![index].image_list,
                                            onUpdateComplete: () {
                                              setState(() {
                                                noteList =
                                                    dbHelper!.getNotesList();
                                              });
                                            },
                                            onDismissed: (
                                              id,
                                              title,
                                              note,
                                              email,
                                              createDate,
                                              editedDate,
                                              pin,
                                              archive,
                                              deleted,
                                            ) {
                                              setState(() {
                                                // dbHelper!.delete(snapshot
                                                //     .data![index].id!);
                                                noteList =
                                                    dbHelper!.getNotesList();
                                                snapshot.data!.remove(
                                                    snapshot.data![index]);
                                              });
                                            })
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
              splashColor: AppColors.blueGrayColor,
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
                      color: AppColors.whiteColor.withOpacity(0.4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.add,
                      color: AppColors.blackColor,
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
