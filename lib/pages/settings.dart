import 'package:flutter/material.dart';
import 'package:nfc_plinkd/config.dart';
import 'package:nfc_plinkd/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isLoading = true;
  late ConfigTheme theme;
  late ConfigLanguage language;
  late bool useBuiltinVideoPlayer;
  late bool useBuiltinAudioPlayer;

  Future<void> loadSettings() async {
    final [theme, language, useBuiltinVideoPlayer, useBuiltinAudioPlayer] = await Configuration.readAll();
    this.theme = theme as ConfigTheme;
    this.language = language as ConfigLanguage;
    this.useBuiltinVideoPlayer = useBuiltinVideoPlayer as bool;
    this.useBuiltinAudioPlayer = useBuiltinAudioPlayer as bool;
    setState(() => isLoading = false);
  }

  Future<void> setTheme(ConfigTheme newTheme) async {
    await Configuration.theme.save(newTheme);
    setState(() => theme = newTheme);
  }
  Future<void> setUseBuiltinVideoPlayer() async {
    await Configuration.useBuiltinVideoPlayer.save(!useBuiltinVideoPlayer);
    setState(() => useBuiltinVideoPlayer = !useBuiltinVideoPlayer );
  }
  Future<void> setUseBuiltinAudioPlayer() async {
    await Configuration.useBuiltinAudioPlayer.save(!useBuiltinAudioPlayer);
    setState(() => useBuiltinAudioPlayer = !useBuiltinAudioPlayer );
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    if (isLoading) {
      return Center(child: Container(
        width: 64,
        height: 64,
        margin: const EdgeInsets.only(bottom: 64),
        child: const CircularProgressIndicator.adaptive(),
      ));
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        _ThemeDropdownSelector(theme, setTheme),
        _SettingItem(
          title: l10n.settingsPage_useBuiltinVideoPlayer_title,
          description: l10n.settingsPage_useBuiltinVideoPlayer_description,
          icon: Icons.movie,
          onTap: setUseBuiltinVideoPlayer,
          editor: Switch.adaptive(
            value: useBuiltinVideoPlayer,
            onChanged: (_) => setUseBuiltinVideoPlayer(),
          ),
        ),
        _SettingItem(
          title: l10n.settingsPage_useBuiltinAudioPlayer_title,
          description: l10n.settingsPage_useBuiltinAudioPlayer_description,
          icon: Icons.music_note,
          onTap: setUseBuiltinAudioPlayer,
          editor: Switch.adaptive(
            value: useBuiltinAudioPlayer,
            onChanged: (_) => setUseBuiltinAudioPlayer(),
          ),
        ),
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.title,
    required this.icon,
    required this.editor,
    required this.onTap,
    this.description,
  });

  final String title;
  final String? description;
  final IconData icon;
  final VoidCallback onTap;
  final Widget editor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        title: Text(title),
        subtitle: description != null
          ? Text(description!)
          : null,
        leading: Icon(icon),
        trailing: editor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      ),
    );
  }
}

class _ThemeDropdownSelector extends StatefulWidget {
  const _ThemeDropdownSelector(this.theme, this.setTheme);

  final ConfigTheme theme;
  final Function(ConfigTheme) setTheme;

  @override
  State<StatefulWidget> createState() => _ThemeDropdownSelectorState();
}
class _ThemeDropdownSelectorState extends State<_ThemeDropdownSelector> {
  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final dropdownMenuItems = [
      DropdownMenuItem(
        value: ConfigTheme.light,
        child: Text(l10n.settingsPage_applicationTheme_light),
      ),
      DropdownMenuItem(
        value: ConfigTheme.dark,
        child: Text(l10n.settingsPage_applicationTheme_dark),
      ),
      DropdownMenuItem(
        value: ConfigTheme.system,
        child: Text(l10n.settingsPage_applicationTheme_system),
      ),
    ];
    return _SettingItem(
      title: l10n.settingsPage_applicationTheme_title,
      icon: Icons.brightness_4,
      editor: DropdownButton(
        value: widget.theme,
        items: dropdownMenuItems,
        onChanged: (ConfigTheme? newTheme) {
          if (newTheme == null) return;
          widget.setTheme(newTheme);
        },
      ),
      onTap: () {},
    );
  }
}
