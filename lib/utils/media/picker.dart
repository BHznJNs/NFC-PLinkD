import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nfc_plinkd/components/recorder.dart';
import 'package:nfc_plinkd/components/custom_dialog.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:nfc_plinkd/l10n/app_localizations.dart';
import 'package:nfc_plinkd/pages/create/note_uri_input.dart';
import 'package:nfc_plinkd/utils/index.dart';

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
    builder: (BuildContext context) => UriInputDialog(),
  ) as String?;
  if (result == null) return [];
  return [(result, ResourceType.webLink)];
}

final List<NoteAppItem> supportedNoteAppList = [
  NoteAppItem(
    id: 'notion', name: 'Notion', uri: 'notion://',
    uriProcessor: (Uri inputUri) => inputUri.host.contains('notion.so')
      ? inputUri.replace(scheme: 'notion').toString()
      : null),
  NoteAppItem(
    id: 'obsidian', name: 'Obsidian', uri: 'obsidian://',
    uriProcessor: (Uri inputUri) => inputUri.scheme == 'obsidian'
        ? inputUri.toString()
        : null,),
  NoteAppItem(
    id: 'joplin', name: 'Joplin', uri: 'joplin://',
    uriProcessor: (Uri inputUri) => inputUri.scheme == 'joplin'
        ? inputUri.toString()
        : null,),
];
Future<ResourcePickerResult> inputNoteLink(BuildContext context) async {
  /// Throw `PickerError.NotSupportedNote` if the input uri is not supported
  String tryResolveNoteLink(BuildContext context, Uri inputUri) {
    for (final item in supportedNoteAppList) {
      final output = item.uriProcessor(inputUri);
      if (output != null) return output;
    }
    throw PickerError.NotSupportedNote(context,
      supportedNoteAppList.map((item) => item.name).toList()
    );
  }

  final result = await Navigator.of(context).push(
    MaterialPageRoute(builder: (context) =>
      NoteUriInputPage())) as String?;
  if (result == null) return [];
  if (!context.mounted) return [];

  try {
    // since there is a check in the `UriInputDialog`,
    // there is not need to check if uri valid here.
    final resolvedLink = tryResolveNoteLink(context, Uri.parse(result));
    return [(resolvedLink, ResourceType.note)];
  } catch (e) {
    resolveDynamicError(context, e);
    return [];
  }
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

// --- --- --- --- --- ---

class NoteAppItem {
  const NoteAppItem({
    required this.id,
    required this.name,
    required this.uri,
    required this.uriProcessor
  }): iconPath='assets/images/$id-icon.png';
  final String iconPath;
  final String id;
  final String name;
  final String uri;
  final String? Function(Uri) uriProcessor;
}

class PickerError extends CustomError {
  PickerError({required super.title, required super.content});

  // ignore: non_constant_identifier_names
  static PickerError NotSupportedNote(BuildContext context, List<String> supportedList) {
    final l10n = S.of(context)!;
    return PickerError(
      title: l10n.pickerError_unsupportedNoteLink_title,
      content: '${l10n.pickerError_unsupportedNoteLink_content}\n${supportedList.join('\n')}',
    );
  }
}
