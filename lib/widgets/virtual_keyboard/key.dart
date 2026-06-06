import 'key_action.dart';
import 'key_type.dart';

/// Virtual Keyboard key
class VirtualKeyboardKey {
  String? text;
  String? capsText;
  final VirtualKeyboardKeyType keyType;
  final VirtualKeyboardKeyAction? action;

  VirtualKeyboardKey(
      {this.text, this.capsText, required this.keyType, this.action}) {
    if (text == null && action != null) {
      text = action == VirtualKeyboardKeyAction.Space
          ? ' '
          : (action == VirtualKeyboardKeyAction.Return ? '\n' : '');
    }
    if (capsText == null && action != null) {
      capsText = action == VirtualKeyboardKeyAction.Space
          ? ' '
          : (action == VirtualKeyboardKeyAction.Return ? '\n' : '');
    }
  }
}
