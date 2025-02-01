import 'package:permission_handler/permission_handler.dart';

Future<void> requestRecordingPermission({
  required Function onGranted,
  required Function onDenied,
  Function? onPermanentlyDenied,
}) async {
  PermissionStatus status = await Permission.microphone.request();

  if (status.isGranted) {
    onGranted();
  } else if (status.isDenied) {
    onDenied();
  } else if (status.isPermanentlyDenied) {
    (onPermanentlyDenied ?? openAppSettings)();
  }
}
