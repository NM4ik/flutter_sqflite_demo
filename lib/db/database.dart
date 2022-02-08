import 'dart:io';

import 'package:flutter_sqlite_crud_demo/entity/student.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider dbProvider = DBProvider._();

  static Database? _database;

  String studentsTable = 'Students';
  String columnID = 'id';
  String columnName = 'name';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'Student.db';
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  //create table
  //Students
  //Id  |  Name
  //0...
  //1...
  _createDB(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $studentsTable($columnID INTEGER PRIMARY KEY AUTOINCREMENT, $columnName TEXT)');
  }

  //Read drom DB
  Future<List<Student>> getStudents() async {
    Database db = await database;
    final List<Map<String, dynamic>> studentsMapList =
        await db.query(studentsTable);
    final List<Student> studentsList = [];
    for (var studentMap in studentsMapList) {
      studentsList.add(Student.fromMap(studentMap));
    }

    return studentsList;
  }

  //Insert to db
  Future<Student> insertStudent(Student student) async {
    Database db = await database;
    student.id = await db.insert(studentsTable, student.toMap());

    return student;
  }

  //Update student
  Future<int> updateStudent(Student student) async {
    Database db = await database;

    return await db.update(studentsTable, student.toMap(),
        where: '$columnID = ?', whereArgs: [student.id]);
  }

  //Delete student
  Future<int> deleteStudent(int id) async {
    Database db = await database;

    return await db
        .delete(studentsTable, where: '$columnID = ?', whereArgs: [id]);
  }
}
