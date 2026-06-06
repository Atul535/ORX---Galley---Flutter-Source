import 'dart:async';
import 'package:flutter/material.dart';

class HoldToActionButton extends StatefulWidget {
  final VoidCallback onHeldFor10Seconds;
  final Widget child;

  const HoldToActionButton({
    Key? key,
    required this.onHeldFor10Seconds,
    required this.child,
  }) : super(key: key);

  @override
  State<HoldToActionButton> createState() => _HoldToActionButtonState();
}

class _HoldToActionButtonState extends State<HoldToActionButton> {
  Timer? _timer;
  bool _isHeld = false;

  void _handleTapDown(TapDownDetails details) {
    // Mark the button as “being held”
    _isHeld = true;

    // Start the 10s timer
    _timer = Timer(const Duration(seconds: 2), () {
      if (_isHeld) {
        // If the button is still being held after 10s
        widget.onHeldFor10Seconds();
      }
    });
  }

  void _handleTapUp(TapUpDetails details) {
    // As soon as the user lifts their finger, cancel the timer
    _cancelTimer();
  }

  void _handleTapCancel() {
    // If some other event cancels the gesture, cancel
    _cancelTimer();
  }

  void _cancelTimer() {
    _isHeld = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,   // Start timing
      onTapUp: _handleTapUp,       // End timing
      onTapCancel: _handleTapCancel,
      child: widget.child,
    );
  }
}
