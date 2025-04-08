import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('attendance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE attendees (
      id $idType,
      name $textType,
      date $textType,
      time $textType
    )
  ''');
  }


  Future<void> insertAttendee(Map<String, dynamic> row) async {
    final db = await database;
    await db.insert('attendees', {
      'name': row['name'],
      'date': row['date'], // Assuming `row` has a 'date' key
      'time': row['time'], // Assuming `row` has a 'time' key
    });
  }


  Future<List<Map<String, dynamic>>> getAttendees() async {
    final db = await database;
    return await db.query('attendees');
  }

  Future<void> deleteAllRows() async {
    final db = await database;
    await db.delete('attendees');
  }

  // New method to check if a code has already been scanned
  Future<bool> isCodeScanned(String code) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'attendees',
      where: 'name = ?',
      whereArgs: [code],
    );

    return result.isNotEmpty;
  }
}
