import 'dart:isolate';
import 'dart:async';
import 'package:dart_periphery/dart_periphery.dart';
import 'logger.dart';

class PwmManager {
  static bool isEnabled = true;
  static bool _isInitialized = false;
  static Isolate? _pwmIsolate;
  static SendPort? _sendPort;
  static ReceivePort _receivePort = ReceivePort();
  static int minDurationMs = 100;
  // static int periodNs = 10000000;
  // static int dutyCycleNs = 10000000;
  static int periodNs = 100000;
  static int dutyCycleNs = 100000;

  static Future<void> initialize() async {
    logDebug('PWM Manager', 'Initializing PWM Manager');

    if (_isInitialized) {
      logError('PWM Manager', 'PWM Manager is already initialized');
      return;
    } // Prevent reinitialization
    _isInitialized = true;

    _pwmIsolate = await Isolate.spawn(_pwmHandler, _receivePort.sendPort);
    _receivePort.listen((data) {
      if (data is SendPort) {
        _sendPort = data;
      } else {
        // Handle other messages from the isolate, if needed
      }
    });
  }

  static void disable() {
    isEnabled = false;
    _sendPort?.send(['stop']);
  }

  static void enable() {
    isEnabled = true;
  }

  static void vibrate(int duration, int periods) {
    if (isEnabled) _sendPort?.send(['vibrate', duration, periods]);
  }

  static void startVibration() {
    if (isEnabled) _sendPort?.send(['start']);
  }

  static void startPeriodicVibration(int onDuration, int offDuration) {
    if (onDuration > 0 && offDuration > 0) {
      if (isEnabled)
        _sendPort?.send(['startPeriodicVibration', onDuration, offDuration]);
    } else if (onDuration > 0) {
      logError('PWM Manager',
          'startPeriodicVibration - Only On duration greater than 0, starting vibration immediately, vibration needs to be stopped by stopVibration()');
      if (isEnabled) _sendPort?.send(['start']);
    } else {
      logError('PWM Manager',
          'startPeriodicVibration - On & Off duration must be greater than 0');
    }
  }

  static void stopVibration() {
    _sendPort?.send(['stop']);
  }

  static void setMinDurationMs(int duration) {
    _sendPort?.send(['setMinDuration', duration]);
  }

  static void setPeriodNs(int periodNs) {
    _sendPort?.send(['setPeriodNs', periodNs]);
  }

  static void setDutyCycleNs(int dutyCycleNs) {
    _sendPort?.send(['setDutyCycleNs', dutyCycleNs]);
  }

  static void dispose() {
    _pwmIsolate?.kill(priority: Isolate.immediate);
    _pwmIsolate = null;
  }

  static void _pwmHandler(SendPort mainSendPort) {
    ReceivePort isolateReceivePort = ReceivePort();
    mainSendPort.send(isolateReceivePort.sendPort);
    PWM? pwm;
    Timer? timer;
    Timer? offTimer;

    int minDuration = 100;
    bool vibrationEnabled = true;

    try {
      pwm = PWM(0, 0); // Setup your PWM hardware here
      pwm.setPeriodNs(100000);
      pwm.setDutyCycleNs(100000);
    } catch (e) {
      logError('PWM Manager', 'Failed to initialize PWM: $e');
    }

    isolateReceivePort.listen((message) {
      vibrationEnabled = false;

      switch (message[0]) {
        case 'vibrate':
          logDebug("PwmIsolate", "vibrate received");
          int requestedDurationMs = message[1];
          int periods =
              message[2]; // Intensity could be used to adjust PWM settings
          timer?.cancel(); // Cancel any existing timer
          offTimer?.cancel(); // Cancel any existing offTimer
          pwm?.disable(); // Ensure it's off before starting
          if (periods > 0) {
            int duration = requestedDurationMs >= minDuration
                ? requestedDurationMs
                : minDuration;
            pwm?.enable(); // Turn on PWM immediately
            logDebug("PwmIsolate", "vibrate enabled");
            int currentPeriod = 1;
            timer = Timer.periodic(Duration(milliseconds: duration), (timer) {
              if (currentPeriod < periods * 2) {
                if (pwm!.getEnabled()) {
                  pwm.disable();
                  logDebug("PwmIsolate", "vibrate disabled");
                } else {
                  pwm.enable();
                  logDebug("PwmIsolate", "vibrate enabled");
                }
                currentPeriod++;
              } else {
                pwm?.disable(); // Ensure it's turned off after the last period
                logDebug("PwmIsolate", "vibrate disabled");
                timer.cancel(); // Stop the timer
              }
            });
          }
          break;
        case 'startPeriodicVibration':
          int onDurationMs = message[1];
          int offDurationMs = message[2];
          vibrationEnabled = true;

          pwm?.enable(); // Start vibrating immediately

          // Start the periodic timer immediately but first turn off after the onDuration
          timer = Timer.periodic(
              Duration(milliseconds: onDurationMs + offDurationMs), (Timer t) {
            if (!vibrationEnabled) {
              t.cancel();
              pwm?.disable();
            } else {
              pwm?.enable();
              // Schedule the off timer right after the onDuration
              offTimer
                  ?.cancel(); // Cancel previous offTimer to manage overlapping timers
              offTimer = Timer(Duration(milliseconds: onDurationMs), () {
                pwm?.disable();
              });
            }
          });

          // Schedule the first off timer to manage the first cycle properly
          offTimer = Timer(Duration(milliseconds: onDurationMs), () {
            pwm?.disable();
          });
          break;
        case 'start':
          pwm?.enable();
          break;
        case 'stop':
          timer?.cancel();
          offTimer?.cancel();
          pwm?.disable();
          break;
        case 'setMinDuration':
          minDuration = message[1];
          break;
        case 'setPeriodNs':
          int periodNs = message[1];
          pwm?.setPeriodNs(periodNs);
          break;
        case 'setDutyCycleNs':
          int dutyCycleNs = message[1];
          pwm?.setDutyCycleNs(dutyCycleNs);
          break;
      }
    });
  }
}
