import 'dart:math' as math show Random;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/model/note_model.dart';

// ignore: must_be_immutable
class NoteWidget extends StatefulWidget {
  String title, description, email;
  void Function() onUpdateComplate, onDismissed;
  Key keyvalue;
  int id, age;
  NoteWidget(
      {super.key,
      required this.title,
      required this.age,
      required this.email,
      required this.description,
      required this.onUpdateComplate,
      required this.onDismissed,
      required this.keyvalue,
      required this.id});

  @override
  State<NoteWidget> createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {
  DBHelper? dbHelper;
  final color =
      Colors.primaries[math.Random().nextInt(Colors.primaries.length)];

  late TextEditingController titleCtr;
  late TextEditingController ageCtr;
  late TextEditingController descriptionCtr;
  late TextEditingController emailCtr;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    titleCtr = TextEditingController(text: widget.title);
    ageCtr = TextEditingController(text: "${widget.age}");
    descriptionCtr = TextEditingController(text: widget.description);
    emailCtr = TextEditingController(text: widget.email);
  }

  void clear() {
    titleCtr.clear();
    ageCtr.clear();
    descriptionCtr.clear();
    emailCtr.clear();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        // showDialog(
        //   context: context,
        //   builder: (context) {
        //     return AlertDialog(
        //       shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(10)),
        //       content: Column(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         crossAxisAlignment: CrossAxisAlignment.center,
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           SizedBox(
        //             height: 10,
        //           ),
        //           Text(
        //             "Update Note",
        //             style: TextStyle(
        //                 color: Colors.blueGrey,
        //                 fontWeight: FontWeight.bold,
        //                 fontSize: 18),
        //           ),
        //           SizedBox(
        //             height: 10,
        //           ),
        //           TextFormField(
        //             controller: titleCtr,
        //             decoration: InputDecoration(
        //               hintText: "Title",
        //             ),
        //             inputFormatters: [
        //               // LengthLimitingTextInputFormatter(2),
        //               // FilteringTextInputFormatter.deny(" ")
        //             ],
        //           ),
        //           SizedBox(
        //             height: 10,
        //           ),
        //           Row(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             crossAxisAlignment: CrossAxisAlignment.center,
        //             mainAxisSize: MainAxisSize.min,
        //             children: [
        //               Container(
        //                 width: 80,
        //                 child: TextFormField(
        //                   controller: ageCtr,
        //                   keyboardType: TextInputType.number,
        //                   decoration: InputDecoration(
        //                     hintText: "age",
        //                   ),
        //                   inputFormatters: [
        //                     FilteringTextInputFormatter.digitsOnly,
        //                     LengthLimitingTextInputFormatter(2),
        //                     FilteringTextInputFormatter.deny(" ")
        //                   ],
        //                 ),
        //               ),
        //               SizedBox(
        //                 width: 20,
        //               ),
        //               Expanded(
        //                 child: TextFormField(
        //                   controller: emailCtr,
        //                   keyboardType: TextInputType.emailAddress,
        //                   decoration: InputDecoration(hintText: "Email"),
        //                   inputFormatters: [
        //                     // FilteringTextInputFormatter.digitsOnly
        //                     FilteringTextInputFormatter.deny(" "),
        //                     LengthLimitingTextInputFormatter(50)
        //                   ],
        //                 ),
        //               ),
        //             ],
        //           ),
        //           SizedBox(
        //             height: 10,
        //           ),
        //           TextFormField(
        //             controller: descriptionCtr,
        //             minLines: 1,
        //             maxLines: 3,
        //             decoration: InputDecoration(hintText: "Description"),
        //           ),
        //           SizedBox(
        //             height: 10,
        //           ),
        //           Row(
        //             children: [
        //               Expanded(
        //                   child: MaterialButton(
        //                 shape: RoundedRectangleBorder(
        //                     borderRadius: BorderRadius.circular(10)),
        //                 color: Colors.blueGrey,
        //                 onPressed: () {
        //                   Navigator.pop(context);
        //                 },
        //                 child: Text(
        //                   "Cancel",
        //                   style: TextStyle(color: Colors.white),
        //                 ),
        //               )),
        //               SizedBox(
        //                 width: 20,
        //               ),
        //               Expanded(
        //                   child: MaterialButton(
        //                 shape: RoundedRectangleBorder(
        //                     borderRadius: BorderRadius.circular(10)),
        //                 color: Colors.green[500],
        //                 onPressed: () {
        //                   dbHelper!
        //                       .update(
        //                     NotesModel(
        //                         id: widget.id,
        //                         title: titleCtr.text.toString(),
        //                         age: int.tryParse(ageCtr.text)!,
        //                         description: descriptionCtr.text.toString(),
        //                         email: emailCtr.text.toString()),
        //                   )
        //                       .then((value) {
        //                     widget.onUpdateComplate();
        //                     Navigator.pop(context);
        //                   });
        //                 },
        //                 child: Text(
        //                   "Update",
        //                   style: TextStyle(color: Colors.white),
        //                 ),
        //               ))
        //             ],
        //           )
        //         ],
        //       ),
        //     );
        //   },
        // );
        showGeneralDialog(
          context: context,
          transitionDuration: Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) {
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
                                .update(
                              NotesModel(
                                  id: widget.id,
                                  title: titleCtr.text.toString(),
                                  age: int.tryParse(ageCtr.text)!,
                                  description: descriptionCtr.text.toString(),
                                  email: emailCtr.text.toString()),
                            )
                                .then((value) {
                              widget.onUpdateComplate();
                              clear();
                              Navigator.pop(context);
                              
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
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
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
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   crossAxisAlignment: CrossAxisAlignment.center,
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
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
                                  color: Colors.black38, fontSize: 16),
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
      child: Dismissible(
        key: widget.keyvalue,
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          widget.onDismissed();
        },
        background: Container(),
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: color.withOpacity(0.54),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
// ListTile(
//             title: Text(widget.title),
//             subtitle: Text(widget.description),
//             trailing: Text("${widget.age}"),
//           ),