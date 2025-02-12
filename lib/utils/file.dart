// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const dataDirname = 'data';

Future<String> getBasePath(String id) async {
  final idDirname = path.join(dataDirname, id);
  final appDir = await getApplicationDocumentsDirectory();
  return path.join(appDir.path, idDirname);
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
