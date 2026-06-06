import 'package:flutter/material.dart';

import '../model/time_service.dart';
import '../widgets/cfg_image.dart';

class ScreenSaverUniverse extends StatefulWidget {
  final String imagePath;
  static const routeName = '/app/screen-saver-universe';

  const ScreenSaverUniverse({
    super.key,
    this.imagePath = "assets/universe.gif",
  });

  @override
  State<ScreenSaverUniverse> createState() => _ScreenSaverUniverseState();
}

class _ScreenSaverUniverseState extends State<ScreenSaverUniverse> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onPanDown: (det) {
            // this is here only to reset screensaver timer in case this screen is called as part of the screensaver
            TimerService.of(context).reset();
            TimerService.of(context).screenSaverActive = false;

            Navigator.of(context).pop();
          },
          child: Container(
            color: Colors.black,
            child: Center(
              child: CfgImage(
                widget.imagePath,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
