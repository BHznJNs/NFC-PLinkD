import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_plinkd/components/snackbar.dart';
import 'package:nfc_plinkd/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<bool> openWebLink(String url) async {
  return launchUrlString(url);
}

Future<bool?> tryOpenNote(BuildContext context, String uri) async {
  late bool result;
  try {
    result = await launchUrlString(uri);
  } on PlatformException {
    if (context.mounted) {
      final l10n = S.of(context)!;
      showInfoSnackBar(context, l10n.general_targetAppNotFoundMsg);
    }
    return null;
  }
  return result;
}
