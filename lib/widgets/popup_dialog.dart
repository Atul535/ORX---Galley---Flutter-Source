import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable popup dialog with rich customization.
/// - content: any widget (page-like)
/// - barrier: color/blur/dismiss
/// - sizing: fixed size or constraints
/// - style: background/border/radius/shadow/padding
/// - optional title/header (null = no header at all; '' = empty header space)
class PopupDialog {
  /// Opens the dialog.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget content,

    // --- Title / header ---
    String? title, // null = no header at all; '' = keep header space but empty
    Widget? titleWidget, // if provided, used instead of title text (still respects null logic via title/titleWidget)
    AlignmentGeometry titleAlignment = Alignment.centerLeft,
    EdgeInsetsGeometry titlePadding = const EdgeInsets.fromLTRB(16, 14, 16, 10),
    TextStyle? titleTextStyle,
    double titleGap = 8.0, // space between header and content (only if header exists)

    // --- Behavior ---
    bool barrierDismissible = true,
    bool canPop = true, // back button / ESC
    bool useSafeArea = true,

    // --- Barrier style ---
    Color barrierColor = const Color(0x99000000),
    double barrierBlurSigma = 0.0,

    // --- Layout / sizing ---
    double? width,
    double? height,
    BoxConstraints? constraints,
    EdgeInsetsGeometry insetPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    AlignmentGeometry alignment = Alignment.center,

    // --- Panel style ---
    Color backgroundColor = const Color(0xFF1E1E1E),
    BorderRadiusGeometry borderRadius = const BorderRadius.all(Radius.circular(18)),
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),

    // --- Optional header close button ---
    bool showCloseButton = false,
    VoidCallback? onClose,

    // --- Animation ---
    Duration transitionDuration = const Duration(milliseconds: 180),
  }) {
    final theme = Theme.of(context);

    // Header exists if either titleWidget is provided OR title is non-null.
    // - title == null and titleWidget == null -> no header at all
    // - title == '' -> header exists but empty text
    final bool hasHeader = titleWidget != null || title != null;

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'PopupDialog',
      barrierColor: barrierColor,
      transitionDuration: transitionDuration,
      pageBuilder: (ctx, anim1, anim2) {
        return _PopupScaffold(
          content: content,
          canPop: canPop,
          useSafeArea: useSafeArea,
          width: width,
          height: height,
          constraints: constraints,
          insetPadding: insetPadding,
          alignment: alignment,
          barrierBlurSigma: barrierBlurSigma,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          border: border,
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                  color: Colors.black.withOpacity(0.35),
                ),
              ],
          padding: padding,

          // header
          hasHeader: hasHeader,
          title: title,
          titleWidget: titleWidget,
          titleAlignment: titleAlignment,
          titlePadding: titlePadding,
          titleTextStyle: titleTextStyle ??
              theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
          titleGap: titleGap,

          // close button
          showCloseButton: showCloseButton,
          onClose: onClose,
          iconColor: theme.colorScheme.onSurface,
        );
      },
      transitionBuilder: (ctx, anim, secondary, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _PopupScaffold extends StatelessWidget {
  const _PopupScaffold({
    required this.content,
    required this.canPop,
    required this.useSafeArea,
    required this.width,
    required this.height,
    required this.constraints,
    required this.insetPadding,
    required this.alignment,
    required this.barrierBlurSigma,
    required this.backgroundColor,
    required this.borderRadius,
    required this.border,
    required this.boxShadow,
    required this.padding,

    // header
    required this.hasHeader,
    required this.title,
    required this.titleWidget,
    required this.titleAlignment,
    required this.titlePadding,
    required this.titleTextStyle,
    required this.titleGap,

    // close
    required this.showCloseButton,
    required this.onClose,
    required this.iconColor,
  });

  final Widget content;

  final bool canPop;
  final bool useSafeArea;

  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry insetPadding;
  final AlignmentGeometry alignment;
  final double barrierBlurSigma;

  final Color backgroundColor;
  final BorderRadiusGeometry borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry padding;

  // header
  final bool hasHeader;
  final String? title;
  final Widget? titleWidget;
  final AlignmentGeometry titleAlignment;
  final EdgeInsetsGeometry titlePadding;
  final TextStyle? titleTextStyle;
  final double titleGap;

  // close
  final bool showCloseButton;
  final VoidCallback? onClose;
  final Color iconColor;

  void _close(BuildContext context) {
    onClose?.call();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    // Build header only if requested:
    // - title == null and titleWidget == null => no header
    // - title == '' => header exists but text empty
    Widget? header;
    if (hasHeader) {
      header = Padding(
        padding: titlePadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: titleAlignment,
                child: titleWidget ??
                    Text(
                      title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: titleTextStyle,
                    ),
              ),
            ),
            if (showCloseButton)
              IconButton(
                tooltip: 'Close',
                icon: Icon(Icons.close, color: iconColor),
                onPressed: () => _close(context),
              ),
          ],
        ),
      );
    }

    // Content area: if header exists, we put content below it.
    // We also avoid using Stack for close button now; it lives in header.
    final Widget bodyContent = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) header,
          if (header != null && titleGap > 0) SizedBox(height: titleGap),
          Flexible(child: content),
        ],
      ),
    );

    Widget panel = Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        constraints: constraints,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: border,
          boxShadow: boxShadow,
        ),
        child: bodyContent,
      ),
    );

    // Optional blur behind the dialog content (on top of barrierColor).
    if (barrierBlurSigma > 0) {
      panel = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: barrierBlurSigma,
          sigmaY: barrierBlurSigma,
        ),
        child: panel,
      );
    }

    Widget body = Align(
      alignment: alignment,
      child: Padding(
        padding: insetPadding,
        child: panel,
      ),
    );

    if (useSafeArea) body = SafeArea(child: body);

    return PopScope(
      canPop: canPop,
      child: body,
    );
  }
}
