import 'dart:async';
import 'package:flutter/material.dart';

import '../can-helpers/can_manager.dart';
import '../model/command.dart';
import 'color_picker/LED_color_picker_rotated.dart';
import 'color_picker/colorpicker.dart';
import 'color_picker/colorpicker_utils.dart';// Import your new LED color picker

class ColorPicker extends StatefulWidget {
  TextStyle? textStyle;
  final List<Command> commands; // List of commands to modify and send
  final String id; // Origin ID for sendCommand
  final Function(List<Command>, String)? sendCommandCallback; // Optional custom send function
  final canManager = CanManager();
  final int throttleMs; // Throttle time in milliseconds
  final List<double> buttonSize;
  final double textScale;
  final double scale;
  final dynamic initialColor; // Can be String, List<int>, or Color
  final Function(List<int>)? onColorDataChanged;
  final double rotationOffset; // Added rotation offset parameter
  final double minBrightness; // Added minimum brightness parameter
  IconData? iconData;

  ColorPicker({
    super.key,
    this.textStyle,
    this.commands = const [],
    required this.id,
    this.sendCommandCallback, // Optional callback to override default sending behavior
    this.throttleMs = 75, // Default throttle time of 100ms
    this.buttonSize = const [200, 80],
    this.textScale = 0.5,
    this.scale = 3,
    this.initialColor = '#FFFFFF', // Default white
    this.onColorDataChanged,
    this.rotationOffset = 0.0, // Default no rotation
    this.minBrightness = 1.0, // Default max brightness for LEDs
    this.iconData,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  bool lightTheme = true;
  Color currentColor = Colors.white;
  List<Color> currentColors = [Colors.yellow, Colors.green];
  List<Color> colorHistory = [];

  // For throttling
  Timer? _throttleTimer;
  Color? _pendingColor;
  bool _hasPendingRequest = false;

  // Picker 4
  final textController = TextEditingController(text: '#FFFFFF');

  @override
  void initState() {
    super.initState();
    // Initialize with the provided color
    _parseInitialColor();
  }

  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if initialColor has changed
    if (_initialColorChanged(oldWidget.initialColor, widget.initialColor)) {
      _parseInitialColor();
    }
  }

  // Helper to check if initialColor changed
  bool _initialColorChanged(dynamic oldColor, dynamic newColor) {
    // only change if new color is not empty
    if (newColor == null) return false;

    // If types differ, they've definitely changed
    if (oldColor.runtimeType != newColor.runtimeType) {
      return true;
    }

    // Compare based on type
    if (oldColor is Color && newColor is Color) {
      return oldColor.value != newColor.value;
    } else if (oldColor is String && newColor is String) {
      return oldColor != newColor;
    } else if (oldColor is List<int> && newColor is List<int>) {
      // Compare RGB values
      if (oldColor.length != newColor.length) return true;

      // For RGB lists, compare each value
      if (oldColor.length >= 3 && newColor.length >= 3) {
        return oldColor[0] != newColor[0] || oldColor[1] != newColor[1] || oldColor[2] != newColor[2];
      }

      // For other lists, compare all values
      for (int i = 0; i < oldColor.length; i++) {
        if (oldColor[i] != newColor[i]) return true;
      }
      return false;
    }

    // Default to assuming changed if we can't determine
    return true;
  }

  // Parse the initial color from various formats
  void _parseInitialColor() {
    if (widget.initialColor is Color) {
      // Direct Color object
      currentColor = widget.initialColor;
    } else if (widget.initialColor is String) {
      // Hex string format
      String hexColor = widget.initialColor as String;

      // Ensure the hex color starts with #
      if (!hexColor.startsWith('#')) {
        hexColor = '#$hexColor';
      }

      // Parse hex color
      try {
        currentColor = hexStringToColor(hexColor);
        textController.text = hexColor;
      } catch (e) {
        print('Error parsing hex color: $e');
      }
    } else if (widget.initialColor is List<int>) {
      // RGB bytes format [R, G, B]
      List<int> rgbBytes = widget.initialColor as List<int>;
      if (rgbBytes.length >= 3) {
        currentColor = Color.fromRGBO(
          rgbBytes[0], // Red
          rgbBytes[1], // Green
          rgbBytes[2], // Blue
          1.0, // Alpha (fully opaque)
        );
        // Update the text controller with the hex representation
        textController.text = '#${currentColor.red.toRadixString(16).padLeft(2, '0')}'
            '${currentColor.green.toRadixString(16).padLeft(2, '0')}'
            '${currentColor.blue.toRadixString(16).padLeft(2, '0')}';
      }
    }

    // Notify listeners about the new color (important for updates)
    setState(() {});
  }

  // Helper function to convert hex string to Color
  Color hexStringToColor(String hexString) {
    // Remove # if present
    final hexCode = hexString.replaceAll('#', '');

    // Convert to int
    return Color(int.parse(hexCode.padRight(8, 'F'), radix: 16));
  }

  // Method to update color programmatically
  void updateColor(dynamic newColor) {
    Color? parsedColor;

    if (newColor is Color) {
      parsedColor = newColor;
    } else if (newColor is String) {
      // Hex string format
      String hexColor = newColor;
      if (!hexColor.startsWith('#')) {
        hexColor = '#$hexColor';
      }
      try {
        parsedColor = hexStringToColor(hexColor);
      } catch (e) {
        print('Error parsing hex color: $e');
        return;
      }
    } else if (newColor is List<int>) {
      // RGB bytes format [R, G, B]
      if (newColor.length >= 3) {
        parsedColor = Color.fromRGBO(
          newColor[0], // Red
          newColor[1], // Green
          newColor[2], // Blue
          1.0, // Alpha
        );
      }
    }

    if (parsedColor != null) {
      setState(() {
        currentColor = parsedColor!;
      });
      sendColorCommand(parsedColor);
    }
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    textController.dispose();
    super.dispose();
  }

  // Method to actually send the CAN command
  void _sendCommand(Color color) {
    // Extract RGB values from the color
    final red = color.red;
    final green = color.green;
    final blue = color.blue;

    // Create a deep copy of the commands list, with RGB values only modified in the first command
    final List<Command> updatedCommands = [];

    // Process commands with special handling for the first one
    for (int i = 0; i < widget.commands.length; i++) {
      Command command = widget.commands[i];

      // is it command sending color info
      if ((command.data[10] & 0x08) != 0) {
        // For the first command, update with RGB values
        List<int> newData = List<int>.from(command.data);

        // Update the last 3 bytes with RGB values if array is long enough
        if (newData.length >= 3) {
          newData[newData.length - 3] = red;
          newData[newData.length - 2] = green;
          newData[newData.length - 1] = blue;
        }

        updatedCommands.add(Command(
          id: command.id,
          canIdBF: command.canIdBF,
          data: newData,
        ));
      } else {
        // For all other commands, just add a copy without modification
        updatedCommands.add(Command(
          id: command.id,
          canIdBF: command.canIdBF,
          data: List<int>.from(command.data),
        ));
      }
    }

    // Use the provided callback or default to canManager.sendCommand
    if (widget.sendCommandCallback != null) {
      widget.sendCommandCallback!(updatedCommands, widget.id);
    } else {
      widget.canManager.sendCommand(commands: updatedCommands, originId: widget.id);
    }
  }

  // Throttled method to send color command
  void sendColorCommand(Color color) {
    // Always update _pendingColor with the latest color
    _pendingColor = color;
    _hasPendingRequest = true;

    // If no timer is active, send immediately and start the throttle timer
    if (_throttleTimer == null || !_throttleTimer!.isActive) {
      // Send this color immediately
      _sendCommand(color);
      _hasPendingRequest = false;

      // Start throttle timer
      _throttleTimer = Timer(Duration(milliseconds: widget.throttleMs), () {
        // When the timer completes, if there's a pending color, send it
        if (_hasPendingRequest && _pendingColor != null) {
          _sendCommand(_pendingColor!);
          _hasPendingRequest = false;
        }
      });
    }
    // If timer is already active, _pendingColor is already updated and will be sent when timer completes
  }

  void changeColor(Color color) {
    // update the text controller with the hex representation
    if (widget.onColorDataChanged != null) {
      widget.onColorDataChanged!([color.red, color.green, color.blue]);
    }
    setState(() => currentColor = color);
    // Send throttled CAN command with the newly selected color
    sendColorCommand(color);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: widget.iconData != null ? Icon(widget.iconData, color: useWhiteForeground(currentColor) ? Colors.white : Colors.black) : const SizedBox.shrink(),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Transform.scale(
              scale: widget.scale,
              child: AlertDialog(
                titlePadding: const EdgeInsets.all(0),
                contentPadding: const EdgeInsets.all(0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                          top: Radius.circular(50),
                          bottom: Radius.circular(500),
                        ),
                ),
                // shape: RoundedRectangleBorder(
                //   borderRadius: MediaQuery.of(context).orientation == Orientation.portrait
                //       ? const BorderRadius.vertical(
                //           top: Radius.circular(500),
                //           bottom: Radius.circular(100),
                //         )
                //       : const BorderRadius.horizontal(right: Radius.circular(500)),
                // ),
                content: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: LEDColorPickerRotated(
                      size: 280,
                      minBrightness: widget.minBrightness,
                      rotationOffset: widget.rotationOffset,
                      initialColor: currentColor, // Initialize with current color
                      onColorSelected: (rgb) {
                        // Convert RGB list to Color and call changeColor
                        final color = Color.fromRGBO(
                          rgb[0],
                          rgb[1],
                          rgb[2],
                          1.0,
                        );
                        changeColor(color);
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: currentColor,
        elevation: 0,
        fixedSize: Size(widget.buttonSize[0], widget.buttonSize[1]),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      label: Text(
        'COLOR',
        style: widget.textStyle != null
            ? widget.textStyle?.copyWith(
                color: useWhiteForeground(currentColor) ? Colors.white : Colors.black,
              )
            : TextStyle(
                color: useWhiteForeground(currentColor) ? Colors.white : Colors.black,
              ),
      ),
    );
  }
}
