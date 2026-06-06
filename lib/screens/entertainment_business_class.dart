import 'package:ORX_Galley/screens/entertainment_business_class_lh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import 'entertainment_business_class_all.dart';
import 'entertainment_business_class_rh.dart';

class EntertainmentBusinessClassScreen extends StatefulWidget {
  const EntertainmentBusinessClassScreen({super.key, title});

  @override
  State<EntertainmentBusinessClassScreen> createState() => _EntertainmentBusinessClassScreenState();
}

class _EntertainmentBusinessClassScreenState extends State<EntertainmentBusinessClassScreen> with TickerProviderStateMixin {
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
            text: 'LH VIDEO',
          ),
          Tab(
            // height: 40,
            // icon: Icon(Icons.speaker),
            text: 'RH VIDEO',
          ),
          Tab(
            // height: 40,
            // icon: Icon(Icons.speaker),
            text: 'ALL',
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
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                EntertainmentBusinessClassLh(key: PageStorageKey('lh')),
                EntertainmentBusinessClassRh(key: PageStorageKey('rh')),
                EntertainmentBusinessClassAll(key: PageStorageKey('all')),
                // EntertainmentLoungeFwd(),
                // EntertainmentLoungeFwd(),
                // EntertainmentLoungeAudio(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
