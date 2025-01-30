import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<List<String>> moveResourcesToAppDir(List<XFile> resources, LinkType type) async {
  final dataDirname = 'data/${type.name}';
  final appDir = await getApplicationDocumentsDirectory();
  final dataDirPath = path.join(appDir.path, dataDirname);
  final directory = Directory(dataDirPath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  final List<String> moveTargetPathList = [];
  for (final xfile in resources) {
    final File originalFile = File(xfile.path);
    final newFilePath = '$dataDirPath/${xfile.name}';
    await originalFile.copy(newFilePath); 
    await originalFile.delete();

    // path relative to `ApplicationDocumentsDirectory`
    final relativePath = path.join(dataDirname, xfile.name);
    moveTargetPathList.add(relativePath);
  }
  return moveTargetPathList;
}
