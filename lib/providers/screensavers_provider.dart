import 'package:flutter/material.dart';

import '../screens/screen_saver_blank.dart';
import '../screens/screen_saver_logo.dart';
import '../screens/screen_saver_universe.dart';

class ScreenSaver {
  String name;
  String route;
  bool isActive;

  ScreenSaver({required this.name, this.isActive = false, required this.route});
}

class ScreenSaversProvider with ChangeNotifier {
  final List<ScreenSaver> _screensavers = <ScreenSaver>[
    ScreenSaver(
      name: 'DISABLED',
      route: '',
      isActive: true,
    ),
    ScreenSaver(
      name: 'Blank screen',
      route: ScreenSaverBlank.routeName,
      isActive: false,
    ),
    ScreenSaver(
      name: 'Logo',
      route: ScreenSaverLogo.routeName,
      isActive: false,
    ),
    ScreenSaver(
      name: 'Universe',
      route: ScreenSaverUniverse.routeName,
      isActive: false,
    ),
    // ScreenSaver(
    //   name: 'Parallax Rain',
    //   route: ScreenSaverParallaxRain.routeName,
    //   isActive: false,
    // ),
  ];

  List<Object> get screensavers => _screensavers;

  void setActiveScreensaver(String screensaverName) {
    _clearActive();
    _screensavers.firstWhere((obj) => obj.name == screensaverName).isActive = true;
    notifyListeners();
  }

  void _clearActive() {
    _screensavers.firstWhere((obj) => obj.isActive == true).isActive = false;
  }

  String getActive() {
    return _screensavers.firstWhere((obj) => obj.isActive == true).name;
  }

  List<String> get getScreensaverNames {
    List<String> screensaverNames = [];
    for (var item in _screensavers) {
      screensaverNames.add(item.name);
    }
    return screensaverNames;
  }

  String getScreensaverRouteByName(screensaverName) {
    return _screensavers.firstWhere((obj) => obj.name == screensaverName).route;
  }
}
