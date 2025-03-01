import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_plinkd/l10n/app_localizations.dart';
import 'package:nfc_plinkd/components/custom_textfield.dart';
import 'package:nfc_plinkd/utils/index.dart';

Future<void> showCustomError(BuildContext context, CustomError err) async {
  final l10n = S.of(context)!;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog.adaptive(
        title: Text(err.title),
        content: Text(err.content),
        actions: [TextButton(
          child: Text(l10n.custom_dialog_action_ok),
          onPressed: () => Navigator.of(context).pop(),
        )],
      );
    },
  );
}

Future<void> showUnexpectedError(BuildContext context, dynamic err) async {
  final l10n = S.of(context)!;
  final errMsg = err.toString();
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog.adaptive(
        title: Text(l10n.custom_dialog_unexpectedError_title),
        content: Text(errMsg),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: errMsg));
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(l10n.custom_dialog_action_copyErrMsg)
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.custom_dialog_action_ok),
          ),
        ],
      );
    },
  );
}

Future<void> showSuccessMsg(BuildContext context, { String? text }) async {
  final l10n = S.of(context)!;
  final successIcon = Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    alignment: Alignment.center,
    child: const Icon(
      Icons.check,
      size: 64,
    ),
  );
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog.adaptive(
        title: Text(l10n.custom_dialog_success_title),
        content: text == null
          ? successIcon
          : Text(text),
        actions: [TextButton(
          child: Text(l10n.custom_dialog_action_ok),
          onPressed: () => Navigator.of(context).pop(),
        )],
      );
    },
  );
}

Future<T?> showWaitingDialog<T>(BuildContext context, {
  required String title,
  required Future<T> Function() task,
  FutureOr<T?> Function()? onCanceled,
}) async {
  final l10n = S.of(context)!;
  final completer = Completer<T>();
  final cancelButton = TextButton(
    onPressed: () async {
      Navigator.of(context).pop();
      final result = await onCanceled?.call();
      completer.complete(result);
    },
    child: Text(l10n.custom_dialog_action_cancel),
  );
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog.adaptive(
      title: Text(title),
      content: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: const Center(
          child: CircularProgressIndicator.adaptive(),
        )
      ),
      actions: [cancelButton],
    ),
  );
  task().then((result) {
    if (context.mounted) Navigator.of(context).pop();
    completer.complete(result);
  }).catchError((e) {
    if (context.mounted) Navigator.of(context).pop();
    completer.completeError(e);
  });
  return completer.future;
}

Future<bool> showDeleteDialog(BuildContext context) async {
  final l10n = S.of(context)!;
  final cancelButton = TextButton(
    onPressed: () => Navigator.of(context).pop(false),
    child: Text(l10n.custom_dialog_action_cancel),
  );
  final deleteButton = TextButton(
    onPressed: () => Navigator.of(context).pop(true),
    child: Text(l10n.custom_dialog_action_delete, style: TextStyle(
      color: Theme.of(context).colorScheme.error
    )),
  );
  final result = await showDialog(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(l10n.custom_dialog_delete_title),
      content: Text(l10n.custom_dialog_delete_content),
      actions: [
        cancelButton,
        deleteButton,
      ],
    ),
  );
  if (result == null) return false;
  return result as bool;
}

// --- --- --- --- --- ---

class UriInputDialog extends StatefulWidget {
  const UriInputDialog({super.key});

  @override
  State<StatefulWidget> createState() => _UriInputDialogState();
}
class _UriInputDialogState extends State<UriInputDialog> {
  final TextEditingController uriController = TextEditingController();
  bool isUrlEmpty = true;
  String? errorText;

  Widget textFieldBuilder() => UriTextField(
    uriController,
    errorText: errorText,
    onChange: (text) =>
      setState(() {
        isUrlEmpty = text.isEmpty;
        errorText = null;
      }),
  );

  List<Widget> actionsBuilder() => [
    TextButton(
      onPressed: () => Navigator.of(context).pop(null),
      child: Text(S.of(context)!.custom_dialog_action_cancel),
    ),
    TextButton(
      onPressed: isUrlEmpty ? null : () {
        if (isValidUri(uriController.text)) {
          Navigator.of(context).pop(uriController.text);
        } else {
          setState(() =>
            errorText = S.of(context)!.general_invalidUrlMsg);
        }
      },
      child: Text(S.of(context)!.custom_dialog_action_confirm),
    )
  ];

  @override
  void dispose() {
    uriController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
    AlertDialog.adaptive(
      title: Text(S.of(context)!.custom_dialog_uri_weblink_title),
      content: textFieldBuilder(),
      actions: actionsBuilder(),
    );
}
