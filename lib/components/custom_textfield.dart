import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UriTextField extends StatefulWidget {
  const UriTextField(this._controller, {
    super.key,
    this.hintText,
    this.errorText,
    this.onChange,
  });

  final TextEditingController _controller;
  final String? hintText;
  final String? errorText;
  final Function(String)? onChange;

  @override
  State<StatefulWidget> createState() => _UriTextFieldState();
}

class _UriTextFieldState extends State<UriTextField> {
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
        hintText: widget.hintText,
        errorText: widget.errorText,
        suffixIcon: isTextFieldEmpty
          ? IconButton(
              onPressed: pasteText,
              icon: const Icon(Icons.paste),
            )
          : IconButton(
              onPressed: clearText,
              icon: const Icon(Icons.delete),
            ),
      ),
    );
  }
}
