import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/db/list_data.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/model/todo_model.dart';
import 'package:notes_sqflite/services/notification_services.dart';
import 'package:notes_sqflite/widget/todo_widget.dart';
import 'package:timezone/standalone.dart'as tz;
import 'package:timezone/timezone.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  // static reFreshScreen(BuildContext context) {
  //   _TodoScreenState? state =
  //       context.findAncestorStateOfType<_TodoScreenState>();
  //   return state?.loadData();
  // }

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final formKey = GlobalKey<FormState>();

  final timeCtr = TextEditingController();
  final dateCtr = TextEditingController();
  final todoCtr = TextEditingController();

  DBHelper? dbHelper;
  late Future<List<TodoModel>> todoList;

  bool isFinished = false;
  String? categoryName;

  DateTime currentDate = DateTime.now();
  TimeOfDay timeOfDay = TimeOfDay.now();

  void initState() {
    super.initState();
    dbHelper = DBHelper();
    categoryName = ListData.category[0];
    loadData();
    // checkData();
  }

  void loadData() {
    setState(() {
      todoList = dbHelper!.getTodosList();
    });
  }

  clear() {
    todoCtr.clear();
    timeCtr.clear();
    dateCtr.clear();
  }

  // void dispose() {
  //   super.dispose();
  // }

  checkData() {
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (isUpdateTodo)
        setState(() {
          loadData();
          print("data updated $isUpdateTodo");
          isUpdateTodo = false;
        });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != currentDate)
      setState(() {
        currentDate = pickedDate;
        final dateFormat = DateFormat('EEEEEEEEE,d MMM y').format(currentDate);
        dateCtr.text = dateFormat;
        // "${currentDate.weekday}, ${currentDate.day} ${currentDate.month} ${currentDate.year},";
      });
  }

  Future displayTimePicker(BuildContext context) async {
    var time = await showTimePicker(
      context: context,
      initialTime: timeOfDay,
    );
    if (time != null) {
      setState(() {
        timeCtr.text = "${time.format(context).toLowerCase()}";
      });
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  color: Colors.blue,
                  // backgroundColor: Colors.trransparent,
                  onRefresh: () =>
                      Future.delayed(Duration(seconds: 1), loadData),
                  child: FutureBuilder(
                    future: todoList,
                    builder:
                        (context, AsyncSnapshot<List<TodoModel>> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          itemCount: snapshot.data!.length,
                          reverse: true,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (snapshot.data![index].finished == 0)
                                  TodoWidget(
                                    description: snapshot.data![index].todo,
                                    categoryName:
                                        snapshot.data![index].category,
                                    dueDate: snapshot.data![index].dueDate,
                                    dueTime: snapshot.data![index].dueTime,
                                    finished: snapshot.data![index].finished,
                                    onDelete: () {
                                      setState(() {
                                        dbHelper!.deleteTodo(
                                            snapshot.data![index].id!);
                                        todoList = dbHelper!.getTodosList();
                                      });
                                    },
                                    onDone:
                                        (todo, date, time, status, category) {
                                      dbHelper!
                                          .updateTodo(TodoModel(
                                        id: snapshot.data![index].id,
                                        todo: todo,
                                        finished: status,
                                        dueDate: date,
                                        dueTime: time,
                                        category: category,
                                      ))
                                          .then((value) {
                                        setState(() {
                                          todoList = dbHelper!.getTodosList();
                                        });
                                      });
                                    },
                                  ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              height:
                                  snapshot.data![index].finished == 0 ? 10 : 0,
                            );
                          },
                        );
                      } else {
                        return Center(
                            child: CircularProgressIndicator(
                          color: Colors.white,
                        ));
                      }
                    },
                  ),
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
                        notificationServices.showNotification();
                        // addTodoDialoge();
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
                        ),
                      ),
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

 

  void addTodoDialoge() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Material(
            color: Colors.black,
            child: Form(
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
                                  hintStyle: TextStyle(
                                      color: Colors.white, fontSize: 16),
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
                                      activeColor: Colors.blueGrey.shade900
                                          .withGreen(140),
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
                                    hintStyle:
                                        TextStyle(color: Colors.red[400])),
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
                                    hintStyle:
                                        TextStyle(color: Colors.red[400])),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                // DateTime scheduleTime = DateTime.now().add(
                                //   Duration(seconds: 5),
                                // );
                                // notificationServices
                                //       .showNotification(scheduleTime);
                                dbHelper!
                                    .insertTodo(TodoModel(
                                        todo: todoCtr.text,
                                        finished: isFinished == false ? 0 : 1,
                                        dueDate: dateCtr.text,
                                        dueTime: timeCtr.text,
                                        category: categoryName.toString()))
                                    .then((value) {
                                  print("data added");
                                  clear();
                                  loadData();
                                  Navigator.pop(context);
                                }).onError((error, stackTrace) {
                                  print(error.toString());
                                  print(stackTrace.toString());
                                });
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
        });
      },
    );
  }
}
