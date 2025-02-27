import 'package:flutter/material.dart';
import 'package:nfc_plinkd/components/link_edit_view.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:nfc_plinkd/l10n/app_localizations.dart';
import 'package:nfc_plinkd/models.dart';
import 'package:nfc_plinkd/utils/file.dart';
import 'package:nfc_plinkd/utils/index.dart';
import 'package:nfc_plinkd/utils/nfc.dart';

Future<LinkEditResult?> openLinkWithUri(BuildContext context, Uri uri) async {
  if (uri.host != linkHost || uri.pathSegments.isEmpty) {
    throw NFCError.NFCTagDataInvalid(context);
  }
  final targetId = uri.pathSegments[0];
  return await openLinkWithId(context, targetId);
}

Future<LinkEditResult?> openLinkWithId(BuildContext context, String id) async {
  final fetchResult = await DatabaseHelper.instance.fetchLink(id);
  if (fetchResult == null) {
    if (context.mounted) throw LinkError.DataNotFound(context);
    return null;
  }

  final (link, resources) = fetchResult;
  final basePath = await getBasePath(link.id);
  final resolvedResources = <ResourceModel>[];
  for (final resource in resources) {
    if ([ResourceType.webLink, ResourceType.note].contains(resource.type)) {
      resolvedResources.add(resource);
      continue;
    }
    resolvedResources.add(resource.copyWith(
      path: '$basePath/${resource.path}'
    ));
  }
  if (!context.mounted) return null;
  return await _openWithNavigator(context, link, resolvedResources);
}

Future<LinkEditResult?> _openWithNavigator(
  BuildContext context,
  LinkModel link,
  List<ResourceModel> resources,
) async {
  final l10n = S.of(context)!;
  return await Navigator.of(context).push(
    MaterialPageRoute(builder: (context) =>
      LinkEditView(
        link: link,
        title: l10n.editLinkPage_title,
        initialResources: resources,
      )
  ));
}