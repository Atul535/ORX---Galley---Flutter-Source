import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/config_items.dart';
import '../model/image_state.dart';
import '../model/side_menu_item.dart';
import '../model/time_service.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../providers/screensavers_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/lopa_menu_screen.dart';
import '../widgets/pullup_tab.dart';
import '../widgets/wallpaper.dart';

// Reuse existing screens (same as HomeScreen)
import 'maintenance_lighting_screen.dart';
import 'maintenance_wifi_screen.dart';
// New placeholder maintenance subpages
import 'maintenance_humidifier_screen.dart';
import 'maintenance_power_outlets_screen.dart';
import 'maintenance_ecb_screen.dart';
import 'maintenance_water_heaters_screen.dart';

class MaintenanceScreen extends StatefulWidget {
  static const routeName = '/app/maintenance';
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  int selectedIndex = 0;

  // Side menu items for Maintenance
  late final List<SideMenuItem> menuItems = [
    SideMenuItem(
      title: 'OUTLETS & DOORS',
      id: 'mi_maint_outlets',
      imageStates: [
        ImageState(imagePath: 'assets/icons/icon_outlets.png', imageEffect: ImageEffect.grayscale),
        ImageState(imagePath: 'assets/icons/icon_outlets.png', imageEffect: ImageEffect.none),
      ],
      backgroundImage: 'assets/banners/banner_outlets.png',
      wallpaper: 'assets/backgrounds/bg_outlets.png',
      widget: const MaintenancePowerOutletsScreen(),
    ),
    SideMenuItem(
      title: 'CIRCUIT BREAKERS',
      id: 'mi_maint_ecb',
      imageStates: [
        ImageState(imagePath: 'assets/icons/icon_ecb.png', imageEffect: ImageEffect.grayscale),
        ImageState(imagePath: 'assets/icons/icon_ecb.png', imageEffect: ImageEffect.none),
      ],
      backgroundImage: 'assets/banners/banner_ecb.png',
      wallpaper: 'assets/backgrounds/bg_ecb.png',
      widget: const MaintenanceEcbScreen(),
    ),
    SideMenuItem(
      title: 'HUMIDIFIER',
      id: 'mi_maint_humidifier',
      imageStates: [
        ImageState(imagePath: 'assets/icons/icon_humid.png', imageEffect: ImageEffect.grayscale),
        ImageState(imagePath: 'assets/icons/icon_humid.png', imageEffect: ImageEffect.none),
      ],
      backgroundImage: 'assets/banners/banner_humidifier.png', // stejné jako HomeScreen
      wallpaper: 'assets/backgrounds/bg_global_humidifier2.png', // stejné jako HomeScreen
      widget: const MaintenanceHumidifierScreen(), // reuse
    ),
    SideMenuItem(
      title: 'LIGHTS',
      id: 'mi_maint_lights',
      imageStates: [
        ImageState(imagePath: 'assets/icons/icon_light.png', imageEffect: ImageEffect.grayscale),
        ImageState(imagePath: 'assets/icons/icon_light.png', imageEffect: ImageEffect.none),
      ],
      backgroundImage: 'assets/banners/banner_light.png', // stejné jako HomeScreen
      wallpaper: 'assets/backgrounds/bg_maint_light2.png', // stejné jako HomeScreen
      widget: const MaintenanceLightingScreen(), // reuse
    ),
    SideMenuItem(
      title: 'WATER HEATERS',
      id: 'mi_maint_water_heaters',
      imageStates: [
        ImageState(imagePath: 'assets/icons/icon_water.png', imageEffect: ImageEffect.grayscale),
        ImageState(imagePath: 'assets/icons/icon_water.png', imageEffect: ImageEffect.none),
      ],
      backgroundImage: 'assets/banners/banner_water.png', // "water background" jako HomeScreen
      wallpaper: 'assets/backgrounds/bg_global_water2.png', // stejné jako HomeScreen
      widget: const MaintenanceWaterHeatersScreen(),
    ),
    SideMenuItem(
      title: 'WIFI',
      id: 'mi_wifi',
      // icon: Icons.lightbulb,
      // imageStates: [
      //   ImageState(imagePath: 'assets/icons/icon_light.png', imageEffect: ImageEffect.grayscale),
      //   ImageState(imagePath: 'assets/icons/icon_light.png', imageEffect: ImageEffect.none)
      // ],
      backgroundImage: 'assets/banners/banner_wifi.png',
      wallpaper: 'assets/backgrounds/bg_wifi.png',
      widget: const MaintenanceWifiScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const String navigationKey = 'navBarCurrState_maintenance';
    const String lopaImage = 'assets/YG039-LOPA_Final.png'; // stejné jako HomeScreen (i když skryté)
    const String menuTitle = 'MAINTENANCE';

    final currentStateProvider = Provider.of<CurrentStateProvider>(context, listen: false);

    void updateIndex(int index) {
      currentStateProvider.setCurrentState(navigationKey, index);
    }

    // create list of Widgets based on the menuItems data
    List<Widget> views = menuItems.map((item) {
      return LopaMenuScreen(title: item.title, child: item.widget);
    }).toList();

    // theme + wallpaper
    final CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    // screensaver same behavior as HomeScreen
    final ScreenSaversProvider screensavers = Provider.of<ScreenSaversProvider>(context, listen: false);
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
                return pullupChild(context, lopaImage, menuTitle, views, menuItems, navigationKey, myTheme, updateIndex, showGlobalMenuBtn: true, showLopa: false);
              },
            ),
          )
        ],
      ),
    );
  }
}
