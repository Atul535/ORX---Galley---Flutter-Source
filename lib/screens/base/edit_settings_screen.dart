import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/custom_theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/socket_provider.dart';
import '../../utils/logger.dart';
import '../../widgets/custom_virtual_keyboard.dart';
import '../../widgets/number_picker/numberpicker.dart';
import '../../widgets/virtual_keyboard/type.dart';

class EditSettingsScreen extends StatefulWidget {
  /// Optionally control the AlertDialog content style
  final TextStyle? contentStyle;

  /// Optionally control the AlertDialog title style
  final TextStyle? titleStyle;

  /// Optionally control the AlertDialog text style
  final TextStyle? textStyle;

  const EditSettingsScreen(
      {super.key, this.contentStyle, this.titleStyle, this.textStyle});
  static const routeName = '/app/editSettingsScreen';

  @override
  State<EditSettingsScreen> createState() => _EditSettingsScreenState();
}

class _EditSettingsScreenState extends State<EditSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEditSettingsDialog();
    });
  }

  Future<void> _showEditSettingsDialog(
      {TextStyle? contentStyle,
      TextStyle? titleStyle,
      TextStyle? textStyle}) async {
    final result = await showDialog(
      context: context,
      builder: (ctx) => EditSettingsDialog(
          contentStyle: contentStyle,
          titleStyle: titleStyle,
          textStyle: textStyle),
    );

    // Whatever the user does (Cancel or Save), we close this screen
    // so we return to the previous route.
    // If you need the result from the dialog, you can pass it to pop()
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    // A simple background or a blank container
    return const Scaffold(
      backgroundColor: Colors.black,
      // Or transparent if your theme allows
    );
  }
}

class EditSettingsDialog extends StatefulWidget {
  /// Optionally control the AlertDialog content style
  final TextStyle? contentStyle;

  /// Optionally control the AlertDialog title style
  final TextStyle? titleStyle;

  /// Optionally control the AlertDialog text style
  final TextStyle? textStyle;
  const EditSettingsDialog(
      {super.key, this.contentStyle, this.titleStyle, this.textStyle});

  @override
  State<EditSettingsDialog> createState() => _EditSettingsDialogState();
}

class _EditSettingsDialogState extends State<EditSettingsDialog> {
  final Map<String, TextEditingController> controllers = {};
  final Map<String, FocusNode> focusNodes = {};
  final Map<String, Color> underlineColors = {};
  Duration selectedTime = Duration.zero;
  bool isPasswordHidden = true;
  int selectedRotation = 0;
  final List<int> rotationOptions = [0, 90, 180, 270];

  @override
  void initState() {
    super.initState();
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    selectedTime = Duration(seconds: settingsProvider.wallpaperTime);
    selectedRotation = settingsProvider.rotation;

    final fields = [
      'id',
      'hwId',
      'sn',
      'password',
      'wallpaperTime',
      'displayWidth',
      'displayHeight'
    ];

    for (var field in fields) {
      controllers[field] =
          TextEditingController(text: settingsProvider.getValue(field));
      focusNodes[field] = FocusNode();
      underlineColors[field] = Colors.grey;
    }
  }

  @override
  void dispose() {
    controllers.forEach((_, controller) => controller.dispose());
    focusNodes.forEach((_, node) => node.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final dialogWidth =
        MediaQuery.of(context).size.width * (isPortrait ? 0.9 : 0.9);
    final fieldWidth = dialogWidth / (isPortrait ? 2.5 : 3.5);

    CustomTheme myTheme =
        Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    logDebug("EditSettingsDialog", "display is in portrait mode: $isPortrait");

    return AlertDialog(
      title: _dialogTitle(context,
          style: widget.titleStyle ?? myTheme.textTheme?.titleSmall),
      titleTextStyle: widget.textStyle ?? myTheme.textTheme?.titleSmall,
      contentTextStyle: widget.contentStyle ?? myTheme.textTheme?.displaySmall,
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 20),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (isPortrait) ...[
                _buildRow(['id', 'hwId'], fieldWidth,
                    style: widget.textStyle ?? myTheme.textTheme?.displaySmall),
                _buildRow(['sn', 'wallpaperTime'], fieldWidth,
                    style: widget.textStyle ?? myTheme.textTheme?.displaySmall),
                _buildRow(
                  ['displayWidth', 'displayHeight'],
                  fieldWidth,
                  style: widget.textStyle ?? myTheme.textTheme?.displaySmall,
                ),
                _buildRow([], fieldWidth,
                    extraWidget: _buildRotationDropdown(),
                    style: widget.textStyle),
                _buildRow(['password'], fieldWidth * 1.5,
                    style: widget.textStyle),
              ] else ...[
                _buildRow(['id', 'hwId'], fieldWidth, style: widget.textStyle),
                _buildRow(['sn', 'wallpaperTime'], fieldWidth,
                    style: widget.textStyle),
                _buildRow(['displayWidth', 'displayHeight'], fieldWidth,
                    extraWidget: _buildRotationDropdown(),
                    style: widget.textStyle),
                _buildRow(['password'], fieldWidth * 2,
                    style: widget.textStyle),
              ],
            ],
          ),
        ),
      ),
      actions: _dialogActions(() => saveChanges(socketProvider),
          style: widget.textStyle ?? myTheme.textTheme?.titleSmall),
    );
  }

  /// Builds a row of text fields with optional extra widget
  Widget _buildRow(List<String> fields, double fieldWidth,
      {Widget? extraWidget, TextStyle? style}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ...fields
            .map((field) => _buildTextField(field, fieldWidth, style: style)),
        if (extraWidget != null)
          SizedBox(width: fieldWidth, child: extraWidget),
      ],
    );
  }

  /// Builds the text field with virtual keyboard integration
  Widget _buildTextField(String field, double width, {TextStyle? style}) {
    VirtualKeyboardType keyboarType = VirtualKeyboardType.Numeric;

    if (field == 'password' || field == 'sn') {
      keyboarType = VirtualKeyboardType.Alphanumeric;
    }

    CustomTheme myTheme =
        Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.5),
        child: TextField(
          style: style,
          controller: controllers[field],
          focusNode: focusNodes[field],
          readOnly: true,
          showCursor: true,
          decoration: InputDecoration(
            labelText: field.toUpperCase(),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: underlineColors[field]!)),
            suffixIcon: IconButton(
              icon: Icon(Icons.cancel,
                  size: myTheme.textTheme?.titleSmall?.fontSize),
              onPressed: () => setState(() => controllers[field]!.clear()),
            ),
          ),
          onTap: () {
            final isPortrait =
                MediaQuery.of(context).orientation == Orientation.portrait;

            double keyboardWidth = isPortrait
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.width * 0.7;

            double keyboardHeight = isPortrait
                ? MediaQuery.of(context).size.height * 0.45
                : MediaQuery.of(context).size.height * 0.5;

            if (field == 'wallpaperTime') {
              _selectTime(context);
            } else {
              CustomVirtualKeyboard.show(
                context: context,
                height: keyboardHeight,
                fontSize: Theme.of(context).textTheme.displayMedium?.fontSize,
                maxWidth: keyboarType == VirtualKeyboardType.Numeric
                    ? keyboardWidth / 1.9
                    : keyboardWidth,
                backgroundColor: Colors.white.withOpacity(0.7),
                controller: controllers[field]!,
                keyboardType: keyboarType,
                focusNode: focusNodes[field]!,
              );
            }
          },
        ),
      ),
    );
  }

  /// Builds the rotation dropdown
  Widget _buildRotationDropdown({TextStyle? style}) {
    return DropdownButtonFormField<int>(
      value: selectedRotation,
      decoration: const InputDecoration(labelText: 'ROTATION'),
      items: rotationOptions.map((value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text('$value°', style: style),
        );
      }).toList(),
      onChanged: (value) => setState(() {
        if (value != null) selectedRotation = value;
      }),
    );
  }

  /// Dialog title
  Widget _dialogTitle(BuildContext context, {TextStyle? style}) {
    return Text(' EDIT  SETTINGS ', style: style);
  }

  /// Saves settings and updates device
  void saveChanges(SocketProvider socketProvider) async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    // Save the settings
    await settingsProvider.updateSettings(
      controllers['id']!.text,
      controllers['hwId']!.text,
      controllers['sn']!.text,
      selectedRotation,
      int.tryParse(controllers['displayWidth']!.text) ?? 0,
      int.tryParse(controllers['displayHeight']!.text) ?? 0,
      newWallpaperTime: selectedTime.inSeconds,
    );
    await settingsProvider.updatePassword0(controllers['password']!.text);

    // Notify the device
    socketProvider.sendMessageWithFraming([1]);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Settings saved successfully!'),
      backgroundColor: Colors.green,
    ));

    // Close the dialog
    Navigator.of(context).pop();
  }

  /// Dialog actions
  List<Widget> _dialogActions(VoidCallback onSave, {TextStyle? style}) {
    CustomTheme myTheme =
        Provider.of<CustomThemes>(context, listen: true).getActiveTheme();
    return [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'CANCEL',
            style: style?.copyWith(
                color:
                    myTheme.highlightColor ?? Theme.of(context).primaryColor),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextButton(
            onPressed: onSave,
            child: Text(
              'SAVE',
              style: style?.copyWith(
                  color:
                      myTheme.highlightColor ?? Theme.of(context).primaryColor),
            )),
      ),
    ];
  }

  /// Number picker widget
  Widget _buildNumberPicker(
      String label, int value, int min, int max, ValueChanged<int> onChanged) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        NumberPicker(
            key: UniqueKey(),
            value: value,
            minValue: min,
            maxValue: max,
            onChanged: onChanged),
      ],
    );
  }

  /// Displays a time picker dialog
  Future<void> _selectTime(BuildContext context) async {
    int minutes = selectedTime.inMinutes;
    int seconds = selectedTime.inSeconds % 60;

    await showDialog<Duration>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Wallpaper Activation"),
              alignment: Alignment.topCenter,
              insetPadding: const EdgeInsets.only(top: 20),
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNumberPicker(
                    "Minutes",
                    minutes,
                    0,
                    59,
                    (value) {
                      setDialogState(
                          () => minutes = value); // Updates UI inside dialog
                      setState(() => selectedTime = Duration(
                          minutes: minutes,
                          seconds: seconds)); // Updates actual state
                    },
                  ),
                  _buildNumberPicker(
                    "Seconds",
                    seconds,
                    0,
                    59,
                    (value) {
                      setDialogState(() => seconds = value);
                      setState(() => selectedTime =
                          Duration(minutes: minutes, seconds: seconds));
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedTime =
                          Duration(minutes: minutes, seconds: seconds);
                      controllers['wallpaperTime']!.text =
                          _formatTime(selectedTime);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Set'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatTime(Duration duration) =>
      '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
}
