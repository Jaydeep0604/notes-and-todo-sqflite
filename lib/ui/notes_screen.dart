import 'package:flutter/material.dart';
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
  late TextEditingController descriptionCtr;
  late TextEditingController emailCtr;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    titleCtr = TextEditingController();
    ageCtr = TextEditingController();
    descriptionCtr = TextEditingController();
    emailCtr = TextEditingController();
    loadData();
  }

  void loadData() async {
    noteList = dbHelper!.getNotesList();
  }

  void clear() {
    titleCtr.clear();
    ageCtr.clear();
    descriptionCtr.clear();
    emailCtr.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FutureBuilder(
                  future: noteList,
                  builder: (context, AsyncSnapshot<List<NotesModel>> snapshot) {
                    if (snapshot.hasData) {
                      return MasonryGridView.count(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                          return NoteWidget(
                              keyvalue:
                                  ValueKey<int>(snapshot.data![index].id!),
                              id: snapshot.data![index].id!,
                              title: snapshot.data![index].title.toString(),
                              age: snapshot.data![index].age,
                              email: snapshot.data![index].email.toString(),
                              description:
                                  snapshot.data![index].description.toString(),
                              onUpdateComplate: () {
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
                              });
                        },
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
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
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return Material(
                              child: Column(
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
                                          icon: Icon(Icons.arrow_back),
                                        ),
                                        Spacer(),
                                        IconButton(
                                          tooltip: "Pin",
                                          onPressed: () {
                                            // Navigator.pop(context);
                                          },
                                          icon: Icon(Icons.push_pin_outlined),
                                        ),
                                        IconButton(
                                          tooltip: "Archive",
                                          onPressed: () {
                                            // Navigator.pop(context);
                                          },
                                          icon: Icon(Icons.archive_outlined),
                                        ),
                                        IconButton(
                                          tooltip: "Save",
                                          onPressed: () {
                                            dbHelper!
                                                .insert(
                                              NotesModel(
                                                title: titleCtr.text.toString(),
                                                age: 0,
                                                // int.tryParse(ageCtr.text)!,
                                                description: descriptionCtr.text
                                                    .toString(),
                                                email: '--',
                                                // emailCtr.text.toString(),
                                              ),
                                            )
                                                .then((value) {
                                              print("data added");
                                              clear();
                                              setState(() {
                                                noteList =
                                                    dbHelper!.getNotesList();
                                              });
                                              Navigator.pop(context);
                                            }).onError((error, stackTrace) {
                                              print(error.toString());
                                              print(stackTrace.toString());
                                            });
                                          },
                                          icon: Icon(Icons.done),
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
                                          fontSize: 20),
                                      decoration: InputDecoration(
                                        hintText: "Title",
                                        hintStyle: TextStyle(
                                            color: Colors.black38,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 20),
                                        enabledBorder: InputBorder.none,
                                        border: InputBorder.none,
                                      ),
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
                                          // Row(
                                          //   mainAxisAlignment: MainAxisAlignment.center,
                                          //   crossAxisAlignment: CrossAxisAlignment.center,
                                          //   mainAxisSize: MainAxisSize.min,
                                          //   children: [
                                          //     Container(
                                          //       width: 80,
                                          //       child: TextFormField(
                                          //         // controller: ageCtr,
                                          //         keyboardType: TextInputType.number,
                                          //         decoration: InputDecoration(
                                          //           hintText: "age",
                                          //         ),
                                          //         inputFormatters: [
                                          //           FilteringTextInputFormatter.digitsOnly,
                                          //           LengthLimitingTextInputFormatter(2),
                                          //           FilteringTextInputFormatter.deny(" ")
                                          //         ],
                                          //       ),
                                          //     ),
                                          //     SizedBox(
                                          //       width: 20,
                                          //     ),
                                          //     Expanded(
                                          //       child: TextFormField(
                                          //         // controller: emailCtr,
                                          //         keyboardType: TextInputType.emailAddress,
                                          //         decoration: InputDecoration(hintText: "Email"),
                                          //         inputFormatters: [
                                          //           // FilteringTextInputFormatter.digitsOnly
                                          //           FilteringTextInputFormatter.deny(" "),
                                          //           LengthLimitingTextInputFormatter(50)
                                          //         ],
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                          TextFormField(
                                            controller: descriptionCtr,
                                            minLines: 1,
                                            maxLines: null,
                                            decoration: InputDecoration(
                                              hintText: "Note",
                                              hintStyle: TextStyle(
                                                  color: Colors.black38,
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
                            );
                          },
                        );
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.yellow,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.4))),
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
            ),
          ),
        ],
      ),
    );
  }
}
