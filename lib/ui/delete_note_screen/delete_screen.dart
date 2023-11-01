import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/model/note_model.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:notes_sqflite/widget/note_widget.dart';

class DeleteNoteScreen extends StatefulWidget {
  const DeleteNoteScreen({super.key});

  @override
  State<DeleteNoteScreen> createState() => _DeleteNoteScreenState();
}

class _DeleteNoteScreenState extends State<DeleteNoteScreen> {
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
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          isUpdateNoteScreen = true;
        });
        Navigator.pop(context);
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
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).iconTheme.color
              )),
          title: Text(
            "Deleted",
            style: TextStyle(
              // color: Colors.black
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
            //     "Deleted",
            //     style: TextStyle(
            //         color: AppColors.whiteColor
            //         fontWeight: FontWeight.w500,
            //         fontSize: 14),
            //   ),
            // ),
            FutureBuilder(
              future: noteList,
              builder: (context, AsyncSnapshot<List<NotesModel>> snapshot) {
                if (snapshot.hasData) {
                  return MasonryGridView.count(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    itemCount: snapshot.data?.length,
                    primary: false,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return snapshot.data![index].deleted == 1
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
                              createDate:
                                  snapshot.data![index].create_date.toString(),
                              editedDate:
                                  snapshot.data![index].edited_date.toString(),
                              onUpdateComplete: () {
                                setState(() {
                                  noteList = dbHelper!.getNotesList();
                                });
                              },
                              onDismissed: () {
                                setState(() {
                                  // dbHelper!.delete(snapshot.data![index].id!);
                                  noteList = dbHelper!.getNotesList();
                                  snapshot.data!.remove(snapshot.data![index]);
                                });
                              })
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
