import 'package:flutter/material.dart';
import 'package:nfc_plinkd/components/custom_textfield.dart';
import 'package:nfc_plinkd/components/snackbar.dart';
import 'package:nfc_plinkd/l10n/app_localizations.dart';
import 'package:nfc_plinkd/utils/index.dart';
import 'package:nfc_plinkd/utils/media/picker.dart';
import 'package:nfc_plinkd/utils/open_uri.dart';

class NoteUriInputPage extends StatefulWidget {
  const NoteUriInputPage({super.key});

  @override
  State<StatefulWidget> createState() => _NoteUriInputPageState();
}

class _NoteUriInputPageState extends State<NoteUriInputPage> {
  final TextEditingController uriController = TextEditingController();
  bool isUrlEmpty = true;
  String? errorText;

  void confirm() {
    final l10n = S.of(context)!;
    if (!isValidUri(uriController.text)) {
      showInfoSnackBar(context, l10n.general_invalidUrlMsg);
      return;
    }
    Navigator.of(context).pop(uriController.text);
  }

  Widget noteItemBuilder(NoteAppItem itemData) {
    const iconSize = 40.0;
    final l10n = S.of(context)!;
    final itemContent = l10n.custom_dialog_uri_selectNoteInApp_title(itemData.name);
    return Card(
      child: ListTile(
        onTap: () => tryOpenNote(context, itemData.uri),
        leading: Image.asset(
          itemData.iconPath,
          width: iconSize,
          height: iconSize,
        ),
        title: Text(itemContent),
      ),
    );
  }

  @override
  void dispose() {
    uriController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final appBar = AppBar(
      title: Text(l10n.createPage_noteUriInputPage_title),
      actions: [IconButton(
        onPressed: !isUrlEmpty ? confirm : null,
        icon: const Icon(Icons.check)
      )],
    );
    final textField = UriTextField(
      uriController,
      autofocus: false,
      hintText: l10n.createPage_noteUriInputPage_hint,
      errorText: errorText,
      onChange: (text) =>
        setState(() {
          isUrlEmpty = text.isEmpty;
        }),
    );
    final noteAppsView = ListView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      children: supportedNoteAppList.map((item) =>
        noteItemBuilder(item)
      ).toList(),
    );
    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Expanded(child:
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              alignment: Alignment.center,
              child: textField,
            ),
          ),
          SizedBox(
            height: 204,
            child: noteAppsView,
          ),
        ],
      ),
    );
  }
}
