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

Future<bool> requestWritingPermission({
  Function? onPermanentlyDenied,
}) async {
  final status = await Permission.storage.request();

  switch (status) {
    case PermissionStatus.denied: return false;
    case PermissionStatus.granted: return true;
    case PermissionStatus.permanentlyDenied:
      (onPermanentlyDenied ?? openAppSettings)();
      return false;
    default: return false;
  }
}
