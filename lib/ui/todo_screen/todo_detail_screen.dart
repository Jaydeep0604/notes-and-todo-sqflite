import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/db/list_data.dart';
import 'package:notes_sqflite/language/localisation.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/model/notification_model.dart';
import 'package:notes_sqflite/model/todo_model.dart';
import 'package:notes_sqflite/services/notification_services.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:notes_sqflite/utils/functions.dart';
import 'package:notes_sqflite/widget/theme_container.dart';

class TodoDetailscreen extends StatefulWidget {
  bool isUpdateTodo;
  int? id;

  void Function()? onDelete;
  void Function()? onUpdate;
  TodoDetailscreen(
      {super.key,
      required this.isUpdateTodo,
      this.id,
      this.onDelete,
      this.onUpdate});

  @override
  State<TodoDetailscreen> createState() => _TodoDetailscreenState();
}

class _TodoDetailscreenState extends State<TodoDetailscreen> {
  DBHelper? dbHelper;

  late Future<List<TodoModel>> sheduleList;
  late Future<List<NotificationDataModel>> notificationList;

  late TextEditingController timeCtr;
  late TextEditingController dateCtr;
  late TextEditingController todoCtr;

  bool isFinished = false;
  String? categoryName;
  int? notificationId;

  void initState() {
    super.initState();
    dbHelper = DBHelper();

    timeCtr = TextEditingController();
    dateCtr = TextEditingController();
    todoCtr = TextEditingController();

    if (widget.isUpdateTodo) {
      loadData();

      notificationList = dbHelper!.getNotification();
      notificationList.then((value) {
        for (var item in value) {
          if (item.parentId == widget.id && item.region == "schedules") {
            notificationId = item.notificationId;
          }
        }
      });
    }
    if (!widget.isUpdateTodo) {
      categoryName = ListData.category[0];
    }
  }

  void loadData() async {
    sheduleList = dbHelper!.getSingleTodo(widget.id!);
  }

  clear() {
    todoCtr.clear();
    timeCtr.clear();
    dateCtr.clear();
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: ThemedContainer(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Form(
            key: formKey,
            child:
                widget.isUpdateTodo ? updateSheduleWidget() : newSheduleWidget(),
          ),
        ),
      ),
    );
  }

  Widget newSheduleWidget() {
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
          final dateFormat =
              DateFormat('EEEEEEEEE, d MMM y').format(currentDate);
          dateCtr.text = dateFormat;
          notificationDateTime = pickedDate;
        });
      }
    }

    Future<void> displayTimePicker(BuildContext context) async {
      var time = await showTimePicker(
        context: context,
        initialTime: timeOfDay,
      );
      if (time != null) {
        if (mounted)
          setState(
            () {
              notificationDateTime = currentDate.add(
                Duration(hours: 00, minutes: 00, seconds: 00),
              );
              timeOfDay = time;
              notificationDateTime = currentDate.add(
                Duration(hours: time.hour, minutes: time.minute, seconds: 00),
              );
              print("$notificationDateTime+++++++++++");
              timeCtr.text = "${time.format(context).toLowerCase()}";
            },
          );
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            tooltip:
                "${AppLocalization.of(context)?.getTranslatedValue('navigate_up')}",
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).iconTheme.color),
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
                  Text(
                    "${AppLocalization.of(context)?.getTranslatedValue('what_is_to_be_done')}?",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: AppColors.blueColor,
                        ),
                  ),
                  TextFormField(
                    controller: todoCtr,
                    minLines: 1,
                    autofocus: true,
                    maxLines: null,
                    style: Theme.of(context).textTheme.titleMedium,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "${AppLocalization.of(context)?.getTranslatedValue('enter_schedule')}";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText:
                          "${AppLocalization.of(context)?.getTranslatedValue('enter_schedule_here')}",
                      errorStyle: TextStyle(color: AppColors.redColor),
                      hintStyle: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 14),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.redColor,
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
                          // checkColor: AppColors.blackColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          activeColor: AppColors.bottomNavigationBarSecondColor,
                          // side: BorderSide(color: AppColors.blackColor),
                          onChanged: (value) {
                            setState(() {
                              isFinished = value!;
                            });
                          }),
                      Text(
                        "${AppLocalization.of(context)?.getTranslatedValue('schedule_complated')}?",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                      "${AppLocalization.of(context)?.getTranslatedValue('due_date')}",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: AppColors.blueColor,
                          )),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: dateCtr,
                    readOnly: true,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                          color: Colors.red[400],
                        ),
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      _selectDate(context);
                    },
                    minLines: 1,
                    maxLines: 1,
                    decoration: InputDecoration(
                        hintText:
                            "${AppLocalization.of(context)?.getTranslatedValue('set_date')}",
                        hintStyle:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 14,
                                  color: Colors.red[400],
                                )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: timeCtr,
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      displayTimePicker(context);
                    },
                    readOnly: true,
                    minLines: 1,
                    maxLines: 1,
                    style: TextStyle(color: AppColors.redColor),
                    decoration: InputDecoration(
                        hintText:
                            "${AppLocalization.of(context)?.getTranslatedValue('set_time')}",
                        hintStyle:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 14,
                                  color: Colors.red[400],
                                )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  PopupMenuButton(
                    color: Theme.of(context).canvasColor,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.blueColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${categoryName}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.arrow_drop_down_sharp,
                              color: Theme.of(context).iconTheme.color)
                        ],
                      ),
                    ),
                    itemBuilder: (context) => List.generate(
                      ListData.category.length,
                      (index) => PopupMenuItem(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            categoryName = ListData.category[index];
                          });
                        },
                        child: Text(
                          ListData.category[index],
                          style: TextStyle(color: AppColors.blackColor),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
            child: MaterialButton(
              color: AppColors.yellowColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  AppFunctions.requestStoragePermission().then((value) {
                    if (value == true) {
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
                          AppFunctions.requestNotificationPermission()
                              .then((value) {
                            if (value == true) {
                              dbHelper!
                                  .getTodoUsingTitle(todoCtr.text)
                                  .then((value) {
                                AppFunctions.setNewSheduleNotification(
                                  id: value.last.id!,
                                  scheduledTime: notificationDateTime!,
                                  body: value.last.dueTime,
                                  title: value.last.todo,
                                );
                              });
                            }
                          });
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
                  });
                }
              },
              child: Text(
                "${AppLocalization.of(context)?.getTranslatedValue('save')}",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontSize: 14, color: AppColors.blackColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget updateSheduleWidget() {
    DateTime? currentDate;
    DateTime currentTime;
    DateTime? notificationDateTime;
    TimeOfDay timeOfDay;

    return FutureBuilder(
        future: sheduleList,
        builder: (context, AsyncSnapshot<List<TodoModel>> snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              timeCtr.text = snapshot.data!.last.dueTime;
              dateCtr.text = snapshot.data!.last.dueDate;
              todoCtr.text = snapshot.data!.last.todo;
              categoryName = snapshot.data!.last.category;
              isFinished = snapshot.data!.last.finished == 1 ? true : false;
            });
            currentDate = dateCtr.text != ''
                ? DateFormat('EEEEEEEEE, dd MMM yyyy', 'en_US')
                    .parseLoose('${dateCtr.text}')
                : DateTime.now();

            currentTime = timeCtr.text != ''
                ? DateFormat('h:mm a', 'en_US').parseLoose('${timeCtr.text}')
                : DateTime.now();
            timeOfDay =
                TimeOfDay(hour: currentTime.hour, minute: currentTime.minute);
            return StatefulBuilder(builder: (context, setState) {
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
                    final dateFormat =
                        DateFormat('EEEEEEEEE, d MMM y').format(currentDate!);
                    dateCtr.text = dateFormat;
                    notificationDateTime = pickedDate;
                  });
                }
              }

              Future<void> displayTimePicker(BuildContext context) async {
                var time = await showTimePicker(
                  context: context,
                  initialTime: timeOfDay,
                );
                if (time != null) {
                  if (mounted)
                    setState(
                      () {
                        notificationDateTime = currentDate!.add(
                          Duration(hours: 00, minutes: 00, seconds: 00),
                        );
                        timeOfDay = time;
                        notificationDateTime = currentDate!.subtract(
                          Duration(
                              hours: time.hour,
                              minutes: time.minute,
                              seconds: 00),
                        );
                        print("$notificationDateTime+++++++++++");
                        timeCtr.text = "${time.format(context).toLowerCase()}";
                      },
                    );
                }
              }

              showDeleteDialoge() {
                return showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Theme.of(context).canvasColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    titleTextStyle: TextStyle(fontWeight: FontWeight.w500),
                    title: Text(
                      "${AppLocalization.of(context)?.getTranslatedValue('are_you_sure_you_want_to_delete')}?",
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
                                  side:
                                      BorderSide(color: AppColors.blackColor)),
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
                                widget.onDelete!();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text(
                                "${AppLocalization.of(context)?.getTranslatedValue('yes')}",
                                style: TextStyle(color: AppColors.whiteColor),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                );
              }

              void shareTodo(String todo, String date, String time) async {
                await FlutterShare.share(
                  title: "todo",
                  text: "$todo ($date, $time)",
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AppBar(
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      tooltip:
                          "${AppLocalization.of(context)?.getTranslatedValue('navigate_up')}",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back,
                          color: Theme.of(context).iconTheme.color),
                    ),
                    actions: [
                      IconButton(
                        tooltip:
                            "${AppLocalization.of(context)?.getTranslatedValue('share_schedule')}",
                        onPressed: () {
                          shareTodo(
                            todoCtr.text.toString(),
                            dateCtr.text.toString(),
                            timeCtr.text.toString(),
                          );
                        },
                        icon: Icon(Icons.share,
                            color: Theme.of(context).iconTheme.color),
                      ),
                      IconButton(
                        tooltip:
                            "${AppLocalization.of(context)?.getTranslatedValue('delete')}",
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          showDeleteDialoge();
                        },
                        icon: Icon(Icons.delete_forever,
                            color: Theme.of(context).iconTheme.color),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${AppLocalization.of(context)?.getTranslatedValue('what_is_to_be_done')}?",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: AppColors.blueColor,
                                  ),
                            ),
                            TextFormField(
                              controller: todoCtr,
                              minLines: 1,
                              autofocus: false,
                              maxLines: null,
                              style: Theme.of(context).textTheme.titleMedium,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "${AppLocalization.of(context)?.getTranslatedValue('enter_schedule')}";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText:
                                    "${AppLocalization.of(context)?.getTranslatedValue('enter_schedule_here')}",
                                errorStyle:
                                    TextStyle(color: AppColors.redColor),
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontSize: 14),
                                errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.redColor,
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
                                    // checkColor: AppColors.blackColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    activeColor: AppColors
                                        .bottomNavigationBarSecondColor,
                                    // side: BorderSide(color: AppColors.blackColor),
                                    onChanged: (value) {
                                      setState(() {
                                        isFinished = value!;
                                      });
                                    }),
                                Text(
                                  "${AppLocalization.of(context)?.getTranslatedValue('schedule_complated')}?",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                                "${AppLocalization.of(context)?.getTranslatedValue('due_date')}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                      color: AppColors.blueColor,
                                    )),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: dateCtr,
                              readOnly: true,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontSize: 14,
                                    color: Colors.red[400],
                                  ),
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                _selectDate(context);
                              },
                              minLines: 1,
                              maxLines: 1,
                              decoration: InputDecoration(
                                  hintText:
                                      "${AppLocalization.of(context)?.getTranslatedValue('set_date')}",
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontSize: 14,
                                        color: Colors.red[400],
                                      )),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: timeCtr,
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                displayTimePicker(context);
                              },
                              readOnly: true,
                              minLines: 1,
                              maxLines: 1,
                              style: TextStyle(color: AppColors.redColor),
                              decoration: InputDecoration(
                                  hintText:
                                      "${AppLocalization.of(context)?.getTranslatedValue('set_time')}",
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontSize: 14,
                                        color: Colors.red[400],
                                      )),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            PopupMenuButton(
                              color: Theme.of(context).canvasColor,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: AppColors.blueColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "${categoryName}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Icon(Icons.arrow_drop_down_sharp,
                                        color:
                                            Theme.of(context).iconTheme.color)
                                  ],
                                ),
                              ),
                              itemBuilder: (context) => List.generate(
                                ListData.category.length,
                                (index) => PopupMenuItem(
                                  onTap: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    setState(() {
                                      categoryName = ListData.category[index];
                                    });
                                  },
                                  child: Text(
                                    ListData.category[index],
                                    style:
                                        TextStyle(color: AppColors.blackColor),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 10),
                      child: MaterialButton(
                        color: AppColors.yellowColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            AppFunctions.requestStoragePermission()
                                .then((value) {
                              if (value == true) {
                                dbHelper!
                                    .updateTodo(TodoModel(
                                  id: widget.id,
                                  todo: todoCtr.text,
                                  finished: isFinished == true ? 1 : 0,
                                  dueDate: dateCtr.text,
                                  dueTime: timeCtr.text,
                                  category: categoryName!,
                                ))
                                    .then((value) {
                                  if (dateCtr.text != "" &&
                                      timeCtr.text != "") {
                                    if (notificationId != "") {
                                      notificationServices
                                          .cancelNotificationById(
                                              notificationId ?? 0);
                                    }
                                    DateTime dateTime = DateFormat(
                                            'EEEEEEEEE, dd MMM yyyy h:mm a',
                                            'en_US')
                                        .parseLoose(
                                            '${dateCtr.text} ${timeCtr.text}');
                                    AppFunctions.requestNotificationPermission()
                                        .then((value) {
                                      if (value == true) {
                                        AppFunctions.setNewSheduleNotification(
                                          id: widget.id!,
                                          scheduledTime: dateTime,
                                          body: timeCtr.text,
                                          title: todoCtr.text,
                                        );
                                      }
                                    });
                                  }
                                  Navigator.pop(context);
                                  widget.onUpdate!();
                                });
                              }
                            });
                          }
                        },
                        child: Text(
                          "${AppLocalization.of(context)?.getTranslatedValue('save')}",
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                  fontSize: 14, color: AppColors.blackColor),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            });
          } else {
            return Container();
          }
        });
  }
}
