import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/custom_theme_provider.dart';

class LopaMenuScreen extends StatelessWidget {
  final Widget? child;
  final String? title;

  const LopaMenuScreen({super.key, this.child, this.title});

  @override
  Widget build(BuildContext context) {
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    return SafeArea(
      child: Stack(
        children: [
          // Layer 1: Background image (child) - zabírá CELOU plochu včetně AppBaru
          Positioned.fill(
            child: SizedBox.expand(
              child: Container(
                color: Colors.black26,
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: kToolbarHeight,
              decoration: BoxDecoration(
                // color: Colors.black12,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.3, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.26),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title.toString(),
                    style: const TextStyle(fontSize: 30, color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: child != null
                ? child as Widget
                : Container(
                    child: Center(
                      child: Text(title.toString()),
                    ),
                  ),
          ),

          // Layer 2: Overlay pro ztmavení obsahu pod AppBarem (optional)
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   height: kToolbarHeight,
          //   child: Container(
          //     color: Colors.black.withOpacity(0.3), // Ztmaví oblast pod AppBarem
          //   ),
          // ),

          // Layer 3: AppBar jako overlay nahoře
        ],
      ),
    );
  }
}
