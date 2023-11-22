import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/language/localisation.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/model/note_model.dart';
import 'package:notes_sqflite/widget/note_widget.dart';

class ArchiveNoteScreen extends StatefulWidget {
  const ArchiveNoteScreen({super.key});

  @override
  State<ArchiveNoteScreen> createState() => _ArchiveNoteScreenState();
}

class _ArchiveNoteScreenState extends State<ArchiveNoteScreen> {
  DBHelper? dbHelper;
  late Future<List<NotesModel>> noteList;
  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();

    loadData();
  }

  void loadData() async {
    noteList = dbHelper!.getNotesList();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          isUpdateNoteScreen = true;
        });
        return true;
      },
      child: Scaffold(
        // backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          // backgroundColor: AppColors.whiteColor,
          leading: IconButton(
              onPressed: () {
                setState(() {
                  isUpdateNoteScreen = true;
                });
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).iconTheme.color)),
          title: Text(
            "${AppLocalization.of(context)?.getTranslatedValue('archive')}",
            style: TextStyle(
                // color: Colors.black,
                ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding(
            //   padding: const EdgeInsets.only(left: 15),
            //   child: Text(
            //     "Archive",
            //     style: TextStyle(
            //         color: AppColors.whiteColor
            //         fontWeight: FontWeight.w500,
            //         fontSize: 14),
            //   ),
            // ),
            FutureBuilder(
              future: noteList,
              builder: (context, AsyncSnapshot<List<NotesModel>> snapshot) {
                int archiveCount = snapshot.data != null &&
                        snapshot.data!.any(
                            (item) => item.archive == 1 && item.deleted != 1)
                    ? snapshot.data!.length
                    : 0;
                if (snapshot.hasData) {
                  if (archiveCount == 0) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          "${AppLocalization.of(context)?.getTranslatedValue('no_data_found')}",
                          style: TextStyle(
                              color: Theme.of(context).highlightColor),
                        ),
                      ),
                    );
                  }
                  return MasonryGridView.count(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    crossAxisCount: 2,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                    itemCount: archiveCount,
                    primary: false,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return snapshot.data![index].archive == 1
                          ? snapshot.data![index].deleted == 0
                              ? NoteWidget(
                                  dbHelper: dbHelper!,
                                  keyvalue:
                                      ValueKey<int>(snapshot.data![index].id!),
                                  id: snapshot.data![index].id!,
                                  title: snapshot.data![index].title.toString(),
                                  note: snapshot.data![index].note.toString(),
                                  pin: snapshot.data![index].pin!,
                                  archive: snapshot.data![index].archive!,
                                  email: snapshot.data![index].email.toString(),
                                  deleted: snapshot.data![index].deleted!,
                                  createDate: snapshot.data![index].create_date
                                      .toString(),
                                  editedDate: snapshot.data![index].edited_date
                                      .toString(),
                                  imageList: snapshot.data![index].image_list,
                                  onUpdateComplete: () {
                                    setState(() {
                                      noteList = dbHelper!.getNotesList();
                                    });
                                  },
                                  // onDismissed: (
                                  //   id,
                                  //   archive,
                                  // ) {
                                  //   setState(() {
                                  //     // dbHelper!.delete(snapshot.data![index].id!);
                                  //     noteList = dbHelper!.getNotesList();
                                  //     snapshot.data!
                                  //         .remove(snapshot.data![index]);
                                  //   });
                                  // },
                                )
                              : Container()
                          : Container();
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        )),
      ),
    );
  }
}
