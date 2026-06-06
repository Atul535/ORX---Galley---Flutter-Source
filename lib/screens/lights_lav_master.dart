import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/generic_selection_widget.dart';
import 'lights_master_lav_main_screen.dart';
import 'lights_vip_lav_main_screen.dart';

class LightsLavMasterScreen extends StatefulWidget {
  const LightsLavMasterScreen({super.key, title});

  @override
  State<LightsLavMasterScreen> createState() => _LightsLavMasterScreenState();
}

class _LightsLavMasterScreenState extends State<LightsLavMasterScreen> with TickerProviderStateMixin {
  String title = '';
  Radius iconsBorderRadius = const Radius.circular(15);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // title = ModalRoute.of(context)?.settings.arguments as String;
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();
    // lets iterate through menu items add the items to the current state provider

    return ActivityDetector(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    // color: Colors.black54,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.black54, const Color.fromARGB(31, 143, 121, 121)],
                    ),
                  ),
                  child: const LightsMasterLavMainScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
