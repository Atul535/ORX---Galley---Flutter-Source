import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/generic_selection_widget.dart';
import 'lights_business_class_main_screen.dart';
import 'lights_master_lav_main_screen.dart';
import 'lights_staff_area_main_screen.dart';
import 'lights_vip_lav_main_screen.dart';

class LightsStaffAreaScreen extends StatefulWidget {
  const LightsStaffAreaScreen({super.key, title});

  @override
  State<LightsStaffAreaScreen> createState() => _LightsStaffAreaScreenState();
}

class _LightsStaffAreaScreenState extends State<LightsStaffAreaScreen> with TickerProviderStateMixin {
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

    return const ActivityDetector(
      child: Padding(
        padding: EdgeInsets.all(0.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SafeArea(
                child: LightsStaffAreaMainScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
