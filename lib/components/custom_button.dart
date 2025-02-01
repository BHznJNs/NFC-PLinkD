import 'package:flutter/material.dart';

class CircularElevatedIconButton extends StatefulWidget {
  const CircularElevatedIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  
  @override
  State<StatefulWidget> createState() => _CircularElevatedIconButtonState();
}

class _CircularElevatedIconButtonState extends State<CircularElevatedIconButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor,
        padding: EdgeInsets.all(24),
        elevation: 4,
      ),
      child: IconTheme(
        data: IconThemeData(
          color: widget.foregroundColor,
          size: 36,
        ),
        child: Icon(widget.icon),
      ),
    );
  }
}
