import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_sqflite/animations/open_container.dart';
import 'package:notes_sqflite/utils/app_colors.dart';

class TodoWidget extends StatefulWidget {
  TodoWidget({
    super.key,
    required this.id,
    required this.todo,
    required this.dueDate,
    required this.dueTime,
    required this.finished,
    required this.onDelete,
    required this.onFinish,
    required this.categoryName,
    required this.onUpdate,
  });
  String todo, dueDate, dueTime, categoryName;
  int finished, id;
  void Function() onDelete;
  void Function() onUpdate;
  void Function(
          String todo, String time, String date, int status, String category)
      onFinish;
  @override
  State<TodoWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  bool? isDone;

  final formKey = GlobalKey<FormState>();
  final timeCtr = TextEditingController();
  final dateCtr = TextEditingController();
  final todoCtr = TextEditingController();

  DateTime currentDate = DateTime.now();
  TimeOfDay timeOfDay = TimeOfDay.now();

  void initState() {
    super.initState();
    // setStatus();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      todoCtr.text = widget.todo;
      dateCtr.text = widget.dueDate;
      timeCtr.text = widget.dueTime;
      isDone = widget.finished == 0 ? false : true;
    });
  }

  // void dispose() {
  //   super.dispose();
  // }

  void setStatus() {
    setState(
      () {
        isDone = widget.finished == 0
            ? false
            : widget.finished == 1
                ? true
                : false;
      },
    );
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

//  Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TodoDetailscreen(
//               isUpdateTodo: true,
//               id: widget.id,
//               onUpdate: widget.onUpdate,
//               onDelete: widget.onDelete,
//             ),
//           ),
//         ).then((value) {
//           setState(() {});
//         });
  @override
  Widget build(BuildContext context) {
    return OpenScheduleContainerWrapper(
      id: widget.id,
      onUpdate: widget.onUpdate,
      onDelete: widget.onDelete,
      closedChild: Card(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: Theme.of(context).iconTheme.color!.withOpacity(0.6),
                width: 0.7),
            // gradient: LinearGradient(
            //   tileMode: TileMode.mirror,
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [
            //     Colors.transparent,
            //     Colors.transparent,
            //     Colors.blueGrey.shade900.withGreen(70).withOpacity(0.5),
            //   ],
            // ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: isDone,
                  checkColor: AppColors.whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  activeColor: Colors.blueGrey.shade900.withGreen(140),
                  side: BorderSide(color: Theme.of(context).iconTheme.color!),
                  onChanged: (newvalue) {
                    setState(() {
                      isDone = newvalue!;
                    });
                    Future.delayed(Duration(milliseconds: 500), () {
                      widget.onFinish(
                        todoCtr.text,
                        dateCtr.text,
                        timeCtr.text,
                        isDone == true ? 1 : 0,
                        widget.categoryName,
                      );
                    });
                  },
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      softWrap: true,
                      text: TextSpan(
                        text: "${widget.todo}",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                      ),
                    ),
                    if (widget.dueTime != "" || widget.dueDate != "")
                      SizedBox(
                        height: 5,
                      ),
                    if (widget.dueTime != "" || widget.dueDate != "")
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: "${widget.dueDate}"),
                            if (widget.dueTime != "" && widget.dueDate != "")
                              TextSpan(text: ", "),
                            TextSpan(text: "${widget.dueTime}"),
                          ],
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 14,
                                    color: Colors.red[400],
                                  ),
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // void updateTodoPopupmenu() {
  //   showGeneralDialog(
  //     context: context,
  //     transitionDuration: Duration(milliseconds: 300),
  //     pageBuilder: (context, animation, secondaryAnimation) {
  //       return StatefulBuilder(
  //         builder: (context, setState) => Material(
  //           color: AppColors.blackColor,
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: <Widget>[
  //               AppBar(
  //                 backgroundColor: AppColors.blackColor,
  //                 leading: IconButton(
  //                   tooltip: "Navigate up",
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   icon: Icon(
  //                     Icons.arrow_back,
  //                     color: AppColors.whiteColor
  //                   ),
  //                 ),
  //                 actions: [
  //                   IconButton(
  //                     tooltip: "Share schedules",
  //                     onPressed: () {
  //                       // Navigator.pop(context);
  //                     },
  //                     icon: Icon(
  //                       Icons.share,
  //                       color: AppColors.whiteColor
  //                     ),
  //                   ),
  //                   IconButton(
  //                     tooltip: "Delete",
  //                     onPressed: () {
  //                       showDialog(
  //                         context: context,
  //                         builder: (context) => AlertDialog(
  //                           backgroundColor: AppColors.whiteColor
  //                           shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(10)),
  //                           alignment: Alignment.center,
  //                           titleTextStyle:
  //                               TextStyle(fontWeight: FontWeight.w500),
  //                           title: Text(
  //                             "Are you sure, you want to delete?",
  //                             textAlign: TextAlign.center,
  //                             style: TextStyle(
  //                                 fontWeight: FontWeight.w700,
  //                                 color: Colors.black),
  //                           ),
  //                           actions: [
  //                             Row(
  //                               children: [
  //                                 Expanded(
  //                                   child: MaterialButton(
  //                                     shape: RoundedRectangleBorder(
  //                                         borderRadius:
  //                                             BorderRadius.circular(10),
  //                                         side:
  //                                             BorderSide(color: Colors.black)),
  //                                     onPressed: () {
  //                                       Navigator.pop(context);
  //                                     },
  //                                     child: Text(
  //                                       "No",
  //                                       style: TextStyle(color: Colors.black),
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 SizedBox(
  //                                   width: 10,
  //                                 ),
  //                                 Expanded(
  //                                   child: MaterialButton(
  //                                     color: Colors.blue,
  //                                     shape: RoundedRectangleBorder(
  //                                       borderRadius: BorderRadius.circular(10),
  //                                       // side: BorderSide(color: Colors.black)
  //                                     ),
  //                                     onPressed: () {
  //                                       widget.onDelete();
  //                                       Navigator.pop(context);
  //                                     },
  //                                     child: Text(
  //                                       "Yes",
  //                                       style: TextStyle(color: Colors.white),
  //                                     ),
  //                                   ),
  //                                 )
  //                               ],
  //                             ),
  //                           ],
  //                         ),
  //                       ).then(
  //                         (value) => Navigator.pop(context),
  //                       );
  //                       // dbHelper!
  //                       //     .update(
  //                       //   NotesModel(
  //                       //       id: widget.id,
  //                       //       title: titleCtr.text.toString(),
  //                       //       age: int.tryParse(ageCtr.text)!,
  //                       //       description: descriptionCtr.text.toString(),
  //                       //       email: emailCtr.text.toString()),
  //                       // )
  //                       //     .then((value) {
  //                       //   widget.onUpdateComplate();
  //                       //   clear();
  //                       //   Navigator.pop(context);
  //                       // });
  //                     },
  //                     icon: Icon(
  //                       Icons.delete_forever,
  //                       color: AppColors.whiteColor
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     width: 10,
  //                   ),
  //                 ],
  //               ),
  //               Expanded(
  //                   child: Stack(
  //                 children: [
  //                   SingleChildScrollView(
  //                     child: Container(
  //                       padding: EdgeInsets.symmetric(horizontal: 15),
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             "What is to be done?",
  //                             style: TextStyle(
  //                                 color: Colors.blue,
  //                                 fontWeight: FontWeight.w500,
  //                                 fontSize: 18),
  //                           ),
  //                           TextFormField(
  //                             controller: descriptionCtr,
  //                             minLines: 1,
  //                             maxLines: null,
  //                             style: TextStyle(color: Colors.white),
  //                             validator: (value) {
  //                               if (value!.isEmpty) {
  //                                 return "Enter schedule";
  //                               }
  //                               return null;
  //                             },
  //                             decoration: InputDecoration(
  //                               hintText: "Enter schedule here",
  //                               errorStyle: TextStyle(color: Colors.red[400]),
  //                               hintStyle: TextStyle(
  //                                   color: AppColors.whiteColor fontSize: 16),
  //                               errorBorder: UnderlineInputBorder(
  //                                 borderSide: BorderSide(
  //                                   color: Colors.red.shade400,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           // TextFormField(
  //                           //   controller: descriptionCtr,
  //                           //   minLines: 1,
  //                           //   maxLines: null,
  //                           //   style: TextStyle(color: Colors.white),
  //                           //   decoration: InputDecoration(
  //                           //     hintText: "Enter schedule here",
  //                           //     hintStyle: TextStyle(
  //                           //         color: Colors.white54, fontSize: 16),
  //                           //     // enabledBorder: InputBorder.none,
  //                           //     // border: InputBorder.none,
  //                           //   ),
  //                           // ),
  //                           SizedBox(
  //                             height: 20,
  //                           ),
  //                           Row(
  //                             children: [
  //                               Checkbox(
  //                                   value: isDone,
  //                                   checkColor: AppColors.whiteColor
  //                                   shape: RoundedRectangleBorder(
  //                                     borderRadius: BorderRadius.circular(3),
  //                                   ),
  //                                   activeColor:
  //                                       Colors.blueGrey.shade900.withGreen(140),
  //                                   side: BorderSide(color: Colors.white),
  //                                   onChanged: (value) {
  //                                     setState(() {
  //                                       isDone = value!;
  //                                       widget.onDone(
  //                                           descriptionCtr.text,
  //                                           dateCtr.text,
  //                                           timeCtr.text,
  //                                           isDone == true ? 1 : 0,
  //                                           widget.categoryName);
  //                                     });
  //                                   }),
  //                               Text(
  //                                 "Schedule complated?",
  //                                 style: TextStyle(
  //                                     color: AppColors.whiteColor
  //                                     // fontWeight: FontWeight.w500,
  //                                     fontSize: 14),
  //                               ),
  //                             ],
  //                           ),
  //                           SizedBox(
  //                             height: 30,
  //                           ),
  //                           Text(
  //                             "Due date",
  //                             style: TextStyle(
  //                                 color: Colors.blue,
  //                                 fontWeight: FontWeight.w500,
  //                                 fontSize: 18),
  //                           ),
  //                           SizedBox(
  //                             height: 10,
  //                           ),
  //                           TextFormField(
  //                             controller: dateCtr,
  //                             readOnly: true,
  //                             style: TextStyle(color: Colors.red[400]),
  //                             onTap: () {
  //                               _selectDate(context);
  //                             },
  //                             minLines: 1,
  //                             maxLines: 1,
  //                             decoration: InputDecoration(
  //                                 hintText: "Date not set",
  //                                 hintStyle: TextStyle(color: Colors.red[400])),
  //                           ),
  //                           SizedBox(
  //                             height: 10,
  //                           ),
  //                           TextFormField(
  //                             controller: timeCtr,
  //                             onTap: () {
  //                               displayTimePicker(context);
  //                             },
  //                             readOnly: true,
  //                             minLines: 1,
  //                             maxLines: 1,
  //                             style: TextStyle(color: Colors.red[400]),
  //                             decoration: InputDecoration(
  //                                 hintText: "Set time",
  //                                 hintStyle: TextStyle(color: Colors.red[400])),
  //                           ),
  //                           SizedBox(
  //                             height: 20,
  //                           ),
  //                           PopupMenuButton(
  //                             color: AppColors.whiteColor
  //                             child: Container(
  //                               padding: const EdgeInsets.symmetric(
  //                                 horizontal: 10,
  //                                 vertical: 5,
  //                               ),
  //                               decoration: BoxDecoration(
  //                                   border: Border.all(color: Colors.blue),
  //                                   borderRadius: BorderRadius.circular(10)),
  //                               child: Row(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 crossAxisAlignment: CrossAxisAlignment.center,
  //                                 mainAxisSize: MainAxisSize.min,
  //                                 children: [
  //                                   Text(
  //                                     "${widget.categoryName}",
  //                                     style: TextStyle(color: Colors.white),
  //                                   ),
  //                                   SizedBox(
  //                                     width: 10,
  //                                   ),
  //                                   Icon(
  //                                     Icons.arrow_drop_down_sharp,
  //                                     color: Colors.blue,
  //                                   )
  //                                 ],
  //                               ),
  //                             ),
  //                             itemBuilder: (context) => List.generate(
  //                               ListData.category.length,
  //                               (index) => PopupMenuItem(
  //                                 onTap: () {
  //                                   setState(() {
  //                                     widget.categoryName =
  //                                         ListData.category[index];
  //                                   });
  //                                 },
  //                                 child: Text(
  //                                   ListData.category[index],
  //                                   style: TextStyle(color: Colors.black),
  //                                 ),
  //                               ),
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   Align(
  //                     alignment: Alignment.bottomRight,
  //                     child: Padding(
  //                       padding: const EdgeInsets.only(bottom: 20, right: 20),
  //                       child: InkWell(
  //                         splashColor: Colors.blueGrey,
  //                         borderRadius: BorderRadius.circular(50),
  //                         radius: 10,
  //                         onTap: () {
  //                           if (formKey.currentState!.validate()) {
  //                             widget.onDone(
  //                                 descriptionCtr.text,
  //                                 dateCtr.text,
  //                                 timeCtr.text,
  //                                 isDone == true ? 1 : 0,
  //                                 widget.categoryName);
  //                             Navigator.pop(context);
  //                           }
  //                         },
  //                         child: Container(
  //                           decoration: BoxDecoration(
  //                               color: Colors.yellow,
  //                               shape: BoxShape.circle,
  //                               border: Border.all(
  //                                   color: Colors.white.withOpacity(0.4))),
  //                           child: Padding(
  //                             padding: const EdgeInsets.all(8.0),
  //                             child: Icon(
  //                               Icons.check,
  //                               color: AppColors.blackColor,
  //                               size: 30,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ))
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
