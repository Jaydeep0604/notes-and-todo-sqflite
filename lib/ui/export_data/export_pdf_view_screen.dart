import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notes_sqflite/db/db_handler.dart';
import 'package:notes_sqflite/language/localisation.dart';
import 'package:notes_sqflite/model/note_model.dart';
import 'package:notes_sqflite/model/todo_model.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:notes_sqflite/utils/app_message.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ExportPdfViewScreen extends StatefulWidget {
  ExportPdfViewScreen({
    super.key,
    required this.title,
    required this.isNoteView,
  });
  String title;
  bool isNoteView;
  @override
  State<ExportPdfViewScreen> createState() => _ExportPdfViewScreenState();
}

class _ExportPdfViewScreenState extends State<ExportPdfViewScreen> {
  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    loadData();
  }

  DBHelper? dbHelper;
  late Future<List<NotesModel>> noteList;
  late Future<List<TodoModel>> todoList;

  loadData() async {
    if (widget.isNoteView) {
      noteList = dbHelper!.getNotesList();
    } else {
      todoList = dbHelper!.getTodosList();
    }
  }

  final pdf = pw.Document();
  void savePdf() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory != null) {
      final file = File('${directory.path}/${widget.title}.pdf');
      await file.writeAsBytes(await pdf.save());
      AppMessage.showToast(context,
          "${AppLocalization.of(context)?.getTranslatedValue('pdf_saved')}");
      print('PDF saved to ${file.path}');
    } else {
      print('External storage directory not available');
    }
  }

  Future<Uint8List> _generateNotePdf(PdfPageFormat format) async {
    final emoji = await PdfGoogleFonts.notoColorEmoji();

    final List<NotesModel> fetchedNotes = await noteList;

    final List<List<dynamic>> noteData = [
      ['Title', 'Note', 'Email', 'Create Date'], // Table header
      for (NotesModel note in fetchedNotes)
        [note.title, note.note, note.email, note.create_date]
    ];

    final table = pw.Table.fromTextArray(
      data: noteData,
      cellAlignment: pw.Alignment.centerLeft,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellStyle: pw.TextStyle(fontFallback: [emoji]),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      border: pw.TableBorder.all(color: PdfColors.black),
      columnWidths: {
        0: pw.FixedColumnWidth(100), // Adjust column widths as needed
        1: pw.FlexColumnWidth(),
        2: pw.FlexColumnWidth(),
        3: pw.FlexColumnWidth(),
      },
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(children: [
                pw.Text("Note's PDF"),
                pw.Spacer(),
                pw.Text(""),
              ]),
            ),
            pw.SizedBox(height: 10),
            table,
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> _generateTododPdf(PdfPageFormat format) async {
    final emoji = await PdfGoogleFonts.notoColorEmoji();
    final List<TodoModel> fetchTodoList = await todoList;

    final List<List<dynamic>> todoData = [
      ['Todo', 'Finished', 'Due Date', 'Due Time', 'Category'], // Table header
      for (TodoModel todo in fetchTodoList)
        [todo.todo, todo.finished, todo.dueDate, todo.dueTime, todo.category]
    ];

    final table = pw.Table.fromTextArray(
      data: todoData,
      cellAlignment: pw.Alignment.centerLeft,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellStyle: pw.TextStyle(fontFallback: [emoji]),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      border: pw.TableBorder.all(color: PdfColors.black),
      columnWidths: {
        0: pw.FlexColumnWidth(),
        1: pw.FlexColumnWidth(),
        2: pw.FlexColumnWidth(),
        3: pw.FlexColumnWidth(),
        4: pw.FlexColumnWidth(),
      },
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                children: [
                  pw.Text("Todos PDF"),
                  pw.Spacer(),
                  pw.Text(""),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            table,
          ];
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).iconTheme.color)),
        title: Text(
          "${AppLocalization.of(context)?.getTranslatedValue("${widget.title}")}",
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          children: [
            
            Spacer(),
            MaterialButton(
              onPressed: () {
                savePdf();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              color: AppColors.greenSplashColor,
              child: Text(
                "${AppLocalization.of(context)?.getTranslatedValue('dounload_pdf')}",
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: InteractiveViewer(
          child: PdfPreview(
            pdfPreviewPageDecoration: BoxDecoration(
              color: Colors.white,
            ),
            loadingWidget: CircularProgressIndicator(color: Colors.black),
            padding: EdgeInsets.zero,
            // previewPageMargin: EdgeInsets.zero,
            canDebug: false,
            useActions: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
            allowSharing: false,
            dynamicLayout: false,
            initialPageFormat: PdfPageFormat.a4,
            allowPrinting: true,

            build: (format) => widget.isNoteView
                ? _generateNotePdf(format)
                : _generateTododPdf(format),
          ),
        ),
      ),
    );
  }
}
