import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import '../can-helpers/can_manager.dart';
import '../model/command.dart';
import '../utils/logger.dart';

class RepeatingTimerProvider extends ChangeNotifier {
  Timer? _timer;
  final int initialDelay; // Delay before the first execution
  final int interval; // Interval between function calls
  final canManager = CanManager();

  RepeatingTimerProvider({this.initialDelay = 5, this.interval = 5});

  void startTimer() async {
    // Wait for the initial delay before the first execution
    await Future.delayed(Duration(seconds: initialDelay));

    // Execute the function for the first time
    _executeFunction();

    // Start periodic timer
    _timer = Timer.periodic(Duration(seconds: interval), (timer) {
      _executeFunction();
    });
  }

  void _executeFunction() {
    // This is the function to be called every interval seconds
    logDebug("RepeatingTimerProvider", "Function executed at: ${DateTime.now()}");

    List<Command> commands = [
      Command(id: 0, canIdBF: 255, data: [00, 04, 00, 01, 01]),
    ];
    if (Platform.isLinux) {
      canManager.sendCommand(commands: commands);
    }
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
}
