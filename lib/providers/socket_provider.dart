import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../config/config_items.dart';
import '../utils/logger.dart';
import '../utils/utils.dart';

class SocketProvider with ChangeNotifier {
  Socket? _socket; // Nullable to avoid uninitialized use
  bool isConnected = false;
  bool isTryingToReconnect = false;
  List<String> logs = [];

  bool isDownloadStarted = false; // Trigger download progress popup
  double downloadProgress = 0.0; // Track progress (0.0 to 1.0)
  String downloadStatus = ''; // 'in-progress', 'success', 'failure'
  bool isDownloadFailed = false; // Track if download failed
  Timer? _timeoutTimer;
  bool _isDialogVisible = false;
  int downloadType = 0;
  final VoidCallback reloadSettingsCallback; // Callback to reload settings
  Timer? _throttleTimer;
  final int _throttleMs = 500;

  bool get isDialogVisible => _isDialogVisible; // Getter for dialog visibility

  SocketProvider({required this.reloadSettingsCallback});

  // Set whether the download dialog is visible or not
  void setDialogVisible(bool isVisible) {
    logInfo('SocketProvider', 'Setting dialog visibility: $isVisible');
    _isDialogVisible = isVisible;
    notifyListeners(); // Notify the UI to re-render if necessary
  }

  // Method to update the download progress
  void updateDownloadProgress(int totalFrames, int currentFrames) {
    logDebug('SocketProvider', 'Updating download progress: $currentFrames / $totalFrames');

    if (totalFrames == 0) {
      logError('SocketProvider', 'Received Invalid Total Frames (0)');
      return;
    }

    isDownloadStarted = true;
    downloadStatus = 'in-progress';

    if (_throttleTimer?.isActive ?? false) {
      return; // Skip updates if timer is running
    }

    downloadProgress = currentFrames / totalFrames;

    // Reset the timeout timer since progress is updating
    _startTimeoutTimer();

    _throttleTimer = Timer(Duration(milliseconds: _throttleMs), () {
      logInfo('SocketProvider', 'Progress Updated: ${(downloadProgress * 100).toStringAsFixed(2)}%');
      notifyListeners();
    });
  }

  // Method to trigger download started
  void startDownload() {
    logDebug('SocketProvider', 'Download started');
    isDownloadStarted = true;
    downloadStatus = 'in-progress';
    notifyListeners();

    // Start timeout timer for inactivity (10s without progress)
    _startTimeoutTimer();
  }

  // Handle timeout if no download progress is made within 10 seconds
  void _startTimeoutTimer() {
    logInfo('SocketProvider', 'Starting timeout timer');

    // Cancel existing timer if running
    _timeoutTimer?.cancel();

    // Start a new timeout timer for 15 seconds
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (downloadProgress < 1.0) {
        // If download is incomplete
        logError('SocketProvider', 'Download timeout! No progress detected in 15s.');
        isDownloadFailed = true;
        downloadStatus = 'failure';
        logs.add('[${DateTime.now()}] Download timeout. No progress within 15 seconds.');

        failDownload(); // Declare download failure
        notifyListeners(); // Notify UI
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel(); // Cancel the timeout timer
    _throttleTimer?.cancel(); // Cancel the throttle timer
    super.dispose();
  }

  // Call this method when download completes successfully
  void completeDownload() {
    logInfo('SocketProvider', 'Download complete');
    _timeoutTimer?.cancel(); // Cancel timeout since download finished
    downloadStatus = 'success';

    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pop(); // Close loading screen when done
    }

    notifyListeners();
  }

  // Call this method when download fails
  void failDownload() {
    logInfo('SocketProvider', 'Download failed, showing error message.');
    _timeoutTimer?.cancel(); // Cancel previous timers
    downloadStatus = 'failure';
    isDownloadFailed = true;

    notifyListeners(); // Notify UI to update

    // Auto-close the error screen after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      final context = navigatorKey.currentContext;
      if (context != null && isDownloadFailed) {
        Navigator.of(context).pop(); // Close loading screen
        resetDownload(); // Reset state after closing
      }
    });
  }

  // Reset download state
  void resetDownload() {
    logDebug('SocketProvider', 'Resetting download state');
    isDownloadStarted = false;
    downloadProgress = 0.0;
    downloadStatus = '';
    isDownloadFailed = false;
    notifyListeners();
  }

  void finishDownload() {
    logInfo('SocketProvider', 'Finishing download');
    isDownloadStarted = false;
    downloadStatus = 'success';
    notifyListeners();
  }

  Future<void> connect() async {
    logDebug('SocketProvider', 'Connecting to the socket');
    if (isTryingToReconnect) {
      logDebug('SocketProvider', 'Already trying to reconnect');
      return;
    }

    isTryingToReconnect = true;
    int retryCount = 0;
    const int maxRetries = 150; // Prevent endless loop

    while (_socket == null && retryCount < maxRetries) {
      logDebug('SocketProvider', 'Attempting to connect to the socket');
      try {
        final socketAddress = InternetAddress('/tmp/flutter_socket', type: InternetAddressType.unix);
        _socket = await Socket.connect(socketAddress, 0);
        _handleSocketConnected();
      } catch (e) {
        if (Platform.isLinux) {
          logError('SocketProvider', 'Socket connection error: $e');
        }
        logs.add('[${DateTime.now()}] Error: Can\'t connect to the socket. Retrying in 5s...');
        notifyListeners(); // Notify the UI that logs were updated
        await Future.delayed(const Duration(seconds: 5)); // Retry after 5 seconds
      }
    }
  }

  void _handleSocketConnected() {
    logDebug('SocketProvider', 'Socket connected');
    if (_socket == null) return; // Ensure socket is valid
    isConnected = true;
    isTryingToReconnect = false;
    logs.add('[${DateTime.now()}] Socket connected');
    notifyListeners(); // Notify UI of connection status

    StrParsingState sps = StrParsingState();
    parserInit(sps); // Initialize parser state

    List<int> outBuffer = List<int>.empty(growable: true); // Buffer for detected frames

    // Send 'Started OK' message to the C++ app
    logDebug("SocketProvider", "Sending 'Started OK' message to the C++ app");
    sendStartedOK();

    _socket!.listen(
      (data) {
        logDebug('SocketProvider', 'Received socket data: $data');

        for (int byte in data) {
          parserDetect(byte, sps, outBuffer, 1500, (detectedFrameSize) {
            logDebug('SocketProvider', 'Frame Detected - Size: $detectedFrameSize, Data: ${outBuffer.sublist(0, detectedFrameSize)}');
            // A frame has been detected, process the frame
            _processProtocolData(outBuffer.sublist(0, detectedFrameSize));
          });
        }
      },
      onError: (error) {
        logs.add('[${DateTime.now()}] Socket error: $error');
        logError('SocketProvider', 'Socket error: $error');
        notifyListeners();
        _reconnect();
      },
      onDone: () {
        logs.add('[${DateTime.now()}] Socket disconnected');
        logError('SocketProvider', 'Socket disconnected');
        notifyListeners();
        _reconnect();
      },
      cancelOnError: true,
    );

    // Check Socket Status Every 5s
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!isConnected) {
        logWarning('SocketProvider', 'Socket not receiving data, reconnecting...');
        _reconnect();
        timer.cancel();
      }
    });
  }

  void _processProtocolData(List<int> data) {
    if (data.isEmpty) return;

    logDebug('SocketProvider', 'Processing protocol data: $data');

    int command = data[0]; // First byte is the command
    switch (command) {
      case 5: // Download Started
        logs.add('[${DateTime.now()}] Download Started');
        logDebug('SocketProvider', 'Download started');
        startDownload(); // Show download progress popup
        break;

      case 6: // Download Type
        int downloadType = data[1];
        logs.add('[${DateTime.now()}] Download Type: $downloadType');
        logDebug('SocketProvider', 'Download Type: $downloadType');
        updateType(data[1]); // Update download type
        break;

      case 7: // Download OK
        logs.add('[${DateTime.now()}] Download OK');
        logDebug('SocketProvider', 'Download OK');
        completeDownload(); // Mark download as successful
        break;

      case 8: // Download FAIL
        logError('SocketProvider', 'Download failed! Showing error...');
        failDownload(); // Now calls failDownload()
        notifyListeners();
        break;

      case 9: // Download Status (progress)
        int totalFrames = (data[1] << 24) | (data[2] << 16) | (data[3] << 8) | data[4];
        int currentFrames = (data[5] << 24) | (data[6] << 16) | (data[7] << 8) | data[8];
        logDebug('SocketProvider', 'Download Status - Total: $totalFrames, Current: $currentFrames');
        updateDownloadProgress(totalFrames, currentFrames); // Update progress bar
        break;

      case 10: // Started OK
        logs.add('[${DateTime.now()}] App started OK');
        break;

      case 11: // Started OK
        logs.add('[${DateTime.now()}] GUI to reload settings.');
        reloadSettingsCallback();
        break;

      default:
        logs.add('[${DateTime.now()}] Unknown command: $command');
        break;
    }
  }

  void sendMessage(String message) {
    if (_socket != null && isConnected) {
      _socket!.write(message);
      logs.add('[${DateTime.now()}] GUI to APP: $message');
      notifyListeners(); // Notify UI that a message was sent
    } else {
      logs.add('[${DateTime.now()}] Failed to send. Socket not connected.');
      notifyListeners(); // Notify UI of failed message
    }
  }

  // Send the 'Started OK' message to the C++ app using the protocol
  void sendStartedOK() {
    logs.add('[${DateTime.now()}] GUI to APP: Sending STARTED OK message.');
    List<int> command = [10]; // Command 10: 'Started OK'
    sendMessageWithFraming(command); // Frame and send the message
  }

  // Update the download type
  void updateType(int type) {
    downloadType = type;
    notifyListeners(); // Notify UI of the change
  }

  // Send a framed message (command) to the C++ app using SOH, EOT, and DLE framing
  void sendMessageWithFraming(List<int> messageBytes) {
    if (_socket == null || !isConnected) {
      logs.add('[${DateTime.now()}] Failed to send. Socket not connected.');
      notifyListeners();
      return;
    }

    // Calculate CRC16 of the message
    int crc = crc16(messageBytes);

    // Convert CRC to two bytes (high byte and low byte)
    int crcHigh = (crc >> 8) & 0xFF;
    int crcLow = crc & 0xFF;

    // Append CRC bytes to the message
    messageBytes.add(crcHigh);
    messageBytes.add(crcLow);

    // Construct the framed message using SOH, EOT, DLE
    List<int> framedMessage = [];
    framedMessage.add(0x01); // SOH

    for (int byte in messageBytes) {
      // Escape SOH, EOT, DLE
      if (byte == 0x01 || byte == 0x04 || byte == 0x10) {
        framedMessage.add(0x10); // DLE
      }
      framedMessage.add(byte);
    }

    framedMessage.add(0x04); // EOT

    // Convert to Uint8List and send
    Uint8List message = Uint8List.fromList(framedMessage);
    _socket!.add(message); // Send the framed message as bytes

    logs.add('[${DateTime.now()}] GUI to APP: ${framedMessage.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}');
    notifyListeners(); // Update logs in the UI
  }

  void clearLog() {
    logs.clear();
    notifyListeners();
  }

  void _reconnect() {
    isConnected = false;
    _socket = null;
    notifyListeners();
    connect(); // Retry connection
  }

  void disconnect() {
    _socket?.close();
    isConnected = false;
    _socket = null;
    notifyListeners();
  }

  List<String> getLogs() {
    return logs;
  }
}

enum DownloadType {
  none,
  app1,
  app2,
  app3,
  app4,
  cfg1,
  cfg2,
  cfg3,
  cfg4,
}

// Define the parser state
class StrParsingState {
  List<int> frameBuffer = []; // Buffer to store received bytes
  int byteCount = 0; // Track how many bytes we have collected
  bool escape = false; // Escape flag for handling DLE sequences
}

// Initialize the parser state
void parserInit(StrParsingState sps) {
  sps.frameBuffer.clear();
  sps.byteCount = 0;
  sps.escape = false;
}

// Detect frames in the incoming data stream
void parserDetect(int serialByte, StrParsingState sps, List<int> outBuffer, int outBufferSize, Function(int) onFrameDetected) {
  // If escape is true, treat the current byte as data, regardless of its value
  if (sps.escape) {
    sps.frameBuffer.add(serialByte);
    sps.byteCount++;
    sps.escape = false; // Reset escape after handling the byte
    return;
  }

  switch (serialByte) {
    case 0x01: // SOH (Start of header)
      sps.byteCount = 0; // Start a new frame
      break;

    case 0x04: // EOT (End of transmission)
      if (sps.byteCount > 0) {
        // Copy the frame to the output buffer and notify
        outBuffer.clear();
        outBuffer.addAll(sps.frameBuffer.take(outBufferSize));
        onFrameDetected(sps.byteCount); // Detected frame size callback
        sps.byteCount = 0; // Reset the buffer for the next frame
        sps.frameBuffer.clear(); // Clear buffer after processing
      }
      break;

    case 0x10: // DLE (Data link escape)
      sps.escape = true; // Set escape flag to handle the next byte
      break;

    default: // Data field
      sps.frameBuffer.add(serialByte);
      sps.byteCount++;
      break;
  }
}
