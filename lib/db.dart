import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const dbName = 'data.db';
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    // create table for all types of resources and image resources table
    await db.execute('''
      CREATE TABLE links (
        id TEXT PRIMARY KEY,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        path TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (list_id) REFERENCES links(id)
      )
    ''');
  }

  Future<void> insertImageList(String id, List<XFile> imageList) async {
    final db = await instance.database;
    final int now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('links', {'created_at': now});
    for (final image in imageList) {
      db.insert('images', {
        // 
      });
    }
  }

  // Future<int> insertImage(File imageFile) async {
  //   final db = await instance.database;
  //   return db.insert('files', row);
  // }

  // Future<List<Map<String, dynamic>>> fetchFiles() async {
  //   final db = await instance.database;
  //   return db.query('files');
  // }
}
