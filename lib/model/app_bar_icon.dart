import 'package:flutter/material.dart';

class AppBarIcon with ChangeNotifier {
  String? id;
  String? title;
  IconData? symbol;
  double symbolSize;
  double height;
  double width;
  double textIconSpacing;
  bool isActive;

  AppBarIcon(
      {this.id,
      this.title,
      this.symbol,
      this.symbolSize = 50,
      this.height = 100,
      this.width = 100,
      this.textIconSpacing = 10,
      this.isActive = false});

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
