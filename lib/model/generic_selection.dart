import 'package:flutter/material.dart';

import 'component_state.dart';
import 'component.dart';
import 'position_model.dart';

class GenericSelection extends Component {
  final String? title;
  final List<IconData> icons;
  double iconSize;
  Color? iconsColor;
  List<Shadow>? iconsShadow;
  double height;
  double width;
  double textIconSpacing;
  bool isActive;
  bool isMomentary;
  String? route;
  Widget? textIcon;
  VoidCallback onStateCallBack;
  VoidCallback offStateCallBack;
  bool touchDisabled;
  String group;
  TextStyle? textStyle;
  Position? position;
  List<int> data;
  final bool isTransparent;
  final BorderRadius? borderRadius;
  final Color? color;
  final String? backgroundImage;
  final String? customThemeKey;

  @override
  final Map<int, GenericSelectionState> states;

  GenericSelection({
    required super.id,
    super.inhibits = const {},
    super.inhibitInfo,
    this.title,
    this.icons = const [],
    this.iconsColor,
    this.height = 400,
    this.width = 400,
    this.isActive = false,
    this.iconSize = 160,
    this.textIconSpacing = 25,
    this.isMomentary = false,
    this.route,
    this.onStateCallBack = emptyOnStateCallBack,
    this.offStateCallBack = emptyOffStateCallBack,
    this.textIcon,
    this.touchDisabled = false,
    this.group = '',
    this.textStyle,
    this.iconsShadow,
    this.position,
    this.isTransparent = false,
    this.borderRadius,
    this.color,
    this.data = const [],
    this.backgroundImage,
    this.customThemeKey,
    @override Map<int, GenericSelectionState>? states,
  }) : states = states ?? const {};

  static void emptyOnStateCallBack() {}
  static void emptyOffStateCallBack() {}
}
