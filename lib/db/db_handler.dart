import 'package:notes_sqflite/model/note_model.dart';
import 'package:notes_sqflite/model/todo_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'notes.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE notes (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, note TEXT NOT NULL, pin INTEGER NOT NULL, archive INTEGER NOT NULL, email TEXT NOT NULL, deleted INTEGER NOT NULL, create_date TEXT NOT NULL, edited_date Text, image_list TEXT)");
    await db.execute(
        "CREATE TABLE todos (id INTEGER PRIMARY KEY AUTOINCREMENT, todo TEXT NOT NULL, finished INTEGER NOT NULL, due_date TEXT NOT NULL,due_time TEXT NOT NULL, category TEXT NOT NULL)");
  }

  Future<NotesModel> insertNote(NotesModel notesModel) async {
    var dbClient = await db;
    await dbClient!.insert('notes', notesModel.toMap());
    return notesModel;
  }

  Future<TodoModel> insertTodo(TodoModel todoModel) async {
    var dbClient = await db;
    await dbClient!.insert('todos', todoModel.toMap());
    return todoModel;
  }

  Future<List<NotesModel>> getNotesList() async {
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult =
        await dbClient!.query('notes');
    return queryResult.map((data) => NotesModel.fromMap(data)).toList();
  }

  Future<List<TodoModel>> getTodosList() async {
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult =
        await dbClient!.query('todos');
    return queryResult.map((e) => TodoModel.fromMap(e)).toList();
  }

  Future<int> deleteNote(int id) async {
    var dbClient = await db;
    return await dbClient!.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTodo(int id) async {
    var dbClient = await db;
    return await dbClient!.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(NotesModel notesModel) async {
    var dbClient = await db;
    return await dbClient!.update(
      'notes',
      notesModel.toMap(),
      where: 'id = ?',
      whereArgs: [notesModel.id],
    );
  }

  Future<int> updatetile(NotesModel notesModel) async {
    var dbClient = await db;
    final updateFields = <String, dynamic>{};
    if (notesModel.title != null) {
      updateFields['title'] = notesModel.title;
    }
    return await dbClient!.update(
      'notes',
      updateFields,
      where: 'id = ?',
      whereArgs: [notesModel.id],
    );
  }

  Future<int> updateTodo(TodoModel todoModel) async {
    var dbClient = await db;
    return await dbClient!.update('todos', todoModel.toMap(),
        where: 'id = ?', whereArgs: [todoModel.id]);
  }
}
