import 'package:flutter/material.dart';
import 'package:nfc_plinkd/components/link_edit_view.dart';
import 'package:nfc_plinkd/utils/media/picker.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  static final itemsData = [
    _CreateItemData(
      icon: Icons.photo_camera,
      title: 'Take a photo',
      onTap: (context) =>
        takePhoto(context).then((resources) {
          if (!context.mounted) return;
          linkEditViewBuilder(context, resources);
        })
    ),
    _CreateItemData(
      icon: Icons.videocam,
      title: 'Record a Video',
      onTap: (context) =>
        recordVideo(context).then((resources) {
          if (!context.mounted) return;
          linkEditViewBuilder(context, resources);
        })
    ),
    _CreateItemData(
      icon: Icons.mic,
      title: 'Record a Audio',
      onTap: (context) =>
        recordAudio(context).then((resources) {
          if (!context.mounted) return;
          linkEditViewBuilder(context, resources);
        })
    ),
    _CreateItemData(
      icon: Icons.link,
      title: 'Attach a Web Link',
      onTap: (context) {
        inputWebLink(context).then((resources) {
          if (!context.mounted) return;
          linkEditViewBuilder(context, resources);
        });
      }
    ),
  ];

  static void linkEditViewBuilder(BuildContext context, ResourcePickerResult resources) {
    if (resources.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) =>
        LinkEditView(
          title: 'Create a Link',
          resourcePickerResult: resources,
        )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
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
