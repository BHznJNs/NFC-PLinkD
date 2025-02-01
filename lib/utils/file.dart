import 'dart:io';

import 'package:nfc_plinkd/db.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<List<ResourceModel>> moveResourcesToAppDir(String id, List<ResourceModel> resources) async {
  final dataDirname = 'data/$id';
  final appDir = await getApplicationDocumentsDirectory();
  final dataDirPath = path.join(appDir.path, dataDirname);
  final directory = Directory(dataDirPath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  final List<ResourceModel> resultResources = [];
  for (final resource in resources) {
    final originalFile = File(resource.path);
    final filename = path.basename(resource.path);
    final newFilePath = '$dataDirPath/$filename';
    await originalFile.copy(newFilePath); 
    await originalFile.delete();

    // path relative to `ApplicationDocumentsDirectory`
    final relativePath = path.join(dataDirname, filename);
    resultResources.add(ResourceModel(
      linkId: id,
      type: resource.type,
      path: relativePath,
    ));
  }
  return resultResources;
}
