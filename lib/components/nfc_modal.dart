// ignore_for_file: use_build_context_synchronously

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

  _showNFCApprochingAlert(context);
  try {
    final uri = linkIdUriFactory(id);
    final dataToWrite = [NdefRecord.createUri(uri)];
    await tryWriteNFCData(dataToWrite);

    Navigator.of(context).pop();
    onSuccess?.call();
  } catch(e) {
    Navigator.of(context).pop();
    onError?.call(NFCError(
      title: 'NFC tag writing error',
      content: e.toString(),
    ));
  }
}

void _showNFCApprochingAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Approach an NFC Tag'),
        content: Container(
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: const Center(
            child: CircularProgressIndicator(),
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

void showNFCWritingSuccessMsg(BuildContext context, Function() onConfirm) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Succeed'),
        content: Container(
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Center(child: SizedBox(
            height: 40,
            child: Icon(
              Icons.check,
              size: 40,
            ),
          )
        )),
        actions: [TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
        )],
      );
    },
  );
}
