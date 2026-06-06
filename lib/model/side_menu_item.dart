import 'package:flutter/material.dart';

import 'image_state.dart';

class SideMenuItem {
  final String id;
  final String title;
  final IconData? icon;
  Widget? widget;
  final Alignment? align;
  final String? route;
  final Duration holdTimeDuration;
  final bool isVisible;
  final List<ImageState>? imageStates;
  final String? backgroundImage;
  final String? wallpaper;
  // final String routeName;

  SideMenuItem({
    required this.id,
    required this.title,
    this.icon,
    this.widget,
    this.align,
    this.route,
    this.holdTimeDuration = const Duration(seconds: 0),
    this.isVisible = true,
    this.imageStates,
    this.backgroundImage,
    this.wallpaper,
    // required this.routeName,
  });
}
