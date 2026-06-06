import 'package:ORX_Galley/screens/ionization_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/config_items.dart';
import '../model/image_state.dart';
import '../model/side_menu_item.dart';
import '../model/time_service.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../providers/screensavers_provider.dart';
import '../screens/screen_callmap.dart';
import '../widgets/activity_detector.dart';
import '../widgets/lopa_menu_screen.dart';
// import '../widgets/fps_counter.dart';
import '../widgets/pullup_tab.dart';
import '../widgets/wallpaper.dart';
import 'entertainment_global.dart';
import 'lights_global.dart';
import 'screen_humidifier.dart';
import 'shades_screen.dart';
import 'water_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/app/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // in case we need to track navBar selected menu
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  // lets track navBar expanded state globally

  // list of navBar items / menus it points to - specific for each menu
  List<SideMenuItem> menuItems = [
    SideMenuItem(
      title: 'LIGHTING',
      id: 'mi_lights',
      // icon: Icons.lightbulb,
      imageStates: [
        ImageState(imagePath: 'assets/icons/icon_light.png', imageEffect: ImageEffect.grayscale),
        ImageState(imagePath: 'assets/icons/icon_light.png', imageEffect: ImageEffect.none)
      ],
      backgroundImage: 'assets/banners/banner_light.png',
      wallpaper: 'assets/backgrounds/bg_global_lights.png',
      widget: const LightsGlobalScreen(),
    ),
    SideMenuItem(
      title: 'ENTERTAINMENT',
      id: 'mi_Entertainment',
      // icon: Icons.tv,
      imageStates: [
        ImageState(imagePath: 'assets/icons/icon_tv.png', imageEffect: ImageEffect.grayscale),
        ImageState(imagePath: 'assets/icons/icon_tv.png', imageEffect: ImageEffect.none)
      ],
      backgroundImage: 'assets/banners/banner_entertainment.png',
      wallpaper: 'assets/backgrounds/bg_global_ent.png',
      widget: const EntertainmentGlobalScreen(),
    ),
    // SideMenuItem(
    //     title: 'TEMPERATURE',
    //     id: 'mi_Temperature',
    //     // icon: Icons.thermostat,
    //     imageStates: [
    //       ImageState(imagePath: 'assets/icons/icon_temp.png', imageEffect: ImageEffect.grayscale),
    //       ImageState(imagePath: 'assets/icons/icon_temp.png', imageEffect: ImageEffect.none)
    //     ],
    //     widget: const TempScreen(
    //       key: ValueKey('temp-screen'), // Use stable key
    //     )),
    SideMenuItem(
        title: 'SHADES',
        id: 'mi_Shades',
        // icon: Icons.thermostat,
        imageStates: [
          ImageState(imagePath: 'assets/icons/icon_shade.png', imageEffect: ImageEffect.grayscale),
          ImageState(imagePath: 'assets/icons/icon_shade.png', imageEffect: ImageEffect.none)
        ],
        backgroundImage: 'assets/banners/banner_shades.png',
        wallpaper: 'assets/backgrounds/bg_dining_shades.png',
        widget: const ShadesScreen(
          key: ValueKey('shades-screen'), // Use stable key
        )),
    SideMenuItem(
      title: 'HUMIDIFICATION',
      id: 'mi_humidifier',
      // icon: Icons.water_drop,
      imageStates: [
        ImageState(imagePath: 'assets/icons/icon_humid.png', imageEffect: ImageEffect.grayscale),
        ImageState(imagePath: 'assets/icons/icon_humid.png', imageEffect: ImageEffect.none)
      ],
      backgroundImage: 'assets/banners/banner_humidifier.png',
      wallpaper: 'assets/backgrounds/bg_global_humidifier.png',
      widget: const HumidifierScreen(),
    ),
    SideMenuItem(
      title: 'WATER',
      id: 'mi_water',
      // icon: Icons.water_drop,
      imageStates: [
        ImageState(imagePath: 'assets/icons/icon_water.png', imageEffect: ImageEffect.grayscale),
        ImageState(imagePath: 'assets/icons/icon_water.png', imageEffect: ImageEffect.none)
      ],
      backgroundImage: 'assets/banners/banner_water.png',
      wallpaper: 'assets/backgrounds/bg_global_water.png',
      widget: const WaterScreen(),
    ),
    SideMenuItem(
      title: 'CALL MAP',
      id: 'mi_CallMap',
      // icon: Icons.notifications,
      imageStates: [
        ImageState(imagePath: 'assets/icons/icon_bell.png', imageEffect: ImageEffect.grayscale),
        ImageState(imagePath: 'assets/icons/icon_bell.png', imageEffect: ImageEffect.none)
      ],
      backgroundImage: 'assets/banners/banner_call.png',
      wallpaper: 'assets/backgrounds/bg_global_callmap3.png',
      widget: const CallMapScreen(
        // Use const constructor with stable key
        key: ValueKey('call-map-screen'),
      ),
    ),
    SideMenuItem(
      title: 'IONIZATION',
      id: 'mi_Ionization',
      // icon: Icons.notifications,
      imageStates: [
        ImageState(imagePath: 'assets/icons/banner_ionizer.png', imageEffect: ImageEffect.grayscale),
        ImageState(imagePath: 'assets/icons/banner_ionizer.png', imageEffect: ImageEffect.none)
      ],
      backgroundImage: 'assets/banners/banner_ionizer.png',
      wallpaper: 'assets/backgrounds/bg_global_ionization.png',
      widget: const IonizationScreen(),
    ),
    // SideMenuItem(
    //   title: 'BRIGHTNESS',
    //   id: 'mi_Brightness',
    //   // icon: Icons.brightness_medium,
    //   imageStates: [
    //     ImageState(imagePath: 'assets/icons/icon_brt.png', imageEffect: ImageEffect.grayscale),
    //     ImageState(imagePath: 'assets/icons/icon_brt.png', imageEffect: ImageEffect.none)
    //   ],
    //   widget: const BrightnessScreen(
    //     key: ValueKey('brightness-screen'), // Use stable key
    //   ),
    // ),
    // SideMenuItem(
    //   title: 'SETTINGS',
    //   id: 'mi_Settings',
    //   // icon: Icons.settings,
    //   imageStates: [
    //     // ImageState(imagePath: 'assets/icons/icon_wrench.png', imageEffect: ImageEffect.grayscale),
    //     // ImageState(imagePath: 'assets/icons/icon_wrench.png', imageEffect: ImageEffect.none)
    //   ],
    //   backgroundImage: 'assets/banners/banner_settings.png',
    //   isVisible: true,
    //   holdTimeDuration: const Duration(seconds: 2),
    //   widget: const SettingsScreen(),
    // ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    String navigationKey = 'navBarCurrState_home';
    String lopaImage = 'assets/YG039-LOPA_Final.png';
    String menuTitle = 'GLOBAL';

    final currentStateProvider = Provider.of<CurrentStateProvider>(
      context,
      listen: false,
    );

    void updateIndex(int index) {
      // final startTime = DateTime.now();
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
