import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/model/note_model.dart';
import 'package:flutter/services.dart';
import 'package:notes_sqflite/ui/image_view_screen.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class NoteDetailScreen extends StatefulWidget {
  NoteDetailScreen({
    super.key,
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
    this.onDismissed,
    this.imageList,
  });
  bool isUpdateNote;
  int? id;
  String? title, createDate, email, note, editedDate;
  bool isDeleted, isPined, isArchived;
  List<String>? imageList;
  void Function()? onUpdateComplete, onDismissed;
  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  bool isEdited = false;
  DBHelper? dbHelper;

  late TextEditingController titleCtr;
  late TextEditingController noteCtr;

  final ImagePicker imagePicker = ImagePicker();
  List<XFile>? imageFileList = [];

  void initState() {
    super.initState();
    dbHelper = DBHelper();
    this.noteColor = Colors.black;
    indexOfCurrentColor = colors.indexOf(noteColor);
    if (widget.isUpdateNote) {
      titleCtr = TextEditingController(text: widget.title);
      noteCtr = TextEditingController(text: widget.note);
      if (widget.imageList != null) {
        imageFileList = widget.imageList!
            .where((path) => path.isNotEmpty) // Filter out empty strings
            .map((path) => XFile(path))
            .toList();
      } else {
        imageFileList = [];
      }

      // imageFileList = widget.imageList!.map((path) => XFile(path)).toList();
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

  void selectImages() async {
    final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages!.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
    }
    print("Image List Length:" + imageFileList!.length.toString());
    setState(() {});
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
        statusBarColor: Colors.transparent,
        // systemNavigationBarColor: noteColor, // navigation bar color
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          // backgroundColor: AppColors.whiteColor,
          // backgroundColor: noteColor,
          appBar: AppBar(
            // backgroundColor: AppColors.whiteColor,
            // backgroundColor: noteColor,
            leading: IconButton(
              tooltip: "Navigate up",
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).iconTheme.color),
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
                            image_list: imageFileList!
                                .map((image) => image.path)
                                .toList()))
                        .then((value) {
                      widget.onUpdateComplete!();
                    });
                  }
                },
                icon: Transform.scale(
                  scale: 1,
                  child: widget.isPined
                      ? Icon(Icons.push_pin,
                          color: Theme.of(context).iconTheme.color)
                      : Icon(Icons.push_pin_outlined,
                          color: Theme.of(context).iconTheme.color),
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
                            image_list: imageFileList!
                                .map((image) => image.path)
                                .toList()))
                        .then((value) {
                      widget.onUpdateComplete!();
                    });
                  }
                },
                icon: Transform.scale(
                  scale: 1,
                  child: widget.isArchived
                      ? Icon(Icons.archive,
                          color: Theme.of(context).iconTheme.color)
                      : Icon(Icons.archive_outlined,
                          color: Theme.of(context).iconTheme.color),
                ),
              ),
              // if (widget.isDeleted == false && widget.isUpdateNote == true)
              //   IconButton(
              //     tooltip: "Delete",
              //     onPressed: () {
              //       showDeleteDialoge();
              //     },
              //     icon: Icon(
              //       Icons.delete_forever,
              //       color: AppColors.whiteColor
              //     ),
              //   ),
              if (widget.isDeleted == true)
                PopupMenuButton(
                  color: Theme.of(context).canvasColor,
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        onTap: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
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
                                  image_list: imageFileList!
                                      .map((image) => image.path)
                                      .toList()))
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
                              color: Theme.of(context).cardColor,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Restore",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(fontSize: 14),
                            )
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () {
                          dbHelper?.deleteNote(widget.id!).then(
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
                              color: AppColors.redColor,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Delete forever",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(fontSize: 14),
                            )
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
                            autofocus: widget.isUpdateNote ? false : true,
                            maxLines: null,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                ),
                            decoration: InputDecoration(
                                hintText: "Title",
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                        color: Theme.of(context)
                                            .highlightColor
                                            .withOpacity(0.5)),
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                                disabledBorder: InputBorder.none),
                            inputFormatters: [],
                          ),
                          TextFormField(
                            controller: noteCtr,
                            minLines: 1,
                            maxLines: null,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: 16,
                                ),
                            decoration: InputDecoration(
                              hintText: "Note",
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .highlightColor
                                          .withOpacity(0.5)),
                              enabledBorder: InputBorder.none,
                              border: InputBorder.none,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 100,
                                      childAspectRatio: 3 / 3,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10),
                              scrollDirection: Axis.vertical,
                              primary: false,
                              shrinkWrap: true,
                              itemCount: imageFileList!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageViewScreen(
                                            path: imageFileList![index]
                                                .path
                                                .toString()),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 104,
                                    width: 104,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(11),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .highlightColor
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(imageFileList![index].path),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(context).canvasColor,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (widget.isDeleted == false &&
                                                    widget.isUpdateNote == true)
                                                  ListTile(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      showDeleteDialoge();
                                                    },
                                                    leading: Icon(
                                                        Icons.delete_forever,
                                                        color: AppColors
                                                            .blackColor),
                                                    title: Text(
                                                      "Delete",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                              fontSize: 14,
                                                              color: AppColors
                                                                  .blackColor),
                                                    ),
                                                  ),
                                                ListTile(
                                                  onTap: () {},
                                                  leading: Icon(Icons.copy,
                                                      color:
                                                          AppColors.blackColor),
                                                  title: Text(
                                                    "Make a Copy",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .blackColor),
                                                  ),
                                                ),
                                                ListTile(
                                                  onTap: () {},
                                                  leading: Icon(Icons.share,
                                                      color:
                                                          AppColors.blackColor),
                                                  title: Text(
                                                    "Send",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .blackColor),
                                                  ),
                                                ),
                                                ListTile(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    selectImages();
                                                  },
                                                  leading: Icon(
                                                      Icons
                                                          .add_photo_alternate_outlined,
                                                      color:
                                                          AppColors.blackColor),
                                                  title: Text(
                                                    "Add Image",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .blackColor),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.more_vert,
                                      color: Theme.of(context).iconTheme.color
                                      // color: AppColors.blackColor,
                                      ),
                                ),
                              ],
                            ),
                          )),
                      Expanded(
                          flex: 1,
                          child: widget.isUpdateNote
                              ? Container(
                                  child: Center(
                                    child: Text(
                                      "Edited ${_extractDate(widget.editedDate)}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
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
                                color: AppColors.yellowColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                onPressed: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
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
                                          edited_date: editedDate.toString(),
                                          image_list: imageFileList!
                                              .map((image) => image.path)
                                              .toList()),
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
                                child: Text(
                                  "Save",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                          fontSize: 14,
                                          color: AppColors.blackColor),
                                ),
                              ),
                            )),
                      )
                    ],
                  ),
                ),
              ],
            ),
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
        return 'Invalid Date';
      }
    } catch (e) {
      return 'Invalid Date';
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
        .insertNote(NotesModel(
      title: titleCtr.text.toString(),
      note: noteCtr.text.toString(),
      pin: widget.isPined == true ? 1 : 0,
      archive: widget.isArchived == true ? 1 : 0,
      email: '',
      deleted: 0,
      create_date: date.toString(),
      edited_date: date.toString(),
      image_list: imageFileList!.map((image) => image.path).toList(),
    ))
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
      barrierColor: Colors.black45,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).canvasColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        titleTextStyle: TextStyle(fontWeight: FontWeight.w500),
        title: Text(
          "Are you sure, you want to delete?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.blackColor,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: AppColors.blackColor)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "No",
                    style: TextStyle(color: AppColors.blackColor),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: MaterialButton(
                  color: AppColors.blueColor,
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
                              image_list: imageFileList!
                                  .map((image) => image.path)
                                  .toList()))
                          .then((value) {
                        Navigator.pop(context);
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
    ).then(
      (value) {
        if (widget.isUpdateNote) {
          widget.onUpdateComplete!();
        }
      },
    );
  }
}
