
import '../model/command.dart';
import '../model/command_location.dart';

/// Types of messages that can be sent to the command processor isolate
enum MessageType {
  initialize,
  processCommand,
  matchFound,
  shutdown,
}

/// Base class for all messages sent between isolates
class IsolateMessage {
  final MessageType type;
  
  IsolateMessage(this.type);
  
  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
    };
  }
}

/// Message to initialize the command processor isolate
class InitializeMessage extends IsolateMessage {
  final Map<int, List<CommandLocation>> reverseLookup;
  final Map<int, List<int>> matchRulesByMsgType;
  
  InitializeMessage({
    required this.reverseLookup,
    required this.matchRulesByMsgType,
  }) : super(MessageType.initialize);
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['reverseLookup'] = reverseLookup;
    map['matchRulesByMsgType'] = matchRulesByMsgType;
    return map;
  }
}

/// Message to process a command
class ProcessCommandMessage extends IsolateMessage {
  final Command command;
  final String commandType;
  final int msgType;
  final int interfaceNumber;
  
  ProcessCommandMessage({
    required this.command,
    required this.commandType,
    required this.msgType,
    required this.interfaceNumber,
  }) : super(MessageType.processCommand);
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['command'] = {
      'id': command.id,
      'len': command.len,
      'flags': command.flags,
      'data': command.data,
      'canProtocol': command.canProtocol,
      'canId': command.canId,
      'canIdBF': command.canIdBF,
      'delayMs': command.delayMs,
      'originId': command.originId,
    };
    map['commandType'] = commandType;
    map['msgType'] = msgType;
    map['interfaceNumber'] = interfaceNumber;
    return map;
  }
}

/// Message sent when a command match is found
class MatchFoundMessage extends IsolateMessage {
  final String objectId;
  final int stateId;
  final List<int> data;
  
  MatchFoundMessage({
    required this.objectId,
    required this.stateId,
    this.data = const [],
  }) : super(MessageType.matchFound);
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['objectId'] = objectId;
    map['stateId'] = stateId;
    map['data'] = data;
    return map;
  }
  
  factory MatchFoundMessage.fromMap(Map<String, dynamic> map) {
    return MatchFoundMessage(
      objectId: map['objectId'] as String,
      stateId: map['stateId'] as int,
      data: List<int>.from(map['data'] ?? []),
    );
  }
}

/// Message to shutdown the isolate
class ShutdownMessage extends IsolateMessage {
  ShutdownMessage() : super(MessageType.shutdown);
}

/// Helper functions to convert between messages and maps
class IsolateMessageHelper {
  static IsolateMessage fromMap(Map<String, dynamic> map) {
    final messageType = MessageType.values[map['type'] as int];
    
    switch (messageType) {
      case MessageType.matchFound:
        return MatchFoundMessage.fromMap(map);
      case MessageType.initialize:
      case MessageType.processCommand:
      case MessageType.shutdown:
        // These are only sent to the isolate, not received
        throw UnimplementedError('Not implemented for $messageType');
    }
  }
  
  static Command commandFromMap(Map<String, dynamic> map) {
    final commandMap = map['command'] as Map<String, dynamic>;
    return Command(
      id: commandMap['id'] as int,
      len: commandMap['len'] as int,
      flags: commandMap['flags'] as int,
      data: List<int>.from(commandMap['data']),
      canProtocol: commandMap['canProtocol'] as int,
      canId: commandMap['canId'] as int,
      canIdBF: commandMap['canIdBF'] as int,
      delayMs: commandMap['delayMs'] as int,
      originId: commandMap['originId'] as String?,
    );
  }
}