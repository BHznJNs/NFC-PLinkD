import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FocusOutTextField extends StatefulWidget {
  const FocusOutTextField({
    super.key,
    this.maxLines,
    this.minLines,
    this.autofocus=false,
    this.controller,
    this.decoration,
  });

  final int? maxLines;
  final int? minLines;
  final bool autofocus;
  final TextEditingController? controller;
  final InputDecoration? decoration;

  @override
  State<StatefulWidget> createState() => _FocusOutTextFieldState();
}
class _FocusOutTextFieldState extends State<FocusOutTextField> {
  final focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      autofocus: widget.autofocus,
      controller: widget.controller,
      decoration: widget.decoration,
      focusNode: focusNode,
      onTapOutside: (_) => focusNode.unfocus(),
    );
  }
}

class UriTextField extends StatefulWidget {
  const UriTextField(this._controller, {
    super.key,
    this.autofocus,
    this.hintText,
    this.errorText,
    this.onChange,
  });

  final bool? autofocus;
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
    return FocusOutTextField(
      maxLines: 1,
      autofocus: widget.autofocus ?? true,
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
