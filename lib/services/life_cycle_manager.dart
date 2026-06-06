import 'package:flutter/material.dart';

import '../utils/pwm_manager.dart';

class LifecycleManager extends StatefulWidget {
  final Widget child;

  const LifecycleManager({Key? key, required this.child}) : super(key: key);

  @override
  State<LifecycleManager> createState() => _LifecycleManagerState();
}

class _LifecycleManagerState extends State<LifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PwmManager.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    PwmManager.dispose(); // Dispose of the PWM Manager
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is resumed
    } else if (state == AppLifecycleState.paused) {
      // App is paused
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
