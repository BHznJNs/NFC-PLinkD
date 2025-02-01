import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class CircularElevatedIconButton extends StatefulWidget {
  const CircularElevatedIconButton({
    super.key,
    this.mini = false,
    required this.onPressed,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final bool mini;
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
        padding: EdgeInsets.all(widget.mini ? 20 : 24),
        elevation: 4,
      ),
      child: IconTheme(
        data: IconThemeData(
          color: widget.foregroundColor,
          size: widget.mini ? 32 : 36,
        ),
        child: Icon(widget.icon),
      ),
    );
  }
}

class EnhancedSpeedDial extends StatefulWidget {
  const EnhancedSpeedDial(this.speedDialChildren, {
    super.key,
    this.onDialRootPressed,
  });

  final List<SpeedDialChild> speedDialChildren;
  final Function(bool)? onDialRootPressed;

  @override
  State<StatefulWidget> createState() => _PageSpeedDialState();
}
class _PageSpeedDialState extends State<EnhancedSpeedDial>
    with SingleTickerProviderStateMixin {
  late void Function() toggleSpeedDial;
  late AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  late Animation<double> scale = Tween<double>(begin: 1.0, end: 0.0).animate(
    CurvedAnimation(parent: controller, curve: Curves.easeInOut),
  );
  late Animation<double> scaleRev = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: controller, curve: Curves.easeInOut),
  );
  bool isSpeedDialOpen = false;

  @override
  Widget build(BuildContext context) {
    final speedDial = SpeedDial(
      heroTag: 'list-view-fab',
      animationDuration: const Duration(milliseconds: 200),
      renderOverlay: false,
      icon: Icons.add,
      onOpen: () => setState(() {
        isSpeedDialOpen = true;
        controller.forward();
      }),
      onClose: () => setState(() {
        isSpeedDialOpen = false;
        controller.reverse();
      }),
      dialRoot: (context, open, toggleChildren) {
        toggleSpeedDial = toggleChildren;
        return ScaleTransition(
          scale: scale,
          child: FloatingActionButton(
            heroTag: 'add',
            onPressed: () {
              toggleChildren();
              widget.onDialRootPressed?.call(isSpeedDialOpen);
            },
            child: Icon(Icons.add),
          ),
        );
      },
      childPadding: const EdgeInsets.all(4),
      spacing: 16,
      spaceBetweenChildren: 4,
      children: widget.speedDialChildren,
    );

    return Stack(
      children: [
        Positioned(
          right: 8,
          bottom: 8,
          child: speedDial,
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: ScaleTransition(
            scale: scaleRev,
            child: FloatingActionButton.extended(
              heroTag: 'Add-a-photo',
              onPressed: () {
                toggleSpeedDial();
                widget.onDialRootPressed?.call(isSpeedDialOpen);
              },
              label: Text('Add a Photo'),
              icon: Icon(Icons.add_a_photo),
            ),
          ),
        )
      ]
    );
  }
}

