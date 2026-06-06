import '../model/command.dart';
import 'can_interface.dart';
import '/utils/logger.dart';

class CanManager {
  static final CanManager _instance = CanManager._internal();

  CanInterface can0 = CanInterface("can1");
  CanInterface can1 = CanInterface("can0");

  CanManager._internal() {
    can0.initCan();
    can1.initCan();
  }

  factory CanManager() => _instance;

  void sendCommand(
      {required List<Command> commands,
      String interfaceName = "",
      int interfaceNumber = 0,
      originId = ""}) {
    // assuming can command contains can bus interface number
    // then lets iterate through the commands and send them to the right interface
    // we can also delay command if delayMs is not 0

    for (var command in commands) {
      // Set the originId for the command
      command.originId = originId;

      // if command is delayed, delay it before sending
      if (command.delayMs > 0) {
        logDebug("CanManager",
            "Delaying command ${command} for ${command.delayMs}ms");
        Future.delayed(Duration(milliseconds: command.delayMs), () {
          _sendAndProcessCommand(command, interfaceNumber);
        });
      } else {
        _sendAndProcessCommand(command, interfaceNumber);
      }
    }
  }

  void sendSingleCommand({int interfaceNumber = 0, required Command command}) {
    // flipping the can interfaces here, since in reality CAN0 is connected to CAN1 and vice versa

    if (interfaceNumber == 0) {
      can0.sendSingleCommand(command);
    } else {
      can1.sendSingleCommand(command);
    }
  }

  // New private function to send and process commands internally
  void _sendAndProcessCommand(Command command, int interfaceNumber) {
    if (interfaceNumber == 0) {
      can0.sendSingleCommand(command);
    } else {
      can1.sendSingleCommand(command);
    }

    // Loop the command back into the processing stream
    _processInternalCommand(command, interfaceNumber);
  }

  void _processInternalCommand(Command command, int interfaceNumber) {
    logDebug("CanManager",
        "Looping back command: $command for processing, with command originId: ${command.originId}");
    final commandString =
        command.commandForStream(); // Serialize to match CAN data

    // Push the command into the appropriate processing stream
    if (interfaceNumber == 0) {
      can0.commandControllers[command.msgType]?.add(commandString);
    } else {
      can1.commandControllers[command.msgType]?.add(commandString);
    }
  }

  void dispose() {
    can0.dispose();
    can1.dispose();
  }
}
