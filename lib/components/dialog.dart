import 'package:flutter/material.dart';
import 'package:nfc_plinkd/utils/index.dart';

void showAlert(
  BuildContext context,
  String title,
  String content,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(
          child: const Text('Ok'),
          onPressed: () => Navigator.of(context).pop(),
        )],
      );
    },
  );
}

void showCustomError(BuildContext context, CustomError err) {
  showAlert(context, err.title, err.content);
}
