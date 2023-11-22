import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/language/localisation.dart';
import 'package:notes_sqflite/model/note_model.dart';
import 'package:flutter/services.dart';
import 'package:notes_sqflite/services/notification_services.dart';
import 'package:notes_sqflite/ui/image_view_screen.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_sqflite/utils/app_message.dart';
import 'package:notes_sqflite/utils/functions.dart';
import 'package:share_plus/share_plus.dart';

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
  void Function()? onUpdateComplete;
  void Function(
    int id,
    int archive,
    int pin,
  )? onDismissed;
  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  bool isEdited = false;
  DBHelper? dbHelper;
  bool isEvening = false, isNextEvening = false, isCheckNextEvening = false;
  bool isNextMorning = false;
  bool isCustom = true;
  bool isDefault = false;

  late TextEditingController titleCtr;
  late TextEditingController noteCtr;

  late TextEditingController dateCtr;
  late TextEditingController timeCtr;

  DateTime? notificationDateTime;
  DateTime currentDate = DateTime.now();

  TimeOfDay timeOfDay = TimeOfDay.now();

  final ImagePicker imagePicker = ImagePicker();
  List<XFile>? imageFileList = [];

  void initState() {
    super.initState();
    dbHelper = DBHelper();
    timeCtr = TextEditingController();
    dateCtr = TextEditingController();
    checkEvening();
    // this.noteColor = Colors.black;
    // indexOfCurrentColor = colors.indexOf(noteColor);
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

  void checkEvening() {
    if (currentDate.hour >= 18) {
      setState(() {
        isCheckNextEvening = true;
      });
    }
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

  // final _check = Icon(Icons.check);
  // late Color noteColor;
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
        child: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, true);
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip:
                    "${AppLocalization.of(context)?.getTranslatedValue('navigate_up')}",
                onPressed: () {
                  Navigator.pop(context, true);
                },
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).iconTheme.color),
              ),
              actions: [
                IconButton(
                  tooltip:
                      "${AppLocalization.of(context)?.getTranslatedValue('pin')}",
                  onPressed: () {
                    isPinedChange();
                    if (widget.isUpdateNote) {
                      dbHelper
                          ?.updatePin(
                        NotesModel(
                          id: widget.id,
                          pin: widget.isPined == true ? 1 : 0,
                          archive: 0,
                          image_list: [],
                        ),
                      )
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
                  tooltip:
                      "${AppLocalization.of(context)?.getTranslatedValue('archive')}",
                  onPressed: () {
                    isArchivedChange();
                    if (widget.isUpdateNote) {
                      dbHelper
                          ?.updateArchive(
                        NotesModel(
                          id: widget.id,
                          archive: widget.isArchived == true ? 1 : 0,
                          pin: 0,
                          image_list: [],
                        ),
                      )
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
                                ?.deleteNote(
                              NotesModel(
                                id: widget.id,
                                deleted: 0,
                                image_list: [],
                              ),
                            )
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
                                "${AppLocalization.of(context)?.getTranslatedValue('restore')}",
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
                            dbHelper?.deleteForeverNote(widget.id!).then(
                              (value) {
                                Navigator.pop(context);
                                widget.onUpdateComplete!();
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
                                "${AppLocalization.of(context)?.getTranslatedValue('delete_forever')}",
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
                                hintText:
                                    "${AppLocalization.of(context)?.getTranslatedValue('title')}",
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                      color: Theme.of(context)
                                          .highlightColor
                                          .withOpacity(0.5),
                                    ),
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                                disabledBorder: InputBorder.none,
                              ),
                              inputFormatters: [],
                              onChanged: (value) {
                                final editedDate =
                                    DateFormat('EEEEEEEEE,d MMM y').format(
                                  DateTime.now(),
                                );

                                dbHelper!
                                    .updatetile(NotesModel(
                                  id: widget.id,
                                  title: value,
                                  edited_date: editedDate.toString(),
                                  image_list: [],
                                ))
                                    .then((result) {
                                  if (result == 1) {
                                    print("Auto-saved");
                                  }
                                });
                              },
                            ),
                            TextFormField(
                              controller: noteCtr,
                              minLines: 1,
                              maxLines: null,
                              style: Theme.of(context).textTheme.titleMedium,
                              decoration: InputDecoration(
                                hintText:
                                    "${AppLocalization.of(context)?.getTranslatedValue('note')}",
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .highlightColor
                                            .withOpacity(0.5)),
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                                disabledBorder: InputBorder.none,
                              ),
                              onChanged: (value) {
                                final editedDate =
                                    DateFormat('EEEEEEEEE,d MMM y').format(
                                  DateTime.now(),
                                );
                                dbHelper!
                                    .updateNoteText(NotesModel(
                                  id: widget.id,
                                  note: value,
                                  edited_date: editedDate.toString(),
                                  image_list: [],
                                ))
                                    .then((result) {
                                  if (result == 1) {
                                    print("Auto-saved");
                                  }
                                });
                              },
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
                                    child: SizedBox(
                                      height: 104,
                                      width: 104,
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 104,
                                            width: 104,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(11),
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .highlightColor
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.file(
                                                File(
                                                    imageFileList![index].path),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(11),
                                                color: Colors.black12),
                                            child: Align(
                                                alignment: Alignment.topRight,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        imageFileList!.removeWhere(
                                                            (element) =>
                                                                element ==
                                                                imageFileList![
                                                                    index]);
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.delete_forever,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )),
                                          )
                                        ],
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
                                        elevation: 0,
                                        builder: (context) {
                                          return Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .canvasColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (widget.isDeleted ==
                                                          false &&
                                                      widget.isUpdateNote ==
                                                          true)
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
                                                        "${AppLocalization.of(context)?.getTranslatedValue('delete')}",
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
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                              text: noteCtr.text
                                                                  .toString()));
                                                      AppMessage.showToast(
                                                          context,
                                                          "${AppLocalization.of(context)?.getTranslatedValue('note_copied')}");
                                                    },
                                                    leading: Icon(Icons.copy,
                                                        color: AppColors
                                                            .blackColor),
                                                    title: Text(
                                                      "${AppLocalization.of(context)?.getTranslatedValue('copy_note')}",
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
                                                      onshareTodo(
                                                          context,
                                                          noteCtr.text
                                                              .toString());
                                                    },
                                                    leading: Icon(Icons.share,
                                                        color: AppColors
                                                            .blackColor),
                                                    title: Text(
                                                      "${AppLocalization.of(context)?.getTranslatedValue('share_note')}",
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
                                                      showNoteDateTimeMainDialoge(
                                                        isCustom: isCustom,
                                                        isDefault: isDefault,
                                                        notificationDateTime:
                                                            notificationDateTime,
                                                        currentDate:
                                                            currentDate,
                                                        timeOfDay: timeOfDay,
                                                      );
                                                    },
                                                    leading: Icon(
                                                        Icons
                                                            .notification_add_outlined,
                                                        color: AppColors
                                                            .blackColor),
                                                    title: Text(
                                                      "${AppLocalization.of(context)?.getTranslatedValue('add_remider')}",
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
                                                        color: AppColors
                                                            .blackColor),
                                                    title: Text(
                                                      "${AppLocalization.of(context)?.getTranslatedValue('add_image')}",
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
                                      "${AppLocalization.of(context)?.getTranslatedValue('edited')} ${_extractDate(widget.editedDate)}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontSize: 12,
                                          ),
                                    ),
                                  ),
                                )
                              : Container(),
                        ),
                        Expanded(
                          flex: 1,
                          child: widget.isUpdateNote
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.symmetric(vertical: 3),
                                  child: Center(
                                    child: MaterialButton(
                                      color: AppColors.yellowColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      onPressed: () {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        addNote();
                                      },
                                      child: Text(
                                        "${AppLocalization.of(context)?.getTranslatedValue('save')}",
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
      ),
    );
  }

  void selectImages() async {
    final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages!.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
    }
    print("Image List Length:" + imageFileList!.length.toString());
    await dbHelper?.updateImageList(
      NotesModel(
        id: widget.id,
        image_list: imageFileList!.map((image) => image.path).toList(),
      ),
    );
    setState(() {});
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

  // Widget? checkOrNot(int index) {
  //   if (indexOfCurrentColor == index) {
  //     return _check;
  //   }
  //   return null;
  // }

  void onshareTodo(BuildContext context, String note) async {
    await Share.shareXFiles(
      imageFileList!,
      text: note,
      subject: "note",
    );
  }

  void addNote() {
    final date = DateFormat('EEEEEEEEE,d MMM y').format(DateTime.now());
    final time = DateFormat('kk:mm a').format(DateTime.now());
    print("$date, $time");
    dbHelper!
        .insertNote(NotesModel(
      title: titleCtr.text.toString() ?? '',
      note: noteCtr.text.toString() ?? '',
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
          "${AppLocalization.of(context)?.getTranslatedValue('are_you_sure_you_want_to_delete')}",
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
                    "${AppLocalization.of(context)?.getTranslatedValue('no')}",
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
                          ?.deleteNote(
                        NotesModel(
                          id: widget.id,
                          deleted: 1,
                          image_list: [],
                        ),
                      )
                          .then((value) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: Text(
                    "${AppLocalization.of(context)?.getTranslatedValue('yes')}",
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

  showNotificationBottomSheet() {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.access_time,
                  color: AppColors.blackColor,
                ),
                title: Row(
                  children: [
                    Text(
                      "${AppLocalization.of(context)?.getTranslatedValue('later_today')}",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 14, color: AppColors.blackColor),
                    ),
                    Spacer(),
                    Text(
                      "6:00 pm",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 14, color: AppColors.blackColor),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.access_time,
                  color: AppColors.blackColor,
                ),
                title: Row(
                  children: [
                    Text(
                      "${AppLocalization.of(context)?.getTranslatedValue('tomorrow_morning')}",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 14, color: AppColors.blackColor),
                    ),
                    Spacer(),
                    Text(
                      "8:00 am",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 14, color: AppColors.blackColor),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.access_time,
                  color: AppColors.blackColor,
                ),
                title: Text(
                  "${AppLocalization.of(context)?.getTranslatedValue('chose_a_date_and_time')}",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 14, color: AppColors.blackColor),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  showNoteDateTimeMainDialoge({
    bool? isCustom,
    bool? isDefault,
    DateTime? notificationDateTime,
    DateTime? currentDate,
    TimeOfDay? timeOfDay,
  }) {
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          Future<void> selectDate(BuildContext context) async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: currentDate,
              firstDate: DateTime(2015),
              lastDate: DateTime(2050),
            );
            if (pickedDate != null && pickedDate != currentDate) {
              setState(() {
                currentDate = pickedDate;
                final dateFormat =
                    DateFormat('EEE, d MMM y').format(currentDate!);
                dateCtr.text = dateFormat;
                // Combine date and time when the date is selected.
                notificationDateTime = currentDate!.add(
                  Duration(hours: timeOfDay!.hour, minutes: timeOfDay!.minute),
                );
                print("notificationDateTime date is :$notificationDateTime");
              });
            }
          }

          Future<void> displayTimePicker(BuildContext context) async {
            var time = await showTimePicker(
              context: context,
              initialTime: timeOfDay!,
            );
            if (time != null) {
              setState(
                () {
                  timeOfDay = time;
                  notificationDateTime = currentDate!.add(
                    Duration(
                        hours: time.hour, minutes: time.minute, seconds: 00),
                  );
                  timeCtr.text = "${time.format(context).toLowerCase()}";
                },
              );
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Theme.of(context).iconTheme.color,
            title: Row(
              children: [
                Text(
                    "${AppLocalization.of(context)?.getTranslatedValue('add_your_reminder')}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        fontSize: 18)),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      dateCtr.clear();
                      timeCtr.clear();
                      isEvening = false;
                      isNextEvening = false;
                      isNextMorning = false;
                      isCustom = true;
                      isDefault = false;
                    });
                  },
                  child: Text(
                    "${AppLocalization.of(context)?.getTranslatedValue('clear')}",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.blue),
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  GestureDetector(
                    // borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        isCustom = true;
                        isDefault = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCustom == true
                            ? AppColors.blueColor.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCustom == true
                              ? AppColors.blueColor.withOpacity(0.6)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        "${AppLocalization.of(context)?.getTranslatedValue('custom')}",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).cardColor,
                                ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    // borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() {
                      isDefault = true;
                      isCustom = false;
                    }),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDefault == true
                            ? AppColors.blueColor.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDefault == true
                              ? AppColors.blueColor.withOpacity(0.6)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        "${AppLocalization.of(context)?.getTranslatedValue('default')}",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).cardColor,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              isCustom!
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          onTap: () {
                            selectDate(context);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          splashColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          title: dateCtr.text == ""
                              ? Text(
                                  "${AppLocalization.of(context)?.getTranslatedValue('select_date')}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                )
                              : Text(
                                  "${dateCtr.text}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                ),
                          trailing: Icon(
                            Icons.date_range_outlined,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        ListTile(
                          splashColor: Colors.transparent,
                          onTap: () {
                            displayTimePicker(context);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          title: timeCtr.text == ""
                              ? Text(
                                  '${AppLocalization.of(context)?.getTranslatedValue('select_time')}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                )
                              : Text(
                                  "${timeCtr.text}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                ),
                          trailing: Icon(
                            Icons.watch_later_outlined,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: MaterialButton(
                                color: Colors.blue[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "${AppLocalization.of(context)?.getTranslatedValue('cancel')}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: MaterialButton(
                                color: dateCtr.text != "" && timeCtr.text != ""
                                    ? Colors.green[400]
                                    : Colors.green[100],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onPressed: () {
                                  if (dateCtr.text != "" &&
                                      timeCtr.text != "") {
                                    print(
                                        "notificationDateTime is :: $notificationDateTime");
                                    notificationServices.showNotification(
                                        notificationDateTime!,
                                        widget.title == ""
                                            ? widget.note!
                                            : widget.title!,
                                        timeCtr.text);
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text(
                                  "${AppLocalization.of(context)?.getTranslatedValue('add')}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCheckNextEvening == false)
                          ListTile(
                            onTap: () {
                              setState(() {
                                isEvening = !isEvening;
                                isNextMorning = false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isEvening
                                    ? AppColors.blueColor.withOpacity(0.4)
                                    : Colors.transparent,
                              ),
                            ),
                            selectedTileColor:
                                AppColors.blueColor.withOpacity(0.2),
                            selected: isEvening,
                            splashColor: Colors.transparent,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            title: Row(
                              children: [
                                Text(
                                  "${AppLocalization.of(context)?.getTranslatedValue('today_evening')}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                ),
                                Spacer(),
                                Text(
                                  "6:00 pm",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.date_range_outlined,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                        ListTile(
                          onTap: () {
                            setState(() {
                              isNextMorning = !isNextMorning;
                              isEvening = false;
                              isNextEvening = false;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isNextMorning
                                  ? AppColors.blueColor.withOpacity(0.4)
                                  : Colors.transparent,
                            ),
                          ),
                          selectedTileColor:
                              AppColors.blueColor.withOpacity(0.2),
                          selected: isNextMorning,
                          splashColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          title: Row(
                            children: [
                              Text(
                                "${AppLocalization.of(context)?.getTranslatedValue('next_morning')}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor),
                              ),
                              Spacer(),
                              Text(
                                "7:00 am",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.date_range_outlined,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        if (isCheckNextEvening == true)
                          ListTile(
                            onTap: () {
                              setState(() {
                                isNextEvening = !isNextEvening;
                                isNextMorning = false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isEvening
                                    ? AppColors.blueColor.withOpacity(0.4)
                                    : Colors.transparent,
                              ),
                            ),
                            selectedTileColor:
                                AppColors.blueColor.withOpacity(0.2),
                            selected: isNextEvening,
                            splashColor: Colors.transparent,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            title: Row(
                              children: [
                                Text(
                                  "${AppLocalization.of(context)?.getTranslatedValue('next_evening')}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                ),
                                Spacer(),
                                Text(
                                  "6:00 pm",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.date_range_outlined,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        MaterialButton(
                          minWidth: double.infinity,
                          color: Colors.green[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onPressed: () {
                            if (isNextMorning) {
                              if (widget.title != "") {
                                AppFunctions.setNextMorningNotification(
                                    widget.title!);
                                Navigator.pop(context);
                              } else {
                                AppFunctions.setNextMorningNotification(
                                    widget.note!);
                                Navigator.pop(context);
                              }
                            }
                            if (isEvening) {
                              if (widget.title != "") {
                                AppFunctions.setTodayEveningNotification(
                                    widget.note!);
                                Navigator.pop(context);
                              } else {
                                AppFunctions.setTodayEveningNotification(
                                    widget.note!);
                                Navigator.pop(context);
                              }
                            }
                            if (isNextEvening) {
                              if (widget.title != "") {
                                AppFunctions.setNextEveningNotification(
                                    widget.note!);
                                Navigator.pop(context);
                              } else {
                                AppFunctions.setNextEveningNotification(
                                    widget.note!);
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: Text(
                            "${AppLocalization.of(context)?.getTranslatedValue('add')}",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: 12,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                          ),
                        )
                      ],
                    ),
            ],
          );
        },
      ),
    ).then((value) {
      setState(() {
        isEvening = false;
        isNextMorning = false;
        isNextEvening = false;
      });
    });
  }
}
