import 'dart:async';
import 'dart:ffi' as ffi; // For calloc
import 'dart:isolate';
import '../model/command.dart';
import 'package:ffi/ffi.dart';

import '../utils/logger.dart';
import 'can_fd_Manager.dart';

class IsolateManager {
  IsolateManager() {
    Logger logger = Logger();
    logger.setLogLevel(LogLevel.info);
  }

  List<Command> commands = [];
  Command receivedCommand =
      Command(id: 0, len: 0, flags: 0, canId: 0, data: []);
  isolateEntryPoint(List<dynamic> values) {
    SendPort sendPort = values[0];
    int sockfd = values[1];
    final frame = calloc<CanFdFrame>();

    void readFromSocket(Timer timer) {
      int bytesRead = CanFdManager()
          .read(sockfd, frame.cast<ffi.Void>(), ffi.sizeOf<CanFdFrame>());
      if (bytesRead > 0) {
        final canId = frame.ref.canId;

        // logDebug(
        //     'IsolateManager', 'received canId: ${canId.toRadixString(16)}');

        // lets see if any of errors are present based on the canId
        // and lets check the CAN_ERR_FLAG bits

        // If the top bits are set => error frame
        if ((canId & 0x1FFFFFFF) == 0x1FFFFFFF) {
          // or check for CAN_ERR_FLAG bits
          // parse the error details from the data field
          logError('IsolateManager',
              "Error frame received: bus may be disconnected or bus-off.");
        }

        final dataLength = frame.ref.len;
        final dataBytes =
            List.generate(dataLength, (index) => frame.ref.data[index]);
        final dataString = dataBytes
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join(' ');
        // logDebug('IsolateManager', '${DateTime.now()} - Received CAN frame:');
        // logDebug('IsolateManager',
        //     'ID = ${int.parse(frame.ref.canId.toRadixString(16), radix: 16)}');
        // logDebug(
        //     'IsolateManager', 'ID hex = ${frame.ref.canId.toRadixString(16)}');
        // logDebug('IsolateManager', 'DLC = ${frame.ref.len}');
        // logDebug('IsolateManager', 'Flags = ${frame.ref.flags}');
        // logDebug('IsolateManager', 'Data = $dataString');
        receivedCommand = Command(
          id: 0,
          len: frame.ref.len,
          flags: frame.ref.flags,
          canId: int.parse(frame.ref.canId.toRadixString(16), radix: 16),
          data: dataBytes,
        );

        // lets allow only 0x05 and 0x06 protocols - STD message priority STD (0x06) and HIGH(0x05)
        if (receivedCommand.canProtocol == 0x05 || receivedCommand.canProtocol == 0x06) {
          // logDebug('IsolateManager',
          //     'CommandForStream = ${receivedCommand.commandForStream()}');
          sendPort.send(receivedCommand.commandForStream());
        } else {
          // we should ignore any other protocols
        }
        // commands.add(receivedCommand);
        // sendPort.send(commands);
        // commands.clear(); // Clear the list after sending the commands
      } else if (bytesRead == 0) {
        // If bytesRead is 0, it indicates that the socket is closed
        timer.cancel();
        logDebug('IsolateManager', 'Timer canceled. Socket closed.');
        calloc.free(frame);
      } else {
        // If an error occurs, cancel the timer and indicate the error
        timer.cancel();
        logError('IsolateManager', 'Error occurred. Timer canceled.');
        calloc.free(frame);
        // Handle the error, such as reconnecting the CAN interface or closing the application
      }
    }

    // Start a periodic timer to read data from the socket
    Timer.periodic(const Duration(microseconds: 100), (timer) {
      readFromSocket(timer); // Call the read function
    });
  }
}
