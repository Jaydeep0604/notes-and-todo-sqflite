// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:notes_sqflite/db/db_handler.dart';
// import 'package:notes_sqflite/language/localisation.dart';
// import 'package:notes_sqflite/model/note_model.dart';
// import 'package:notes_sqflite/ui/image_view_screen.dart';
// import 'package:notes_sqflite/utils/app_colors.dart';

// class NewNoteScreen extends StatefulWidget {
//   const NewNoteScreen({super.key});

//   @override
//   State<NewNoteScreen> createState() => _NewNoteScreenState();
// }

// class _NewNoteScreenState extends State<NewNoteScreen> {
//   late TextEditingController titleCtr;
//   late TextEditingController noteCtr;
//   late TextEditingController dateCtr;
//   late TextEditingController timeCtr;

//   bool? pin = false, archive = false, deleted = false;
//   String? email;
//   List<String>? imageList;
//   final ImagePicker imagePicker = ImagePicker();

//   DBHelper? dbHelper;

//   List<XFile>? imageFileList = [];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             AppBar(
//               leading: IconButton(
//                 tooltip:
//                     "${AppLocalization.of(context)?.getTranslatedValue('navigate_up')}",
//                 onPressed: () {
//                   Navigator.pop(context, true);
//                 },
//                 icon: Icon(Icons.arrow_back,
//                     color: Theme.of(context).iconTheme.color),
//               ),
//               actions: [
//                 IconButton(
//                   tooltip:
//                       "${AppLocalization.of(context)?.getTranslatedValue('pin')}",
//                   onPressed: () {
//                     setState(() {
//                       pin = !pin!;
//                     });
//                   },
//                   icon: Transform.scale(
//                     scale: 1,
//                     child: pin!
//                         ? Icon(Icons.push_pin,
//                             color: Theme.of(context).iconTheme.color)
//                         : Icon(Icons.push_pin_outlined,
//                             color: Theme.of(context).iconTheme.color),
//                   ),
//                 ),
//                 IconButton(
//                   tooltip:
//                       "${AppLocalization.of(context)?.getTranslatedValue('archive')}",
//                   onPressed: () {
//                     setState(() {
//                       archive = !archive!;
//                     });
//                   },
//                   icon: Transform.scale(
//                     scale: 1,
//                     child: archive!
//                         ? Icon(Icons.archive,
//                             color: Theme.of(context).iconTheme.color)
//                         : Icon(Icons.archive_outlined,
//                             color: Theme.of(context).iconTheme.color),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 10,
//                 ),
//               ],
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 15),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextFormField(
//                         controller: titleCtr,
//                         autofocus: true,
//                         maxLines: null,
//                         style:
//                             Theme.of(context).textTheme.titleMedium?.copyWith(
//                                   fontWeight: FontWeight.w400,
//                                   fontSize: 20,
//                                 ),
//                         decoration: InputDecoration(
//                           hintText:
//                               "${AppLocalization.of(context)?.getTranslatedValue('title')}",
//                           hintStyle:
//                               Theme.of(context).textTheme.titleMedium?.copyWith(
//                                     fontWeight: FontWeight.w500,
//                                     fontSize: 20,
//                                     color: Theme.of(context)
//                                         .highlightColor
//                                         .withOpacity(0.5),
//                                   ),
//                           enabledBorder: InputBorder.none,
//                           border: InputBorder.none,
//                           disabledBorder: InputBorder.none,
//                         ),
//                         inputFormatters: [],
//                         onChanged: (value) {
//                           final editedDate =
//                               DateFormat('EEEEEEEEE,d MMM y').format(
//                             DateTime.now(),
//                           );
//                         },
//                       ),
//                       TextFormField(
//                         controller: noteCtr,
//                         minLines: 1,
//                         maxLines: null,
//                         style: Theme.of(context).textTheme.titleMedium,
//                         decoration: InputDecoration(
//                           hintText:
//                               "${AppLocalization.of(context)?.getTranslatedValue('note')}",
//                           hintStyle: Theme.of(context)
//                               .textTheme
//                               .titleMedium
//                               ?.copyWith(
//                                   fontWeight: FontWeight.w500,
//                                   color: Theme.of(context)
//                                       .highlightColor
//                                       .withOpacity(0.5)),
//                           enabledBorder: InputBorder.none,
//                           border: InputBorder.none,
//                           disabledBorder: InputBorder.none,
//                         ),
//                         onChanged: (value) {
//                           final editedDate =
//                               DateFormat('EEEEEEEEE,d MMM y').format(
//                             DateTime.now(),
//                           );
//                         },
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Container(
//                         child: GridView.builder(
//                           gridDelegate:
//                               const SliverGridDelegateWithMaxCrossAxisExtent(
//                                   maxCrossAxisExtent: 100,
//                                   childAspectRatio: 3 / 3,
//                                   crossAxisSpacing: 10,
//                                   mainAxisSpacing: 10),
//                           scrollDirection: Axis.vertical,
//                           primary: false,
//                           shrinkWrap: true,
//                           itemCount: imageFileList!.length,
//                           itemBuilder: (BuildContext context, int index) {
//                             return GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => ImageViewScreen(
//                                         path: imageFileList![index]
//                                             .path
//                                             .toString()),
//                                   ),
//                                 );
//                               },
//                               child: SizedBox(
//                                 height: 104,
//                                 width: 104,
//                                 child: Stack(
//                                   children: [
//                                     Container(
//                                       height: 104,
//                                       width: 104,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(11),
//                                         border: Border.all(
//                                           color: Theme.of(context)
//                                               .highlightColor
//                                               .withOpacity(0.5),
//                                         ),
//                                       ),
//                                       child: ClipRRect(
//                                         borderRadius: BorderRadius.circular(10),
//                                         child: Image.file(
//                                           File(imageFileList![index].path),
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     ),
//                                     Container(
//                                       decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(11),
//                                           color: Colors.black12),
//                                       child: Align(
//                                           alignment: Alignment.topRight,
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: GestureDetector(
//                                               onTap: () async {
//                                                 setState(() {
//                                                   imageFileList!.removeWhere(
//                                                     (element) =>
//                                                         element ==
//                                                         imageFileList![index],
//                                                   );
//                                                 });
//                                               },
//                                               child: Icon(
//                                                 Icons.delete_forever,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                           )),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Container(
//               height: 50,
//               child: Row(
//                 children: [
//                   Expanded(
//                       flex: 1,
//                       child: Container(
//                         child: Row(
//                           children: [
//                             IconButton(
//                               onPressed: () {
//                                 FocusManager.instance.primaryFocus?.unfocus();

//                                 showModalBottomSheet(
//                                   backgroundColor: Colors.transparent,
//                                   context: context,
//                                   elevation: 0,
//                                   builder: (context) {
//                                     return Padding(
//                                       padding: const EdgeInsets.all(10),
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           color: Theme.of(context).canvasColor,
//                                           borderRadius:
//                                               BorderRadius.circular(20),
//                                         ),
//                                         child: Column(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             ListTile(
//                                               onTap: () {
//                                                 Navigator.pop(context);
//                                                 selectImages();
//                                               },
//                                               leading: Icon(
//                                                   Icons
//                                                       .add_photo_alternate_outlined,
//                                                   color: AppColors.blackColor),
//                                               title: Text(
//                                                 "${AppLocalization.of(context)?.getTranslatedValue('add_image')}",
//                                                 style: Theme.of(context)
//                                                     .textTheme
//                                                     .titleMedium
//                                                     ?.copyWith(
//                                                         fontSize: 14,
//                                                         color: AppColors
//                                                             .blackColor),
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 );
//                               },
//                               icon: Icon(Icons.more_vert,
//                                   color: Theme.of(context).iconTheme.color
//                                   // color: AppColors.blackColor,
//                                   ),
//                             ),
//                           ],
//                         ),
//                       )),
//                   Expanded(
//                     flex: 1,
//                     child: Container(),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(vertical: 3),
//                       child: Center(
//                         child: MaterialButton(
//                           color: AppColors.yellowColor,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                           onPressed: () {
//                             FocusManager.instance.primaryFocus?.unfocus();
//                             addNote();
//                           },
//                           child: Text(
//                             "${AppLocalization.of(context)?.getTranslatedValue('save')}",
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .labelMedium
//                                 ?.copyWith(
//                                     fontSize: 14, color: AppColors.blackColor),
//                           ),
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void addNote() {
//     final date = DateFormat('EEEEEEEEE,d MMM y').format(DateTime.now());
//     final time = DateFormat('kk:mm a').format(DateTime.now());
//     print("$date, $time");
//     dbHelper!
//         .insertNote(NotesModel(
//       title: titleCtr.text.toString() ?? '',
//       note: noteCtr.text.toString() ?? '',
//       pin: pin == true ? 1 : 0,
//       archive: archive == true ? 1 : 0,
//       email: '',
//       deleted: 0,
//       create_date: date.toString(),
//       edited_date: date.toString(),
//       image_list: imageFileList!.map((image) => image.path).toList(),
//     ))
//         .then((value) {
//       print("data added");
//       Navigator.pop(context, true);
//     }).onError((error, stackTrace) {
//       print(error.toString());
//       print(stackTrace.toString());
//     });
//   }

//   void selectImages() async {
//     final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
//     if (selectedImages!.isNotEmpty) {
//       imageFileList!.addAll(selectedImages);
//     }
//     print("Image List Length:" + imageFileList!.length.toString());

//     setState(() {});
//   }
// }
