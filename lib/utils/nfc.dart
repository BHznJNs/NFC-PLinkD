import 'dart:async';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_plinkd/utils/index.dart';

Future<Function> tryStartReadNFCData({
  required FutureOr Function(String) onRead,
  required void Function(Object)     onError,
}) async {
  await NfcManager.instance.startSession(
    onDiscovered: (NfcTag tag) async {
      final ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        onError(NFCError.NFCTagUnusable); return;
      }

      NdefMessage data;
      try {
        data = await ndef.read();
      } catch(_) {
        onError(NFCError.NFCTagEmpty); return;
      }

      if (data.records.isEmpty) {
        onError(NFCError.NFCTagEmpty); return;
      }
      final record = data.records[0];
      if (record.typeNameFormat != NdefTypeNameFormat.nfcWellknown) {
        onError(NFCError.NFCTagDataInvalid); return;
      }
      final uri = String.fromCharCodes(record.payload.sublist(1));
      try {
        await onRead(uri);
      } catch(e) {
        onError(e);
      }
    },
  );
  return () => NfcManager.instance.stopSession();
}

Future<void> tryWriteNFCData(List<NdefRecord> data) async {
  final completer = Completer<void>();
  await NfcManager.instance.startSession(
    onDiscovered: (NfcTag tag) async {
      final ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        completer.completeError(NFCError.NFCTagUnusable);
      } else {
        final message = NdefMessage(data);
        await ndef.write(message);
      }
      await NfcManager.instance.stopSession();
      completer.complete();
    },
  );
  return completer.future;
}

Future<bool> checkNFCAvailability() async {
  return await NfcManager.instance.isAvailable();
}

class NFCError extends CustomError {
  NFCError({required super.title, required super.content});

  // ignore: non_constant_identifier_names
  static final NFCFunctionDisabled = NFCError(
    title: 'NFC Function Disabled',
    content: 'Please enable the NFC function of your phone and retry.',
  );
  // ignore: non_constant_identifier_names
  static final NFCTagUnusable = NFCError(
    title: 'NFC Tag Unusable',
    content:
      'The approached NFC tag is not writable, '
      'it may be locked or does not support NDEF.',
  );
  // ignore: non_constant_identifier_names
  static final NFCTagDataInvalid = NFCError(
    title: 'NFC Tag Data Invalid',
    content:
      'The data read from the NFC tag is not in the expected format. '
      'It may not be a valid URI or not compatible with this application. '
      'Please ensure the tag contains the correct data type for this app.',
  );
  // ignore: non_constant_identifier_names
  static final NFCTagEmpty = NFCError(
    title: 'NFC Tag Empty',
    content: 'The approached NFC tag is empty.',
  );
}
