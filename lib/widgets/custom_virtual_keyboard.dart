import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/custom_theme_provider.dart';
import 'virtual_keyboard/key.dart';
import 'virtual_keyboard/key_action.dart';
import 'virtual_keyboard/key_type.dart';
import 'virtual_keyboard/keyboard.dart';
import 'virtual_keyboard/layouts.dart';
import 'virtual_keyboard/type.dart';

class CustomVirtualKeyboard extends StatelessWidget {
  final TextEditingController controller;
  final Function() onClose;
  final Function() onSubmit;
  final double maxWidth;
  final Color backgroundColor;
  final Color textColor;
  final VirtualKeyboardType keyboardType;
  final double? fontSize;
  final double height;
  final bool supressEnterInText;
  final FocusNode? focusNode;

  const CustomVirtualKeyboard({
    super.key,
    required this.controller,
    this.onClose = _defaultOnClose,
    this.onSubmit = _defaultOnSubmit,
    this.maxWidth = 800,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.keyboardType = VirtualKeyboardType.Alphanumeric,
    this.fontSize,
    this.height = 300,
    this.supressEnterInText = true,
    this.focusNode,
  });

  // Provide default empty functions
  static void _defaultOnClose() {}
  static void _defaultOnSubmit() {}

  static void show({
    required BuildContext context,
    required TextEditingController controller,
    VoidCallback onClose = _defaultOnClose,
    VoidCallback onSubmit = _defaultOnSubmit,
    double maxWidth = 800,
    double height = 300,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
    double? fontSize,
    bool supressEnterInText = true,
    VirtualKeyboardType keyboardType = VirtualKeyboardType.Alphanumeric,
    FocusNode? focusNode,
  }) {
    if (focusNode!.hasFocus) {
      focusNode.requestFocus();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (BuildContext context) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          if (focusNode.hasFocus) {
            focusNode.requestFocus();
          }
        });
        return Container(
          constraints: BoxConstraints(
            maxHeight: height,
            maxWidth: maxWidth,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: CustomVirtualKeyboard(
              controller: controller,
              onClose: () {
                onClose;
                Navigator.of(context).pop();
              },
              onSubmit: onSubmit,
              maxWidth: maxWidth,
              backgroundColor: backgroundColor,
              textColor: textColor,
              keyboardType: keyboardType,
              fontSize: fontSize,
              height: height,
              supressEnterInText: supressEnterInText,
              focusNode: focusNode,
            ),
          ),
        );
      },
    ).whenComplete(() {
      // This ensures that the focus is returned after the sheet is closed
      if (focusNode.hasFocus) {
        focusNode.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    CustomTheme myTheme =
        Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(10),
        color: backgroundColor,
        child: VirtualKeyboard(
          fontSize: fontSize ?? 14,
          height: height - height * 0.05,
          textController: controller,
          width: MediaQuery.of(context).size.width > maxWidth
              ? maxWidth - maxWidth * 0.05
              : MediaQuery.of(context).size.width -
                  MediaQuery.of(context).size.width * 0.05,
          textColor: textColor,
          type: keyboardType,
          defaultLayouts: const [VirtualKeyboardDefaultLayouts.English],
          onKeyPress: (key) => _onKeyPress(key, context),
        ),
      ),
    );
  }

  void _onKeyPress(VirtualKeyboardKey key, BuildContext context) {
    // String text = controller.text;
    // if (key.keyType == VirtualKeyboardKeyType.String) {
    //   text += key.text!;
    // } else if (key.keyType == VirtualKeyboardKeyType.Action) {
    //   switch (key.action) {
    //     case VirtualKeyboardKeyAction.Backspace:
    //       if (text.isNotEmpty) {
    //         text = text.substring(0, text.length - 1);
    //       }
    //       break;
    //     case VirtualKeyboardKeyAction.Return:
    //       onClose();
    //       Navigator.pop(context); // Close the bottom sheet
    //       break;
    //     case VirtualKeyboardKeyAction.Space:
    //       text += ' ';
    //       break;
    //     default:
    //       break;
    //   }
    // }

    // controller.value = TextEditingValue(
    //   text: text,
    //   selection: TextSelection.collapsed(offset: text.length),
    // );

    if (key.keyType == VirtualKeyboardKeyType.Action) {
      switch (key.action) {
        case VirtualKeyboardKeyAction.Backspace:
          // Close the bottom sheet
          break;
        case VirtualKeyboardKeyAction.Return:

          // Simulate the 'OK' button behavior when Enter is pressed
          onSubmit;
          // Navigator.of(context).pop();
          break;
        default:
          break;
      }
    }

    if (focusNode != null) {
      focusNode!.requestFocus();
    }

    // Remove new line and carriage return characters
    if (supressEnterInText) {
      controller.text =
          controller.text.replaceAll('\n', '').replaceAll('\r', '');
    }
  }
}
