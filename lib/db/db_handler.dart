import 'package:flutter/material.dart';
import 'package:notes_sqflite/model/note_model.dart';
import 'package:notes_sqflite/model/notification_model.dart';
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
    await db.execute(
        "CREATE TABLE notification (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL)");
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

  Future<List<NotesModel>> getSingleNotes(int id) async {
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult = await dbClient!.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    return queryResult.map((data) => NotesModel.fromMap(data)).toList();
  }

  Future<List<TodoModel>> getSingleTodo(int id) async {
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult = await dbClient!.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
    return queryResult.map((data) => TodoModel.fromMap(data)).toList();
  }

  Future<int> deleteNote(NotesModel notesModel) async {
    var dbClient = await db;
    final updateFields = <String, dynamic>{};
    if (notesModel.deleted != null) {
      updateFields['deleted'] = notesModel.deleted;
    }
    return await dbClient!.update(
      'notes',
      updateFields,
      where: 'id = ?',
      whereArgs: [notesModel.id],
    );
  }

  Future<int> deleteForeverNote(int id) async {
    var dbClient = await db;
    return await dbClient!.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTodo(int id) async {
    var dbClient = await db;
    return await dbClient!.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateNote(NotesModel notesModel) async {
    var dbClient = await db;
    return await dbClient!.update(
      'notes',
      notesModel.toMap(),
      where: 'id = ?',
      whereArgs: [notesModel.id],
    );
  }

  Future<int> updateTodo(TodoModel todoModel) async {
    var dbClient = await db;
    return await dbClient!.update('todos', todoModel.toMap(),
        where: 'id = ?', whereArgs: [todoModel.id]);
  }

  Future<int> updatetile(NotesModel notesModel) async {
    var dbClient = await db;
    final updateFields = <String, dynamic>{};
    if (notesModel.title != null) {
      updateFields['title'] = notesModel.title;
      updateFields['edited_date'] = notesModel.edited_date;
    }
    return await dbClient!.update(
      'notes',
      updateFields,
      where: 'id = ?',
      whereArgs: [notesModel.id],
    );
  }

  Future<int> updateNoteText(NotesModel notesModel) async {
    var dbClient = await db;
    final updateFields = <String, dynamic>{};
    if (notesModel.note != null) {
      updateFields['note'] = notesModel.note;
      updateFields['edited_date'] = notesModel.edited_date;
    }
    return await dbClient!.update(
      'notes',
      updateFields,
      where: 'id = ?',
      whereArgs: [notesModel.id],
    );
  }

  Future<int> updatePin(NotesModel notesModel) async {
    var dbClient = await db;
    final updateFields = <String, dynamic>{};
    if (notesModel.pin != null) {
      updateFields['pin'] = notesModel.pin;
      updateFields['archive'] = notesModel.archive;
    }
    return await dbClient!.update(
      'notes',
      updateFields,
      where: 'id = ?',
      whereArgs: [notesModel.id],
    );
  }

  Future<int> updateArchive(NotesModel notesModel) async {
    var dbClient = await db;
    final updateFields = <String, dynamic>{};
    if (notesModel.archive != null) {
      updateFields['archive'] = notesModel.archive;
      updateFields['pin'] = notesModel.pin;
    }
    return await dbClient!.update(
      'notes',
      updateFields,
      where: 'id = ?',
      whereArgs: [notesModel.id],
    );
  }

  Future<int> updateImageList(NotesModel notesModel) async {
    var dbClient = await db;
    final updateFields = <String, dynamic>{};
    if (notesModel.image_list.isNotEmpty) {
      updateFields['image_list'] = notesModel.image_list
          .reduce((image, element) => image + ',' + element);
    } else {
      updateFields['image_list'] = ''; // For example, assigning an empty string
    }
    return await dbClient!.update(
      'notes',
      updateFields,
      where: 'id = ?',
      whereArgs: [notesModel.id],
    );
  }

  Future<NotificationModel> insertNotification(
      NotificationModel notificationModel) async {
    var dbClient = await db;
    await dbClient!.insert('notification', notificationModel.toMap());
    return notificationModel;
  }

  Future<List<NotificationModel>> getNotification() async {
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult =
        await dbClient!.query('notification');
    return queryResult.map((data) => NotificationModel.fromMap(data)).toList();
  }

  Future<int> deleteNotification(int id) async {
    var dbClient = await db;
    return await dbClient!
        .delete('notification', where: 'id = ?', whereArgs: [id]);
  }
}
