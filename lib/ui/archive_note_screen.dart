import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes_sqflite/db/db_handler.dart';
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: Text(
          "Archive",
          style: TextStyle(color: Colors.white),
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
          //         color: Colors.white,
          //         fontWeight: FontWeight.w500,
          //         fontSize: 14),
          //   ),
          // ),
          FutureBuilder(
            future: noteList,
            builder: (context, AsyncSnapshot<List<NotesModel>> snapshot) {
              if (snapshot.hasData) {
                return MasonryGridView.count(
                  padding: EdgeInsets.zero,
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  itemCount: snapshot.data?.length,
                  primary: false,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return snapshot.data![index].archive == 1
                        ? NoteWidget(
                          dbHelper: dbHelper!,
                            keyvalue: ValueKey<int>(snapshot.data![index].id!),
                            id: snapshot.data![index].id!,
                            title: snapshot.data![index].title.toString(),
                            note: snapshot.data![index].note.toString(),
                            pin: snapshot.data![index].pin!,
                            archive: snapshot.data![index].archive!,
                            email: snapshot.data![index].email.toString(),
                            deleted: 0,
                            createDate: snapshot.data![index].create_date.toString(),
                            editedDate: snapshot.data![index].edited_date.toString(),
                            onUpdateComplete: () {
                              setState(() {
                                noteList = dbHelper!.getNotesList();
                              });
                            },
                            onDismissed: () {
                              setState(() {
                                dbHelper!.delete(snapshot.data![index].id!);
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
    );
  }
}
