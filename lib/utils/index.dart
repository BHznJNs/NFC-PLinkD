import 'package:flutter/material.dart';
import 'package:nfc_plinkd/components/custom_dialog.dart';

const String appScheme = 'nfcplinkd';
const String linkHost = 'link';

Uri linkIdUriFactory(String id) =>
  Uri(scheme: appScheme, host: linkHost, path: id);

bool isValidUri(String uriString) {
  final uri = Uri.tryParse(uriString);
  final isValidUri = uri != null
    && uri.scheme.isNotEmpty
    && uri.host.isNotEmpty;
  return isValidUri;
}

class CustomError extends Error {
  CustomError({required this.title, required this.content});
  final String title;
  final String content;
}

Future<void> resolveDynamicError(BuildContext context, e) async {
  if (e is CustomError) {
    await showCustomError(context, e);
  } else {
    await showUnexpectedError(context, e);
  }
}
