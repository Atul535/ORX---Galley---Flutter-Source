import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/ffi.dart';

import '../helpers/protocol_decoder.dart';
import '../utils/logger.dart';
import 'can_fd_manager.dart';
import 'isolate_manager.dart';
import '../model/command.dart';

class CanInterface {
  final String interfaceName;
  int sockFd = 0;
  final Map<int, StreamController<String>> commandControllers = {
    0x04: StreamController<String>.broadcast(),
    0x10: StreamController<String>.broadcast(),
    0x11: StreamController<String>.broadcast(),
    0x13: StreamController<String>.broadcast(),
    0x14: StreamController<String>.broadcast(),
    0x15: StreamController<String>.broadcast(),
    0x30: StreamController<String>.broadcast(),
    0x31: StreamController<String>.broadcast(),
    0x32: StreamController<String>.broadcast(),
    0x33: StreamController<String>.broadcast(),
    0x40: StreamController<String>.broadcast(),
    0x50: StreamController<String>.broadcast(),
    0x51: StreamController<String>.broadcast(),
  };

  // Stream<String> get commandStream => _commandController.stream;
  Stream<String> getCommandStream(int msgType) {
    return commandControllers[msgType]?.stream ?? const Stream.empty();
  }

  CanInterface(this.interfaceName);

  void initCan() async {
    logDebug('CanInterface', 'initializing can interface $interfaceName');
    int ifIndex = CanFdManager().ifNametoindex(interfaceName.toNativeUtf8());
    if (ifIndex == 0) {
      logError('CanInterface', 'Error getting interface index for $interfaceName');
      // Handle error
      return;
    }
    // Open a socket
    int sockfd =
        // CanFdManager().socket(AF_CAN, SOCK_RAW | SOCK_NONBLOCK, CAN_RAW);
        CanFdManager().socket(AF_CAN, SOCK_RAW, CAN_RAW);
    if (sockfd < 0) {
      logError('CanInterface', 'Error opening socket');
      return;
    }
    sockFd = sockfd;

    // Bind the socket to the can0 interface
    ffi.Pointer<SockAddrCan> addr = calloc<SockAddrCan>();
    addr.ref.canFamily = AF_CAN;
    addr.ref.canIfindex = ifIndex; // Assuming can0 (4) can1 (5)
    if (CanFdManager().bind(sockfd, addr.cast(), ffi.sizeOf<SockAddrCan>()) < 0) {
      logError('CanInterface', 'Error binding socket');
      calloc.free(addr);
      return;
    }

    // Enable CAN FD
    ffi.Pointer<ffi.Int32> enable = calloc<ffi.Int32>();
    enable.value = 1;
    if (CanFdManager().setSockOpt(sockfd, SOL_CAN_RAW, CAN_RAW_FD_FRAMES, enable.cast<ffi.Void>(), ffi.sizeOf<ffi.Int32>()) < 0) {
      logError('CanInterface', 'Error enabling CAN FD');
      calloc.free(enable);
      calloc.free(addr);
      return;
    }
    receiveCommands();
  }

  void receiveCommands() async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn<List<dynamic>>(IsolateManager().isolateEntryPoint, [
      receivePort.sendPort,
      sockFd,
    ]);
    receivePort.listen((rawCommand) {
      // debugPrint('canModel:--> ${commands.toString()}');
      Command command = Command.parse(rawCommand);
      logDebug('CanInterface', 'Received command\'s msgType: ${command.msgType}');
      int msgType = command.msgType;
      if (!commandControllers.containsKey(msgType)) {
        logDebug('CanInterface', 'CanInterface - Command controller doesnt exists for msgType: $msgType, adding it');
        commandControllers[msgType] = StreamController<String>.broadcast();
      } else {
        logDebug('CanInterface', 'CanInterface - Command controller already exists for msgType: $msgType');
      }
      commandControllers[msgType]!.add(rawCommand.toString());
      // _commandController.add(commands.toString());
    });
  }

// Static method
  void sendCommand(List<Command> commands) {
    logDebug('CanInterface', 'Sending command on $interfaceName: ${commands.toString()}');
    final frameToSend = calloc<CanFdFrame>();
    try {
      for (Command command in commands) {
        logDebug('CanInterface', 'command.canId:--> ${command.canId}');
        logDebug('CanInterface', 'command.data:--> ${command.data}');
        logDebug('CanInterface', 'command.len:--> ${command.len}');

        frameToSend.ref.canId = command.canId;
        frameToSend.ref.len = command.data.length;
        frameToSend.ref.flags = 0x04; //Variable Bitrate
        frameToSend.ref.res0 = 0;
        frameToSend.ref.res1 = 0;

        for (int i = 0; i < command.data.length; i++) {
          frameToSend.ref.data[i] = command.data[i];
        }

        if (CanFdManager().write(sockFd, frameToSend.cast<ffi.Void>(), ffi.sizeOf<CanFdFrame>()) < 0) {
          logError('CanInterface', 'Error sending CAN FD frame');
        }
      }
    } catch (e) {
      if (Platform.isLinux) {
        logError('CanInterface', 'Exception in send0Can: $e');
      }
    } finally {
      // Clean up allocated memory
      calloc.free(frameToSend);
    }
  }

  void sendSingleCommand(Command command) {
    logInfo('CanInterface', 'Sending single command on $interfaceName: ${command.toString()}');
    if (ProtocolDecoder.isDecodingEnabled()) {
      final decodedCommand = ProtocolDecoder.decodeCommandWithFallback(command.toString());
      logInfo('CanInterface', 'Decoded: $decodedCommand');
    }
    final frameToSend = calloc<CanFdFrame>();
    try {
      logDebug('CanInterface', 'command.canId:--> ${command.canId}');
      logDebug('CanInterface', 'command.data:--> ${command.data}');
      logDebug('CanInterface', 'command.len:--> ${command.len}');

      frameToSend.ref.canId = command.canId;
      frameToSend.ref.len = command.data.length;
      frameToSend.ref.flags = 0x04; //Variable Bitrate
      frameToSend.ref.res0 = 0;
      frameToSend.ref.res1 = 0;

      for (int i = 0; i < command.data.length; i++) {
        frameToSend.ref.data[i] = command.data[i];
      }

      if (CanFdManager().write(sockFd, frameToSend.cast<ffi.Void>(), ffi.sizeOf<CanFdFrame>()) < 0) {
        logError('CanInterface', 'Error sending CAN FD frame');
      }
    } catch (e) {
      if (Platform.isLinux) {
        logError('CanInterface', 'Exception in send0Can: $e');
      }
    } finally {
      // Clean up allocated memory
      calloc.free(frameToSend);
    }
  }

  void dispose() {
    // _commandController.close();
    commandControllers.forEach((key, controller) {
      controller.close();
    });
  }
}
