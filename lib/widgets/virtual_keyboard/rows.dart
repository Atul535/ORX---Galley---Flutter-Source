import 'key.dart';
import 'key_action.dart';
import 'key_type.dart';
import 'layout_keys.dart';

/// Keys for Virtual Keyboard's rows.
const List<List> _keyRowsNumeric = [
  // Row 1
  [
    '1',
    '2',
    '3',
  ],
  // Row 1
  [
    '4',
    '5',
    '6',
  ],
  // Row 1
  [
    '7',
    '8',
    '9',
  ],
  // Row 1
  [
    '.',
    '0',
  ],
];

/// Returns a list of `VirtualKeyboardKey` objects for Numeric keyboard.
List<VirtualKeyboardKey> getKeyboardRowKeysNumeric(rowNum) {
  // Generate VirtualKeyboardKey objects for each row.
  return List.generate(_keyRowsNumeric[rowNum].length, (int keyNum) {
    // Get key string value.
    String key = _keyRowsNumeric[rowNum][keyNum];

    // Create and return new VirtualKeyboardKey object.
    return VirtualKeyboardKey(
      text: key,
      capsText: key.toUpperCase(),
      keyType: VirtualKeyboardKeyType.String,
    );
  });
}

/// Returns a list of `VirtualKeyboardKey` objects.
List<VirtualKeyboardKey> getKeyboardRowKeys(
    VirtualKeyboardLayoutKeys layoutKeys, rowNum) {
  // Generate VirtualKeyboardKey objects for each row.
  return List.generate(layoutKeys.activeLayout[rowNum].length, (int keyNum) {
    // Get key string value.
    if (layoutKeys.activeLayout[rowNum][keyNum] is String) {
      String key = layoutKeys.activeLayout[rowNum][keyNum];

      // Create and return new VirtualKeyboardKey object.
      return VirtualKeyboardKey(
        text: key,
        capsText: key.toUpperCase(),
        keyType: VirtualKeyboardKeyType.String,
      );
    } else {
      var action =
          layoutKeys.activeLayout[rowNum][keyNum] as VirtualKeyboardKeyAction;
      return VirtualKeyboardKey(
          keyType: VirtualKeyboardKeyType.Action, action: action);
    }
  });
}

/// Returns a list of VirtualKeyboard rows with `VirtualKeyboardKey` objects.
List<List<VirtualKeyboardKey>> getKeyboardRows(
    VirtualKeyboardLayoutKeys layoutKeys) {
  // Generate lists for each keyboard row.
  return List.generate(layoutKeys.activeLayout.length,
      (int rowNum) => getKeyboardRowKeys(layoutKeys, rowNum));
}

/// Returns a list of VirtualKeyboard rows with `VirtualKeyboardKey` objects.
List<List<VirtualKeyboardKey>> getKeyboardRowsNumeric() {
  // Generate lists for each keyboard row.
  return List.generate(_keyRowsNumeric.length, (int rowNum) {
    // Will contain the keyboard row keys.
    List<VirtualKeyboardKey> rowKeys = [];

    // We have to add Action keys to keyboard.
    switch (rowNum) {
      case 3:
        // String keys.
        rowKeys.addAll(getKeyboardRowKeysNumeric(rowNum));

        // Right Shift
        rowKeys.add(
          VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Action,
              action: VirtualKeyboardKeyAction.Backspace),
        );
        break;
      default:
        rowKeys = getKeyboardRowKeysNumeric(rowNum);
    }

    return rowKeys;
  });
}
