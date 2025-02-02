import 'package:flutter/material.dart';
import 'package:nfc_plinkd/pages/create/link_edit_view.dart';
import 'package:nfc_plinkd/utils/media.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  static final itemsData = [
    _CreateItemData(
      icon: Icons.photo_camera,
      title: 'Take a photo',
      onTap: (context) =>
        takePhoto(context).then((resources) =>
          // ignore: use_build_context_synchronously
          linkEditViewBuilder(context, resources))
    ),
    _CreateItemData(
      icon: Icons.videocam,
      title: 'Record a Video',
      onTap: (context) =>
        recordVideo(context).then((resources) =>
          // ignore: use_build_context_synchronously
          linkEditViewBuilder(context, resources))
    ),
    _CreateItemData(
      icon: Icons.mic,
      title: 'Record a Audio',
      onTap: (context) =>
        recordAudio(context).then((resources) =>
          // ignore: use_build_context_synchronously
          linkEditViewBuilder(context, resources))
    ),
    _CreateItemData(
      icon: Icons.link,
      title: 'Attach a Web Link',
      onTap: (context) {
        // 
      }
    ),
  ];

  static void linkEditViewBuilder(BuildContext context, ResourcePickerResult resources) {
    if (resources.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) =>
        LinkEditView(initialResources: resources)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
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
      )
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
