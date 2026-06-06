import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/generic_selection_widget.dart';
import 'entertainment_dining_aft_lh.dart';
import 'entertainment_dining_aft_rh.dart';
import 'entertainment_dining_all.dart';
import 'entertainment_dining_audio.dart';
import 'entertainment_dining_fwd.dart';
import 'entertainment_lounge_all.dart';
import 'entertainment_lounge_audio.dart';
import 'entertainment_lounge_fwd.dart';
import 'lights_lounge_lounge_area_screen.dart';

class EntertainmentDiningScreen extends StatefulWidget {
  const EntertainmentDiningScreen({super.key, title});

  @override
  State<EntertainmentDiningScreen> createState() => _EntertainmentDiningScreenState();
}

class _EntertainmentDiningScreenState extends State<EntertainmentDiningScreen> with TickerProviderStateMixin {
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
        tabs: const <Widget>[
          Tab(
            // height: 40,
            // icon: Icon(Icons.speaker),
            text: 'FWD VIDEO',
          ),
          Tab(
            // height: 40,
            // icon: Icon(Icons.speaker),
            text: 'AFT LH VIDEO',
          ),
          Tab(
            // height: 40,
            // icon: Icon(Icons.speaker),
            text: 'ALL RH VIDEO',
          ),
          Tab(
            // height: 40,
            // icon: Icon(Icons.speaker),
            text: 'ALL VIDEO',
          ),
          Tab(
            // height: 40,
            // icon: Icon(Icons.speaker),
            text: 'AUDIO',
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
          length: _tabBar.tabs.length,
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
                EntertainmentDiningFwd(key: PageStorageKey('fwd')),
                EntertainmentDiningAftLh(key: PageStorageKey('aftlh')),
                EntertainmentDiningAftRh(key: PageStorageKey('aftrh')),
                EntertainmentDiningAll(key: PageStorageKey('all')),
                EntertainmentDiningAudio(key: PageStorageKey('audio')),
                // EntertainmentDiningFwd(),
                // EntertainmentDiningFwd(),
                // EntertainmentDiningAudio(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
