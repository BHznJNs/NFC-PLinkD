import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_plinkd/utils/index.dart';
import 'package:nfc_plinkd/utils/nfc.dart';

Future<void> showNFCWritingModal(BuildContext context, String id, {
  void Function()?            onSuccess,
  void Function(CustomError)? onError,
}) async {
  Uri linkIdUriFactory(String id) {
    final uriString = '$appScheme://$linkHost/$id';
    return Uri.parse(uriString);
  }

  if (!await checkNFCAvailability()) {
    onError?.call(NFCError.NFCFunctionDisabled);
    return;
  }

  if (context.mounted) _showNFCApprochingAlert(context);
  try {
    final uri = linkIdUriFactory(id);
    final dataToWrite = [NdefRecord.createUri(uri)];
    await tryWriteNFCData(dataToWrite);

    if (context.mounted) Navigator.of(context).pop();
    onSuccess?.call();
  } on NFCError catch (e, _) {
    if (context.mounted) Navigator.of(context).pop();
    onError?.call(e);
  }
}

void _showNFCApprochingAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog.adaptive(
        title: const Text('Approach an NFC Tag'),
        content: Container(
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: const Center(
            child: CircularProgressIndicator.adaptive(),
          )
        ),
        actions: [TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel')
        )],
      );
    },
  );
}
