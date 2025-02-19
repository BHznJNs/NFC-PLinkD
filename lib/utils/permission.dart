import 'dart:io';

import 'package:nfc_plinkd/utils/android_native_call.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestRecordingPermission({
  Function? onPermanentlyDenied,
}) async {
  final status = await Permission.microphone.request();

  switch (status) {
    case PermissionStatus.denied: return false;
    case PermissionStatus.granted: return true;
    case PermissionStatus.permanentlyDenied:
      (onPermanentlyDenied ?? openAppSettings)();
      return false;
    default: return false;
  }
}

Future<bool> requestFsAccessingPermission({
  Function? onPermanentlyDenied,
}) async {
  late PermissionStatus status;
  if (Platform.isAndroid && (await getApiLevel()) >= 30) {
    // `manageExternalStorage` is required instead of `storage` for api >= 30 on Android
    status = await Permission.manageExternalStorage.request();
  } else {
    status = await Permission.storage.request();
  }

  switch (status) {
    case PermissionStatus.denied: return false;
    case PermissionStatus.granted: return true;
    case PermissionStatus.permanentlyDenied:
      (onPermanentlyDenied ?? openAppSettings)();
      return false;
    default: return false;
  }
}
