import 'package:flutter/material.dart';
import '../model/time_service.dart';

class ScreenSaverBlank extends StatelessWidget {
  const ScreenSaverBlank({super.key});

  static const routeName = '/app/screen-saver-blank';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () {
      //   Navigator.of(context).pop();
      // },
      onPanDown: (details) {
        TimerService.of(context).reset();
        Navigator.of(context).pop();
        TimerService.of(context).screenSaverActive = false;
      },
      // onScaleStart: (details) {
      //   Navigator.of(context).pop();
      // },
      child: Container(color: Colors.black),
    );
  }
}
