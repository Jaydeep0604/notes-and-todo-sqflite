import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notes_sqflite/animations/list_animation.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/model/todo_model.dart';
import 'package:notes_sqflite/ui/todo_screen/todo_detail_screen.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:notes_sqflite/widget/todo_widget.dart';

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
  DBHelper? dbHelper;
  late Future<List<TodoModel>> todoList;

  void initState() {
    super.initState();
    dbHelper = DBHelper();
    loadData();
    checkData();
  }

  void loadData() {
    setState(() {
      todoList = dbHelper!.getTodosList();
    });
  }

  checkData() {
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (isUpdateTodoScreen)
        setState(() {
          loadData();
          print("data updated $isUpdateTodoScreen");
          isUpdateTodoScreen = false;
        });
    });
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
                  color: AppColors.blueColor,
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
                          // reverse: true,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return VerticalAnimation(
                              index: index,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (snapshot.data![index].finished == 0)
                                    TodoWidget(
                                      id: snapshot.data![index].id!,
                                      todo: snapshot.data![index].todo,
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
                                      onUpdate: () {
                                        setState(() {
                                          todoList = dbHelper!.getTodosList();
                                        });
                                      },
                                      onFinish:
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
                                            .then(
                                          (value) {
                                            setState(
                                              () {
                                                todoList =
                                                    dbHelper!.getTodosList();
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                ],
                              ),
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
                          color: AppColors.whiteColor,
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
                      splashColor: AppColors.blueGrayColor,
                      borderRadius: BorderRadius.circular(50),
                      radius: 10,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TodoDetailscreen(
                              isUpdateTodo: false,
                            ),
                          ),
                        ).then((value) => () {
                              if (value == true) {
                                setState(() {});
                              }
                            });
                        // Navigator.push(
                        //   context,
                        //   PageRouteBuilder(
                        //     pageBuilder:
                        //         (context, animation, secondaryAnimation) =>
                        //             TodoDetailscreen(),
                        //     transitionDuration: Duration(milliseconds: 300),
                        //     transitionsBuilder: (context, animation,
                        //             secondaryAnimation, child) =>
                        //         ScaleTransition(
                        //       scale: Tween<double>(
                        //         begin: 0.0,
                        //         end: 1.0,
                        //       ).animate(
                        //         CurvedAnimation(
                        //           parent: animation,
                        //           curve: Curves.fastOutSlowIn,
                        //         ),
                        //       ),
                        //       child: child,
                        //     ),
                        //   ),
                        // );
                        // notificationServices.showNotificationNow(
                        //     "Done this todo", "3:19 pm");
                        // addTodoDialoge();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: AppColors.yellowColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.4))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.add,
                            color: AppColors.blackColor,
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

  // void addTodoDialoge() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(builder: (context, setState) {
  //         return Material(
  //           color: AppColors.blackColor,
  //           child: Form(
  //             key: formKey,
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: <Widget>[
  //                 AppBar(
  //                   backgroundColor: AppColors.blackColor,
  //                   leading: IconButton(
  //                     tooltip: "Navigate up",
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                     },
  //                     icon: Icon(
  //                       Icons.arrow_back,
  //                       color: AppColors.whiteColor
  //                     ),
  //                   ),
  //                 ),
  //                 Expanded(
  //                     child: Stack(
  //                   children: [
  //                     SingleChildScrollView(
  //                       child: Container(
  //                         padding: EdgeInsets.symmetric(horizontal: 15),
  //                         child: Column(
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Text(
  //                               "What is to be done?",
  //                               style: TextStyle(
  //                                   color: Colors.blue,
  //                                   fontWeight: FontWeight.w500,
  //                                   fontSize: 18),
  //                             ),
  //                             TextFormField(
  //                               controller: todoCtr,
  //                               minLines: 1,
  //                               maxLines: null,
  //                               style: TextStyle(color: Colors.white),
  //                               validator: (value) {
  //                                 if (value!.isEmpty) {
  //                                   return "Enter schedule";
  //                                 }
  //                                 return null;
  //                               },
  //                               decoration: InputDecoration(
  //                                 hintText: "Enter schedule here",
  //                                 errorStyle: TextStyle(color: AppColors.redColor),
  //                                 hintStyle: TextStyle(
  //                                     color: AppColors.whiteColor fontSize: 16),
  //                                 errorBorder: UnderlineInputBorder(
  //                                   borderSide: BorderSide(
  //                                     color: Colors.red.shade400,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                             SizedBox(
  //                               height: 20,
  //                             ),
  //                             Row(
  //                               children: [
  //                                 Checkbox(
  //                                     value: isFinished,
  //                                     checkColor: AppColors.whiteColor
  //                                     shape: RoundedRectangleBorder(
  //                                       borderRadius: BorderRadius.circular(3),
  //                                     ),
  //                                     activeColor: Colors.blueGrey.shade900
  //                                         .withGreen(140),
  //                                     side: BorderSide(color: Colors.white),
  //                                     onChanged: (value) {
  //                                       setState(() {
  //                                         isFinished = value!;
  //                                       });
  //                                     }),
  //                                 Text(
  //                                   "Schedule complated?",
  //                                   style: TextStyle(
  //                                       color: AppColors.whiteColor
  //                                       // fontWeight: FontWeight.w500,
  //                                       fontSize: 14),
  //                                 ),
  //                               ],
  //                             ),
  //                             SizedBox(
  //                               height: 30,
  //                             ),
  //                             Text(
  //                               "Due date",
  //                               style: TextStyle(
  //                                   color: Colors.blue,
  //                                   fontWeight: FontWeight.w500,
  //                                   fontSize: 18),
  //                             ),
  //                             SizedBox(
  //                               height: 10,
  //                             ),
  //                             TextFormField(
  //                               controller: dateCtr,
  //                               readOnly: true,
  //                               style: TextStyle(color: AppColors.redColor),
  //                               onTap: () {
  //                                 _selectDate(context);
  //                               },
  //                               minLines: 1,
  //                               maxLines: 1,
  //                               decoration: InputDecoration(
  //                                   hintText: "Date not set",
  //                                   hintStyle:
  //                                       TextStyle(color: AppColors.redColor)),
  //                             ),
  //                             SizedBox(
  //                               height: 10,
  //                             ),
  //                             TextFormField(
  //                               controller: timeCtr,
  //                               onTap: () {
  //                                 displayTimePicker(context);
  //                               },
  //                               readOnly: true,
  //                               minLines: 1,
  //                               maxLines: 1,
  //                               style: TextStyle(color: AppColors.redColor),
  //                               decoration: InputDecoration(
  //                                   hintText: "Set time",
  //                                   hintStyle:
  //                                       TextStyle(color: AppColors.redColor)),
  //                             ),
  //                             SizedBox(
  //                               height: 20,
  //                             ),
  //                             PopupMenuButton(
  //                               color: AppColors.whiteColor
  //                               child: Container(
  //                                 padding: const EdgeInsets.symmetric(
  //                                   horizontal: 10,
  //                                   vertical: 5,
  //                                 ),
  //                                 decoration: BoxDecoration(
  //                                     border: Border.all(color: Colors.blue),
  //                                     borderRadius: BorderRadius.circular(10)),
  //                                 child: Row(
  //                                   mainAxisAlignment: MainAxisAlignment.center,
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.center,
  //                                   mainAxisSize: MainAxisSize.min,
  //                                   children: [
  //                                     Text(
  //                                       "${categoryName}",
  //                                       style: TextStyle(color: Colors.white),
  //                                     ),
  //                                     SizedBox(
  //                                       width: 10,
  //                                     ),
  //                                     Icon(
  //                                       Icons.arrow_drop_down_sharp,
  //                                       color: Colors.blue,
  //                                     )
  //                                   ],
  //                                 ),
  //                               ),
  //                               itemBuilder: (context) => List.generate(
  //                                 ListData.category.length,
  //                                 (index) => PopupMenuItem(
  //                                   onTap: () {
  //                                     setState(() {
  //                                       categoryName = ListData.category[index];
  //                                     });
  //                                   },
  //                                   child: Text(
  //                                     ListData.category[index],
  //                                     style: TextStyle(color: Colors.black),
  //                                   ),
  //                                 ),
  //                               ),
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     Align(
  //                       alignment: Alignment.bottomRight,
  //                       child: Padding(
  //                         padding: const EdgeInsets.only(bottom: 20, right: 20),
  //                         child: InkWell(
  //                           splashColor: Colors.blueGrey,
  //                           borderRadius: BorderRadius.circular(50),
  //                           radius: 10,
  //                           onTap: () {
  //                             if (formKey.currentState!.validate()) {
  //                               dbHelper!
  //                                   .insertTodo(TodoModel(
  //                                 todo: todoCtr.text,
  //                                 finished: isFinished == false ? 0 : 1,
  //                                 dueDate: dateCtr.text,
  //                                 dueTime: timeCtr.text,
  //                                 category: categoryName.toString(),
  //                               ))
  //                                   .then((value) {
  //                                 print("data added");
  //                                 if (notificationDateTime != null) {
  //                                   notificationServices.showNotification(
  //                                     notificationDateTime!,
  //                                     todoCtr.text,
  //                                     timeCtr.text,
  //                                   );
  //                                 }
  //                                 clear();
  //                                 loadData();
  //                                 Navigator.pop(context);
  //                               }).onError((error, stackTrace) {
  //                                 print(error.toString());
  //                                 print(stackTrace.toString());
  //                               });
  //                             }
  //                           },
  //                           child: Container(
  //                             decoration: BoxDecoration(
  //                                 color: Colors.yellow,
  //                                 shape: BoxShape.circle,
  //                                 border: Border.all(
  //                                     color: Colors.white.withOpacity(0.4))),
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(8.0),
  //                               child: Icon(
  //                                 Icons.check,
  //                                 color: AppColors.blackColor,
  //                                 size: 30,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ))
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  //     },
  //   );
  // }
}
