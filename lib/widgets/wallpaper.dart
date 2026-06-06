import 'package:flutter/material.dart';

import 'cfg_image.dart';

class Wallpaper extends StatelessWidget {
  final String? imagePath;
  const Wallpaper({this.imagePath, super.key});

  @override
  Widget build(BuildContext context) {
    return imagePath == null || imagePath!.isEmpty
        ? Positioned.fill(
            //
            child: Container(color: Theme.of(context).canvasColor),
          )
        : Positioned.fill(
            //
            child: CfgImage(
              imagePath.toString(),
              fit: BoxFit.fill,
              // gaplessPlayback: true,
            ),
            // Image(
            //   image: AssetImage(imagePath.toString()),
            //   fit: BoxFit.fill,
            // ),
          );
  }
}
