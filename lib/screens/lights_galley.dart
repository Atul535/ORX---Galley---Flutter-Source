import 'package:ORX_Galley/screens/lights_entry_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/generic_selection_widget.dart';

class LightsGalleyScreen extends StatefulWidget {
  const LightsGalleyScreen({super.key, title});

  static const routeName = '/app/lights/galley';

  @override
  State<LightsGalleyScreen> createState() => _LightsGalleyScreenState();
}

class _LightsGalleyScreenState extends State<LightsGalleyScreen> {
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

    final menuItems = configItems['galley-lights'] as List<dynamic>;

    // lets iterate through menu items add the items to the current state provider

    return const ActivityDetector(
      child: Padding(
        padding: EdgeInsets.all(0.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SafeArea(
                child:
                    //
                    LightsEntryScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
