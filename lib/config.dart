import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Configuration {
  static final _prefs = SharedPreferencesAsync(options: SharedPreferencesOptions());
  static final theme = _ConfigurationEnumItem(_prefs, 'theme', ConfigTheme.fromName);
  static final language = _ConfigurationEnumItem(_prefs, 'language', ConfigLanguage.fromName);
  static final useBuiltinVideoPlayer = _ConfigurationBoolItem(_prefs, 'use_buildin_video_player');
  static final useBuiltinAudioPlayer = _ConfigurationBoolItem(_prefs, 'use_buildin_audio_player');

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
  const _ConfigurationItem(this.prefs, this.key);
  final SharedPreferencesAsync prefs;
  final String key;

  Future<void> save(T value);
  Future<T?> read();
}
class _ConfigurationBoolItem extends _ConfigurationItem<bool> {
  _ConfigurationBoolItem(super.prefs, super.key);

  @override Future<void> save(bool value) async {
    await prefs.setBool(key, value);
  }
  @override Future<bool?> read() async {
    return await prefs.getBool(key);
  }
}
class _ConfigurationEnumItem<T extends Enum> extends _ConfigurationItem<Enum> {
  const _ConfigurationEnumItem(super.prefs, super.key, this.creator);

  final T Function(String) creator;

  @override Future<void> save(Enum value) async {
    await prefs.setString(key, value.name);
  }
  @override Future<T?> read() async {
    final res = await prefs.getString(key);
    if (res == null) return null;
    return creator(res);
  }
}

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
  traditionalChinese,
  english,
  system;

  static ConfigLanguage fromName(String name) {
    return ConfigLanguage.values.byName(name);
  }
}

class UnexpectedConfigurationItemTypeException implements Exception {
  const UnexpectedConfigurationItemTypeException({
    this.message = 'Unexpected configuration item type.',
  });
  final String message;
}
