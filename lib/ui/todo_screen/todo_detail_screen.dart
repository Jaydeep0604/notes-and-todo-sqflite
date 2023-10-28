import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/db/list_data.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/model/todo_model.dart';
import 'package:notes_sqflite/services/notification_services.dart';

class TodoDetailscreen extends StatefulWidget {
  bool isUpdateTodo;
  bool? isDone;
  String? todo;
  String? date;
  String? time;
  String? categoryName;
  void Function()? onDelete;
  void Function(String description, String time, String date, int status,
      String category)? onUpdate;
  TodoDetailscreen(
      {super.key,
      required this.isUpdateTodo,
      this.isDone,
      this.todo,
      this.date,
      this.time,
      this.categoryName,
      this.onDelete,
      this.onUpdate});

  @override
  State<TodoDetailscreen> createState() => _TodoDetailscreenState();
}

class _TodoDetailscreenState extends State<TodoDetailscreen> {
  DBHelper? dbHelper;

  late TextEditingController timeCtr;
  late TextEditingController dateCtr;
  late TextEditingController todoCtr;

  bool isFinished = false;
  String? categoryName;

  void initState() {
    super.initState();
    dbHelper = DBHelper();

    if (widget.isUpdateTodo) {
      categoryName = widget.categoryName;
      isFinished = widget.isDone!;
    } else {
      categoryName = ListData.category[0];
    }
    setData();
  }

  void setData() {
    if (widget.isUpdateTodo) {
      timeCtr = TextEditingController(text: widget.time);
      dateCtr = TextEditingController(text: widget.date);
      todoCtr = TextEditingController(text: widget.todo);
    } else {
      timeCtr = TextEditingController();
      dateCtr = TextEditingController();
      todoCtr = TextEditingController();
    }
  }

  clear() {
    todoCtr.clear();
    timeCtr.clear();
    dateCtr.clear();
  }

  void dispose() {
    super.dispose();
  }

  DateTime currentDate = DateTime.now();
  DateTime? notificationDateTime;
  TimeOfDay timeOfDay = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2050),
    );
    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        currentDate = pickedDate;
        final dateFormat = DateFormat('EEEEEEEEE, d MMM y').format(currentDate);
        dateCtr.text = dateFormat;
        // Combine date and time when the date is selected.
        notificationDateTime = currentDate.add(
          Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute),
        );
      });
    }
  }

  Future<void> displayTimePicker(BuildContext context) async {
    var time = await showTimePicker(
      context: context,
      initialTime: timeOfDay,
    );
    if (time != null) {
      setState(
        () {
          timeOfDay = time;
          // Combine date and time when the time is selected.
          notificationDateTime = currentDate.add(
            Duration(hours: time.hour, minutes: time.minute),
          );
          timeCtr.text = "${time.format(context).toLowerCase()}";
        },
      );
    }
  }

  RelativeRect buttonMenuPosition(BuildContext context) {
    final RenderBox bar = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    const Offset offset = Offset.zero;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        bar.localToGlobal(bar.size.center(Offset(0, 0)), ancestor: overlay),
        bar.localToGlobal(bar.size.center(Offset(0, 0)), ancestor: overlay),
      ),
      offset & overlay.size,
    );
    return position;
  }

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppBar(
              backgroundColor: Colors.black,
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
                if (widget.isUpdateTodo)
                  IconButton(
                    tooltip: "Share schedules",
                    onPressed: () {
                      // Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                  ),
                if (widget.isUpdateTodo)
                  IconButton(
                    tooltip: "Delete",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          alignment: Alignment.center,
                          titleTextStyle:
                              TextStyle(fontWeight: FontWeight.w500),
                          title: Text(
                            "Are you sure, you want to delete?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black),
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
                                      if (widget.isUpdateTodo) {
                                        widget.onDelete!();
                                      }
                                      Navigator.pop(context);
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
                      ).then((value) => Navigator.pop(context));
                    },
                    icon: Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                    ),
                  ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            Expanded(
                child: Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "What is to be done?",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                        ),
                        TextFormField(
                          controller: todoCtr,
                          minLines: 1,
                          maxLines: null,
                          style: TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter schedule";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Enter schedule here",
                            errorStyle: TextStyle(color: Colors.red[400]),
                            hintStyle:
                                TextStyle(color: Colors.white, fontSize: 16),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red.shade400,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Checkbox(
                                value: isFinished,
                                checkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                activeColor:
                                    Colors.blueGrey.shade900.withGreen(140),
                                side: BorderSide(color: Colors.white),
                                onChanged: (value) {
                                  setState(() {
                                    isFinished = value!;
                                  });
                                }),
                            Text(
                              "Schedule complated?",
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.w500,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Due date",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: dateCtr,
                          readOnly: true,
                          style: TextStyle(color: Colors.red[400]),
                          onTap: () {
                            _selectDate(context);
                          },
                          minLines: 1,
                          maxLines: 1,
                          decoration: InputDecoration(
                              hintText: "Date not set",
                              hintStyle: TextStyle(color: Colors.red[400])),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: timeCtr,
                          onTap: () {
                            displayTimePicker(context);
                          },
                          readOnly: true,
                          minLines: 1,
                          maxLines: 1,
                          style: TextStyle(color: Colors.red[400]),
                          decoration: InputDecoration(
                              hintText: "Set time",
                              hintStyle: TextStyle(color: Colors.red[400])),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        PopupMenuButton(
                          color: Colors.white,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${categoryName}",
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_drop_down_sharp,
                                  color: Colors.blue,
                                )
                              ],
                            ),
                          ),
                          itemBuilder: (context) => List.generate(
                            ListData.category.length,
                            (index) => PopupMenuItem(
                              onTap: () {
                                setState(() {
                                  categoryName = ListData.category[index];
                                });
                              },
                              child: Text(
                                ListData.category[index],
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20, right: 20),
                    child: InkWell(
                      splashColor: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(50),
                      radius: 10,
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          if (widget.isUpdateTodo) {
                            widget.onUpdate!(
                              todoCtr.text,
                              dateCtr.text,
                              timeCtr.text,
                              isFinished == true ? 1 : 0,
                              categoryName!,
                            );
                          } else {
                            dbHelper!
                                .insertTodo(
                              TodoModel(
                                todo: todoCtr.text,
                                finished: isFinished == false ? 0 : 1,
                                dueDate: dateCtr.text,
                                dueTime: timeCtr.text,
                                category: categoryName.toString(),
                              ),
                            )
                                .then((value) {
                              print("data added");
                              setState(() {
                                isUpdateTodoScreen = true;
                              });
                              if (notificationDateTime != null) {
                                notificationServices.showNotification(
                                  notificationDateTime!,
                                  todoCtr.text,
                                  timeCtr.text,
                                );
                              }
                              clear();
                              Navigator.pop(context);
                            }).onError(
                              (error, stackTrace) {
                                print(error.toString());
                                print(stackTrace.toString());
                              },
                            );
                          }
                        }
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
                            Icons.check,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
