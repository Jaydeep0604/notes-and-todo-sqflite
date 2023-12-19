import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/language/localisation.dart';
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
    final height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          isUpdateNoteScreen = true;
        });
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
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
            "${AppLocalization.of(context)?.getTranslatedValue('deleted')}",
            style: TextStyle(
                // color: Colors.black
                ),
          ),
          centerTitle: false,
        ),
        body: FutureBuilder(
          future: noteList,
          builder: (context, AsyncSnapshot<List<NotesModel>> snapshot) {
            int deletedCount = snapshot.data != null &&
                    snapshot.data!.any((item) => item.deleted == 1)
                ? snapshot.data!.length
                : 0;
            if (snapshot.hasData) {
              if (deletedCount == 0) {
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
              return Expanded(
                child: MasonryGridView.count(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  crossAxisCount: 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  itemCount: deletedCount,
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
                            imageList: snapshot.data![index].image_list,
                            onUpdateComplete: () {
                              setState(() {
                                noteList = dbHelper!.getNotesList();
                              });
                            },
                            // onDismissed: (id, archive) {
                            //   setState(() {
                            //     // dbHelper!.delete(snapshot.data![index].id!);
                            //     noteList = dbHelper!.getNotesList();
                            //     snapshot.data!.remove(snapshot.data![index]);
                            //   });
                            // },
                          )
                        : Container();
                  },
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
