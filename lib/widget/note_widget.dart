import 'package:flutter/material.dart';
import 'package:notes_sqflite/animations/open_container.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/language/localisation.dart';
import 'package:notes_sqflite/model/note_model.dart';
import 'package:notes_sqflite/utils/app_colors.dart';

// ignore: must_be_immutable
class NoteWidget extends StatefulWidget {
  String title, note, email, createDate, editedDate;
  void Function() onUpdateComplete;
  void Function(
    int id,
    int archive,
    int pin,
  )? onDismissed;
  Key keyvalue;
  int id, pin, archive, deleted;
  List<String> imageList;
  DBHelper dbHelper;
  NoteWidget({
    super.key,
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
    this.onDismissed,
    required this.keyvalue,
    required this.dbHelper,
    required this.imageList,
  });

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
    return OpenNoteContainerWrapper(
      id: widget.id,
      onUpdateComplete: widget.onUpdateComplete,
      closedChild: Dismissible(
        key: widget.keyvalue,
        direction: widget.archive == 1
            ? DismissDirection.none
            : widget.deleted == 1
                ? DismissDirection.none
                : DismissDirection.horizontal,
        onDismissed: (direction) {
          dbHelper?.updateArchive(
            NotesModel(
              id: widget.id,
              archive: 1,
              pin: 0,
              image_list: [],
            ),
          );
        },
        background: Container(),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            width: MediaQuery.of(context).size.width * 0.5,
            // constraints: BoxConstraints(maxHeight: 270, minHeight: 0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(
                color: Theme.of(context).iconTheme.color!.withOpacity(0.6),
                width: 0.7,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
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
                        color: AppColors.redColor,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "${AppLocalization.of(context)?.getTranslatedValue('pined')}",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                      ),
                    ],
                  ),
                if (widget.pin == 1)
                  SizedBox(
                    height: 5,
                  ),
                if (widget.title != "")
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                  ),
                if (widget.title != "" && widget.note != "")
                  SizedBox(
                    height: 10,
                  ),
                if (widget.note != "")
                  RichText(
                    maxLines: 14,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.note,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 13,
                                  ),
                        ),
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
}
