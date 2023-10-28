// import 'dart:math' as math show Random;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/model/note_model.dart';
import 'package:notes_sqflite/ui/note_screen/note_detail_screen.dart';

// ignore: must_be_immutable
class NoteWidget extends StatefulWidget {
  String title, note, email, createDate, editedDate;
  void Function() onUpdateComplete, onDismissed;
  Key keyvalue;
  int id, pin, archive, deleted;
  DBHelper dbHelper;
  NoteWidget(
      {super.key,
      required this.id,
      required this.title,
      required this.note,
      required this.pin,
      required this.archive,
      required this.email,
      required this.deleted,
      required this.createDate,
      required this.editedDate,
      required this.onUpdateComplete,
      required this.onDismissed,
      required this.keyvalue,
      required this.dbHelper});

  @override
  State<NoteWidget> createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {
  DBHelper? dbHelper;
  // final color =
  //     Colors.primaries[math.Random().nextInt(Colors.primaries.length)];

  late TextEditingController titleCtr;
  late TextEditingController noteCtr;
  late TextEditingController emailCtr;

  bool? isPined, isArchived, isDeleted;

  bool isEdited = false;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    titleCtr = TextEditingController(text: widget.title);
    noteCtr = TextEditingController(text: widget.note);
    emailCtr = TextEditingController(text: widget.email);
    isPined = widget.pin == 0 ? false : true;
    isArchived = widget.archive == 0 ? false : true;
    isDeleted = widget.deleted == 0 ? false : true;
  }

  void clear() {
    titleCtr.clear();
    noteCtr.clear();
    emailCtr.clear();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        // updateNotePopupmenu();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return NoteDetailScreen(
                isUpdateNote: true,
                id: widget.id,
                title: widget.title,
                note: widget.note,
                email: widget.email,
                onDismissed: widget.onDismissed,
                isPined: widget.pin == 0 ? false : true,
                isArchived: widget.archive == 0 ? false : true,
                isDeleted: widget.deleted == 0 ? false : true,
                onUpdateComplete: widget.onUpdateComplete,
                createDate: widget.createDate,
                editedDate: widget.editedDate,
              );
            },
          ),
        );
      },
      child: Dismissible(
        key: widget.keyvalue,
        direction: widget.archive == 1
            ? DismissDirection.none
            : widget.deleted == 1
                ? DismissDirection.none
                : DismissDirection.endToStart,
        onDismissed: (direction) {
          dbHelper
              ?.update(NotesModel(
            id: widget.id,
            title: widget.title,
            note: widget.note,
            pin: widget.pin,
            archive: 1,
            email: widget.email,
            deleted: 0,
            create_date: widget.createDate,
            edited_date: widget.editedDate,
          ))
              .then((value) {
            widget.onDismissed();
            // dbHelper!.delete(
            //     snapshot.data![index].id!);
            // snapshot.data!.remove(
            //     snapshot.data![index]);
          });
        },
        background: Container(),
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Colors.white10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              width: MediaQuery.of(context).size.width * 0.5,
              // constraints: BoxConstraints(maxHeight: 270, minHeight: 0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.9)),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.pin == 1)
                    Row(
                      children: [
                        Icon(
                          Icons.push_pin_sharp,
                          size: 13,
                          color: Colors.red[400],
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Pined",
                          style:
                              TextStyle(color: Colors.red[400], fontSize: 12),
                        ),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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
                          text: widget.note,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  // void updateNotePopupmenu() {
  //   showGeneralDialog(
  //     context: context,
  //     transitionDuration: Duration(milliseconds: 300),
  //     pageBuilder: (context, animation, secondaryAnimation) {
  //       return Material(
  //         color: Colors.black,
  //         child: StatefulBuilder(builder: (context, setState) {
  //           void isPinedChange() {
  //             setState(() {
  //               isEdited = true;
  //               isPined = !isPined!;
  //             });
  //           }
  //           void isArchivedChange() {
  //             setState(() {
  //               isEdited = true;
  //               isArchived = !isArchived!;
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
  //                             Navigator.pop(
  //                                 context, isEdited == true ? true : false);
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
  //                             updateNote();
  //                           },
  //                           icon: Transform.scale(
  //                             scale: 1,
  //                             child: isPined == true
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
  //                             updateNote();
  //                           },
  //                           icon: Transform.scale(
  //                             scale: 1,
  //                             child: isArchived!
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
  //                         if (isDeleted == false)
  //                           IconButton(
  //                             tooltip: "Delete",
  //                             onPressed: () {
  //                               // showDeleteDialoge();
  //                             },
  //                             icon: Icon(
  //                               Icons.delete_forever,
  //                               color: Colors.white,
  //                             ),
  //                           ),
  //                         if (isDeleted == true)
  //                           PopupMenuButton(
  //                             color: Colors.white,
  //                             shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(10)),
  //                             itemBuilder: (context) {
  //                               return [
  //                                 PopupMenuItem(
  //                                   onTap: () async {
  //                                     setState(() {
  //                                       isDeleted = false;
  //                                       isEdited = true;
  //                                     });
  //                                     dbHelper
  //                                         ?.update(NotesModel(
  //                                       id: widget.id,
  //                                       title: titleCtr.text,
  //                                       note: noteCtr.text,
  //                                       pin: isPined == true ? 1 : 0,
  //                                       archive: isArchived == true ? 1 : 0,
  //                                       email: widget.email,
  //                                       deleted: isDeleted == true ? 1 : 0,
  //                                       create_date: widget.createDate,
  //                                       edited_date: widget.editedDate,
  //                                     ))
  //                                         .then((value) {
  //                                       if (value == 1) {
  //                                         widget.onUpdateComplete();
  //                                       }
  //                                     });
  //                                     Navigator.pop(context);
  //                                   },
  //                                   child: Row(
  //                                     children: [
  //                                       Icon(
  //                                         Icons.restore,
  //                                         color: Colors.blue[400],
  //                                       ),
  //                                       SizedBox(
  //                                         width: 10,
  //                                       ),
  //                                       Text("Restore")
  //                                     ],
  //                                   ),
  //                                 ),
  //                                 PopupMenuItem(
  //                                   onTap: () {
  //                                     dbHelper?.delete(widget.id).then(
  //                                       (value) {
  //                                         Navigator.pop(context);
  //                                         Navigator.pop(context,
  //                                             isEdited == true ? true : false);
  //                                         widget.onDismissed();
  //                                       },
  //                                     );
  //                                   },
  //                                   child: Row(
  //                                     children: [
  //                                       Icon(
  //                                         Icons.delete_forever,
  //                                         color: Colors.red[400],
  //                                       ),
  //                                       SizedBox(
  //                                         width: 10,
  //                                       ),
  //                                       Text("Delete forever")
  //                                     ],
  //                                   ),
  //                                 )
  //                               ];
  //                             },
  //                           ),
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
  //                           fontWeight: FontWeight.w400,
  //                           fontSize: 20,
  //                           color: Colors.white),
  //                       decoration: InputDecoration(
  //                         hintText: "Title",
  //                         hintStyle: TextStyle(
  //                             color: Colors.white38,
  //                             fontWeight: FontWeight.w400,
  //                             fontSize: 20),
  //                         enabledBorder: InputBorder.none,
  //                         border: InputBorder.none,
  //                       ),
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
  //                                   color: Colors.white38, fontSize: 16),
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
  //                       final editedDate = DateFormat('EEEEEEEEE,d MMM y')
  //                           .format(DateTime.now());
  //                       dbHelper!
  //                           .update(
  //                         NotesModel(
  //                             id: widget.id,
  //                             title: titleCtr.text.toString(),
  //                             note: noteCtr.text.toString(),
  //                             pin: 0,
  //                             archive: 0,
  //                             email: emailCtr.text.toString(),
  //                             deleted: 0,
  //                             create_date: widget.createDate,
  //                             edited_date: editedDate.toString()),
  //                       )
  //                           .then((value) {
  //                         widget.onUpdateComplete();
  //                         clear();
  //                         Navigator.pop(context);
  //                       });
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
  //   // .then((value) {
  //   //   if (value == true) {
  //   //     // widget.onUpdateComplete();
  //   //     Navigator.pop(context);
  //   //   }
  //   // });
  // }
  // // showDeleteDialoge() {
  // //   showDialog(
  // //     context: context,
  // //     builder: (context) => AlertDialog(
  // //       backgroundColor: Colors.white,
  // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  // //       alignment: Alignment.center,
  // //       titleTextStyle: TextStyle(fontWeight: FontWeight.w500),
  // //       title: Text(
  // //         "Are you sure, you want to delete?",
  // //         textAlign: TextAlign.center,
  // //         style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
  // //       ),
  // //       actions: [
  // //         Row(
  // //           children: [
  // //             Expanded(
  // //               child: MaterialButton(
  // //                 shape: RoundedRectangleBorder(
  // //                     borderRadius: BorderRadius.circular(10),
  // //                     side: BorderSide(color: Colors.black)),
  // //                 onPressed: () {
  // //                   Navigator.pop(context);
  // //                 },
  // //                 child: Text(
  // //                   "No",
  // //                   style: TextStyle(color: Colors.black),
  // //                 ),
  // //               ),
  // //             ),
  // //             SizedBox(
  // //               width: 10,
  // //             ),
  // //             Expanded(
  // //               child: MaterialButton(
  // //                 color: Colors.blue,
  // //                 shape: RoundedRectangleBorder(
  // //                   borderRadius: BorderRadius.circular(10),
  // //                   // side: BorderSide(color: Colors.black)
  // //                 ),
  // //                 onPressed: () {
  // //                   setState(() {
  // //                     isDeleted = true;
  // //                     isEdited = true;
  // //                   });
  // //                   dbHelper
  // //                       ?.update(NotesModel(
  // //                     id: widget.id,
  // //                     title: titleCtr.text,
  // //                     note: noteCtr.text,
  // //                     pin: isPined == true ? 1 : 0,
  // //                     archive: isArchived == true ? 1 : 0,
  // //                     email: widget.email,
  // //                     deleted: isDeleted == true ? 1 : 0,
  // //                     create_date: widget.createDate,
  // //                     edited_date: widget.editedDate,
  // //                   ))
  // //                       .then((value) {
  // //                     Navigator.pop(context);
  // //                   });
  // //                 },
  // //                 child: Text(
  // //                   "Yes",
  // //                   style: TextStyle(color: Colors.white),
  // //                 ),
  // //               ),
  // //             )
  // //           ],
  // //         ),
  // //       ],
  // //     ),
  // //   ).then((value) {
  // //     widget.onUpdateComplete();
  // //     Navigator.pop(context, isEdited == true ? true : false);
  // //     // widget.onUpdateComplete();
  // //   });
  // // }
  //void updateNote() {
  //   dbHelper
  //       ?.update(NotesModel(
  //     id: widget.id,
  //     title: titleCtr.text,
  //     note: noteCtr.text,
  //     pin: isPined == true ? 1 : 0,
  //     archive: isArchived == true ? 1 : 0,
  //     email: widget.email,
  //     deleted: isDeleted == true ? 1 : 0,
  //     create_date: widget.createDate,
  //     edited_date: widget.editedDate,
  //   ))
  //       .then((value) {
  //     widget.onUpdateComplete();
  //   });
  //   //  dbHelper
  //   //     ?.update(NotesModel(
  //   //   id: widget.id,
  //   //   title: titleCtr.text,
  //   //   note: noteCtr.text,
  //   //   pin: isPined == true ? 1 : 0,
  //   //   archive: widget.archive,
  //   //   email: widget.email,
  //   //   deleted: isDeleted == true ? 1 : 0,
  //   //   create_date: widget.createDate,
  //   //   edited_date: widget.editedDate,
  //   // ))
  //   //     .then((value) {
  //   //   // Navigator.pop(context,true);
  //   //   widget.onUpdateComplete();
  //   // });
  // }
}
