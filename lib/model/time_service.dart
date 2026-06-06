import 'dart:async';

import 'package:flutter/material.dart';
import '../providers/timer_service_provider.dart';
import '../screens/screen_saver_blank.dart';

class TimerService extends ChangeNotifier {
  Timer? _timer;
  bool screenSaverActive = false;
  bool isDisabled = false;
  String _screenSaverRoute = ScreenSaverBlank.routeName;

  int get currentDuation => _currentDuration;
  final int _currentDuration = 120;

  bool get isRunning => _timer != null;

  void _showScreenSaver(Timer timer) {
    if (!isDisabled) {
      stop();
      notifyListeners();
    }
  }

  void start() {
    if (_timer != null) return;
    if (!isDisabled) {
      _timer =
          Timer.periodic(Duration(seconds: _currentDuration), _showScreenSaver);
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void disable() {
    stop();
    isDisabled = true;
  }

  void enable() {
    isDisabled = false;
    reset();
  }

  void reset() {
    stop();
    start();
  }

  String get screenSaverRoute {
    return _screenSaverRoute;
  }

  set screenSaverRoute(String route) {
    _screenSaverRoute = route;
  }

  static TimerService of(BuildContext context) {
    final TimerServiceProvider? timerProvider =
        context.dependOnInheritedWidgetOfExactType<TimerServiceProvider>();
    return timerProvider!.service;
  }
}
