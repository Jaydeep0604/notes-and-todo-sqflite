import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_sqflite/db/list_data.dart';

class TodoWidget extends StatefulWidget {
  TodoWidget(
      {super.key,
      required this.description,
      required this.dueDate,
      required this.dueTime,
      required this.finished,
      required this.onDelete,
      required this.onDone,
      required this.categoryName});
  String description, dueDate,dueTime, categoryName;
  int finished;
  void Function() onDelete;
  void Function(int value) onDone;
  @override
  State<TodoWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  bool? isDone;
  final timeCtr = TextEditingController();
  final dateCtr = TextEditingController();
  final descriptionCtr = TextEditingController();
  DateTime currentDate = DateTime.now();
  TimeOfDay timeOfDay = TimeOfDay.now();

  void initState() {
    super.initState();
    setStatus();
    setState(() {
      descriptionCtr.text = widget.description;
      dateCtr.text = widget.dueDate;
      timeCtr.text = widget.dueTime;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        showGeneralDialog(
          context: context,
          transitionDuration: Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) {
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
                    actions: [
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
                      IconButton(
                        tooltip: "Delete",
                        onPressed: () {
                          widget.onDelete();
                          Navigator.pop(context);
                          // dbHelper!
                          //     .update(
                          //   NotesModel(
                          //       id: widget.id,
                          //       title: titleCtr.text.toString(),
                          //       age: int.tryParse(ageCtr.text)!,
                          //       description: descriptionCtr.text.toString(),
                          //       email: emailCtr.text.toString()),
                          // )
                          //     .then((value) {
                          //   widget.onUpdateComplate();
                          //   clear();
                          //   Navigator.pop(context);

                          // });
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
                                controller: descriptionCtr,
                                minLines: 1,
                                maxLines: null,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Enter schedule here",
                                  hintStyle: TextStyle(
                                      color: Colors.white54, fontSize: 16),
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
                                      value: isDone,
                                      checkColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      activeColor: Colors.blueGrey.shade900
                                          .withGreen(140),
                                      side: BorderSide(color: Colors.white),
                                      onChanged: (value) {
                                        setState(() {});
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
                                        "${widget.categoryName}",
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
                                        widget.categoryName = ListData.category[index];
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
                              widget.onDone(1);
                              Navigator.pop(context);
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
            );
          },
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
              ),
              gradient: LinearGradient(
                  tileMode: TileMode.mirror,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black,
                    Colors.black,
                    // Colors.blueGrey.shade900,
                    // Colors.blueGrey.shade900,
                    Colors.blueGrey.shade900.withGreen(70),
                  ])),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isDone,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                activeColor: Colors.blueGrey.shade900.withGreen(140),
                side: BorderSide(color: Colors.white),
                onChanged: (newvalue) {
                  setState(() {
                    isDone = newvalue!;
                  });
                  widget.onDone(newvalue == true ? 1 : 0);
                },
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      softWrap: true,
                      text: TextSpan(
                        text: "${widget.description}",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "${widget.dueDate}, ${widget.dueTime}",
                      style: TextStyle(color: Colors.red[400]),
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
}
