import 'package:flutter/material.dart';

class MyTabBarTheme {
  String? id;
  bool? enableFeedback;
  MaterialStateProperty? overlayColor;
  bool? automaticIndicatorColorAdjustment;
  Color? indicatorColor;
  Color? unselectedLabelColor;
  Color? labelColor;
  TabBarIndicatorSize? indicatorSize;
  TextStyle? labelStyle;
  Color? tabColor;
  int? indicatorWeight;

  MyTabBarTheme({
    this.id,
    this.enableFeedback,
    this.overlayColor,
    this.automaticIndicatorColorAdjustment,
    this.indicatorColor,
    this.unselectedLabelColor,
    this.labelColor,
    this.indicatorSize,
    this.labelStyle,
    this.tabColor,
    this.indicatorWeight,
  });
}
