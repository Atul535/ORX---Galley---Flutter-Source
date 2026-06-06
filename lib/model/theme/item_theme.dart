import 'package:flutter/material.dart';

class ItemTheme {
  final String id;
  final int group;
  final Color? backroundColor;
  final Color? symbolColor;
  final Color? textColor;
  final List<Shadow>? shadow;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final Gradient? gradient;
  final List<Shadow> textShadows;
  final BorderRadius? borderRadius;

  ItemTheme({
    required this.id,
    this.group = 0,
    this.backroundColor,
    this.symbolColor,
    this.shadow,
    this.boxShadow,
    this.border,
    this.gradient,
    this.textColor,
    this.textShadows = const [],
    this.borderRadius,
  });
}
