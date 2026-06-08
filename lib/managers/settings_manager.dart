import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../utils/logger.dart';

class SettingsManager {
  static const String _linuxSettingsPath =
      '/home/nargouser/projects/settings/settings.json';

  static final Map<String, dynamic> _defaultSettings = {
    'id': 0,
    'sn': '00000000',
    'hw': 0,
    'system_password0': 'password',
    'acid': 0,
    'rotation': 0,
    'display_width': 0,
    'display_height': 0,
    'wallpaper_time': 300,
  };

  /// Loads the settings from the JSON file or creates a new one with default values
  static Future<Map<String, dynamic>> loadSettings() async {
    try {
      final file = await _settingsFile();
      logDebug('SettingsManager', 'settingsPath: ${file.path}');

      if (await file.exists()) {
        // If file exists, read and decode it
        final contents = await file.readAsString();
        return jsonDecode(contents);
      } else {
        // If the file doesn't exist, create it with default values
        await saveSettings(_defaultSettings);
        return _defaultSettings;
      }
    } catch (e) {
      logError('SettingsManager', 'Error loading settings: $e');
      throw Exception('Error loading settings: $e');
    }
  }

  /// Saves the provided settings to the JSON file
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final file = await _settingsFile();
      await file.create(
          recursive: true); // Ensure the directory structure exists
      await file.writeAsString(jsonEncode(settings));
    } catch (e) {
      throw Exception('Error saving settings: $e');
    }
  }

  static Future<File> _settingsFile() async {
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      final directory = await getApplicationDocumentsDirectory();
      return File('${directory.path}${Platform.pathSeparator}settings.json');
    }

    if (Platform.isWindows) {
      return File(
        '${Directory.current.path}${Platform.pathSeparator}projects'
        '${Platform.pathSeparator}settings${Platform.pathSeparator}settings.json',
      );
    }

    return File(_linuxSettingsPath);
  }
}
