import 'dart:ui';

import 'package:flutter/material.dart';

class BottomDrawer extends StatelessWidget {
  final Widget? drawerChild;
  final Color? drawerBackgroundColor;
  final Widget child;
  final Color gestureAreaColor;
  final bool showCloseButton;
  final double height;
  final double width;
  final double? heightFractional;
  final EdgeInsets padding;
  final Color closeButtonColor;
  final double? closeButtonIconSize;
  final double borderSize;
  final Color borderColor;
  const BottomDrawer(
      {Key? key,
      required this.child,
      this.drawerChild,
      this.height = 100,
      this.width = double.infinity,
      this.padding = EdgeInsets.zero,
      this.showCloseButton = false,
      this.heightFractional,
      this.gestureAreaColor = Colors.transparent,
      this.drawerBackgroundColor = Colors.transparent,
      this.closeButtonColor = Colors.white,
      this.closeButtonIconSize,
      this.borderSize = 0,
      this.borderColor = Colors.transparent})
      : super(key: key);

  void _showBottomDrawer(BuildContext context) {
    showModalBottomSheet(
      elevation: 50,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: drawerBackgroundColor,
      barrierColor: Colors.black26,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.height - height,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                ),
                Padding(
                  padding: padding,
                  child: drawerChild as Widget,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: borderSize,
                    color: borderColor,
                  ),
                ),
                showCloseButton
                    ? Positioned(
                        top: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            iconSize: closeButtonIconSize,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        child,
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            // key: UniqueKey(),
            behavior: HitTestBehavior.translucent,
            onVerticalDragUpdate: (details) {
              if (details.delta.dy < 0) {
                _showBottomDrawer(context);
              }
            },
            // onDoubleTap: () {
            // _showBottomDrawer(context);
            // },
            child: IgnorePointer(
              child: Container(
                width: width,
                height: heightFractional == null
                    ? height
                    : MediaQuery.of(context).size.height *
                        (heightFractional as double),
                color: gestureAreaColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
