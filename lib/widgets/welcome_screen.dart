import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import 'hold_to_action_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  final Color backgroundColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    GenericSelection welcomeScreen = configItems['common']?.firstWhere((element) => element.id == 'welcomeScreen') as GenericSelection;

    final double luminance = backgroundColor.computeLuminance();
    final Color textColor = luminance > 0.5 ? Colors.black : Colors.white;

    return Selector<CurrentStateProvider, int>(
      selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(welcomeScreen.id.toString()),
      builder: (context, currStateValue, child) {
        if (currStateValue == 0) {
          return const SizedBox.shrink();
        } else {
          return HoldToActionButton(
            onHeldFor10Seconds: () {
              Provider.of<CurrentStateProvider>(context, listen: false).setCurrentState(welcomeScreen.id.toString(), 0);
            },
            child: Scaffold(
              body: Container(
                color: Colors.black,
                child: Center(
                  child: Text('Welcome', style: TextStyle(color: textColor)),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
