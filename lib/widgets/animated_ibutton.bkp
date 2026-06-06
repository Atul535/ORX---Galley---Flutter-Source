import 'package:flutter/material.dart';

class AnimatedIButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final double angle;
  final Duration duration;
  final Icon icon;
  final bool shouldAnimate;
  final EdgeInsets padding;

  const AnimatedIButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.angle = 20.0,
    this.duration = const Duration(seconds: 1),
    this.shouldAnimate = false,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  State<AnimatedIButton> createState() => _AnimatedIButtonState();
}

class _AnimatedIButtonState extends State<AnimatedIButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Only start animating if instructed
    if (widget.shouldAnimate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedIButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle animation state changes properly
    if (widget.shouldAnimate != oldWidget.shouldAnimate) {
      if (widget.shouldAnimate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        // Reset to initial position
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: widget.padding,
      icon: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Transform.rotate(
            angle: widget.shouldAnimate ? (_controller.value - 0.5) * widget.angle * (3.14159265358979323846 / 180) : 0,
            child: widget.icon,
          );
        },
      ),
      onPressed: widget.onPressed,
    );
  }
}
