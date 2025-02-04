import 'dart:async';

import 'package:flutter/services.dart';

const videoUtilChannel = MethodChannel('org.nfc_plinkd.bhznjns/video_util');
Future<int?> getVideoRotation(String videoPath) async {
  try {
    final int rotation = await videoUtilChannel.invokeMethod('getVideoRotation', {
      'videoPath': videoPath,
    });
    return rotation;
  } on PlatformException catch (_) {
    return null;
  }
}
