import 'package:flutter/material.dart';

class LightGroup {
  final String id;
  final double x; // Relativní pozice 0-1
  final double y;
  final String label;
  final IconData icon;

  LightGroup({
    required this.id,
    required this.x,
    required this.y,
    required this.label,
    required this.icon,
  });
}
