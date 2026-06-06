import 'dart:async';
import 'dart:isolate';

import '../model/command.dart';
import '../model/command_location.dart';
import '../model/command_match_result.dart';
import '../model/command_processor_message.dart';
import '../utils/logger.dart';

/// Optimized version of canIdMatches for the isolate
bool _canIdMatches(int receivedCanId, int configCanId) {
  // EXACT or both are 0xFF
  if (configCanId == 0xFF && receivedCanId == 0xFF) return true;
  if (configCanId == receivedCanId) return true;
  return false;
}

/// Optimized version of commandMatches for the isolate 
/// - Removed excessive logging
/// - Optimized matching logic
CommandMatchResult _commandMatches(
  List<int> receivedData,
  List<int> configData,
  List<int> matchOps,
) {
  // Create a list to store bytes when using rule 0x04
  final storedBytes = <int>[];

  // If the received data is shorter than config data, no match possible
  if (receivedData.length < configData.length) {
    return CommandMatchResult(false, storedBytes);
  }

  // If the matchOps is shorter than configData, pad it with 0x00 (ignore)
  final extendedOps = matchOps.length < configData.length 
    ? [...matchOps, ...List<int>.filled(configData.length - matchOps.length, 0)]
    : matchOps;

  // Compare each byte in configData to the corresponding byte in receivedData
  for (int i = 0; i < configData.length; i++) {
    final rule = extendedOps[i];
    final rcvByte = receivedData[i];
    final cfgByte = configData[i];

    bool matched = false;
    
    switch (rule) {
      case 0x00: // IGNORE
        matched = true;
        break;

      case 0x01: // EXACT MATCH
        matched = rcvByte == cfgByte;
        break;

      case 0x02: // BIT-SUBSET
        // If config byte is 0, we treat that as trivially matching
        matched = cfgByte == 0 || (rcvByte & cfgByte) == cfgByte;
        break;

      case 0x03: // EXACT or BROADCAST
        matched = (cfgByte == 0xFF && rcvByte == 0xFF) || 
                 (cfgByte != 0xFF && rcvByte == cfgByte);
        break;

      case 0x04: // EXACT MATCH or MATCH if cfgByte is 0x00 and store
        matched = rcvByte == cfgByte || cfgByte == 0x00;
        // Store the byte if configByte is 0x00 (this is the "store" part)
        if (matched && cfgByte == 0x00) {
          storedBytes.add(rcvByte);
        }
        break;

      default:
        matched = false;
        break;
    }

    if (!matched) {
      return CommandMatchResult(false, storedBytes);
    }
  }

  return CommandMatchResult(true, storedBytes);
}

/// Entry point for the command processor isolate
void commandProcessorIsolate(SendPort mainSendPort) {
  // Setup isolate receiving port
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);
  
  // Data structures used by the isolate
  Map<int, List<CommandLocation>> reverseLookup = {};
  Map<int, List<int>> matchRulesByMsgType = {};
  
  // Additional optimization: Index commands by CAN ID for faster lookups
  final Map<int, Map<int, List<CommandLocation>>> canIdToLocationMap = {};
  
  receivePort.listen((message) {
    if (message is Map<String, dynamic>) {
      final messageType = MessageType.values[message['type'] as int];
      
      switch (messageType) {
        case MessageType.initialize:
          // Initialize data structures
          reverseLookup = Map<int, List<CommandLocation>>.from(message['reverseLookup']);
          matchRulesByMsgType = Map<int, List<int>>.from(message['matchRulesByMsgType']);
          
          // Build optimized lookup by CAN ID
          for (final entry in reverseLookup.entries) {
            final msgType = entry.key;
            
            for (final location in entry.value) {
              final canId = location.command.canIdBF;
              
              // Initialize maps if needed
              canIdToLocationMap[msgType] ??= {};
              canIdToLocationMap[msgType]![canId] ??= [];
              
              // Add to the map
              canIdToLocationMap[msgType]![canId]!.add(location);
            }
          }
          break;
          
        case MessageType.processCommand:
          final command = IsolateMessageHelper.commandFromMap(message['command']);
          final msgType = message['msgType'] as int;
          final matchOps = matchRulesByMsgType[msgType] ?? [];
          
          // Check if there are any possible matches for this message type
          if (!reverseLookup.containsKey(msgType)) {
            break;
          }
          
          // Get potential matches by CAN ID (optimized path)
          final canIdMatches = canIdToLocationMap[msgType]?[command.canIdBF] ?? [];
          final otherMatches = canIdToLocationMap[msgType]?[0xFF] ?? []; // Broadcast ID matches
          
          // Combine both match lists
          final possibleMatches = [...canIdMatches, ...otherMatches];
          
          // Process potential matches
          for (final location in possibleMatches) {
            // Skip if the command came from the same object
            if (command.originId != null && location.objectId == command.originId) {
              continue;
            }
            
            // Check if CAN ID matches
            if (_canIdMatches(command.canIdBF, location.command.canIdBF)) {
              // Check if command data matches
              final matchResult = _commandMatches(
                command.data, 
                location.command.data, 
                matchOps
              );
              
              if (matchResult.isMatch) {
                // Send match back to main isolate
                mainSendPort.send(MatchFoundMessage(
                  objectId: location.objectId,
                  stateId: location.stateId,
                  data: matchResult.storedBytes,
                ).toMap());
                
                // break; // Stop after first match
              }
            }
          }
          break;
          
        case MessageType.shutdown:
          // Clean up resources and close the isolate
          receivePort.close();
          Isolate.current.kill();
          break;
          
        default:
          // Unrecognized message type
          break;
      }
    }
  });
}