import 'dart:io';

import 'package:flutter/material.dart';

/// Central asset path configuration.
/// Edit the two constants below to match your deployment layout.
///
/// Linux layout:
///   /home/nargouser/projects/
///     app/   ← Flutter binary
///     cfg2/  ← all graphics
///
/// Windows layout:
///   C:\Projects\
///     app\   ← Flutter binary
///     cfg2\  ← all graphics
class AssetConfig {
  AssetConfig._();

  // ─── Edit these two paths ────────────────────────────────────────────────

  /// Root folder for all graphics on Linux.
  static const String _linuxBase = '/home/nargouser/projects/cfg2';

  /// Root folder for all graphics on Windows.
  static const String _windowsBase = r'./cfg2';

  // ─────────────────────────────────────────────────────────────────────────

  /// Resolved base path for the current platform.
  static String get base =>
      Platform.isWindows ? _windowsBase : _linuxBase;

  static bool get usesBundledAssets => Platform.isAndroid || Platform.isIOS;

  /// Converts a relative path like 'icons/icon_home.png'
  /// or legacy 'assets/icons/icon_home.png' into the full filesystem path.
  ///
  /// Example:
  ///   AssetConfig.img('icons/icon_home.png')
  ///   → '/home/nargouser/projects/cfg2/icons/icon_home.png'
  static String img(String relativePath) {
    final clean = _cleanPath(relativePath);
    return Platform.isWindows
        ? '$base\\${clean.replaceAll('/', '\\')}'
        : '$base/$clean';
  }

  static ImageProvider imageProvider(String relativePath) {
    final clean = _cleanPath(relativePath);

    if (usesBundledAssets) {
      return AssetImage('cfg2/$clean');
    }

    return FileImage(File(img(clean)));
  }

  static String _cleanPath(String relativePath) {
    return relativePath.startsWith('assets/')
        ? relativePath.substring('assets/'.length)
        : relativePath;
  }
}
