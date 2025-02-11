import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nfc_plinkd/components/link_edit_view.dart';
import 'package:nfc_plinkd/utils/media/picker.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  static void linkEditViewBuilder(BuildContext context, ResourcePickerResult resources) {
    if (resources.isEmpty) return;
    final l10n = S.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) =>
        LinkEditView(
          title: l10n.createPage_title,
          resourcePickerResult: resources,
        )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final itemsData = [
      _CreateItemData(
        icon: Icons.photo_camera,
        title: l10n.createPage_image,
        onTap: (context) =>
          takePhoto(context).then((resources) {
            if (!context.mounted) return;
            linkEditViewBuilder(context, resources);
          })
      ),
      _CreateItemData(
        icon: Icons.videocam,
        title: l10n.createPage_video,
        onTap: (context) =>
          recordVideo(context).then((resources) {
            if (!context.mounted) return;
            linkEditViewBuilder(context, resources);
          })
      ),
      _CreateItemData(
        icon: Icons.mic,
        title: l10n.createPage_audio,
        onTap: (context) =>
          recordAudio(context).then((resources) {
            if (!context.mounted) return;
            linkEditViewBuilder(context, resources);
          })
      ),
      _CreateItemData(
        icon: Icons.link,
        title: l10n.createPage_weblink,
        onTap: (context) {
          inputWebLink(context).then((resources) {
            if (!context.mounted) return;
            linkEditViewBuilder(context, resources);
          });
        }
      ),
    ];

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      children: itemsData.map((data) =>
        _CreateItem.fromData(data)
      ).toList(),
    );
  }
}

class _CreateItem extends StatelessWidget {
  _CreateItem.fromData(_CreateItemData data)
      : icon = data.icon,
        title = data.title,
        onTap = data.onTap;

  final IconData icon;
  final String title;
  final void Function(BuildContext) onTap; 

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => onTap(context),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, size: 28),
          title: Text(title, style: const TextStyle(fontSize: 18)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }
}

class _CreateItemData {
  const _CreateItemData({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final void Function(BuildContext) onTap; 
}
