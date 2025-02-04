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
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $resourcesTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_index INTEGER NOT NULL,
        path TEXT NOT NULL,
        type INTEGER NOT NULL,
        link_id INTEGER NOT NULL,
        description TEXT NOT NULL,
        FOREIGN KEY (link_id) REFERENCES links(id)
      )
    ''');
  }

  Future<void> insertLink(LinkModel link, List<ResourceModel> resources) async {
    final db = await database;
    await db.insert(linksTableName, link.toMap());
    for (int i = 0; i < resources.length; i++) {
      final resource = resources[i];
      final map = resource.toMap();
      map['order_index'] = i;
      await db.insert(resourcesTableName, map);
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
      orderBy: 'order_index',
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

  Future<List<LinkModel>> fetchLinks({
    int page = 0,
    int pageSize = 10,
    OrderBy orderBy = OrderBy.createTime,
  }) async {
    final db = await database;
    final candidateLinks = await db.query(
      linksTableName,
      // TODO: orderBy, page, pageSize
      // orderBy: 
      // where: "id = ?",
      // whereArgs: [id]
    );
    return candidateLinks.map((item) =>
      LinkModel.fromMap(item)
    ).toList();
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

enum ResourceType {
  image,
  video,
  audio,
  webLink;

  static ResourceType fromInt(int typeId) {
    return ResourceType.values[typeId];
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
  final int createTime;

  LinkModel({
    required this.id,
    required this.createTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createTime,
    };
  }

  factory LinkModel.fromMap(Map<String, dynamic> map) {
    return LinkModel(
      id: map['id'] as String,
      createTime: map['created_at'] as int,
    );
  }
}

class ResourceModel {
  final String linkId;
  final String path;
  final ResourceType type;
  final String description;

  ResourceModel({
    required this.linkId,
    required this.type,
    required this.path,
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'link_id': linkId,
      'type': type.index,
      'path': path,
      'description': description,
    };
  }

  ResourceModel copyWith({
    String? linkId,
    String? path,
    ResourceType? type,
    String? description,
  }) => ResourceModel(
    linkId: linkId ?? this.linkId,
    path: path ?? this.path,
    type: type ?? this.type,
    description: description ?? this.description,
  );

  factory ResourceModel.fromMap(Map<String, dynamic> map) {
    return ResourceModel(
      linkId: map['link_id'] as String,
      type: ResourceType.fromInt(map['type'] as int),
      path: map['path'] as String,
      description: map['description'] as String,
    );
  }
}

enum OrderBy {
  name,
  createTime,
  createTimeRev,
}
