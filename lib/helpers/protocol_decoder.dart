// protocol_decoder.dart

import 'dart:typed_data';
import 'dart:io';

// Abstract base class for all protocol decoders
abstract class IProtocolDecoder {
  String decode(Uint8List protocolHeader, Uint8List protocolData, int protocolType);
}

// Registry to manage all decoders
class ProtocolDecoderRegistry {
  static final Map<int, IProtocolDecoder> _decoders = {};

  static void registerDecoder(int messageType, IProtocolDecoder decoder) {
    _decoders[messageType] = decoder;
  }

  static String? decode(int messageType, Uint8List protocolHeader, Uint8List protocolData, int protocolType) {
    final decoder = _decoders[messageType];
    if (decoder != null) {
      return decoder.decode(protocolHeader, protocolData, protocolType);
    }
    return null;
  }

  static bool hasDecoder(int messageType) {
    return _decoders.containsKey(messageType);
  }
}

// DO/Relay Decoder implementation
class DoRelayDecoder implements IProtocolDecoder {
  final String prefix;

  DoRelayDecoder(this.prefix);

  @override
  String decode(Uint8List protocolHeader, Uint8List protocolData, int protocolType) {
    if (protocolData.length < 10) return "Invalid Protocol Data";

    StringBuffer result = StringBuffer();
    result.write('ID ${protocolHeader[0]} - $prefix On: ');

    // Process "On" bits (first 5 bytes)
    for (int i = 0; i < 5; i++) {
      for (int bit = 0; bit < 8; bit++) {
        if ((protocolData[i] & (1 << bit)) != 0) {
          int output = (i * 8) + bit + 1;
          String bitPrefix = "";

          if (output > 12) {
            bitPrefix = "C";
            output -= 12;
          }

          result.write('$bitPrefix$output, ');
        }
      }
    }

    result.write('$prefix Off: ');

    // Process "Off" bits (next 5 bytes)
    for (int i = 5; i < 10; i++) {
      for (int bit = 0; bit < 8; bit++) {
        if ((protocolData[i] & (1 << bit)) != 0) {
          int output = ((i - 5) * 8) + bit + 1;
          String bitPrefix = "";

          if (output > 12) {
            bitPrefix = "C";
            output -= 12;
          }

          result.write('$bitPrefix$output, ');
        }
      }
    }

    return result.toString().replaceAll(RegExp(r'[, ]+$'), '');
  }
}

// Command parser to work with your toString format
class CommandParser {
  static ParsedCommand? parseCommandString(String commandString) {
    // Parse format: "11-0-16-0-12-0-0-0-0-0-4-0-0-0-0-0-0"
    final parts = commandString.split('-');
    if (parts.length < 3) return null;

    try {
      final canId = int.parse(parts[0]);
      final protocolType = int.parse(parts[2]);

      // lets parse protocol header
      final protocolHeader = Uint8List.fromList(
        parts.sublist(0, 4).map((s) => int.parse(s)).toList(),
      );

      // Extract data bytes (skip canId, unknown byte, protocolType)
      final dataBytes = parts.skip(5).map((s) => int.parse(s)).toList();

      return ParsedCommand(
        canId: canId,
        protocolHeader: protocolHeader,
        protocolType: protocolType,
        data: Uint8List.fromList(dataBytes),
      );
    } catch (e) {
      return null;
    }
  }
}

class ParsedCommand {
  final int canId;
  final int protocolType;
  final Uint8List protocolHeader;
  final Uint8List data;

  ParsedCommand({
    required this.canId,
    required this.protocolType,
    required this.protocolHeader, // Default empty header
    required this.data,
  });
}

// Protocol setup and initialization
class ProtocolSetup {
  static void initialize() {
    // Only initialize decoders on Windows
    if (!Platform.isWindows) return;

    ProtocolDecoderRegistry.registerDecoder(0x10, DoRelayDecoder("DO"));
    ProtocolDecoderRegistry.registerDecoder(0x11, DoRelayDecoder("Relay"));

    // Add more decoders as needed:
    // ProtocolDecoderRegistry.registerDecoder(0x31, MacroStatusInhibitDecoder("Inhibit"));
    // ProtocolDecoderRegistry.registerDecoder(0x32, MacroStatusInhibitDecoder("Macro"));
    // etc.
  }
}

// Main decoder function for your use case
class ProtocolDecoder {
  static String? decodeCommand(String commandString) {
    // Only decode on Windows
    if (!Platform.isWindows) return null;

    final parsed = CommandParser.parseCommandString(commandString);
    if (parsed == null) {
      return "Invalid command format";
    }

    // For your use case, we'll use the protocol type as the message type
    // You might need to adjust this logic based on your specific protocol
    final messageType = parsed.protocolType;

    if (ProtocolDecoderRegistry.hasDecoder(messageType)) {
      // Create empty header for now - adjust if you have header data
      final emptyHeader = Uint8List(0);

      final decoded = ProtocolDecoderRegistry.decode(
        messageType,
        parsed.protocolHeader.isEmpty ? emptyHeader : parsed.protocolHeader,
        parsed.data,
        parsed.protocolType,
      );

      return decoded ?? "Unknown decoder result";
    }

    return "No decoder for message type: 0x${messageType.toRadixString(16).toUpperCase()}";
  }

  static String decodeCommandWithFallback(String commandString) {
    // Only decode on Windows, otherwise return raw command
    if (!Platform.isWindows) return commandString;

    final result = decodeCommand(commandString);
    return result ?? "Raw: $commandString";
  }

  static bool isDecodingEnabled() {
    return Platform.isWindows;
  }
}
