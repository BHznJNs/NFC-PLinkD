import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String formatTimestampToLocalizedDate(BuildContext context, int timestampMilliseconds, {String? locale}) {
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);
  final currentLocale = locale ?? _getCurrentDeviceLocale(context);

  final formatter = switch (currentLocale) {
    String() when currentLocale.startsWith('zh') =>
      DateFormat.yMMMd('zh_CN'),
    String() when currentLocale.startsWith('en') =>
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
