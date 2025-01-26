import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

const String scheme = 'org.nfc_plinkd.bhznjns';

Future<String> getImageHash(File imageFile) async {
  Uint8List imageBytes = await imageFile.readAsBytes();
  Digest digest = sha256.convert(imageBytes);
  String hash = digest.toString();
  return hash;
}
