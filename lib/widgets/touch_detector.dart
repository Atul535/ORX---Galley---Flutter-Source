import 'package:flutter/material.dart';
import 'dart:async';

import '../utils/logger.dart';

class TouchDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelayedActivation;
  final int delayMilliseconds;
  final bool disabled;

  const TouchDetector({
    Key? key,
    required this.child,
    required this.onDelayedActivation,
    this.delayMilliseconds = 5, // Default to 50 milliseconds
    this.disabled = false,
  }) : super(key: key);

  @override
  State<TouchDetector> createState() => _TouchDetectorState();
}

class _TouchDetectorState extends State<TouchDetector> {
  Timer? _timer;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // behavior: HitTestBehavior.translucent,
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: _handleTapCancel,
      child: widget.child,
    );
  }

  void _handleTapDown() {
    logDebug("TouchDetector", "onTapDown");
    _isPressed = true;
    _timer = Timer(Duration(milliseconds: widget.delayMilliseconds), () {
      if (_isPressed && !widget.disabled) {
        logDebug("TouchDetector", "executing onDelayedActivation");
        widget.onDelayedActivation();
      }
    });
  }

  void _handleTapUp() {
    logDebug("TouchDetector", "onTapUp");
    _isPressed = false;
    _timer?.cancel();
  }

  void _handleTapCancel() {
    logDebug("TouchDetector", "TapCancel");
    _isPressed = false;
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
