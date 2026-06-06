import 'package:ORX_Galley/screens/shades_lounge_area_screen.dart';
import 'package:ORX_Galley/screens/shades_lounge_lounge_hallway_area_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/enum_room_type.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/generic_selection_widget.dart';
import 'lights_lounge_all_area_screen.dart';
import 'lights_lounge_hallway_area_screen.dart';
import 'lights_lounge_lounge_area_screen.dart';
import 'shades_lounge_hallway_area_screen.dart';

class ShadesLoungeScreen extends StatefulWidget {
  const ShadesLoungeScreen({super.key, title});

  @override
  State<ShadesLoungeScreen> createState() => _ShadesLoungeScreenState();
}

class _ShadesLoungeScreenState extends State<ShadesLoungeScreen> with TickerProviderStateMixin {
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

  TabBar get _tabBar => TabBar(
        enableFeedback: false,
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black; //<-- SEE HERE
            }
            return null;
          },
        ),
        automaticIndicatorColorAdjustment: true,
        indicatorColor: myTheme.tabBarTheme?.indicatorColor,
        unselectedLabelColor: myTheme.tabBarTheme?.unselectedLabelColor,
        labelColor: myTheme.tabBarTheme?.labelColor,
        indicatorSize: myTheme.tabBarTheme?.indicatorSize,
        labelStyle: myTheme.tabBarTheme?.labelStyle,
        indicatorWeight: myTheme.tabBarTheme!.indicatorWeight!.toDouble(),
        physics: const NeverScrollableScrollPhysics(),
        tabs: const <Widget>[
          Tab(
            // height: 40,
            // icon: Icon(Icons.speaker),
            text: 'LOUNGE & HALLWAY',
          ),
          Tab(
            // height: 40,
            // icon: Icon(Icons.speaker),
            text: 'LOUNGE',
          ),
          Tab(
            // height: 40,
            // icon: Icon(Icons.speaker),
            text: 'HALLWAY',
          ),
        ],
      );

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
              bottom: PreferredSize(
                preferredSize: _tabBar.preferredSize,
                child: ColoredBox(
                  color: myTheme.tabBarTheme?.tabColor as Color,
                  child: _tabBar,
                ),
              ),
            ),
            body: const TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                ShadesLoungeLoungeHallwayAreaScreen(),
                ShadesLoungeAreaScreen(),
                ShadesLoungeHallwayAreaScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
