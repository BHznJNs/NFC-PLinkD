import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:nfc_plinkd/models.dart';
import 'package:nfc_plinkd/utils/formatter.dart';

const dataDirname = 'data';

Future<String> getDataPath() async {
  final appDir = await getApplicationDocumentsDirectory();
  return path.join(appDir.path, dataDirname);
}

Future<String> getBasePath(String id) async {
  final dataPath = await getDataPath();
  return path.join(dataPath, id);
}

Future<List<ResourceModel>> copyResourcesToAppDir(String id, List<ResourceModel> resources) async {
  final dataDirPath = await getBasePath(id);
  final directory = Directory(dataDirPath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  final List<ResourceModel> resultResources = [];
  for (final resource in resources) {
    if ([ResourceType.webLink, ResourceType.note].contains(resource.type)) {
      resultResources.add(resource);
      continue;
    }

    final originalFile = File(resource.path);
    final filename = path.basename(resource.path);
    final newFilePath = path.join(dataDirPath, filename);
    if (!await File(newFilePath).exists()) {
      await originalFile.copy(newFilePath); 
    }
  
    // path relative to `ApplicationDocumentsDirectory`
    final relativePath = path.join(filename);
    resultResources.add(resource.copyWith(path: relativePath));
  }
  return resultResources;
}

Future<void> mergeFolder({
  required Directory source,
  required Directory destination,
}) async {
  if (!await source.exists()) return;

  await destination.create(recursive: true);
  await for (final item in source.list()) {
    final itemName = path.basename(item.path);
    final destinationPath = path.join(destination.path, itemName);

    if (item is File) {
      await item.copy(destinationPath);
    } else if (item is Directory) {
      final destinationDir = Directory(destinationPath);
      await mergeFolder(source: Directory(item.path), destination: destinationDir); // 递归合并文件夹
    }
  }
}

Future<String> creatBackupArchive() async {
  const archiveFilePrefix = 'NFC-PLinkD-archive';

  await DatabaseHelper.instance.createCheckpoint();
  final dbFile = File(await DatabaseHelper.dbPath);
  final dataDir = Directory(await getDataPath());

  final tempDir = await getTemporaryDirectory();
  final dateTimeString = formatDateTimeToHyphenSeparated(DateTime.now());
  final tempZipPath = '${tempDir.path}/$archiveFilePrefix-$dateTimeString.zip';

  final encoder = ZipFileEncoder();
  encoder.create(tempZipPath);
  await Future.wait([
    dbFile .exists().then((_) => encoder.addFile(dbFile)),
    dataDir.exists().then((_) => encoder.addDirectory(dataDir)),
  ]);
  await encoder.close();
  return tempZipPath;
}

Future<Directory> extractArchiveToTemp(String archivePath) async {
  final input = InputFileStream(archivePath);
  final archive = ZipDecoder().decodeStream(input);

  final tempDir = await getTemporaryDirectory();
  final outputDirPath = path.join(tempDir.path, path.basename(archivePath));
  final outputDir = Directory(outputDirPath);
  await outputDir.create();

  for (final archiveFile in archive.files) {
    final outputPath = path.join(outputDir.path, archiveFile.name);

    if (archiveFile.isFile) {
      final outFile = File(outputPath);
      if (!await outFile.parent.exists()) {
        await outFile.parent.create(recursive: true);
      }
      await outFile.writeAsBytes(archiveFile.content);
    } else {
      final dir = Directory(outputPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }
  }
  return outputDir;
}

List<String> extractUrlsFromString(String? text) {
  if (text == null) return [];

  const urlPatString = r'((?:https?:\/\/|www\.)[^\s]+)';
  final urlRegex = RegExp(urlPatString);
  final matches = urlRegex.allMatches(text);
  final resultUrls = <String>[];
  for (Match match in matches) {
    String? url = match.group(0);
    if (url != null) resultUrls.add(url);
  }
  return resultUrls;
}

Future<void> debugPrintInternalFiles(String base) async {
  if (!kDebugMode) return;
  try {
    debugPrint('--- Internal Storage Files ---');
    final directory = await getApplicationDocumentsDirectory();
    final subDir = Directory(path.join(directory.path, base));
    List<FileSystemEntity> files = subDir.listSync();
    if (files.isEmpty) {
      debugPrint('$base directory is empty.');
      return;
    }
    for (var file in files) {
      debugPrint(file.path);
    }
    debugPrint('--- End of Internal Storage Files ---');

  } catch (e) {
    debugPrint('Error listing internal storage files: $e');
  }
}
