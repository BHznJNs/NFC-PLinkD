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
  final successIcon = Center(child: Icon(
    Icons.check,
    size: 64,
  ));
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog.adaptive(
        title: Text('Succeed'),
        content: Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (text != null)
                Text(text),
              successIcon,
            ],
          ),
        ),
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
