import 'package:flutter/material.dart';

class TabSpec {
  final String id;
  final String label;
  final int? flex;
  final bool isSpacer;
  final double? fontSize;

  // NEW
  final String? iconAsset; // cesta k obrázku
  final double iconSize; // velikost ikony
  final Axis iconPosition; // horizontal = vlevo, vertical =
  final double? iconWidth; // šířka ikony (pro horizontal)

  const TabSpec({
    required this.id,
    required this.label,
    this.flex,
    this.isSpacer = false,
    this.iconAsset,
    this.iconSize = 32,
    this.iconWidth,
    this.iconPosition = Axis.horizontal,
    this.fontSize,
  });

  const TabSpec.spacer({
    required this.id,
    this.flex,
  })  : label = '',
        isSpacer = true,
        iconAsset = null,
        iconSize = 0,
        iconWidth = null,
        iconPosition = Axis.horizontal,
        fontSize = null;
}
