import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/model/note_model.dart';
import 'package:flutter/services.dart';

class NoteDetailScreen extends StatefulWidget {
  NoteDetailScreen(
      {super.key,
      required this.isUpdateNote,
      this.id,
      this.title,
      this.note,
      this.createDate,
      this.email,
      this.editedDate,
      this.isDeleted = false,
      this.isPined = false,
      this.isArchived = false,
      this.onUpdateComplete,
      this.onDismissed});
  bool isUpdateNote;
  int? id;
  String? title, createDate, email, note, editedDate;
  bool isDeleted, isPined, isArchived;
  void Function()? onUpdateComplete, onDismissed;
  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  bool isEdited = false;

  DBHelper? dbHelper;

  late TextEditingController titleCtr;
  late TextEditingController noteCtr;

  void initState() {
    super.initState();
    dbHelper = DBHelper();
    this.noteColor = Colors.black;
    indexOfCurrentColor = colors.indexOf(noteColor);
    if (widget.isUpdateNote) {
      titleCtr = TextEditingController(text: widget.title);
      noteCtr = TextEditingController(text: widget.note);
    } else {
      titleCtr = TextEditingController();
      noteCtr = TextEditingController();
    }
  }

  void clear() {
    titleCtr.clear();
    noteCtr.clear();
    setState(() {
      widget.isPined = false;
      widget.isArchived = false;
    });
  }

  void isPinedChange() {
    setState(() {
      widget.isPined = !widget.isPined;
    });
  }

  void isArchivedChange() {
    setState(() {
      widget.isArchived = !widget.isArchived;
      setState;
    });
  }

  final colors = [
    Color(0xff000000), // Black
    Color(0xffF28B81), // Light Pink
    Color.fromARGB(255, 2, 47, 247), // Yellow
    Color.fromARGB(255, 240, 149, 75), // Light Yellow
    Color.fromARGB(255, 74, 101, 223), // Light Green
    Color.fromARGB(255, 35, 175, 175), // Turquoise
    Color.fromARGB(255, 84, 153, 170), // Light Cyan
    Color.fromARGB(255, 76, 133, 230), // Light Blue
    Color.fromARGB(255, 171, 101, 233), // Plum
    Color.fromARGB(255, 228, 129, 187), // Misty Rose
    Color.fromARGB(255, 196, 155, 112), // Light Brown
    Color.fromARGB(255, 108, 142, 158) // Light Gray
  ];

  final Color borderColor = Color(0xffd3d3d3);
  final Color foregroundColor = Color(0xff595959);

  final _check = Icon(Icons.check);
  late Color noteColor;

  late int indexOfCurrentColor;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, //i like transaparent :-)
        systemNavigationBarColor: noteColor, // navigation bar color
        statusBarIconBrightness: Brightness.dark, // status bar icons' color
        systemNavigationBarIconBrightness:
            Brightness.dark, //navigation bar icons' color
      ),
      child: Scaffold(
        backgroundColor: noteColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: noteColor,
          leading: IconButton(
            tooltip: "Navigate up",
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              tooltip: "Pin",
              onPressed: () {
                isPinedChange();
                if (widget.isUpdateNote) {
                  dbHelper
                      ?.update(NotesModel(
                    id: widget.id,
                    title: titleCtr.text,
                    note: noteCtr.text,
                    pin: widget.isPined == true ? 1 : 0,
                    archive: widget.isArchived == true ? 1 : 0,
                    email: widget.email,
                    deleted: widget.isDeleted == true ? 1 : 0,
                    create_date: widget.createDate,
                    edited_date: widget.editedDate,
                  ))
                      .then((value) {
                    widget.onUpdateComplete!();
                  });
                }
              },
              icon: Transform.scale(
                scale: 1,
                child: widget.isPined
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
                if (widget.isUpdateNote) {
                  dbHelper
                      ?.update(NotesModel(
                    id: widget.id,
                    title: titleCtr.text,
                    note: noteCtr.text,
                    pin: widget.isPined == true ? 1 : 0,
                    archive: widget.isArchived == true ? 1 : 0,
                    email: widget.email,
                    deleted: widget.isDeleted == true ? 1 : 0,
                    create_date: widget.createDate,
                    edited_date: widget.editedDate,
                  ))
                      .then((value) {
                    widget.onUpdateComplete!();
                  });
                }
              },
              icon: Transform.scale(
                scale: 1,
                child: widget.isArchived
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
            if (widget.isDeleted == false && widget.isUpdateNote == true)
              IconButton(
                tooltip: "Delete",
                onPressed: () {
                  showDeleteDialoge();
                },
                icon: Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                ),
              ),
            if (widget.isDeleted == true)
              PopupMenuButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      onTap: () async {
                        setState(() {
                          widget.isDeleted = false;
                          isEdited = true;
                        });
                        dbHelper
                            ?.update(NotesModel(
                          id: widget.id,
                          title: titleCtr.text,
                          note: noteCtr.text,
                          pin: widget.isPined == true ? 1 : 0,
                          archive: widget.isArchived == true ? 1 : 0,
                          email: widget.email,
                          deleted: widget.isDeleted == true ? 1 : 0,
                          create_date: widget.createDate,
                          edited_date: widget.editedDate,
                        ))
                            .then((value) {
                          if (value == 1) {
                            widget.onUpdateComplete!();
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.restore,
                            color: Colors.blue[400],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Restore")
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        dbHelper?.delete(widget.id!).then(
                          (value) {
                            Navigator.pop(context);
                            widget.onDismissed!();
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_forever,
                            color: Colors.red[400],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Delete forever")
                        ],
                      ),
                    )
                  ];
                },
              ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
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
                        TextFormField(
                          controller: noteCtr,
                          minLines: 1,
                          maxLines: null,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Note",
                            hintStyle:
                                TextStyle(color: Colors.white60, fontSize: 16),
                            enabledBorder: InputBorder.none,
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 50,
                color: noteColor,
                // color: Colors.grey[900],
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    // backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: noteColor,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20)),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              onTap: () {},
                                              leading: Icon(
                                                Icons.delete_forever,
                                                color: Colors.white,
                                              ),
                                              title: Text(
                                                "Delete",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              onTap: () {},
                                              leading: Icon(
                                                Icons.copy,
                                                color: Colors.white,
                                              ),
                                              title: Text(
                                                "Make a Copy",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              onTap: () {},
                                              leading: Icon(
                                                Icons.share,
                                                color: Colors.white,
                                              ),
                                              title: Text(
                                                "Send",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons
                                                    .add_photo_alternate_outlined,
                                                color: Colors.white,
                                              ),
                                              title: Text(
                                                "Add Image",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                icon: Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                ),
                              ),
                              // IconButton(
                              //   onPressed: () {
                              //     showModalBottomSheet(
                              //       context: context,
                              //       builder: (context) {
                              //         return StatefulBuilder(
                              //             builder: (context, setState) {
                              //           void _colorChangeTapped(
                              //               int indexOfColor) {
                              //             setState(() {
                              //               noteColor = colors[indexOfColor];
                              //               indexOfCurrentColor = indexOfColor;
                              //               Navigator.pop(context);
                              //               // widget.callBackColorTapped(
                              //               //     colors[indexOfColor]);
                              //             });
                              //           }
                              //           return Container(
                              //             padding: EdgeInsets.symmetric(
                              //                 vertical: 10),
                              //             decoration: BoxDecoration(
                              //               color: noteColor,
                              //               borderRadius: BorderRadius.only(
                              //                   topLeft: Radius.circular(20),
                              //                   topRight: Radius.circular(20)),
                              //             ),
                              //             width:
                              //                 MediaQuery.of(context).size.width,
                              //             child: Column(
                              //               mainAxisAlignment:
                              //                   MainAxisAlignment.start,
                              //               crossAxisAlignment:
                              //                   CrossAxisAlignment.start,
                              //               mainAxisSize: MainAxisSize.min,
                              //               children: [
                              //                 Padding(
                              //                   padding: const EdgeInsets.only(
                              //                       left: 10),
                              //                   child: Text(
                              //                     "Colour",
                              //                     style: TextStyle(
                              //                       color: Colors.white,
                              //                     ),
                              //                   ),
                              //                 ),
                              //                 SizedBox(
                              //                   height: 10,
                              //                 ),
                              //                 Container(
                              //                   height: 50,
                              //                   child: ListView(
                              //                     scrollDirection:
                              //                         Axis.horizontal,
                              //                     children: List.generate(
                              //                         colors.length, (index) {
                              //                       return GestureDetector(
                              //                           onTap: () =>
                              //                               _colorChangeTapped(
                              //                                   index),
                              //                           child: Padding(
                              //                               padding:
                              //                                   EdgeInsets.only(
                              //                                       left: 6,
                              //                                       right: 6),
                              //                               child: Container(
                              //                                   child:
                              //                                       new CircleAvatar(
                              //                                     child:
                              //                                         _checkOrNot(
                              //                                             index),
                              //                                     foregroundColor:
                              //                                         foregroundColor,
                              //                                     backgroundColor:
                              //                                         colors[
                              //                                             index],
                              //                                   ),
                              //                                   width: 48.0,
                              //                                   height: 48.0,
                              //                                   padding: const EdgeInsets
                              //                                           .all(
                              //                                       1.0), // border width
                              //                                   decoration:
                              //                                       new BoxDecoration(
                              //                                     color: Colors
                              //                                         .yellow, // border color
                              //                                     shape: BoxShape
                              //                                         .circle,
                              //                                   ))));
                              //                     }),
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           );
                              //         });
                              //       },
                              //     ).then((value) {
                              //       setState(() {});
                              //     });
                              //   },
                              //   icon: Icon(
                              //     Icons.color_lens_outlined,
                              //     color: Colors.white,
                              //   ),
                              // ),
                            ],
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: widget.isUpdateNote
                            ? Container(
                                child: Center(
                                  child: Text(
                                    _extractDate(widget.editedDate),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                            : Container()),
                    Expanded(
                      flex: 1,
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 3),
                          child: Center(
                            child: MaterialButton(
                              color: Colors.yellow,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              onPressed: () {
                                if (widget.isUpdateNote) {
                                  final editedDate =
                                      DateFormat('EEEEEEEEE,d MMM y').format(
                                    DateTime.now(),
                                  );
                                  dbHelper!
                                      .update(
                                    NotesModel(
                                        id: widget.id,
                                        title: titleCtr.text.toString(),
                                        note: noteCtr.text.toString(),
                                        pin: 0,
                                        archive: 0,
                                        email: '',
                                        deleted:
                                            widget.isDeleted == true ? 1 : 0,
                                        create_date: widget.createDate,
                                        edited_date: editedDate.toString()),
                                  )
                                      .then((value) {
                                    widget.onUpdateComplete!();
                                    clear();
                                    Navigator.pop(context);
                                  });
                                } else {
                                  addNote();
                                }
                              },
                              child: Text("Save"),
                            ),
                          )),
                    )
                  ],
                ),
              ),
              // Align(
              //   alignment: Alignment.bottomRight,
              //   child: Padding(
              //     padding: const EdgeInsets.only(bottom: 20, right: 20),
              //     child: InkWell(
              //       splashColor: Colors.blueGrey,
              //       borderRadius: BorderRadius.circular(50),
              //       radius: 10,
              //       onTap: () {
              //         if (widget.isUpdateNote) {
              //           final editedDate = DateFormat('EEEEEEEEE,d MMM y')
              //               .format(DateTime.now());
              //           dbHelper!
              //               .update(
              //             NotesModel(
              //                 id: widget.id,
              //                 title: titleCtr.text.toString(),
              //                 note: noteCtr.text.toString(),
              //                 pin: 0,
              //                 archive: 0,
              //                 email: '',
              //                 deleted: 0,
              //                 create_date: widget.createDate,
              //                 edited_date: editedDate.toString()),
              //           )
              //               .then((value) {
              //             widget.onUpdateComplete!();
              //             clear();
              //             Navigator.pop(context);
              //           });
              //         } else {
              //           addNote();
              //         }
              //       },
              //       child: Container(
              //         decoration: BoxDecoration(
              //             color: Colors.yellow,
              //             shape: BoxShape.circle,
              //             border:
              //                 Border.all(color: Colors.white.withOpacity(0.4))),
              //         child: Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Icon(
              //             Icons.check,
              //             color: Colors.black,
              //             size: 30,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractDate(String? dateString) {
    try {
      final dateParts = dateString!.split(','); // Split the string by comma
      if (dateParts.length == 2) {
        return dateParts[1]
            .trim(); // Return the second part after trimming any leading/trailing spaces
      } else {
        return 'Invalid Date'; // Handle invalid format
      }
    } catch (e) {
      return 'Invalid Date'; // Handle parsing errors
    }
  }

  Widget? _checkOrNot(int index) {
    if (indexOfCurrentColor == index) {
      return _check;
    }
    return null;
  }

  void addNote() {
    final date = DateFormat('EEEEEEEEE,d MMM y').format(DateTime.now());
    final time = DateFormat('kk:mm a').format(DateTime.now());
    print("$date, $time");
    dbHelper!
        .insert(
      NotesModel(
        title: titleCtr.text.toString(),
        note: noteCtr.text.toString(),
        pin: widget.isPined == true ? 1 : 0,
        archive: widget.isArchived == true ? 1 : 0,
        email: '',
        deleted: 0,
        create_date: date.toString(),
        edited_date: date.toString(),
      ),
    )
        .then((value) {
      print("data added");
      clear();
      Navigator.pop(context, true);
    }).onError((error, stackTrace) {
      print(error.toString());
      print(stackTrace.toString());
    });
  }

  showDeleteDialoge() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        titleTextStyle: TextStyle(fontWeight: FontWeight.w500),
        title: Text(
          "Are you sure, you want to delete?",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.black)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "No",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: MaterialButton(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    // side: BorderSide(color: Colors.black)
                  ),
                  onPressed: () {
                    if (widget.isUpdateNote) {
                      setState(() {
                        widget.isDeleted = true;
                        isEdited = true;
                      });
                      dbHelper
                          ?.update(NotesModel(
                        id: widget.id,
                        title: titleCtr.text,
                        note: noteCtr.text,
                        pin: widget.isPined == true ? 1 : 0,
                        archive: widget.isArchived == true ? 1 : 0,
                        email: widget.email,
                        deleted: widget.isDeleted == true ? 1 : 0,
                        create_date: widget.createDate,
                        edited_date: widget.editedDate,
                      ))
                          .then((value) {
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: Text(
                    "Yes",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    ).then((value) {
      if (widget.isUpdateNote) {
        widget.onUpdateComplete!();
      }
      Navigator.pop(context, isEdited == true ? true : false);
    });
  }
}
