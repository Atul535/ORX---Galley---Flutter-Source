import 'dart:ffi' as ffi;
import 'dart:io';

import '../utils/logger.dart';

class GpioService {
  static final GpioService _instance = GpioService._internal();
  factory GpioService() => _instance;

  // Changed from 'late' to nullable — prevents LateInitializationError
  // when libwiringPi.so is not available (e.g. on RPi5)
  ffi.DynamicLibrary? _wiringPi;
  void Function()? _wiringPiSetup;
  void Function(int, int)? _pinMode;
  void Function(int, int)? _digitalWrite;
  int Function(int)? _digitalRead;
  void Function(int, int)? _pwmWrite;
  int Function(int, int, int)? _softPwmCreate;
  void Function(int, int)? _softPwmWrite;

  bool _initialized = false;

  // Define relay pins (WiringPi numbering)
  final List<int> _relayPins = [24, 28, 29, 3];

  // Define Fan pin
  final int _fanPin = 21;

  GpioService._internal() {
    if (Platform.isWindows) {
      logError('GPIOService', "GPIO Service is not supported on Windows");
      return;
    }
    _initNativeLibrary();
    _initializeRelays();
    _initializePWM();
    _initializeFanPin();
  }

  void _initNativeLibrary() {
    try {
      _wiringPi = ffi.DynamicLibrary.open("libwiringPi.so");

      _wiringPiSetup =
          _wiringPi!.lookupFunction<ffi.Void Function(), void Function()>(
              'wiringPiSetup');

      _pinMode = _wiringPi!.lookupFunction<
          ffi.Void Function(ffi.Int32, ffi.Int32),
          void Function(int, int)>('pinMode');

      _digitalWrite = _wiringPi!.lookupFunction<
          ffi.Void Function(ffi.Int32, ffi.Int32),
          void Function(int, int)>('digitalWrite');

      _digitalRead = _wiringPi!.lookupFunction<ffi.Int32 Function(ffi.Int32),
          int Function(int)>('digitalRead');

      _pwmWrite = _wiringPi!.lookupFunction<
          ffi.Void Function(ffi.Int32, ffi.Int32),
          void Function(int, int)>('pwmWrite');

      _softPwmCreate = _wiringPi!.lookupFunction<
          ffi.Int32 Function(ffi.Int32, ffi.Int32, ffi.Int32),
          int Function(int, int, int)>('softPwmCreate');

      _softPwmWrite = _wiringPi!.lookupFunction<
          ffi.Void Function(ffi.Int32, ffi.Int32),
          void Function(int, int)>('softPwmWrite');

      _wiringPiSetup!();
      _initialized = true;

      logDebug('GPIOService',
          "GPIO Service Initialized (WiringPi Pin Mode) and PWM Support");
    } catch (e) {
      // Log error but DO NOT crash — app continues without GPIO
      logError('GPIOService',
          "Error initializing GPIO or PWM: $e. GPIO disabled, app will continue.");
      _initialized = false;
    }
  }

  void _initializeRelays() {
    // Guard added — if not initialized, skip silently
    if (!_initialized) return;
    for (int pin in _relayPins) {
      setupPin(pin, true);
      setPinLow(pin);
    }
    logDebug('GPIOService', "✅ Relay Pins Initialized: $_relayPins");
  }

  void _initializeFanPin() {
    // Guard added — if not initialized, skip silently
    if (!_initialized) return;
    setupPin(_fanPin, true);
    setPinLow(_fanPin);
    logDebug('GPIOService', "✅ Fan Pin Initialized: $_fanPin");
  }

  void _initializePWM() {
    // Guard added — if not initialized, skip silently
    // This was the root cause of LateInitializationError crash on RPi5
    if (!_initialized) {
      logError('GPIOService',
          "PWM initialization skipped: GPIO not initialized (libwiringPi.so not available).");
      return;
    }
    _pinMode!(1, 2); // 2 = PWM_OUTPUT
    setHardwarePWM(1, 1024);
    logDebug('GPIOService',
        "✅ HW PWM Initialized on WiringPi pin 1 (GPIO 18 / RPI pin 12)");
  }

  int? _getPinFromIndex(int index) {
    if (index < 1 || index > _relayPins.length) {
      logError('GPIOService', "❌ Invalid relay index: $index");
      return null;
    }
    return _relayPins[index - 1];
  }

  void setupPin(int pin, bool isOutput) {
    if (!_initialized) {
      logError('GPIOService', "GPIO setup failed: wiringPi is not initialized!");
      return;
    }
    logDebug('GPIOService',
        "Setting up WiringPi Pin $pin as ${isOutput ? 'OUTPUT' : 'INPUT'}");
    _pinMode!(pin, isOutput ? 1 : 0);
  }

  void relayOn(int index) {
    int? pin = _getPinFromIndex(index);
    if (pin == null || !_initialized) return;
    logDebug('GPIOService', "Turning Relay $index (Pin $pin) ON");
    _digitalWrite!(pin, 1);
  }

  void relayOff(int index) {
    int? pin = _getPinFromIndex(index);
    if (pin == null || !_initialized) return;
    logDebug('GPIOService', "Turning Relay $index (Pin $pin) OFF");
    _digitalWrite!(pin, 0);
  }

  void fanOn() {
    if (!_initialized) return;
    logDebug('GPIOService', "Turning Fan ON (Pin $_fanPin)");
    _digitalWrite!(_fanPin, 1);
  }

  void fanOff() {
    if (!_initialized) return;
    logDebug('GPIOService', "Turning Fan OFF (Pin $_fanPin)");
    _digitalWrite!(_fanPin, 0);
  }

  void toggleRelay(int index) {
    int? pin = _getPinFromIndex(index);
    if (pin == null || !_initialized) return;
    int currentState = _digitalRead!(pin);
    logDebug('GPIOService',
        "Toggling Relay $index (Pin $pin). Current state: $currentState");
    _digitalWrite!(pin, currentState == 1 ? 0 : 1);
  }

  bool isRelayOn(int index) {
    int? pin = _getPinFromIndex(index);
    if (pin == null || !_initialized) return false;
    int state = _digitalRead!(pin);
    logDebug('GPIOService',
        "Reading Relay $index (Pin $pin): ${state == 1 ? 'ON' : 'OFF'}");
    return state == 1;
  }

  Map<int, bool> getAllRelayStates() {
    if (!_initialized) return {};
    Map<int, bool> states = {};
    for (int i = 0; i < _relayPins.length; i++) {
      states[i + 1] = isRelayOn(i + 1);
    }
    return states;
  }

  void setPinHigh(int pin) {
    if (!_initialized) return;
    logDebug('GPIOService', "Setting WiringPi Pin $pin HIGH");
    _digitalWrite!(pin, 1);
  }

  void setPinLow(int pin) {
    if (!_initialized) return;
    logDebug('GPIOService', "Setting WiringPi Pin $pin LOW");
    _digitalWrite!(pin, 0);
  }

  void setHardwarePWM(int pin, int value) {
    if (!_initialized) {
      logError('GPIOService', "Failed to set Hardware PWM: wiringPi not ready");
      return;
    }
    logDebug('GPIOService', "Setting Hardware PWM on Pin $pin to $value");
    _pwmWrite!(pin, value);
  }

  bool setupSoftwarePWM(int pin, int initialValue, int range) {
    if (!_initialized) return false;
    int result = _softPwmCreate!(pin, initialValue, range);
    if (result == 0) {
      logDebug('GPIOService',
          "Software PWM initialized on Pin $pin with range $range");
      return true;
    } else {
      logError('GPIOService', "Failed to initialize Software PWM on Pin $pin");
      return false;
    }
  }

  void setSoftwarePWM(int pin, int value) {
    if (!_initialized) return;
    logDebug('GPIOService', "Setting Software PWM on Pin $pin to $value");
    _softPwmWrite!(pin, value);
  }
}