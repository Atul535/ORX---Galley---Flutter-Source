import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/custom_theme_provider.dart';
import '../../utils/logger.dart';
import '../../widgets/custom_virtual_keyboard.dart';
import '../../widgets/virtual_keyboard/type.dart';

class PasswordProtectedScreen extends StatefulWidget {
  final String correctPassword;

  /// If provided, we'll navigate to this route (via push)
  /// after successful password entry.
  final String? protectedRouteName;

  /// If [protectedRouteName] is null, we show [protectedContent] in place
  /// after the password is correct.
  final Widget? protectedContent;

  /// Optionally control the AlertDialog positioning
  final Alignment alignment;

  /// Optionally control the AlertDialog content style
  final TextStyle? contentStyle;

  /// Optionally control the AlertDialog title style
  final TextStyle? titleStyle;

  /// Optionally control the AlertDialog text style
  final TextStyle? textStyle;

  /// Optionally control the AlertDialog padding
  final EdgeInsets insetPadding;

  final String dialogTitle;
  final VirtualKeyboardType keyboardType;
  final int maxLength;
  final bool obscureText;
  final bool barrierDismissible;
  final Alignment dialogAlignment;
  final Offset dialogOffset;
  final Color barrierColor;

  const PasswordProtectedScreen({
    super.key,
    this.correctPassword = '123456',

    // If protectedRouteName is given, we navigate there on success.
    this.protectedRouteName,

    // Otherwise, if protectedRouteName is null, we display this widget in the same screen on success.
    this.protectedContent,

    // For controlling the dialog alignment
    this.alignment = Alignment.center,

    // For controlling the dialog padding
    this.insetPadding = EdgeInsets.zero,

    // For controlling the dialog content style
    this.contentStyle = const TextStyle(fontSize: 20),

    // For controlling the dialog title style
    this.titleStyle = const TextStyle(fontSize: 24),

    // For controlling the dialog text style
    this.textStyle = const TextStyle(fontSize: 20),
    this.dialogTitle = ' ENTER PIN ',
    this.keyboardType = VirtualKeyboardType.Numeric,
    this.maxLength = 4,
    this.obscureText = true,
    this.barrierDismissible = false,
    this.dialogAlignment = Alignment.center,
    this.dialogOffset = const Offset(0, 0),
    this.barrierColor = Colors.transparent, // transparent
  });

  @override
  State<PasswordProtectedScreen> createState() => _PasswordProtectedScreenState();
}

class _PasswordProtectedScreenState extends State<PasswordProtectedScreen> {
  bool _isAuthorized = false; // track if user has passed the check

  @override
  void initState() {
    super.initState();
    // After the first frame is rendered, show the dialog.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPasswordDialog();
    });
  }

  Future<void> _showPasswordDialog() async {
    // final bool? passwordCorrect = await showDialog<bool>(
    //   context: context,
    //   barrierDismissible: widget.barrierDismissible,
    //   barrierColor: widget.barrierColor, // ✅ no black full-screen feel
    //   useSafeArea: false,
    //   builder: (_) => Align(
    //     alignment: widget.dialogAlignment, // ✅ position control
    //     child: FractionalTranslation(
    //       translation: widget.dialogOffset, // ✅ fine offset
    //       child: _PasswordDialog(
    //         correctPassword: widget.correctPassword,
    //         alignment: widget.alignment,
    //         insetPadding: widget.insetPadding,
    //         contentStyle: widget.contentStyle!,
    //         titleStyle: widget.titleStyle!,
    //         textStyle: widget.textStyle!,
    //         dialogTitle: widget.dialogTitle,
    //         keyboardType: widget.keyboardType,
    //         maxLength: widget.maxLength,
    //         obscureText: widget.obscureText,
    //         dialogAlignment: widget.dialogAlignment,
    //         dialogOffset: widget.dialogOffset,
    //         barrierColor: widget.barrierColor,
    //       ),
    //     ),
    //   ),
    // );
    final bool? passwordCorrect = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: widget.barrierDismissible,
      barrierLabel: 'PIN',
      barrierColor: widget.barrierColor, // transparent / light overlay
      transitionDuration: Duration.zero, // ✅ bez animace
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: widget.dialogAlignment,
          child: FractionalTranslation(
            translation: widget.dialogOffset,
            child: _PasswordDialog(
              correctPassword: widget.correctPassword,
              alignment: widget.alignment,
              insetPadding: widget.insetPadding,
              contentStyle: widget.contentStyle!,
              titleStyle: widget.titleStyle!,
              textStyle: widget.textStyle!,
              dialogTitle: widget.dialogTitle,
              keyboardType: widget.keyboardType,
              maxLength: widget.maxLength,
              obscureText: widget.obscureText,
              dialogAlignment: widget.dialogAlignment,
              dialogOffset: widget.dialogOffset,
              barrierColor: widget.barrierColor,
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) => child, // ✅ žádný přechod
    );

    if (passwordCorrect == true) {
      // If password is correct:
      if (widget.protectedRouteName != null) {
        // If protectedRouteName is set, navigate there
        Navigator.of(context).pushReplacementNamed(widget.protectedRouteName!);
      } else {
        // Otherwise, show the protected content in this screen
        setState(() {
          _isAuthorized = true;
        });
      }
    } else {
      // If canceled or incorrect, pop this screen.
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isAuthorized ? (widget.protectedContent ?? const SizedBox()) : const SizedBox.shrink(),
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  final String correctPassword;
  final Alignment dialogAlignment;
  final Offset dialogOffset;
  final Color barrierColor;
  final Alignment alignment;
  final EdgeInsets insetPadding;
  final TextStyle contentStyle;
  final TextStyle titleStyle;
  final TextStyle textStyle;
  final String dialogTitle;
  final VirtualKeyboardType keyboardType;
  final int maxLength;
  final bool obscureText;

  const _PasswordDialog({
    super.key,
    required this.correctPassword,
    this.alignment = Alignment.center,
    this.insetPadding = EdgeInsets.zero,
    this.contentStyle = const TextStyle(fontSize: 20),
    this.titleStyle = const TextStyle(fontSize: 24),
    this.textStyle = const TextStyle(fontSize: 20),
    required this.dialogTitle,
    required this.keyboardType,
    required this.maxLength,
    required this.obscureText,
    required this.dialogAlignment,
    required this.dialogOffset,
    required this.barrierColor,
  });

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordHidden = true;
  final FocusNode _focusNode = FocusNode();
  bool _isKeyboardOpen = false;

  @override
  void initState() {
    super.initState();

    // ✅ Sleduj ztrátu focusu = zavření klávesnice
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isKeyboardOpen) {
        setState(() {
          _isKeyboardOpen = false;
        });
      }
    });

    // Otevři klávesnici při startu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _openKeyboard();
    });
  }

  void _openKeyboard() {
    if (_isKeyboardOpen) return;

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final keyboardWidth = isPortrait ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.7;
    final keyboardHeight = isPortrait ? MediaQuery.of(context).size.height * 0.45 : MediaQuery.of(context).size.height * 0.5;

    setState(() {
      _isKeyboardOpen = true;
    });

    CustomVirtualKeyboard.show(
      height: keyboardHeight,
      maxWidth: keyboardWidth,
      fontSize: Theme.of(context).textTheme.displayMedium?.fontSize,
      backgroundColor: Colors.white.withOpacity(0.7),
      context: context,
      controller: _passwordController,
      keyboardType: widget.keyboardType,
      focusNode: _focusNode,
      onSubmit: _onSubmit,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();
    return AlertDialog(
      contentTextStyle: widget.contentStyle,
      titleTextStyle: widget.titleStyle,
      alignment: widget.alignment,
      insetPadding: widget.insetPadding,
      title: Text(widget.dialogTitle, style: widget.titleStyle),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          focusNode: _focusNode,
          controller: _passwordController,
          obscuringCharacter: '*',
          style: widget.textStyle,
          obscureText: widget.obscureText ? _isPasswordHidden : false,
          maxLength: widget.maxLength,
          keyboardType: TextInputType.none,
          inputFormatters: widget.keyboardType == VirtualKeyboardType.Numeric ? [FilteringTextInputFormatter.digitsOnly] : [],
          decoration: InputDecoration(
            counterText: '',
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                      size: widget.contentStyle.fontSize! * 0.85,
                    ),
                    onPressed: () {
                      setState(() => _isPasswordHidden = !_isPasswordHidden);
                    },
                  )
                : null,
          ),
          onChanged: (v) {
            if (v.trim().length >= widget.maxLength) {
              _onSubmit();
            }
          },
          onTap: () {
            // ✅ Při kliknutí zkus otevřít (pokud není otevřená)
            if (!_focusNode.hasFocus) {
              _focusNode.requestFocus();
            }
            _openKeyboard();
          },
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: _onSubmit,
            child: Text('SUBMIT', style: widget.textStyle.copyWith(color: myTheme.highlightColor)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('CANCEL', style: widget.textStyle.copyWith(color: myTheme.highlightColor)),
          ),
        ),
      ],
    );
  }

  void _onSubmit() {
    final typedPassword = _passwordController.text.trim();
    if (typedPassword == widget.correctPassword) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect password')),
      );
    }
  }
}
