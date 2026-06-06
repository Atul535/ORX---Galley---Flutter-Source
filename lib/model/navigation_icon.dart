import 'package:flutter/material.dart';

class NavigationIcon with ChangeNotifier {
  final String id;
  final String title;
  final IconData icon;
  final String route;
  final String menuId;
  double iconSize;
  double height;
  double width;
  double textIconSpacing;
  bool isActive;

  NavigationIcon(
      {required this.id,
      required this.title,
      required this.icon,
      required this.route,
      required this.menuId,
      this.height = 150,
      this.width = 150,
      this.isActive = false,
      this.iconSize = 170,
      this.textIconSpacing = 10});

  void toggleActiveStatus([status]) {
    if (status == null) {
      isActive = !isActive;
      notifyListeners();
    } else if (status != isActive) {
      isActive = status;
      notifyListeners();
    }
  }
}
