import 'package:flutter/material.dart';
import 'package:nfc_plinkd/config.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._theme);

  ConfigTheme? _theme;
  ConfigTheme get theme => _theme ?? ConfigTheme.system;

  Future<void> change(ConfigTheme newTheme) async {
    _theme = newTheme;
    notifyListeners();
  }
}
