import 'dart:io';

import 'package:flutter/material.dart';

import '../config/config_items.dart';
import '../model/bargraph_model.dart';
import '../model/command.dart';
import '../model/command_location.dart';
import '../model/command_match_result.dart';
import '../model/generic_selection.dart';
import '../utils/logger.dart';

String idGenerator() {
  final now = DateTime.now();
  return now.microsecondsSinceEpoch.toString();
}

// Method to calculate the luminance of a color
double getLuminance(Color color) {
  // Convert the color to RGB
  double r = color.red / 255.0;
  double g = color.green / 255.0;
  double b = color.blue / 255.0;

  // Apply the luminance formula
  double luminance = 0.299 * r + 0.587 * g + 0.114 * b;
  return luminance;
}

List<int> prepareString(String input, int maxLength) {
  List<int> bytes = input.codeUnits;
  if (bytes.length > maxLength) {
    return bytes.sublist(0, maxLength); // Truncate if too long
  } else {
    // If shorter, pad with zeros up to maxLength
    return bytes + List<int>.filled(maxLength - bytes.length, 0);
  }
}

String enumToString(Enum enumValue) {
  return enumValue.name.toString().split('.').last.replaceAll('_', ' ').toUpperCase();
}

/// Each config Command is associated with an objectId + stateId + the command itself.
Map<int, List<CommandLocation>> buildReverseLookup(
  Map<String, List<dynamic>> configItems,
) {
  final reverse = <int, List<CommandLocation>>{};

  for (var itemList in configItems.values) {
    for (var item in itemList) {
      if (item is GenericSelection) {
        item.states.forEach((stateId, stateObj) {
          if (stateObj.commands.isNotEmpty && stateObj.track == true) {
            final msgType = stateObj.commands[0].data[1];
            reverse.putIfAbsent(msgType, () => []);
            reverse[msgType]!.add(CommandLocation(item.id, stateId, stateObj.commands[0]));
          }
        });
      } else if (item is BargraphModel) {
        item.states.forEach((stateId, stateObj) {
          if (stateObj.commands.isNotEmpty) {
            final msgType = stateObj.commands[0].data[1];
            reverse.putIfAbsent(msgType, () => []);
            reverse[msgType]!.add(CommandLocation(item.id, stateId, stateObj.commands[0]));
          }
        });
      }
    }
  }

  return reverse;
}

/// Compare `receivedData` to `configData` using `matchOps`.
/// - `receivedData` can be longer; that’s okay, as long as it has at least
///   as many bytes as `configData`.
/// - We only compare up to `configData.length`.
/// - For each byte, apply the operation defined in `matchOps[i]`.
// bool commandMatches(
//   List<int> receivedData,
//   List<int> configData,
//   List<int> matchOps,
// ) {
//   // If the received data is shorter than config data, no match possible.
//   if (receivedData.length < configData.length) {
//     logDebug('CommandMatches', 'commandMatches: receivedData is shorter than configData');
//     return false;
//   }

//   // If the matchOps is shorter than configData, pad it with 0x00 (ignore)
//   final extendedOps = List<int>.from(matchOps);
//   while (extendedOps.length < configData.length) {
//     logDebug('CommandMatches', 'commandMatches: extendedOps is shorter than configData, padding data');
//     extendedOps.add(0x00); // default to ignore
//   }

//   // Compare each byte in configData to the corresponding byte in receivedData
//   for (int i = 0; i < configData.length; i++) {
//     final rule = extendedOps[i];
//     final rcvByte = receivedData[i];
//     final cfgByte = configData[i];

//     String matchStatus = "MATCHED"; // Default status

//     logDebug('CommandMatches', 'Byte[$i]: Rule: 0x${rule.toRadixString(2)}, Rcv: 0x${rcvByte.toRadixString(16)}, Cfg: 0x${cfgByte.toRadixString(16)}');

//     switch (rule) {
//       case 0x00: // IGNORE
//         matchStatus = "IGNORING";
//         logDebug('CommandMatches', 'Byte[$i]: $matchStatus');
//         continue; // Just skip

//       case 0x01: // EXACT MATCH
//         if (rcvByte != cfgByte) {
//           matchStatus = "NOT MATCHED";
//           logDebug('CommandMatches', 'Byte[$i]: $matchStatus - Mismatch found, stopping.');
//           return false;
//         }
//         break;

//       case 0x02: // BIT-SUBSET
//         // If config byte is 0, we treat that as trivially matching
//         if (cfgByte != 0 && (rcvByte & cfgByte) != cfgByte) {
//           matchStatus = "NOT MATCHED";
//           logDebug('CommandMatches', 'Byte[$i]: $matchStatus - Mismatch found, stopping.');
//           return false;
//         }
//         break;

//       case 0x03: // EXACT or BROADCAST
//         if (cfgByte == 0xFF && rcvByte != 0xFF) {
//           matchStatus = "NOT MATCHED";
//           logDebug('CommandMatches', 'Byte[$i]: $matchStatus - Mismatch found, stopping.');
//           return false;
//         }
//         if (cfgByte != 0xFF && rcvByte != cfgByte) {
//           matchStatus = "NOT MATCHED";
//           logDebug('CommandMatches', 'Byte[$i]: $matchStatus - Mismatch found, stopping.');
//           return false;
//         }
//         break;

//       case 0x04: // EXACT MATCH or MATCH if cfgByte is 0x00 and store
//         if (rcvByte == cfgByte || cfgByte == 0x00) {
//           matchStatus = "MATCHED";
//         } else {
//           matchStatus = "NOT MATCHED";
//           logDebug('CommandMatches', 'Byte[$i]: $matchStatus - Mismatch found, stopping.');
//           return false;
//         }
//         break;

//       default:
//         logDebug('CommandMatches', 'Byte[$i]: UNRECOGNIZED RULE - FAIL');
//         return false;
//     }

//     logDebug('CommandMatches', 'Byte[$i]: $matchStatus');
//   }

//   return true;
// }

CommandMatchResult commandMatches(
  List<int> receivedData,
  List<int> configData,
  List<int> matchOps,
) {
  // Create a list to store bytes when using rule 0x04
  List<int> storedBytes = [];

  // If the received data is shorter than config data, no match possible.
  if (receivedData.length < configData.length) {
    logDebug('CommandMatches', 'commandMatches: receivedData is shorter than configData');
    return CommandMatchResult(false, storedBytes);
  }

  // If the matchOps is shorter than configData, pad it with 0x00 (ignore)
  final extendedOps = List<int>.from(matchOps);
  while (extendedOps.length < configData.length) {
    logDebug('CommandMatches', 'commandMatches: extendedOps is shorter than configData, padding data');
    extendedOps.add(0x00); // default to ignore
  }

  // Compare each byte in configData to the corresponding byte in receivedData
  for (int i = 0; i < configData.length; i++) {
    final rule = extendedOps[i];
    final rcvByte = receivedData[i];
    final cfgByte = configData[i];

    String matchStatus = "MATCHED"; // Default status

    logDebug('CommandMatches', 'Byte[$i]: Rule: 0x${rule.toRadixString(2)}, Rcv: 0x${rcvByte.toRadixString(16)}, Cfg: 0x${cfgByte.toRadixString(16)}');

    switch (rule) {
      case 0x00: // IGNORE
        matchStatus = "IGNORING";
        logDebug('CommandMatches', 'Byte[$i]: $matchStatus');
        continue; // Just skip

      case 0x01: // EXACT MATCH
        if (rcvByte != cfgByte) {
          matchStatus = "NOT MATCHED";
          logDebug('CommandMatches', 'Byte[$i]: $matchStatus - Mismatch found, stopping.');
          return CommandMatchResult(false, storedBytes);
        }
        break;

      case 0x02: // BIT-SUBSET
        // If config byte is 0, we treat that as trivially matching
        if (cfgByte != 0 && (rcvByte & cfgByte) != cfgByte) {
          matchStatus = "NOT MATCHED";
          logDebug('CommandMatches', 'Byte[$i]: $matchStatus - Mismatch found, stopping.');
          return CommandMatchResult(false, storedBytes);
        }
        break;

      case 0x03: // EXACT or BROADCAST
        if (cfgByte == 0xFF && rcvByte != 0xFF) {
          matchStatus = "NOT MATCHED";
          logDebug('CommandMatches', 'Byte[$i]: $matchStatus - Mismatch found, stopping.');
          return CommandMatchResult(false, storedBytes);
        }
        if (cfgByte != 0xFF && rcvByte != cfgByte) {
          matchStatus = "NOT MATCHED";
          logDebug('CommandMatches', 'Byte[$i]: $matchStatus - Mismatch found, stopping.');
          return CommandMatchResult(false, storedBytes);
        }
        break;

      case 0x04: // EXACT MATCH or MATCH if cfgByte is 0x00 and store
        if (rcvByte == cfgByte || cfgByte == 0x00) {
          matchStatus = "MATCHED";
          // Store the byte if configByte is 0x00 (this is the "store" part)
          if (cfgByte == 0x00) {
            storedBytes.add(rcvByte);
            logDebug('CommandMatches', 'Storing byte[$i]: 0x${rcvByte.toRadixString(16)}');
          }
        } else {
          matchStatus = "NOT MATCHED";
          logDebug('CommandMatches', 'Byte[$i]: $matchStatus - Mismatch found, stopping.');
          return CommandMatchResult(false, storedBytes);
        }
        break;

      default:
        logDebug('CommandMatches', 'Byte[$i]: UNRECOGNIZED RULE - FAIL');
        return CommandMatchResult(false, storedBytes);
    }

    logDebug('CommandMatches', 'Byte[$i]: $matchStatus');
  }

  return CommandMatchResult(true, storedBytes);
}

/// Returns a lookup so we can quickly do:
///   Command? cmd = commandLookup[id]?[stateId];
/// and get the first command if it exists.
Map<String, Map<int, Command>> buildCommandLookup(
  Map<String, List<dynamic>> configItems,
) {
  final Map<String, Map<int, Command>> commandLookup = {};

  // Iterate over each key in configItems (e.g. 'home', 'video', 'lights')
  configItems.forEach((_, itemList) {
    for (var item in itemList) {
      // Handle GenericSelection
      if (item is GenericSelection) {
        item.states.forEach((stateId, stateObj) {
          final commands = stateObj.commands;
          if (commands.isNotEmpty) {
            // Take only the first Command
            final firstCommand = commands.first;
            // Insert into the commandLookup map
            commandLookup[item.id] ??= {};
            commandLookup[item.id]![stateId] = firstCommand;
          }
        });
      }
      // Handle BargraphModel
      else if (item is BargraphModel) {
        item.states.forEach((stateId, stateObj) {
          final commands = stateObj.commands;
          if (commands.isNotEmpty) {
            final firstCommand = commands.first;
            commandLookup[item.id] ??= {};
            commandLookup[item.id]![stateId] = firstCommand;
          }
        });
      }
    }
  });

  return commandLookup;
}

bool canIdMatches(int receivedCanId, int configCanId) {
  // EXACT or both are 0xFF
  // or if you want 0xFF to be a broadcast acceptance, define your logic:
  if (configCanId == 0xFF && receivedCanId == 0xFF) return true;
  if (configCanId == receivedCanId) return true;
  return false;
}

void setPwmValue(double value) {
  logDebug("ConfigItems", "setPwmValue value: $value");
  if (Platform.isLinux) {
    value = value * (1024 / 14);
    int valueInt = value.round();
    if (valueInt < 50) {
      valueInt = 50;
    } else if (valueInt > 1024) {
      valueInt = 1024;
    }

    logDebug("ConfigItems", "setPwmValue valueInt: $valueInt");
    gpioService?.setHardwarePWM(1, valueInt);
  }
}

void printNavigationStack() {
  final NavigatorState? navigator = navigatorKey.currentState;
  if (navigator == null) return;
  
  List<String> routeNames = [];
  
  navigator.popUntil((route) {
    // Add route name to list
    String routeName = route.settings.name ?? 'unnamed';
    routeNames.insert(0, routeName); // Insert at beginning to show bottom of stack first
    return true; // Continue to check all routes
  });
  
  // Print stack from bottom to top
  debugPrint('📱 CURRENT NAVIGATION STACK (bottom to top):');
  for (int i = 0; i < routeNames.length; i++) {
    debugPrint('  $i: ${routeNames[i]}');
  }
}
