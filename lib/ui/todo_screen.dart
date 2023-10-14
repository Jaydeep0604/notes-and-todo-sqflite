import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/db/list_data.dart';
import 'package:notes_sqflite/model/todo_model.dart';
import 'package:notes_sqflite/widget/todo_widget.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();

  
}

class _TodoScreenState extends State<TodoScreen> {
  late Future<List<TodoModel>> todoList;
  bool isFinished = false;
  DBHelper? dbHelper;
  final timeCtr = TextEditingController();
  final dateCtr = TextEditingController();
  final todoCtr = TextEditingController();
  String? categoryName;

  DateTime currentDate = DateTime.now();
  TimeOfDay timeOfDay = TimeOfDay.now();

  void initState() {
    super.initState();
    dbHelper = DBHelper();
    categoryName = ListData.category[0];
    loadData();
  }

  void loadData() async {
    setState(() {
      todoList = dbHelper!.getTodosList();
    });
  }

  clear() {
    todoCtr.clear();
    timeCtr.clear();
    dateCtr.clear();
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
    // final bool isEnglish =
    //     LocalizedApp.of(context).delegate.currentLocale.languageCode == 'en';
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
                FutureBuilder(
                  future: todoList,
                  builder: (context, AsyncSnapshot<List<TodoModel>> snapshot) {
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
                          return snapshot.data![index].finished == 0
                              ? TodoWidget(
                                  description: snapshot.data![index].todo,
                                  categoryName: snapshot.data![index].category,
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
                                  onDone: (status) {
                                    dbHelper!
                                        .updateTodo(TodoModel(
                                      id: snapshot.data![index].id,
                                      todo: snapshot.data![index].todo,
                                      finished: status,
                                      dueDate: snapshot.data![index].dueDate,
                                      dueTime: snapshot.data![index].dueTime,
                                      category: snapshot.data![index].category,
                                    ))
                                        .then((value) {
                                      setState(() {
                                        todoList = dbHelper!.getTodosList();
                                      });
                                    });
                                  },
                                )
                              : SizedBox();
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: 10,
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
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10, right: 10),
                    child: InkWell(
                      splashColor: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(50),
                      radius: 10,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                                builder: (context, setState) {
                              return Material(
                                color: Colors.black,
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "What is to be done?",
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 18),
                                                ),
                                                TextFormField(
                                                  controller: todoCtr,
                                                  minLines: 1,
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        "Enter schedule here",
                                                    hintStyle: TextStyle(
                                                        color: Colors.white54,
                                                        fontSize: 16),
                                                    // enabledBorder: InputBorder.none,
                                                    // border: InputBorder.none,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                        value: isFinished,
                                                        checkColor:
                                                            Colors.white,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                        ),
                                                        activeColor: Colors
                                                            .blueGrey.shade900
                                                            .withGreen(140),
                                                        side: BorderSide(
                                                            color:
                                                                Colors.white),
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
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 18),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                TextFormField(
                                                  controller: dateCtr,
                                                  readOnly: true,
                                                  style: TextStyle(
                                                      color: Colors.red[400]),
                                                  onTap: () {
                                                    _selectDate(context);
                                                  },
                                                  minLines: 1,
                                                  maxLines: 1,
                                                  decoration: InputDecoration(
                                                      hintText: "Date not set",
                                                      hintStyle: TextStyle(
                                                          color:
                                                              Colors.red[400])),
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
                                                  style: TextStyle(
                                                      color: Colors.red[400]),
                                                  decoration: InputDecoration(
                                                      hintText: "Set time",
                                                      hintStyle: TextStyle(
                                                          color:
                                                              Colors.red[400])),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                PopupMenuButton(
                                                  color: Colors.white,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5,
                                                    ),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.blue),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          "${categoryName}",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .arrow_drop_down_sharp,
                                                          color: Colors.blue,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  itemBuilder: (context) =>
                                                      List.generate(
                                                    ListData.category.length,
                                                    (index) => PopupMenuItem(
                                                      onTap: () {
                                                        setState(() {
                                                          categoryName =
                                                              ListData.category[
                                                                  index];
                                                        });
                                                      },
                                                      child: Text(
                                                        ListData
                                                            .category[index],
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
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
                                            padding: const EdgeInsets.only(
                                                bottom: 20, right: 20),
                                            child: InkWell(
                                              splashColor: Colors.blueGrey,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              radius: 10,
                                              onTap: () {
                                                dbHelper!
                                                    .insertTodo(TodoModel(
                                                        todo: todoCtr.text,
                                                        finished:
                                                            isFinished == false
                                                                ? 0
                                                                : 1,
                                                        dueDate: dateCtr.text,
                                                        dueTime: timeCtr.text,
                                                        category: categoryName
                                                            .toString()))
                                                    .then((value) {
                                                  print("data added");
                                                  clear();
                                                  loadData();
                                                  Navigator.pop(context);
                                                }).onError((error, stackTrace) {
                                                  print(error.toString());
                                                  print(stackTrace.toString());
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.yellow,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.4))),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
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
                              );
                            });
                            // StatefulBuilder(
                            //   builder: (context, setState) => AlertDialog(
                            //     shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(10)),
                            //     content: Column(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       crossAxisAlignment: CrossAxisAlignment.center,
                            //       mainAxisSize: MainAxisSize.min,
                            //       children: [
                            //         SizedBox(
                            //           height: 10,
                            //         ),
                            //         Text(
                            //           "Add Sedules",
                            //           style: TextStyle(
                            //               color: Colors.black,
                            //               fontWeight: FontWeight.bold,
                            //               fontSize: 18),
                            //         ),
                            //         SizedBox(
                            //           height: 10,
                            //         ),
                            //         TextFormField(
                            //           controller: descriptionCtr,
                            //           decoration: InputDecoration(
                            //             hintText: "Description",
                            //           ),
                            //           inputFormatters: [
                            //             // FilteringTextInputFormatter.deny(" "),
                            //           ],
                            //         ),
                            //         SizedBox(
                            //           height: 10,
                            //         ),
                            //         TextFormField(
                            //           controller: dateCtr,
                            //           readOnly: true,
                            //           onTap: () {
                            //             _selectDate(context);
                            //           },
                            //           minLines: 1,
                            //           maxLines: 1,
                            //           decoration: InputDecoration(
                            //             hintText: "Date not set",
                            //           ),
                            //         ),
                            //         SizedBox(
                            //           height: 10,
                            //         ),
                            //         Row(
                            //           children: [
                            //             Expanded(
                            //               flex: 1,
                            //               child: TextFormField(
                            //                 controller: timeCtr,
                            //                 onTap: () {
                            //                   displayTimePicker(context);
                            //                 },
                            //                 readOnly: true,
                            //                 minLines: 1,
                            //                 maxLines: 1,
                            //                 decoration: InputDecoration(
                            //                     hintText: "Set time"),
                            //               ),
                            //             ),
                            //             SizedBox(
                            //               width: 10,
                            //             ),
                            //             Expanded(
                            //                 flex: 2,
                            //                 child: Padding(
                            //                   padding:
                            //                       const EdgeInsets.all(8.0),
                            //                   child: InkWell(
                            //                     borderRadius:
                            //                         BorderRadius.circular(10),
                            //                     onTap: () {
                            //                       showMenu(
                            //                         context: context,
                            //                         initialValue: category[0],
                            //                         color: Color.fromARGB(
                            //                             255, 255, 255, 255),
                            //                         surfaceTintColor:
                            //                             Colors.amberAccent,
                            //                         shape:
                            //                             RoundedRectangleBorder(
                            //                                 borderRadius:
                            //                                     BorderRadius
                            //                                         .circular(
                            //                                             10)),
                            //                         position:
                            //                             buttonMenuPosition(
                            //                                 context),
                            //                         items: List.generate(
                            //                           category.length,
                            //                           (index) => PopupMenuItem(
                            //                             onTap: () {
                            //                               setState(() {
                            //                                 categoryName =
                            //                                     category[index];
                            //                               });
                            //                             },
                            //                             child: Text(
                            //                               category[index],
                            //                               style: TextStyle(
                            //                                   color:
                            //                                       Colors.black),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       );
                            //                     },
                            //                     child: Container(
                            //                       padding: const EdgeInsets
                            //                           .symmetric(
                            //                         horizontal: 10,
                            //                         vertical: 5,
                            //                       ),
                            //                       decoration: BoxDecoration(
                            //                           border: Border.all(
                            //                               color: Colors.black),
                            //                           borderRadius:
                            //                               BorderRadius.circular(
                            //                                   10)),
                            //                       child: Center(
                            //                           child: Row(
                            //                         mainAxisAlignment:
                            //                             MainAxisAlignment
                            //                                 .center,
                            //                         crossAxisAlignment:
                            //                             CrossAxisAlignment
                            //                                 .center,
                            //                         children: [
                            //                           Text("$categoryName"),
                            //                           SizedBox(
                            //                             width: 10,
                            //                           ),
                            //                           Icon(Icons
                            //                               .arrow_drop_down_sharp)
                            //                         ],
                            //                       )),
                            //                     ),
                            //                   ),
                            //                 )),
                            //           ],
                            //         ),
                            //         SizedBox(
                            //           height: 10,
                            //         ),
                            //         Row(
                            //           children: [
                            //             Expanded(
                            //                 child: MaterialButton(
                            //               shape: RoundedRectangleBorder(
                            //                   borderRadius:
                            //                       BorderRadius.circular(10)),
                            //               color:
                            //                   Color.fromARGB(255, 57, 149, 199),
                            //               onPressed: () {
                            //                 // clear();
                            //                 Navigator.pop(context);
                            //               },
                            //               child: Text(
                            //                 "Cancel",
                            //                 style:
                            //                     TextStyle(color: Colors.white),
                            //               ),
                            //             )),
                            //             SizedBox(
                            //               width: 20,
                            //             ),
                            //             Expanded(
                            //                 child: MaterialButton(
                            //               shape: RoundedRectangleBorder(
                            //                   borderRadius:
                            //                       BorderRadius.circular(10)),
                            //               color: Colors.blueGrey.shade900
                            //                   .withGreen(140),
                            //               onPressed: () {
                            //                 dbHelper!
                            //                     .insertTodo(TodoModel(
                            //                         description:
                            //                             descriptionCtr.text,
                            //                         todoDone: 0,
                            //                         dueDate:
                            //                             "${dateCtr.text}, ${timeCtr.text}",
                            //                         category: categoryName
                            //                             .toString()))
                            //                     .then((value) {
                            //                   print("data added");
                            //                   clear();
                            //                   loadData();
                            //                   Navigator.pop(context);
                            //                 }).onError((error, stackTrace) {
                            //                   print(error.toString());
                            //                   print(stackTrace.toString());
                            //                 });
                            //               },
                            //               child: Text(
                            //                 "Add",
                            //                 style:
                            //                     TextStyle(color: Colors.white),
                            //               ),
                            //             ))
                            //           ],
                            //         )
                            //       ],
                            //     ),
                            //   ),
                            // );
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
}
