import 'package:flutter/material.dart';
import 'package:nfc_plinkd/l10n/app_localizations.dart';
import 'package:nfc_plinkd/components/custom_textfield.dart';
import 'package:nfc_plinkd/utils/index.dart';

Future<void> showAlert(BuildContext context, String title, String content) async {
  final l10n = S.of(context)!;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog.adaptive(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(
          child: Text(l10n.custom_dialog_action_ok),
          onPressed: () => Navigator.of(context).pop(),
        )],
      );
    },
  );
}

Future<void> showCustomError(BuildContext context, CustomError err) async {
  await showAlert(context, err.title, err.content);
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

Future<void> showNFCApproachingAlert(BuildContext context) async {
  final l10n = S.of(context)!;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog.adaptive(
        title: Text(l10n.custom_dialog_nfc_approach_title),
        content: Container(
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: const Center(
            child: CircularProgressIndicator.adaptive(),
          )
        ),
        actions: [TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.custom_dialog_action_cancel)
        )],
      );
    },
  );
}

// --- --- --- --- --- ---

class WebLinkInputDialog extends StatefulWidget {
  const WebLinkInputDialog({super.key});

  @override
  State<StatefulWidget> createState() => _WebLinkInputDialogState();
}
class _WebLinkInputDialogState extends State<WebLinkInputDialog> {
  final TextEditingController textEditingController = TextEditingController();
  bool isUrlEmpty = true;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final textField = UrlTextField(
      textEditingController,
      errorMessage: errorMessage,
      onChange: (text) =>
        setState(() => isUrlEmpty = text.isEmpty),
    );
    final cancelButton = TextButton(
      onPressed: () => Navigator.of(context).pop(null),
      child: Text(l10n.custom_dialog_action_cancel),
    );
    final confirmButton = TextButton(
      onPressed: isUrlEmpty ? null : () {
        final uri = Uri.tryParse(textEditingController.text);
        final isValidUri = uri != null
          && uri.scheme.isNotEmpty
          && uri.host.isNotEmpty;
        if (isValidUri) {
          Navigator.of(context).pop(textEditingController.text);
        } else {
          setState(() =>
            errorMessage = l10n.custom_dialog_weblink_invalidUrlMsg);
        }
      },
      child: Text(l10n.custom_dialog_action_confirm),
    );
    return AlertDialog.adaptive(
      title: Text(l10n.custom_dialog_weblink_title),
      content: textField,
      actions: [
        cancelButton,
        confirmButton,
      ],
    );
  }
}
