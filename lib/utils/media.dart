import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nfc_plinkd/components/audio.dart';
import 'package:path/path.dart';

final picker = ImagePicker();

Future<XFile?> takePhoto() async {
  return await picker.pickImage(source: ImageSource.camera);
}

Future<XFile?> recordVideo() async {
  return await ImagePicker().pickVideo(source: ImageSource.camera);
}

Future<XFile?> recordAudio(BuildContext context) async {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => 
    Recorder()
  ));
}

Future<XFile?> pickMediaFile() async {
  FilePickerResult? result = await FilePicker
    .platform
    .pickFiles(
      type: FileType.media,
      allowMultiple: true);
  if (result != null) {
    return XFile(result.files.single.path!);
  }
  return null;
}
