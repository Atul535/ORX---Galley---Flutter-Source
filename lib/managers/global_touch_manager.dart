
import 'dart:async';

import '../utils/logger.dart';

class GlobalTouchManager {
  static bool _isTouchActive = false;
  static Timer? _cooldownTimer;
  static Timer? _safetyResetTimer;

  /// Configurable cooldown duration after release
  static const Duration touchCooldown = Duration(milliseconds: 150);
  static const Duration safetyResetTime = Duration(milliseconds: 500);

  /// Check if any button is currently active
  static bool canTouch() => !_isTouchActive;

  /// Activate touch (preventing other touches)
  static void activateTouch() {
    
    logDebug("GlobalTouchManager", "activateTouch");
    _isTouchActive = true;

    // Safety reset in case of unintentional lock
    _safetyResetTimer?.cancel();
    _safetyResetTimer = Timer(safetyResetTime, () {
      _isTouchActive = false;
      logDebug("GlobalTouchManager", "Touch safety reset");
    });
  }

  /// Deactivate and enforce cooldown
  static void releaseTouch() {
    if (!_isTouchActive) return; // Ignore if already inactive
    logDebug("GlobalTouchManager", "resettingTouch");

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(touchCooldown, () {
      _isTouchActive = false; // Allow new touches after cooldown
      logDebug("GlobalTouchManager", "Touch cooldown reset");
    });

    // Also cancel safety reset since touch is released properly
    _safetyResetTimer?.cancel();
  }
}
