import 'package:flutter/material.dart';
import 'package:notes_sqflite/animations/list_animation.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/db/list_data.dart';
import 'package:notes_sqflite/main.dart';
import 'package:notes_sqflite/model/todo_model.dart';
import 'package:notes_sqflite/widget/todo_widget.dart';

class TodoDoneScreen extends StatefulWidget {
  const TodoDoneScreen({super.key});

  @override
  State<TodoDoneScreen> createState() => _TodoDoneScreenState();
}

class _TodoDoneScreenState extends State<TodoDoneScreen> {
  late Future<List<TodoModel>> todoList;
  DBHelper? dbHelper;
  String? categoryName;
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

  // void dispose() {
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          isUpdateTodoScreen = true;
        });
        return true;
      },
      child: Scaffold(
        // backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          // backgroundColor: AppColors.whiteColor,
          leading: IconButton(
              onPressed: () {
                setState(() {
                  isUpdateTodoScreen = true;
                });
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).iconTheme.color)),
          title: Text(
            "Finished",
            style: TextStyle(
                // color: Colors.black,
                ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: FutureBuilder(
            future: todoList,
            builder: (context, AsyncSnapshot<List<TodoModel>> snapshot) {
              final todoDoneCount = snapshot.data != null &&
                      snapshot.data!.any((item) => item.finished == 1)
                  ? snapshot.data!.length
                  : 0;
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty || todoDoneCount == 0) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        "No Data Found",
                        style:
                            TextStyle(color: Theme.of(context).highlightColor),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  itemCount: todoDoneCount,
                  // reverse: true,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return snapshot.data![index].finished == 1
                        ? VerticalAnimation(
                            index: index,
                            child: TodoWidget(
                              id: snapshot.data![index].id!,
                              todo: snapshot.data![index].todo,
                              categoryName: snapshot.data![index].category,
                              dueDate: snapshot.data![index].dueDate,
                              dueTime: snapshot.data![index].dueTime,
                              finished: snapshot.data![index].finished,
                              onDelete: () {
                                setState(() {
                                  dbHelper!
                                      .deleteTodo(snapshot.data![index].id!);
                                  todoList = dbHelper!.getTodosList();
                                });
                              },
                              onUpdate: () {
                                setState(() {
                                  todoList = dbHelper!.getTodosList();
                                });
                              },
                              onFinish: (todo, date, time, status, category) {
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
                          )
                        : Container();
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: snapshot.data![index].finished == 1 ? 10 : 0,
                    );
                  },
                );
              } else {
                return Center(
                    child: CircularProgressIndicator(
                  color: Theme.of(context).iconTheme.color,
                ));
              }
            },
          ),
        ),
      ),
    );
  }
}
