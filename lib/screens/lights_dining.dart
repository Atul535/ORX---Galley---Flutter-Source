import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/enum_room_type.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/generic_selection_widget.dart';
import 'lights_dining_area_screen.dart';
import 'lights_lounge_all_area_screen.dart';
import 'lights_lounge_hallway_area_screen.dart';
import 'lights_lounge_lounge_area_screen.dart';

class LightsDiningScreen extends StatefulWidget {
  const LightsDiningScreen({super.key, title});

  @override
  State<LightsDiningScreen> createState() => _LightsDiningScreenState();
}

class _LightsDiningScreenState extends State<LightsDiningScreen> with TickerProviderStateMixin {
  String title = '';
  Radius iconsBorderRadius = const Radius.circular(15);

  CustomThemes myThemes = CustomThemes();
  late CustomTheme myTheme = myThemes.getActiveTheme();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final CustomThemes myThemes = Provider.of<CustomThemes>(context, listen: true);
    myTheme = myThemes.getActiveTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ActivityDetector(
      child: Padding(
        padding: const EdgeInsets.only(top: kToolbarHeight), // ⭐ Celá stránka odsazená
        child: DefaultTabController(
          animationDuration: Duration.zero,
          length: 3,
          initialIndex: 0,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 0,
            ),
            body: const LightsDiningAreaScreen(),
          ),
        ),
      ),
    );
  }
}
