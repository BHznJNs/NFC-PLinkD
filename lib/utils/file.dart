import 'dart:io';

import 'package:nfc_plinkd/db.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const dataDirname = 'data';

Future<String> getDataBasePath(String id) async {
  final idDirname = path.join(dataDirname, id);
  final appDir = await getApplicationDocumentsDirectory();
  return path.join(appDir.path, idDirname);
}

Future<List<ResourceModel>> moveResourcesToAppDir(String id, List<ResourceModel> resources) async {
  final dataDirPath = await getDataBasePath(id);
  final directory = Directory(dataDirPath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  final List<ResourceModel> resultResources = [];
  for (final resource in resources) {
    final originalFile = File(resource.path);
    final filename = path.basename(resource.path);
    final newFilePath = path.join(dataDirPath, filename);
    await originalFile.copy(newFilePath); 

    // path relative to `ApplicationDocumentsDirectory`
    final relativePath = path.join(filename);
    resultResources.add(ResourceModel(
      linkId: id,
      type: resource.type,
      path: relativePath,
    ));
  }
  return resultResources;
}
