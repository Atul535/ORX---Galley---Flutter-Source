import 'package:flutter/material.dart';

class BargraphTheme extends SliderThemeData {
  final ShowValueIndicator? myShowValueIndicator;
  final double? myTrackHeight;
  final SliderTrackShape? myTrackShape;
  final Color? myActiveTrackColor;
  final Color? myInactiveTrackColor;
  final SliderComponentShape? myThumbShape;
  final Color? myThumbColor;
  final Color? myOverlayColor;
  final SliderComponentShape? myOverlayShape;
  final SliderTickMarkShape? myTickerMarkShape;
  final Color? myActiveTickerMarkColor;
  final Color? myInactiveTickerMarkColor;
  final SliderComponentShape? myValueIndicatorShape;
  final Color? myValueIndicatorColor;
  final TextStyle? myValueIndicatorTextStyle;

  const BargraphTheme(
    BuildContext? context,
    this.myShowValueIndicator,
    this.myTrackHeight,
    this.myTrackShape,
    this.myActiveTrackColor,
    this.myInactiveTrackColor,
    this.myThumbShape,
    this.myOverlayColor,
    this.myOverlayShape,
    this.myThumbColor,
    this.myTickerMarkShape,
    this.myActiveTickerMarkColor,
    this.myInactiveTickerMarkColor,
    this.myValueIndicatorColor,
    this.myValueIndicatorShape,
    this.myValueIndicatorTextStyle
  ) : super(
          showValueIndicator: myShowValueIndicator,
          trackHeight: myTrackHeight,
          trackShape: myTrackShape,
          activeTrackColor: myActiveTrackColor,
          inactiveTrackColor: myInactiveTrackColor,
          thumbShape: myThumbShape,
          thumbColor: myThumbColor,
          overlayColor: myOverlayColor,
          overlayShape: myOverlayShape,
          tickMarkShape: myTickerMarkShape,
          activeTickMarkColor: myActiveTickerMarkColor,
          inactiveTickMarkColor: myInactiveTickerMarkColor,
          valueIndicatorShape: myValueIndicatorShape,
          valueIndicatorColor: myValueIndicatorColor,
          valueIndicatorTextStyle: myValueIndicatorTextStyle
        );
}

SliderThemeData buildBargraphThemeFromMap(BuildContext context, Map<String, dynamic> themeMap) {
  return SliderTheme.of(context).copyWith(
    showValueIndicator: themeMap['showValueIndicator'],
    trackHeight: themeMap['trackHeight'],
    trackShape: themeMap['trackShape'],
    activeTrackColor: themeMap['activeTrackColor'],
    inactiveTrackColor: themeMap['inactiveTrackColor'],
    thumbShape: themeMap['thumbShape'],
    thumbColor: themeMap['thumbColor'],
    overlayColor: themeMap['overlayColor'],
    overlayShape: themeMap['overlayShape'],
    tickMarkShape: themeMap['tickMarkShape'],
    activeTickMarkColor: themeMap['activeTickMarkColor'],
    inactiveTickMarkColor: themeMap['inactiveTickMarkColor'],
    valueIndicatorShape: themeMap['valueIndicatorShape'],
    valueIndicatorColor: themeMap['valueIndicatorColor'],
    valueIndicatorTextStyle: themeMap['valueIndicatorTextStyle'],
  );
}