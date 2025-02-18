// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:archive/archive_io.dart';
import 'package:nfc_plinkd/utils/formatter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:sqflite/sqflite.dart';

const dataDirname = 'data';

Future<String> getBasePath(String id) async {
  final idDirPath = path.join(dataDirname, id);
  final appDir = await getApplicationDocumentsDirectory();
  return path.join(appDir.path, idDirPath);
}

Future<List<ResourceModel>> copyResourcesToAppDir(String id, List<ResourceModel> resources) async {
  final dataDirPath = await getBasePath(id);
  final directory = Directory(dataDirPath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  final List<ResourceModel> resultResources = [];
  for (final resource in resources) {
    if (resource.type == ResourceType.webLink) continue;

    final originalFile = File(resource.path);
    final filename = path.basename(resource.path);
    final newFilePath = path.join(dataDirPath, filename);
    if (!File(newFilePath).existsSync()) {
      await originalFile.copy(newFilePath); 
    }
  
    // path relative to `ApplicationDocumentsDirectory`
    final relativePath = path.join(filename);
    resultResources.add(resource.copyWith(path: relativePath));
  }
  return resultResources;
}

Future<File> creatBackupArchive() async {
  String getRelativePath({required Directory root, required FileSystemEntity item}) {
    // root: the root directory to add to archive
    // item: the file or directory to add
    final rootPath = root.path;
    final itemPath = item.path;

    if (itemPath.startsWith(rootPath)) {
      final relativePath = itemPath
        .substring(rootPath.length)
        .replaceAll(r'^\/', '');
      return relativePath;
    } else {
      throw Exception('The `item` is not a subitem of `root`');
    }
  }
  Future<void> addDirectoryToArchive(Archive archive, Directory directory) async {
    List<FileSystemEntity> items = directory.listSync();
    for (FileSystemEntity item in items) {
      if (item is File) {
        final fileBytes = await item.readAsBytes();
        final relativePath = getRelativePath(root: directory, item: item);
        archive.add(ArchiveFile.typedData(relativePath, fileBytes));
      } else if (item is Directory) {
        await addDirectoryToArchive(archive, item);
      }
    }
  }

  final archive = Archive();

  final dbFile = File(await getDatabasesPath());
  if (dbFile.existsSync()) {
    final dbBytes = await dbFile.readAsBytes();
    archive.addFile(ArchiveFile.typedData(DatabaseHelper.dbName, dbBytes));
  }

  final appDir = await getApplicationDocumentsDirectory();
  final dataDir = Directory(path.join(appDir.path, dataDirname));
  await addDirectoryToArchive(archive, dataDir);

  final encoder = ZipEncoder();
  final zipBytes = encoder.encode(archive);

  final tempDir = await getTemporaryDirectory();
  final dateTimeString = formatDateTimeToHyphenSeparated(DateTime.now());
  final tempZipFile = File('${tempDir.path}/nfc_plinkd-archive-$dateTimeString.zip');
  await tempZipFile.writeAsBytes(zipBytes);
  return tempZipFile;
}

Future<void> debugPrintInternalFiles(String base) async {
  if (!kDebugMode) return;
  try {
    print('--- Internal Storage Files ---');
    final directory = await getApplicationDocumentsDirectory();
    final subDir = Directory(path.join(directory.path, base));
    List<FileSystemEntity> files = subDir.listSync();
    if (files.isEmpty) {
      print('$base directory is empty.');
      return;
    }
    for (var file in files) {
      print(file.path);
    }
    print('--- End of Internal Storage Files ---');

  } catch (e) {
    print('Error listing internal storage files: $e');
  }
}
