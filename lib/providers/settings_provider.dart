import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../managers/settings_manager.dart';
import '../utils/logger.dart';

class SettingsProvider with ChangeNotifier {
  String id = '';
  String hwId = '';
  String sn = '';
  String password = '';
  int _wallpaperTime = 0;
  int rotation = 0;
  int displayWidth = 0;
  int displayHeight = 0;
  int scaleFactorGuiApp = 1; // Default scale factor for GUI app
  int scaleFactorGuiAppLoader = 1; // Default scale factor for GUI app loader
  int acid = 0;
  Map<String, int> configVersion = {'major': 0, 'minor': 0};

  static const String _linuxVersionFilePath =
      '/home/nargouser/projects/app2/version.json';

  int get wallpaperTime => _wallpaperTime;

  set wallpaperTime(int value) {
    if (_wallpaperTime != value) {
      _wallpaperTime = value;
      notifyListeners();
    }
  }

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  /// Loads settings from persistent storage
  Future<void> loadSettings() async {
    
    final settings = await SettingsManager.loadSettings();

    id = settings['id'].toString();
    hwId = settings['hw'].toString();
    sn = settings['sn'].toString();
    password = settings['system_password0'].toString();
    _wallpaperTime = settings['wallpaper_time'] ?? 300;
    acid = int.tryParse(settings['ac'].toString()) ?? 0;

    // Ensure integer values are correctly parsed
    rotation = int.tryParse(settings['rotation'].toString()) ?? 0;
    displayWidth = int.tryParse(settings['display_width'].toString()) ?? 0;
    displayHeight = int.tryParse(settings['display_height'].toString()) ?? 0;
    scaleFactorGuiApp = int.tryParse(settings['scalefactor_gui_app'].toString()) ?? 1;
    scaleFactorGuiAppLoader = int.tryParse(settings['scalefactor_gui_apploader'].toString()) ?? 1;

    logInfo('SettingsProvider',
        'Loaded settings: id=$id, hwId=$hwId, sn=$sn, wallpaperTime=$_wallpaperTime, rotation=$rotation, displayWidth=$displayWidth, displayHeight=$displayHeight, acid=$acid');

    // Load version from version.json file
    await loadVersionFile();

    _isLoaded = true; // Mark as loaded
    notifyListeners();
  }

  // Add method to load version file
  Future<void> loadVersionFile() async {
    try {
      final file = await _versionFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final Map<String, dynamic> versionData = json.decode(contents);
        configVersion = {
          'major': versionData['major'] ?? 0,
          'minor': versionData['minor'] ?? 0,
        };
      }
    } catch (e) {
      logError('SettingsProvider', 'Error loading version file: $e');
      // Use default version if file doesn't exist or can't be read
      configVersion = {'major': 0, 'minor': 0};
    }
  }

  // Add method to update version file
  Future<void> updateVersionFile(Map<String, int> newVersion) async {
    try {
      final file = await _versionFile();
      await file.create(recursive: true);
      final versionJson = json.encode(newVersion);
      await file.writeAsString(versionJson);
      configVersion = Map.from(newVersion);
      notifyListeners();
    } catch (e) {
      logError('SettingsProvider', 'Error updating version file: $e');
    }
  }

  Future<File> _versionFile() async {
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      final directory = await getApplicationDocumentsDirectory();
      return File('${directory.path}${Platform.pathSeparator}version.json');
    }

    if (Platform.isWindows) {
      return File(
        '${Directory.current.path}${Platform.pathSeparator}projects'
        '${Platform.pathSeparator}app2${Platform.pathSeparator}version.json',
      );
    }

    return File(_linuxVersionFilePath);
  }

  /// Dynamically fetches a setting value
  String getValue(String key) {
    switch (key) {
      case 'id':
        return id;
      case 'hwId':
        return hwId;
      case 'sn':
        return sn;
      case 'password':
        return password;
      case 'wallpaperTime':
        return _wallpaperTime.toString();
      case 'rotation':
        return rotation.toString();
      case 'displayWidth':
        return displayWidth.toString();
      case 'displayHeight':
        return displayHeight.toString();
      case 'acid':
        return acid.toString();
      case 'configVersionMajor':
        return configVersion['major'].toString();
      case 'configVersionMinor':
        return configVersion['minor'].toString();
      case 'scaleFactorGuiApp':
        return scaleFactorGuiApp.toString();
      case 'scaleFactorGuiAppLoader':
        return scaleFactorGuiAppLoader.toString();
      default:
        return '';
    }
  }

  /// Updates multiple settings and persists changes
  Future<void> updateSettings(String newId, String newHwId, String newSn, int newRotation, int newDisplayWidth, int newDisplayHeight,
      {int newWallpaperTime = 0, int newAcid = 0}) async {
    final currentSettings = await SettingsManager.loadSettings();

    // Safe parsing with fallback to current values if parsing fails
    currentSettings['id'] = int.tryParse(newId) ?? int.tryParse(id) ?? 0;
    currentSettings['hw'] = int.tryParse(newHwId) ?? int.tryParse(hwId) ?? 0;
    currentSettings['sn'] = newSn;
    currentSettings['wallpaper_time'] = newWallpaperTime;
    currentSettings['rotation'] = newRotation;
    currentSettings['display_width'] = newDisplayWidth;
    currentSettings['display_height'] = newDisplayHeight;
    currentSettings['ac'] = newAcid; // Add this line

    await SettingsManager.saveSettings(currentSettings);

    // Update provider values
    id = newId;
    hwId = newHwId;
    sn = newSn;
    _wallpaperTime = newWallpaperTime;
    rotation = newRotation;
    displayWidth = newDisplayWidth;
    displayHeight = newDisplayHeight;
    acid = newAcid;

    notifyListeners();
  }

  /// Updates only the password field
  Future<void> updatePassword0(String newPassword) async {
    final currentSettings = await SettingsManager.loadSettings();
    currentSettings['system_password0'] = newPassword;
    await SettingsManager.saveSettings(currentSettings);

    password = newPassword;
    notifyListeners();
  }

  Future<void> updateRotation(int newRotation) async {
    final currentSettings = await SettingsManager.loadSettings();
    currentSettings['rotation'] = newRotation;
    await SettingsManager.saveSettings(currentSettings);

    rotation = newRotation;
    notifyListeners();
  }

  /// Updates only the AC (ACID) field
  Future<void> updateAcid(int newAcid) async {
    final currentSettings = await SettingsManager.loadSettings();
    currentSettings['ac'] = newAcid; // Use 'ac' not 'acid'
    await SettingsManager.saveSettings(currentSettings);

    acid = newAcid;
    notifyListeners();
  }

  /// U[pdates only the display width
  Future<void> updateDisplayWidth(int newDisplayWidth) async {
    final currentSettings = await SettingsManager.loadSettings();
    currentSettings['display_width'] = newDisplayWidth;
    await SettingsManager.saveSettings(currentSettings);

    displayWidth = newDisplayWidth;
    notifyListeners();
  }

  /// Updates only the display height
  Future<void> updateDisplayHeight(int newDisplayHeight) async {
    final currentSettings = await SettingsManager.loadSettings();
    currentSettings['display_height'] = newDisplayHeight;
    await SettingsManager.saveSettings(currentSettings);

    displayHeight = newDisplayHeight;
    notifyListeners();
  }

  /// Updates only the HW ID
  Future<void> updateHwId(int newHwId) async {
    final currentSettings = await SettingsManager.loadSettings();
    currentSettings['hw'] = newHwId;
    await SettingsManager.saveSettings(currentSettings);

    hwId = newHwId.toString();
    notifyListeners();
  }

  /// Updates only the Scale Factor for GUI App
  Future<void> updateScaleFactorGuiApp(int newScaleFactor) async {
    final currentSettings = await SettingsManager.loadSettings();
    currentSettings['scalefactor_gui_app'] = newScaleFactor;
    await SettingsManager.saveSettings(currentSettings);

    scaleFactorGuiApp = newScaleFactor;
    notifyListeners();
  }

  /// Updates only the Scale Factor for GUI App Loader
  Future<void> updateScaleFactorGuiAppLoader(int newScaleFactor) async {
    final currentSettings = await SettingsManager.loadSettings();
    currentSettings['scalefactor_gui_apploader'] = newScaleFactor;
    await SettingsManager.saveSettings(currentSettings);

    scaleFactorGuiAppLoader = newScaleFactor;
    notifyListeners();
  }
}
