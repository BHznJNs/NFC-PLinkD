import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String formatTimestampToLocalizedDate(BuildContext context, int timestampMilliseconds, {String? locale}) {
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);
  final currentLocale = locale ?? _getCurrentDeviceLocale(context); // Get locale, prioritize param

  final formatter = switch (currentLocale) {
    'zh_CN' => DateFormat.yMMMd('zh_CN'),
    String() when currentLocale.startsWith('en_') =>
      DateFormat('MMMM d, y', 'en_US'),
    _ => DateFormat.yMd(),
  };

  String formattedDate = formatter.format(dateTime);
  return formattedDate;
}

String formatTimestampToHourMinute(int timestampMilliseconds, {String? locale}) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);
  final formatter = DateFormat.Hm(locale);
  return formatter.format(dateTime);
}

String _getCurrentDeviceLocale(BuildContext context) {
  final deviceLocale = Localizations.localeOf(context);
  String localeString = deviceLocale.toString(); // e.g., 'en_US', 'zh_CN'
  return localeString;
}
