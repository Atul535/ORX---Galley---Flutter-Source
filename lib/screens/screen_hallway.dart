import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/config_items.dart';
import '../model/time_service.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../model/side_menu_item.dart';
import '../providers/screensavers_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/lopa_menu_screen.dart';
import '../widgets/wallpaper.dart';
import 'lights_hallway.dart';
import '../widgets/pullup_tab.dart';

class HallwayScreen extends StatefulWidget {
  static const routeName = '/app/hallway';
  const HallwayScreen({super.key});

  @override
  State<HallwayScreen> createState() => _HallwayScreenState();
}

class _HallwayScreenState extends State<HallwayScreen> {
  // in case we need to track navBar selected menu
  int selectedIndex = 0;

  // list of navBar items / menus it points to - specific for each menu
  List<SideMenuItem> menuItems = [
    SideMenuItem(
      title: 'LIGHTS',
      id: 'mi_lights',
      icon: Icons.lightbulb,
      widget: const LightsHallwayScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // precacheImage(AssetImage('assets/floorPlan.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    String navigationKey = 'navBarCurrState_hallway';
    String lopaImage = 'assets/YG039-LOPA_Final_hallway.png';
    String menuTitle = 'HALLWAY';

    final currentStateProvider = Provider.of<CurrentStateProvider>(
      context,
      listen: false,
    );

    void updateIndex(int index) {
      currentStateProvider.setCurrentState(navigationKey, index);
    }

    // create list of Widgets based on the menuItems data
    List<Widget> views = menuItems.map((item) {
      return LopaMenuScreen(title: item.title, child: item.widget);
    }).toList();

    // lets get the active theme and adjust if neccessary
    CustomTheme myTheme =
        Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    // assets/floorPlan.png

    // make sure screensaver is enabled or disabled based on the default value
    ScreenSaversProvider screensavers =
        Provider.of<ScreenSaversProvider>(context, listen: false);
    if (screensavers.getActive().toUpperCase() == 'DISABLED') {
      TimerService.of(context).disable();
    } else {
      TimerService.of(context).enable();
      TimerService.of(context).screenSaverRoute = screensavers
          .getScreensaverRouteByName(screensavers.getActive().toString());
    }

    return ActivityDetector(
      shouldNavigate: true,
      child: Stack(
        children: [
          Wallpaper(imagePath: myTheme.backgroundImagePath),
          PullupTab(
            body: pullupBody(context),
            child: Selector<CurrentStateProvider, int>(
              selector: (context, currentStateNotifier) =>
                  currentStateNotifier.getCurrentState(navigationKey),
              builder: (context, currStateValue, child) {
                return pullupChild(context, lopaImage, menuTitle, views,
                    menuItems, navigationKey, myTheme, updateIndex,
                    showGlobalMenuBtn: true);
              },
            ),
          )
        ],
      ),
    );
  }
}

