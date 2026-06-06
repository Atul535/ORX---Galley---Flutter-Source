import 'package:flutter/material.dart';

import '../model/time_service.dart';

class ActivityDetector extends StatelessWidget {
  final Widget? child;
  final bool shouldNavigate;



  const ActivityDetector(
      {Key? key,
      this.child,
      this.shouldNavigate = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

   void handleUserInteraction([_]) {
      TimerService.of(context).reset();
    }

    void handleTimerNotifier() {
      if (TimerService.of(context).screenSaverActive == false) {
        TimerService.of(context).screenSaverActive = true;
        Navigator.of(context).pushNamed(TimerService.of(context).screenSaverRoute);
      }
    }

    TimerService.of(context).start();
    if (shouldNavigate) {
      TimerService.of(context).addListener(handleTimerNotifier);
    }

    return GestureDetector(
      onTap: handleUserInteraction,
      onPanDown: handleUserInteraction,
      onScaleStart: handleUserInteraction,
      child: child,
    );
  }
}
