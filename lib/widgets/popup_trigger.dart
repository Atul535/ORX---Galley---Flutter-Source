import 'package:flutter/material.dart';
import 'popup_dialog.dart';

class PopupTrigger extends StatelessWidget {
  const PopupTrigger({
    super.key,
    required this.child,
    required this.contentBuilder,

    // forward basic options
    this.barrierDismissible = true,
    this.canPop = true,
    this.barrierColor = const Color(0x99000000),
    this.barrierBlurSigma = 0.0,
    this.title,
    this.width,
    this.height,
    this.constraints,
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.border,
    this.padding = const EdgeInsets.all(16),
    this.showCloseButton = false,
  });

  final Widget child;
  final WidgetBuilder contentBuilder;

  final bool barrierDismissible;
  final bool canPop;
  final Color barrierColor;
  final double barrierBlurSigma;

  final double? width;
  final double? height;
  final BoxConstraints? constraints;

  final Color backgroundColor;
  final BorderRadiusGeometry borderRadius;
  final BoxBorder? border;
  final EdgeInsetsGeometry padding;

  final String? title;

  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        PopupDialog.show(
          context: context,
          content: contentBuilder(context),
          title: title,
          barrierDismissible: barrierDismissible,
          canPop: canPop,
          barrierColor: barrierColor,
          barrierBlurSigma: barrierBlurSigma,
          width: width,
          height: height,
          constraints: constraints,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          border: border,
          padding: padding,
          showCloseButton: showCloseButton,
        );
      },
      child: child,
    );
  }
}
