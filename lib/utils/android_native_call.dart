import 'dart:async';

import 'package:flutter/services.dart';

const channel = MethodChannel('org.nfc_plinkd.bhznjns/channel');

Future<int> getApiLevel() async {
  try {
    return await channel.invokeMethod('getApiLevel') as int;
  } on PlatformException catch (_) {
    throw Exception('Called on non-Android platform.');
  }
}

Future<int?> getVideoRotation(String videoPath) async {
  try {
    final rotation = await channel.invokeMethod('getVideoRotation', {
      'videoPath': videoPath,
    }) as int;
    return rotation;
  } on PlatformException catch (_) {
    return null;
  }
}
