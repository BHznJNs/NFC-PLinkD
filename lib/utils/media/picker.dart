import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nfc_plinkd/components/recorder.dart';
import 'package:nfc_plinkd/components/custom_dialog.dart';
import 'package:nfc_plinkd/db.dart';

final picker = ImagePicker();

typedef ResourcePicker = Future<ResourcePickerResult> Function(BuildContext);
typedef ResourcePickerResult = List<(String, ResourceType)>;

ResourceType? getResourceTypeFromExtname(String extname) {
  switch (extname) {
    case "jpeg": case "jpg":
    case "tiff": case "tif":
    case "webp":
    case "indd":
    case "png":
    case "gif":
    case "ico":
    case "svg":
    case "eps":
    case "psd":
    case "raw":
      return ResourceType.image;

    case "rmvb": case "rm":
    case "avchd":
    case "avi":
    case "mov":
    case "mp4":
    case "flv":
    case "wmv":
    case "asf":
    case "asx":
    case "3gp":
    case "mkv":
    case "dat":
      return ResourceType.video;

    case "aiff": case "aif":
    case "midi": case "mid":
    case "flac":
    case "ogg":
    case "cda":
    case "wav":
    case "mp3":
    case "m4a":
    case "wma":
    case "ra":
    case "vqf":
    case "ape":
      return ResourceType.audio;
  }
  return null;
}

Future<ResourcePickerResult> takePhoto(BuildContext _) async {
  final photo = await picker.pickImage(source: ImageSource.camera);
  if (photo == null) return [];
  return [(photo.path, ResourceType.image)];
}

Future<ResourcePickerResult> recordVideo(BuildContext _) async {
  final video = await picker.pickVideo(source: ImageSource.camera);
  if (video == null) return [];
  return [(video.path, ResourceType.video)];
}

Future<ResourcePickerResult> recordAudio(BuildContext context) async {
  final completer = Completer<ResourcePickerResult>();
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => 
    Recorder(onRecordEnd: (recordedFilePath) {
      if (recordedFilePath == null) completer.complete([]);
      completer.complete([(recordedFilePath!, ResourceType.audio)]);
    })
  ));
  return completer.future;
}

Future<ResourcePickerResult> inputWebLink(BuildContext context) async {
  final result = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return WebLinkInputDialog();
    },
  );
  if (result == null) return [];
  return [(result, ResourceType.webLink)];
}

Future<ResourcePickerResult> pickMediaFile(BuildContext _) async {
  FilePickerResult? result = await FilePicker
    .platform
    .pickFiles(
      type: FileType.media,
      allowMultiple: true);
  if (result == null) return [];
  final ResourcePickerResult resultList = [];
  for (final file in result.files) {
    if (file.extension == null || file.path == null) {
      continue;
    }
    final fileType = getResourceTypeFromExtname(file.extension!);
    if (fileType == null) {
      continue;
    }
    resultList.add((file.path!, fileType));
  }
  return resultList;
}
