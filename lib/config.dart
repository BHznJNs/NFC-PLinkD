import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Configuration {
  static final _prefs = SharedPreferencesAsync(options: SharedPreferencesOptions());
  static final theme = _ConfigurationEnumItem(_prefs, 'theme', ConfigTheme.fromName, ConfigTheme.system);
  static final language = _ConfigurationEnumItem(_prefs, 'language', ConfigLanguage.fromName, ConfigLanguage.system);
  static final useBuiltinVideoPlayer = _ConfigurationBoolItem(_prefs, 'use_buildin_video_player', false);
  static final useBuiltinAudioPlayer = _ConfigurationBoolItem(_prefs, 'use_buildin_audio_player', true);

  static Future<bool> get isFirstLaunch async {
    final res = await _prefs.getBool('is_first_launch') ?? true;
    if (res) await _prefs.setBool('is_first_launch', false);
    return res;
  }

  static Future<void> init() async {
    await Future.wait([
      Configuration.theme.save(ConfigTheme.system),
      Configuration.language.save(ConfigLanguage.system),
      Configuration.useBuiltinVideoPlayer.save(false),
      Configuration.useBuiltinAudioPlayer.save(true),
    ]);
  }

  static Future<List<dynamic>> readAll() async {
    return Future.wait([
      Configuration.theme.read(),
      Configuration.language.read(),
      Configuration.useBuiltinVideoPlayer.read(),
      Configuration.useBuiltinAudioPlayer.read(),
    ]);
  }
}

abstract class _ConfigurationItem<T> {
  const _ConfigurationItem(this.prefs, this.key, this.defaultValue);
  final SharedPreferencesAsync prefs;
  final String key;
  final T defaultValue;

  Future<void> save(T value);
  Future<T> read(); // return stored value or defaultValue
}
class _ConfigurationBoolItem extends _ConfigurationItem<bool> {
  _ConfigurationBoolItem(super.prefs, super.key, super.defaultValue);

  @override Future<void> save(bool value) async {
    await prefs.setBool(key, value);
  }
  @override Future<bool> read() async {
    return await prefs.getBool(key) ?? defaultValue;
  }
}
class _ConfigurationEnumItem<T extends Enum> extends _ConfigurationItem<Enum> {
  const _ConfigurationEnumItem(super.prefs, super.key, this.creator, super.defaultValue);

  final T Function(String) creator;

  @override Future<void> save(Enum value) async {
    await prefs.setString(key, value.name);
  }
  @override Future<T> read() async {
    final res = await prefs.getString(key);
    if (res == null) return defaultValue as T;
    return creator(res);
  }
}

// --- --- --- --- --- ---

enum ConfigTheme {
  dark,
  light,
  system;

  static ConfigTheme fromName(String name) {
    return ConfigTheme.values.byName(name);
  }
  ThemeMode toThemeMode() {
    switch (this) {
      case ConfigTheme.dark  : return ThemeMode.dark;
      case ConfigTheme.light : return ThemeMode.light;
      case ConfigTheme.system: return ThemeMode.system;
    }
  }
}
enum ConfigLanguage {
  simplifiedChinese,
  // traditionalChinese,
  english,
  system;

  static ConfigLanguage fromName(String name) {
    return ConfigLanguage.values.byName(name);
  }

  static ConfigLanguage fromLocale(Locale locale) {
    if (locale.languageCode == 'en') {
      return ConfigLanguage.english;
    } else
    if (locale.languageCode == 'zh') {
      return ConfigLanguage.simplifiedChinese;
    }
    throw Exception('Unresolved locale: $locale');
  }

  Locale? toLocale() {
    switch (this) {
      case ConfigLanguage.simplifiedChinese: return Locale('zh', 'CN');
      case ConfigLanguage.english: return Locale('en');
      case ConfigLanguage.system: return null;
    }
  }

  String toLanguageDisplayName() {
    switch (this) {
      case ConfigLanguage.simplifiedChinese: return '简体中文';
      case ConfigLanguage.english: return 'English';
      default: throw Exception('Unresolved locale: $this');
    }
  }
}

class UnexpectedConfigurationItemTypeException implements Exception {
  const UnexpectedConfigurationItemTypeException({
    this.message = 'Unexpected configuration item type.',
  });
  final String message;
}
