import 'package:flutter/material.dart';
import 'dart:async';

class InkWellDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelayedActivation;
  final int delayMilliseconds;

  const InkWellDetector({
    Key? key,
    required this.child,
    required this.onDelayedActivation,
    this.delayMilliseconds = 5, // Default to 50 milliseconds
  }) : super(key: key);

  @override
  State<InkWellDetector> createState() => _InkWellDetectorState();
}

class _InkWellDetectorState extends State<InkWellDetector> {
  Timer? _timer;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: _handleTapCancel,
      child: widget.child,
    );
  }

  void _handleTapDown() {
    // logDebug("TouchDetector", "onTapDown");
    _isPressed = true;
    _timer = Timer(Duration(milliseconds: widget.delayMilliseconds), () {
      if (_isPressed) {
        widget.onDelayedActivation();
      }
    });
  }

  void _handleTapUp() {
    // logDebug("TouchDetector", "onTapUp");
    _isPressed = false;
    _timer?.cancel();
  }

  void _handleTapCancel() {
    // logDebug("TouchDetector", "TapCancel");
    _isPressed = false;
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
