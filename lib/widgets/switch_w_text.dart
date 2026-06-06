import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/current_state_provider.dart';
import '../utils/pwm_manager.dart';
import 'touch_detector.dart';

class SwitchWithText extends StatelessWidget {
  final String id;
  final int value;
  final String text;
  final double textSize;
  final double spacing;
  final double scale;
  final EdgeInsets? padding;
  final Color? activeColor;
  final MainAxisAlignment? mainAxisAlignment;
  final VoidCallback onStateCallBack;
  final VoidCallback offStateCallBack;

  const SwitchWithText(
      {required this.id,
      this.value = 0,
      this.text = '',
      this.scale = 1.0,
      this.textSize = 20,
      this.spacing = 10,
      this.padding,
      this.activeColor,
      this.mainAxisAlignment,
      this.onStateCallBack = emptyOnStateCallBack,
      this.offStateCallBack = emptyOffStateCallBack,
      super.key});

  static void emptyOnStateCallBack() {}
  static void emptyOffStateCallBack() {}

  @override
  Widget build(BuildContext context) {
    return Selector<CurrentStateProvider, int>(
      selector: (context, currentStateNotifier) =>
          currentStateNotifier.getCurrentState(id.toString()),
      builder: (context, currStateValue, child) {
        return Padding(
          padding: padding as EdgeInsets,
          child: Row(
            mainAxisAlignment: mainAxisAlignment as MainAxisAlignment,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(text, style: TextStyle(fontSize: textSize)),
              SizedBox(width: spacing),
              Transform.scale(
                alignment: Alignment.centerRight,
                scale: scale,
                child: TouchDetector(
                  delayMilliseconds: 1,
                  onDelayedActivation: () {
                    PwmManager.vibrate(250, 1);
                    (currStateValue == 0)
                        ? onStateCallBack()
                        : offStateCallBack();
                    Provider.of<CurrentStateProvider>(context, listen: false)
                        .setCurrentState(
                            id.toString(), (currStateValue == 0) ? 1 : 0);
                  },
                  child: Switch(
                    dragStartBehavior: DragStartBehavior.start,
                    value: (currStateValue == 0) ? false : true,
                    activeColor: activeColor,
                    onChanged: (bool value) {
                      // (value) ? onStateCallBack() : offStateCallBack();
                      // Provider.of<CurrentStateProvider>(context, listen: false)
                      //     .setCurrentState(id.toString(), (value) ? 1 : 0);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
