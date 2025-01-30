import 'dart:io';

import 'package:nfc_plinkd/utils/index.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const dbName = 'data.db';
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;
  static const String linksTableName = 'links';
  static const String resourcesTableName = 'resources';

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
      CREATE TABLE $linksTableName (
        id TEXT,
        created_at INTEGER NOT NULL,
        type TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $resourcesTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        link_id INTEGER NOT NULL,
        path TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (link_id) REFERENCES links(id)
      )
    ''');
  }

  Future<void> insertLink(LinkModel link, List<ResourceModel> resources) async {
    final db = await database;
    await db.insert(linksTableName, link.toMap());
    for (final resource in resources) {
      await db.insert(resourcesTableName, resource.toMap());
    }
  }

  Future<(LinkModel, List<ResourceModel>)> fetchLink(String id) async {
    final db = await database;
    final candidateLinks = await db.query(
      linksTableName,
      where: "id = ?",
      whereArgs: [id]
    );
    final linkResources = await db.query(
      resourcesTableName,
      where: "link_id = ?",
      whereArgs: [id],
    );
    if (candidateLinks.isEmpty || linkResources.isEmpty) {
      throw LinkError.DataNotFound;
    }

    final targetLink = candidateLinks[0];
    return (
      LinkModel.fromMap(targetLink),
      linkResources.map((resourceMap) =>
        ResourceModel.fromMap(resourceMap)
      ).toList(),
    );
  }

  Future<void> reset() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    if (await File(path).exists()) {
      await deleteDatabase(path);
    }
  }
}

// --- --- --- --- --- ---

enum LinkType {
  image,
  video,
  audio,
  webLink;

  static LinkType fromName(String name) {
    return LinkType.values.byName(name);
  }
}

class LinkError extends CustomError {
  LinkError({required super.title, required super.content});

  // ignore: non_constant_identifier_names
  static final DataNotFound = LinkError(
    title: 'Link Data Not Found',
    content:
      'The data for this link is not found,'
      'it may has been deleted.',
  );
}

class LinkModel {
  final String id;
  final LinkType type;
  final int createTime;

  LinkModel({
    required this.id,
    required this.type,
    required this.createTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'created_at': createTime,
    };
  }

  factory LinkModel.fromMap(Map<String, dynamic> map) {
    return LinkModel(
      id: map['id'] as String,
      type: LinkType.fromName(map['type']),
      createTime: map['created_at'] as int,
    );
  }
}

class ResourceModel {
  final String linkId;
  final String path;
  final String? description;

  ResourceModel({
    required this.linkId,
    required this.path,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'link_id': linkId,
      'path': path,
      'description': description,
    };
  }

  factory ResourceModel.fromMap(Map<String, dynamic> map) {
    return ResourceModel(
      linkId: map['link_id'] as String,
      path: map['path'] as String,
      description: map['description'] as String?,
    );
  }
}
