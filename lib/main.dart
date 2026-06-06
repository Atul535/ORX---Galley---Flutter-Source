import 'dart:async';
import 'dart:io';
import 'package:ORX_Galley/screens/screen_aft_galley.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../providers/ethernet_info_provider.dart';
import '../providers/wallpapers_provider.dart';
import 'config/config_items.dart';
import 'generated/assets.dart';
import 'helpers/utility.dart';
import 'managers/download_manager.dart';
import 'providers/settings_provider.dart';
import 'providers/socket_provider.dart';
import 'screens/base/edit_settings_screen.dart';
import 'screens/home_menu_screen.dart';
import 'screens/screen_aft_lh_lav.dart';
import 'screens/screen_bedroom.dart';
import 'screens/screen_dining.dart';
import 'screens/screen_vip_lav.dart';
import 'screens/screen_galley.dart';
import 'screens/screen_hallway.dart';
import 'screens/screen_lounge.dart';
import 'screens/screen_maintenance.dart';
import 'screens/screen_business_class.dart';
import '../screens/screen_saver_blank.dart';

import 'can-helpers/can_manager.dart';
import 'providers/current_state_provider.dart';
import 'providers/custom_theme_provider.dart';

import 'model/time_service.dart';
import 'providers/screensavers_provider.dart';
import 'providers/timer_service_provider.dart';
import 'screens/screen_aft_rh_lav.dart';
import 'screens/screen_master_lav.dart';
import 'screens/screen_saver_logo.dart';
import 'screens/home_screen.dart';
import 'screens/screen_saver_universe.dart';
import 'screens/screen_staff_area.dart';
import 'screens/settings_screen.dart';
import 'screens/temp_screen.dart';
import 'services/gpio_service.dart';
import 'utils/logger.dart';

import 'helpers/protocol_decoder.dart';
import 'widgets/cfg_image.dart';

// this is solely for demo and testing purposes on windows
double windowScale = 1.0;
double windowHeight = 1080;
double windowWidth = 1920;
Future<void> configureWindow() async {
  if (Platform.isWindows) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    final windowOptions = WindowOptions(
      fullScreen: false,
      size: Size(windowWidth * windowScale, windowHeight * windowScale),
      center: true,
      titleBarStyle: TitleBarStyle.normal,
      windowButtonVisibility: true,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

void logImageCacheStats() {
  final cache = PaintingBinding.instance.imageCache;
  logDebug(
      'ImageCache',
      'Current: ${cache.currentSize} images, '
          '${(cache.currentSizeBytes / 1024 / 1024).toStringAsFixed(2)} MB / '
          '${(cache.maximumSizeBytes / 1024 / 1024).toStringAsFixed(2)} MB');
}

void main() async {
  // ensures that all the lower-level engine services, plugin calls, and widget system events
  // are fully accessible before you proceed with app initialization
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐ INCREASE IMAGE CACHE SIZE FOR FULL HD IMAGES
  //
  // Default values are:
  // - maximumSize: 1000 images
  // - maximumSizeBytes: 100 MB (104857600 bytes)
  //
  // CALCULATION FOR FULL HD (1920x1080):
  // - Uncompressed: 1920 × 1080 × 4 bytes (RGBA) = ~8.3 MB per image
  // - With 50 full HD images: 50 × 8.3 MB = ~415 MB
  // - With 100 full HD images: 100 × 8.3 MB = ~830 MB
  //
  // RECOMMENDED FOR FULL HD IMAGES:
  PaintingBinding.instance.imageCache.maximumSize =
      200; // Enough for all your screens
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      1024 * 1024 * 1024; // 1 GB

  // ⚠️ If you're running on Raspberry Pi or limited hardware, consider:
  // PaintingBinding.instance.imageCache.maximumSizeBytes = 512 * 1024 * 1024; // 512 MB

  // 💡 For desktop/high-memory devices with many full HD images:
  // PaintingBinding.instance.imageCache.maximumSizeBytes = 2 * 1024 * 1024 * 1024; // 2 GB

  // Log current cache settings (for debugging)
  logInfo('ImageCache',
      'Max images: ${PaintingBinding.instance.imageCache.maximumSize}');
  logInfo('ImageCache',
      'Max size: ${(PaintingBinding.instance.imageCache.maximumSizeBytes / 1024 / 1024).toStringAsFixed(2)} MB');

  // for testing and demo purposes mainly
  configureWindow();

  // for Debug only in windows
  ProtocolSetup.initialize();

  // Make app full-screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // prevent system gestures
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );

  // start CAN
  CanManager();

  // ensure to have logger initialized
  Logger logger = Logger();
  logger.setLogLevel(LogLevel.info);

  // lets initialize the reverseLookupMap with configItems
  // this is for state management to quickly find object and state a first command belongs to - for tracking
  // meaning based on the received command and first command attached to a state of a an object we can find out
  // which object and which state we should switch this object to
  registerAdditionalConfigs(configItems); // register additional configs
  reverseLookup = buildReverseLookup(configItems);

  // Initialize the GPIO service for local relay control
  gpioService = GpioService();

  Future.delayed(const Duration(seconds: 5), () {
    // This runs after 5 seconds, without blocking anything
    gpioService?.fanOn();
  });

  // Add periodic memory check
  // Timer.periodic(const Duration(seconds: 5), (timer) {
  //   developer.log('Memory used: ${(ProcessInfo.currentRss / 1024 / 1024).toStringAsFixed(2)} MB');
  // });

  runApp(
    TimerServiceProvider(
      service: TimerService(),
      child: Platform.isWindows && windowScale != 1
          ? _ScaledApp(child: const MyApp())
          : const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;
  bool _imagesLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!_imagesLoaded) {
      _precacheImages();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesLoaded) {
      _precacheImages();
    }
  }

  Future<void> _precacheImages() async {
    try {
      await Future.wait(
        GeneratedAssets.allImages.map(
          (path) => precacheImage(
            cfgImageProvider(path),
            context,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _imagesLoaded = true;
      });

      logDebug(
        "main",
        "Precached ${GeneratedAssets.allImages.length} images using cfgImageProvider",
      );

      logImageCacheStats();
    } catch (e) {
      logDebug("main", "Error precaching images: $e");

      if (!mounted) {
        return;
      }

      setState(() {
        _imagesLoaded = true; // continue even on failure
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cache images to avoid initial image flicker
    // List<String> imageNames = [
    //   'YG039-LOPA_Final_FwdLav.png',
    //   'YG039-LOPA_Final_AftLav.png',
    //   'YG039-LOPA_Final_AftLav2.png',
    //   'YG039-LOPA_Final_AftGalley.png',
    //   'YG039-LOPA_Final_bedroom.png',
    //   'YG039-LOPA_Final_office.png',
    //   'YG039-LOPA_Final_hallway.png',
    //   'YG039-LOPA_Final_dining.png',
    //   'YG039-LOPA_Final_lounge.png',
    //   'YG039-LOPA_Final_crew.png',
    //   'YG039-LOPA_Final_galley.png',
    //   'YG039-LOPA_Final.png'
    // ];
    // for (var imageName in imageNames) {
    //   precacheImage(AssetImage('assets/$imageName'), context);
    // }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => SettingsProvider(),
        ),
        ChangeNotifierProvider<SocketProvider>(
          create: (context) => SocketProvider(
            reloadSettingsCallback: () =>
                Provider.of<SettingsProvider>(context, listen: false)
                    .loadSettings(),
          )..connect(),
        ),
        ChangeNotifierProvider(
            create: (ctx) =>
                Wallpapers() // -- more efficient if new instance of object is created
            // value: Products(), -- this id for reusing exisitng objecst - like list of grids
            ),
        // ChangeNotifierProvider(create: (ctx) => CurrentStateProvider(configItems, SettingsProvider()..loadSettings()) // -- more efficient if new instance of object is created
        //     // value: Products(), -- this id for reusing exisitng objecst - like list of grids
        //     ),
        ChangeNotifierProvider(create: (ctx) {
          final settingsProvider = SettingsProvider()..loadSettings();
          return CurrentStateProvider(
              settingsProvider: settingsProvider,
              useCan: true,
              useEthernet: false,
              useGpio: true)
            ..initialize(configItems);
        }),
        ChangeNotifierProvider(
            create: (ctx) =>
                ScreenSaversProvider() // -- more efficient if new instance of object is created
            // value: Products(), -- this id for reusing exisitng objecst - like list of grids
            ),
        ChangeNotifierProvider(
            create: (ctx) =>
                EthernetInfoProvider() // -- more efficient if new instance of object is created
            // value: Products(), -- this id for reusing exisitng objecst - like list of grids
            ),
        ChangeNotifierProvider(
            create: (ctx) =>
                TimerService() // -- more efficient if new instance of object is created
            // value: Products(), -- this id for reusing exisitng objecst - like list of grids
            ),
        ChangeNotifierProvider(
            create: (ctx) =>
                CustomThemes() // -- more efficient if new instance of object is created
            // value: customThemes[0],
            // builder:  -- this id for reusing exisitng objecst - like list of grids
            ),
      ],
      child: Consumer<CustomThemes>(
        builder: (context, theme, child) {
          // Initialize SocketProvider to make sure connection is made
          Provider.of<SocketProvider>(context, listen: false).connect();

          // Initialize the SettingsProvider
          Provider.of<SettingsProvider>(context, listen: false).loadSettings();

          // Initialize Download manager
          if (!_isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              DownloadManager().init(context);

              // make sure we check config and update config version / settings.json if different
              checkAndUpdateConfiguration(context);
            });
            _isInitialized = true;
          }

          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false, // hide debug
            title: 'ORX_10_2_Galley',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not restarted.
              // iconTheme: IconThemeData(size: 55),
              useMaterial3: false,
              fontFamily: theme.getActiveTheme().fontFamily ?? 'Roboto',
              fontFamilyFallback: [
                theme.getActiveTheme().fontFamily.toString(),
                'Roboto'
              ],
              brightness: theme.getActiveTheme().brightness,
              primaryColor: theme.getActiveTheme().primaryColor,
              appBarTheme: theme.getActiveTheme().appBarTheme,
              bottomAppBarTheme: BottomAppBarThemeData(
                color: Colors.black87.withOpacity(0.2),
                height: 120,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              canvasColor: theme.getActiveTheme().backgroundImagePath == null ||
                      theme.getActiveTheme().backgroundImagePath!.isEmpty
                  ? theme.getActiveTheme().canvasColor
                  : Colors.transparent,
              elevatedButtonTheme:
                  theme.getActiveTheme().elevatedButtonThemeData,
              textTheme: theme.getActiveTheme().textTheme,
            ),
            home: const HomeMenuScreen(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case HomeScreen.routeName:
                  return buildPageRoute(
                      child: const HomeScreen(),
                      settings: settings,
                      animated: false);
                case TempScreen.routeName:
                  return buildPageRoute(
                      child: const TempScreen(),
                      settings: settings,
                      animated: false);
                case SettingsScreen.routeName:
                  return buildPageRoute(
                      child: const SettingsScreen(),
                      settings: settings,
                      animated: false);
                case ScreenSaverBlank.routeName:
                  return buildPageRoute(
                      child: const ScreenSaverBlank(),
                      settings: settings,
                      animated: false);

                case ScreenSaverLogo.routeName:
                  return buildPageRoute(
                      child: const ScreenSaverLogo(),
                      settings: settings,
                      animated: false);
                case ScreenSaverUniverse.routeName:
                  return buildPageRoute(
                      child: const ScreenSaverUniverse(),
                      settings: settings,
                      animated: false);

                case AftLavScreen.routeName:
                  return buildPageRoute(
                      child: const AftLavScreen(),
                      settings: settings,
                      animated: false);
                case AftLav2Screen.routeName:
                  return buildPageRoute(
                      child: const AftLav2Screen(),
                      settings: settings,
                      animated: false);

                case AftGalleyScreen.routeName:
                  return buildPageRoute(
                      child: const AftGalleyScreen(),
                      settings: settings,
                      animated: false);
                case StaffAreaScreen.routeName:
                  return buildPageRoute(
                      child: const StaffAreaScreen(),
                      settings: settings,
                      animated: false);
                case MasterLavScreen.routeName:
                  return buildPageRoute(
                      child: const MasterLavScreen(),
                      settings: settings,
                      animated: false);
                case GalleyScreen.routeName:
                  return buildPageRoute(
                      child: const GalleyScreen(),
                      settings: settings,
                      animated: false);
                case HallwayScreen.routeName:
                  return buildPageRoute(
                      child: const HallwayScreen(),
                      settings: settings,
                      animated: false);
                case LoungeScreen.routeName:
                  return buildPageRoute(
                      child: const LoungeScreen(),
                      settings: settings,
                      animated: false);
                case DiningScreen.routeName:
                  return buildPageRoute(
                      child: const DiningScreen(),
                      settings: settings,
                      animated: false);
                case BusinessClassScreen.routeName:
                  return buildPageRoute(
                      child: const BusinessClassScreen(),
                      settings: settings,
                      animated: false);
                case BedroomScreen.routeName:
                  return buildPageRoute(
                      child: const BedroomScreen(),
                      settings: settings,
                      animated: false);
                case VipLavScreen.routeName:
                  return buildPageRoute(
                      child: const VipLavScreen(),
                      settings: settings,
                      animated: false);

                case HomeMenuScreen.routeName:
                  return buildPageRoute(
                      child: const HomeMenuScreen(),
                      settings: settings,
                      animated: false);
                case MaintenanceScreen.routeName:
                  return buildPageRoute(
                      child: const MaintenanceScreen(),
                      settings: settings,
                      animated: false);
                case EditSettingsScreen.routeName:
                  return buildPageRoute(
                      child: const EditSettingsScreen(),
                      settings: settings,
                      animated: false);
                default:
                  return buildPageRoute(
                      child: const HomeMenuScreen(),
                      settings: settings,
                      animated: false);
              }
            },

            onUnknownRoute: (RouteSettings settings) {
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (BuildContext context) => Scaffold(
                    body: SafeArea(
                        child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Menu Not Found',
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, HomeMenuScreen.routeName);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Colors.green, // set the background color
                      ),
                      child: const Text('Return HOME!'),
                    ),
                  ],
                ))),
              );
            },
          );
        },
      ),
    );
  }
}

class UnanimatedPageRoute<T> extends MaterialPageRoute<T> {
  UnanimatedPageRoute({
    required Widget Function(BuildContext) builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
          builder: builder,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

Route<T?> buildPageRoute<T>({
  required Widget child,
  RouteSettings? settings,
  bool animated = false,
}) {
  if (animated) {
    return MaterialPageRoute<T?>(
        builder: (BuildContext context) => child, settings: settings);
  }

  return UnanimatedPageRoute<T?>(
    builder: (BuildContext context) => child,
    settings: settings,
  );
}

Future<void> checkAndUpdateConfiguration(BuildContext context) async {
  final settingsProvider =
      Provider.of<SettingsProvider>(context, listen: false);
  final socketProvider = Provider.of<SocketProvider>(context, listen: false);

  // Wait until settings are actually loaded
  while (!settingsProvider.isLoaded) {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  bool needConfigReload = false;
  bool needsRestart = false;

  // Check Rotation
  if ((CONFIG_ROTATION == 0 ||
          CONFIG_ROTATION == 90 ||
          CONFIG_ROTATION == 180 ||
          CONFIG_ROTATION == 270) &&
      settingsProvider.rotation != CONFIG_ROTATION) {
    logInfo('Main',
        'Rotation mismatch: ${settingsProvider.rotation} != $CONFIG_ROTATION');
    await settingsProvider.updateRotation(CONFIG_ROTATION);
    needsRestart = true;
  }

  // Check ACID
  if ((CONFIG_ACID >= 0 && CONFIG_ACID <= 255) &&
      settingsProvider.acid != CONFIG_ACID) {
    logInfo('Main', 'ACID mismatch: ${settingsProvider.acid} != $CONFIG_ACID');
    await settingsProvider.updateAcid(CONFIG_ACID);
    needsRestart = true;
  }

  // Check Version
  if (settingsProvider.configVersion['major'] != CONFIG_VERSION['major'] ||
      settingsProvider.configVersion['minor'] != CONFIG_VERSION['minor']) {
    logInfo('Main',
        'Version mismatch: ${settingsProvider.configVersion} != $CONFIG_VERSION');
    await settingsProvider.updateVersionFile(CONFIG_VERSION);
    needsRestart = true;
  }

  // Check Display Width
  if (CONFIG_DISPLAY_WIDTH >= 0 &&
      settingsProvider.displayWidth != CONFIG_DISPLAY_WIDTH) {
    logInfo('Main',
        'Display Width mismatch: ${settingsProvider.displayWidth} != $CONFIG_DISPLAY_WIDTH');
    await settingsProvider.updateDisplayWidth(CONFIG_DISPLAY_WIDTH);
    needsRestart = true;
  }

  // Check Display Height
  if (CONFIG_DISPLAY_HEIGHT >= 0 &&
      settingsProvider.displayHeight != CONFIG_DISPLAY_HEIGHT) {
    logInfo('Main',
        'Display Height mismatch: ${settingsProvider.displayHeight} != $CONFIG_DISPLAY_HEIGHT');
    await settingsProvider.updateDisplayHeight(CONFIG_DISPLAY_HEIGHT);
    needsRestart = true;
  }

  // Check HW type
  if (CONFIG_HW_ID >= 0 && settingsProvider.hwId != CONFIG_HW_ID.toString()) {
    logInfo(
        'Main', 'HW ID mismatch: ${settingsProvider.hwId} != $CONFIG_HW_ID');
    await settingsProvider.updateHwId(CONFIG_HW_ID);
    needsRestart = true;
  }

  // Check App aspect ratio
  if (settingsProvider.scaleFactorGuiApp > 0 &&
      CONFIG_SCALE_FACTOR_GUI_APP != settingsProvider.scaleFactorGuiApp) {
    logInfo('Main',
        'App aspect ratio mismatch: ${settingsProvider.scaleFactorGuiApp} != $CONFIG_SCALE_FACTOR_GUI_APP');
    await settingsProvider.updateScaleFactorGuiApp(CONFIG_SCALE_FACTOR_GUI_APP);
    needsRestart = true;
  }

  // Check apploader GUI aspect ratio
  if (settingsProvider.scaleFactorGuiAppLoader > 0 &&
      CONFIG_SCALE_FACTOR_GUI_APP_LOADER !=
          settingsProvider.scaleFactorGuiAppLoader) {
    logInfo('Main',
        'AppLoader GUI aspect ratio mismatch: ${settingsProvider.scaleFactorGuiAppLoader} != $CONFIG_SCALE_FACTOR_GUI_APP_LOADER');
    await settingsProvider
        .updateScaleFactorGuiAppLoader(CONFIG_SCALE_FACTOR_GUI_APP_LOADER);
    needsRestart = true;
  }

  // Send appropriate socket commands
  if (needsRestart) {
    logInfo('Main', 'Sending restart command due to rotation change');
    socketProvider.sendMessageWithFraming([2]);
  } else if (needConfigReload) {
    logInfo('Main', 'Sending reset command due to ACID/version change');
    socketProvider.sendMessageWithFraming([1]);
  }
}

class _ScaledApp extends StatelessWidget {
  final Widget child;
  const _ScaledApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fill, // nebo BoxFit.contain / cover podle chuti
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: windowWidth,
        height: windowHeight,
        child: MediaQuery(
          // říkáme celé appce: "máš 1080x1920"
          data: const MediaQueryData(
            size: Size(1080, 1920),
            // můžeš doladit, ale pro dev účely tohle většinou stačí
            devicePixelRatio: 1.0,
          ),
          child: child,
        ),
      ),
    );
  }
}
