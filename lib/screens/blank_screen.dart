import 'package:flutter/material.dart';
import '../model/time_service.dart';

class BlankScreen extends StatelessWidget {
  const BlankScreen({super.key});

  static const routeName = '/app/blank-screen';

  @override
  Widget build(BuildContext context) {
    TimerService.of(context).screenSaverActive = true;
    return GestureDetector(
      // onTap: () {
      //   Navigator.of(context).pop();
      // },
      onPanDown: (details) {
        TimerService.of(context).screenSaverActive = false;
        TimerService.of(context).reset();
        Navigator.of(context).pop();
      },
      // onScaleStart: (details) {
      //   Navigator.of(context).pop();
      // },
      child: Container(color: Colors.black),
    );
  }
}
