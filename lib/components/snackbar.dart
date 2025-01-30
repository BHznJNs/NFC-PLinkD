import 'package:flutter/material.dart';

void showInfoSnackBar(BuildContext context, String info, {int duration = 2}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(info),
      duration: Duration(seconds: duration),
    ),
  );
}
