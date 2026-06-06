import 'package:flutter/material.dart';

import 'bottom_drawer.dart';

class PullupTab extends StatelessWidget {
  final Widget body;
  final Widget child;
  final double height;

  const PullupTab(
      {super.key, required this.body, required this.child, this.height = 0});

  @override
  Widget build(BuildContext context) {
    return BottomDrawer(
        gestureAreaColor: Colors.red,
        height: height,
        width: 600,
        borderSize: 2,
        borderColor: Colors.white54,
        // drawerBackgroundColor: Colors.grey.shade800.withOpacity(0.5),
        drawerBackgroundColor: Colors.black54.withOpacity(0.2),
        drawerChild: body,
        // heightFractional: 0.05,
        showCloseButton: true,
        closeButtonColor: Colors.redAccent,
        closeButtonIconSize: 70,
        child: child);
  }
}
