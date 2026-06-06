import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/time_service.dart';
import '../providers/current_state_provider.dart';
import '../providers/screensavers_provider.dart';
import '../widgets/lopa_menu_screen.dart';
import '../widgets/pullup_tab.dart';

import '../model/config_items.dart';
import '../providers/custom_theme_provider.dart';
import '../model/side_menu_item.dart';
import '../widgets/activity_detector.dart';
import '../widgets/wallpaper.dart';
import 'lights_aft_lav_lh_main_screen.dart';

class AftLav2Screen extends StatefulWidget {
  static const routeName = '/app/aftLav2';
  const AftLav2Screen({super.key});

  @override
  State<AftLav2Screen> createState() => _AftLav2ScreenState();
}

class _AftLav2ScreenState extends State<AftLav2Screen> {
  // in case we need to track navBar selected menu
  int selectedIndex = 0;

  // list of navBar items / menus it points to - specific for each menu
  List<SideMenuItem> menuItems = [
    SideMenuItem(
      title: 'LIGHTS',
      id: 'mi_lights',
      backgroundImage: 'assets/banners/banner_light.png',
      wallpaper: 'assets/backgrounds/bg_aft_lav.png',
      icon: Icons.lightbulb,
      widget: const LightsAftLavLhMainScreen(),
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
    String navigationKey = 'navBarCurrState_aftLav2';
    String lopaImage = 'assets/YG039-LOPA_Final_AftLavLH.png';
    String menuTitle = 'AFT LH LAV';

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
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    // assets/floorPlan.png

    // make sure screensaver is enabled or disabled based on the default value
    ScreenSaversProvider screensavers = Provider.of<ScreenSaversProvider>(context, listen: false);
    if (screensavers.getActive().toUpperCase() == 'DISABLED') {
      TimerService.of(context).disable();
    } else {
      TimerService.of(context).enable();
      TimerService.of(context).screenSaverRoute = screensavers.getScreensaverRouteByName(screensavers.getActive().toString());
    }

    return ActivityDetector(
      shouldNavigate: true,
      child: Stack(
        children: [
          // based on selected menu, change wallpaper
          // we need to find out from provider which menu is selected
          Selector<CurrentStateProvider, int>(
            selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(navigationKey),
            builder: (context, currStateValue, child) {
              selectedIndex = currStateValue;
              String wallpaperPath = menuItems[selectedIndex].wallpaper ?? myTheme.backgroundImagePath ?? '';
              return Wallpaper(imagePath: wallpaperPath);
            },
          ),
          // Wallpaper(imagePath: menuItems[selectedIndex].wallpaper),
          PullupTab(
            body: pullupBody(context),
            child: Selector<CurrentStateProvider, int>(
              selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(navigationKey),
              builder: (context, currStateValue, child) {
                return pullupChild(context, lopaImage, menuTitle, views, menuItems, navigationKey, myTheme, updateIndex, showGlobalMenuBtn: true);
              },
            ),
          )
        ],
      ),
    );
  }
}
