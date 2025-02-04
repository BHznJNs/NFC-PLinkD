import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UrlTextField extends StatefulWidget {
  const UrlTextField(this._controller, {
    super.key,
    this.errorMessage,
    this.onChange,
  });

  final TextEditingController _controller;
  final String? errorMessage;
  final Function(String)? onChange;

  @override
  State<StatefulWidget> createState() => _UrlTextFieldState();
}

class _UrlTextFieldState extends State<UrlTextField> {
  bool isTextFieldEmpty = true;

  void pasteText() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null) {
      widget._controller.text = data.text ?? '';
    }
  }
  void clearText() {
    widget._controller.clear();
  }
  void onTextChanged() {
    widget.onChange?.call(widget._controller.text);
    setState(() =>
      isTextFieldEmpty = widget._controller.text.isEmpty);
  }

  @override
  void initState() {
    super.initState();
    widget._controller.addListener(onTextChanged);
  }

  @override
  void dispose() {
    widget._controller.removeListener(onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: 1,
      autofocus: true,
      controller: widget._controller,
      decoration: InputDecoration(
        errorText: widget.errorMessage,
        suffixIcon: isTextFieldEmpty
          ? IconButton(
              onPressed: pasteText,
              icon: const Icon(Icons.paste),
            )
          : IconButton(
              onPressed: clearText,
              icon: const Icon(Icons.clear),
            ),
      ),
    );
  }
}
