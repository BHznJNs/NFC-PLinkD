import 'package:flutter/material.dart';
import 'package:nfc_plinkd/components/custom_textfield.dart';
import 'package:nfc_plinkd/utils/index.dart';

void showAlert(
  BuildContext context,
  String title,
  String content,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog.adaptive(
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

void showSuccessMsg(BuildContext context, {
  String? text,
  Function()? onConfirm,
}) {
  final successIcon = Container(
    padding: EdgeInsets.symmetric(vertical: 16),
    alignment: Alignment.center,
    child: Icon(
      Icons.check,
      size: 64,
    ),
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog.adaptive(
        title: Text('Succeed'),
        icon: Icon(Icons.check),
        content: text == null
          ? successIcon
          : Text(text),
        actions: [TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
        )],
      );
    },
  );
}

Future<bool> showDeleteDialog(BuildContext context) async {
  final cancelButton = TextButton(
    onPressed: () => Navigator.of(context).pop(false),
    child: Text('Cancel'),
  );
  final deleteButton = TextButton(
    onPressed: () => Navigator.of(context).pop(true),
    child: Text('Delete', style: TextStyle(
      color: Theme.of(context).colorScheme.error
    )),
  );
  final result = await showDialog(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text('Confirm Deletion'),
      content: Text(
        'Are you sure you want to delete this item?'
        'This action cannot be undone, '
        'so please proceed with caution.'
      ),
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
    final textField = UrlTextField(
      textEditingController,
      errorMessage: errorMessage,
      onChange: (text) =>
        setState(() => isUrlEmpty = text.isEmpty),
    );
    final cancelButton = TextButton(
      onPressed: () => Navigator.of(context).pop(null),
      child: Text('Cancel'),
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
          setState(() => errorMessage = "Invalid URL");
        }
      },
      child: Text('Confirm'),
    );
    return AlertDialog.adaptive(
      title: Text('Website Link'),
      content: textField,
      actions: [
        cancelButton,
        confirmButton,
      ],
    );
  }
}
