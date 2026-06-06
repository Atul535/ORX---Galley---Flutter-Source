import 'package:flutter/material.dart';
import 'command.dart';
import 'image_state.dart';

abstract class ComponentState {
  final int stateId;
  final List<Command> commands;
  final bool touchDisabled;
  final bool track;
  final Map<int?, String?>? popRoute;

  ComponentState({
    required this.stateId,
    this.commands = const [],
    this.touchDisabled = false,
    this.track = true,
    this.popRoute,
  });
}

class GenericState extends ComponentState {
  GenericState({
    required super.stateId,
    super.commands = const [],
    super.touchDisabled = false,
    super.track,
    super.popRoute,
  });

  static void emptyStateCallback() {}
}

class GenericSelectionState extends ComponentState {
  final String navigationRoute;
  String? title;
  List<IconData> icons;
  double? iconSize;
  double? textIconSpacing;
  VoidCallback stateCallback;
  double? width;
  double? height;
  String? itemThemeId;
  String route;
  List<ImageState> imageState;

  GenericSelectionState({
    required super.stateId,
    super.touchDisabled = false,
    super.track = true,
    super.commands = const [],
    super.popRoute,
    this.navigationRoute = '',
    this.title,
    this.icons = const [],
    this.iconSize,
    this.textIconSpacing,
    this.width,
    this.height,
    this.itemThemeId,
    this.stateCallback = emptyStateCallback,
    this.route = '',
    this.imageState = const [],
  });

  static void emptyStateCallback() {}
}
