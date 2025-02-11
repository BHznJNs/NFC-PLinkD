import 'package:flutter/material.dart';
import 'package:nfc_plinkd/config.dart';

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
    final [theme, language, useBuiltinVideoPlayer, useBuiltinAudioPlayer] = await Future.wait([
      Configuration.theme.read(),
      Configuration.language.read(),
      Configuration.useBuiltinVideoPlayer.read(),
      Configuration.useBuiltinAudioPlayer.read(),
    ]);
    this.theme = theme as ConfigTheme;
    this.language = language as ConfigLanguage;
    this.useBuiltinVideoPlayer = useBuiltinVideoPlayer as bool;
    this.useBuiltinAudioPlayer = useBuiltinAudioPlayer as bool;
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: Container(
        width: 64,
        height: 64,
        margin: const EdgeInsets.only(bottom: 64),
        child: const CircularProgressIndicator.adaptive(),
      ));
    }

    setTheme(ConfigTheme newTheme) => setState(() => theme = newTheme);
    setUseBuiltinVideoPlayer() => setState(() => useBuiltinVideoPlayer = !useBuiltinVideoPlayer );
    setUseBuiltinAudioPlayer() => setState(() => useBuiltinAudioPlayer = !useBuiltinAudioPlayer );

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        _ThemeDropdownSelector(theme, setTheme),
        _SettingItem(
          title: 'Use built-in video player',
          description: 'Or use system default player',
          icon: Icons.movie,
          onTap: setUseBuiltinVideoPlayer,
          editor: Switch.adaptive(
            value: useBuiltinVideoPlayer,
            onChanged: (_) => setUseBuiltinVideoPlayer(),
          ),
        ),
        _SettingItem(
          title: 'Use built-in audio player',
          description: 'Or use system default player',
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
    final dropdownMenuItems = [
      DropdownMenuItem(
        value: ConfigTheme.light,
        child: Text('Light'),
      ),
      DropdownMenuItem(
        value: ConfigTheme.dark,
        child: Text('Dark'),
      ),
      DropdownMenuItem(
        value: ConfigTheme.system,
        child: Text('System'),
      ),
    ];
    return InkWell(
      onTap: () {},
      child: ListTile(
        title: Text('Application theme'),
        leading: Icon(Icons.brightness_4),
        trailing: DropdownButton(
          value: widget.theme,
          items: dropdownMenuItems,
          onChanged: (ConfigTheme? newTheme) {
            if (newTheme == null) return;
            widget.setTheme(newTheme);
          },
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      ),
    );
  }
}
