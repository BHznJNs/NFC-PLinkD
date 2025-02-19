import 'package:flutter/material.dart';
import 'package:nfc_plinkd/config.dart';

class LanguageProvider extends ChangeNotifier {
  LanguageProvider(this._language);

  ConfigLanguage? _language;
  ConfigLanguage get language => _language ?? ConfigLanguage.system;

  Future<void> change(ConfigLanguage newLanguage) async {
    _language = newLanguage;
    notifyListeners();
  }
}
