import 'package:flutter/material.dart';

import '../model/time_service.dart';

class TimerServiceProvider extends InheritedWidget {
  final TimerService service;
  const TimerServiceProvider(
      {Key? key, required this.service, required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(TimerServiceProvider oldWidget) =>
      service != oldWidget.service;
}
