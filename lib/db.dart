import 'dart:io';

import 'package:nfc_plinkd/models.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

extension on Database {
  Future<void> attach(sourceDbPath, sourceDbName) async {
    await execute('ATTACH DATABASE ? AS ?', [sourceDbPath, sourceDbName]); 
  }
  Future<void> detach(sourceDbName) async {
    await execute('DETACH DATABASE ?', [sourceDbName]);
  }
}

class DatabaseHelper {
  static const dbName = 'data.db';
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;
  static const String linksTableName = 'links';
  static const String resourcesTableName = 'resources';
  static const int defaultPageSize = 10;

  DatabaseHelper._init();

  static Future<String> get dbPath async {
    final appDir = await getApplicationDocumentsDirectory();
    return path.join(appDir.path, dbName);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    return openDatabase(
      await dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // create table for all types of resources and image resources table
    await db.execute('''
      CREATE TABLE $linksTableName (
        id TEXT PRIMARY KEY,
        name TEXT,
        ${OrderBy.createTime.toFieldName()} INTEGER NOT NULL,
        ${OrderBy.modifyTime.toFieldName()} INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $resourcesTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_index INTEGER NOT NULL,
        path TEXT NOT NULL,
        type INTEGER NOT NULL,
        link_id INTEGER NOT NULL,
        description TEXT,
        FOREIGN KEY (link_id) REFERENCES links(id)
      )
    ''');
  }

  Future<void> mergeDatabases(String sourceDbPath) async {
    const mergeMode = 'INSERT OR REPLACE';
    const sourceDbName = 'source_db';
    final mainDb = await database;

    try {
      await mainDb.attach(sourceDbPath, sourceDbName);
      final createTimeFieldName = OrderBy.createTime.toFieldName();
      final modifyTimeFieldName = OrderBy.modifyTime.toFieldName();
      await mainDb.transaction((txn) async {
        await txn.rawInsert("""
            $mergeMode INTO $linksTableName (id, name, $createTimeFieldName, $modifyTimeFieldName)
            SELECT id, name, $createTimeFieldName, $modifyTimeFieldName
            FROM source_db.$linksTableName
        """);
        await txn.rawInsert("""
            $mergeMode INTO $resourcesTableName (id, order_index, path, type, link_id, description)
            SELECT id, order_index, path, type, link_id, description
            FROM source_db.$resourcesTableName
        """);
      });
    } catch (e) {
      rethrow;
    } finally {
      await mainDb.detach(sourceDbName);
    }
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

  Future<void> updateLink(LinkModel link, List<ResourceModel> resources) async {
    final db = await database;
    await db.update(linksTableName, {
      'name': link.name,
      'modified_at': link.modifyTime,
    },
      where: 'id = ?',
      whereArgs: [link.id],
    );
    await db.delete(resourcesTableName,
      where: 'link_id = ?',
      whereArgs: [link.id],
    );
    // re-insert new data
    for (int i = 0; i < resources.length; i++) {
      final resource = resources[i];
      final map = resource.toMap();
      map['order_index'] = i;
      await db.insert(resourcesTableName, map);
    }
  }

  Future<(LinkModel, List<ResourceModel>)?> fetchLink(String id) async {
    final db = await database;
    final candidateLinks = await db.query(
      linksTableName,
      where: "id = ?",
      whereArgs: [id],
    );
    final linkResources = await db.query(
      resourcesTableName,
      where: "link_id = ?",
      whereArgs: [id],
      orderBy: 'order_index',
    );
    if (candidateLinks.isEmpty || linkResources.isEmpty) return null;

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
    int pageSize = defaultPageSize,
    OrderBy orderBy = OrderBy.createTime,
  }) async {
    final db = await database;
    final orderByFieldName = orderBy.toFieldName();
    final isReversed = orderBy.isReversed;

    final candidateLinks = await db.query(
      linksTableName,
      offset: page * pageSize,
      limit: pageSize,
      orderBy: orderByFieldName + (isReversed ? ' ASC' : ' DESC'),
    );
    return candidateLinks.map((item) =>
      LinkModel.fromMap(item)
    ).toList();
  }

  Future<int?> getLinkCount() async {
    final db = await database;
    final res = await db.rawQuery('SELECT COUNT (*) from $linksTableName');
    final count = Sqflite.firstIntValue(res);
    return count;
  }

  Future<void> createCheckpoint() async {
    final db = await database;
    await db.rawQuery("PRAGMA wal_checkpoint;");
  }

  Future<void> deleteLink(LinkModel link) async {
    final db = await database;
    await db.delete(resourcesTableName,
      where: 'link_id = ?',
      whereArgs: [link.id],
    );
    await db.delete(linksTableName,
      where: 'id = ?',
      whereArgs: [link.id],
    );
  }

  Future<void> reset() async {
    final dbPath = await DatabaseHelper.dbPath;
    if (await File(dbPath).exists()) {
      await deleteDatabase(dbPath);
    }
  }
}

// --- --- --- --- --- ---

enum ResourceType {
  image,
  video,
  audio,
  webLink,
  note;

  static ResourceType fromInt(int typeId) {
    return ResourceType.values[typeId];
  }
  static ResourceType? fromMimetype(String mimeType) {
    switch (mimeType) {
      case String() when mimeType.startsWith('image'): return ResourceType.image;
      case String() when mimeType.startsWith('video'): return ResourceType.video;
      case String() when mimeType.startsWith('audio'): return ResourceType.audio;
      case String() when mimeType == 'text/url': return ResourceType.webLink;
    }
    return null;
  }
}

enum OrderBy {
  createTime,
  createTimeRev,
  modifyTime,
  modifyTimeRev;

  bool get isReversed {
    if (this == OrderBy.createTimeRev || this == OrderBy.modifyTimeRev) {
      return true;
    }
    return false;
  }

  String toFieldName() {
    final fieldName = switch (this) {
      OrderBy.createTime || OrderBy.createTimeRev => 'created_at',
      OrderBy.modifyTime || OrderBy.modifyTimeRev => 'modified_at',
    };
    return fieldName;
  }
}
