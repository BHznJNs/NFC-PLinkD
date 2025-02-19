import 'package:flutter/material.dart';
import 'package:nfc_plinkd/config.dart';
import 'package:nfc_plinkd/l10n/app_localizations.dart';

class LanguageSettings extends StatelessWidget {
  const LanguageSettings(this.currentLanguage, {super.key});

  final ConfigLanguage currentLanguage;

  @override
  Widget build(BuildContext context) {
    void onLanguageSelected(ConfigLanguage? value) {
      Navigator.of(context).pop(value);
    }

    final l10n = S.of(context)!;
    final languageList = S.supportedLocales
      .map((locale) =>
        ConfigLanguage.fromLocale(locale)
      ).toSet();
    final languageListTiles = languageList.map((lang) {
      return RadioListTile<ConfigLanguage>.adaptive(
        title: Text(lang.toLanguageDisplayName()),
        value: lang,
        groupValue: currentLanguage,
        onChanged: onLanguageSelected,
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsPage_languageSettingsPage_title)),
      body: ListView(
        children: [
          RadioListTile<ConfigLanguage>.adaptive(
          title: Text(l10n.settingsPage_languageSettingsPage_useDevideLanguage),
          value: ConfigLanguage.system,
          groupValue: currentLanguage,
          onChanged: onLanguageSelected,
        ),
          ...languageListTiles,
        ],
      ),
    );
  }
}
