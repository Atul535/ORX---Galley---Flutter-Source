import 'package:flutter/material.dart';

import 'app_bar_icon.dart';
import 'navigation_icon.dart';

class HomeMenu with ChangeNotifier {
  final List<NavigationIcon> _navItems = [
    NavigationIcon(
        id: 'nl_fwd_lav',
        title: 'Fwd Entrance',
        icon: Icons.abc,
        route: '/app/fwdLav',
        isActive: false,
        menuId: 'lopa'),
    NavigationIcon(
        id: 'nl_entrance',
        title: 'Fwd Entrance',
        icon: Icons.abc,
        route: '/app/fwdEntrance',
        isActive: false,
        menuId: 'lopa'),
    NavigationIcon(
        id: 'nl_galley',
        title: 'Galley',
        icon: Icons.abc,
        route: '/app/galley',
        isActive: false,
        menuId: 'lopa'),
    NavigationIcon(
        id: 'nl_refresh',
        title: 'Refreshment Center',
        icon: Icons.abc,
        route: '/app/refreshCenter',
        isActive: false,
        menuId: 'lopa'),
    NavigationIcon(
        id: 'nl_z1',
        title: 'z1',
        icon: Icons.abc,
        route: '/app/z1',
        isActive: false,
        menuId: 'lopa'),
    NavigationIcon(
        id: 'nl_z2',
        title: 'z2',
        icon: Icons.abc,
        route: '/app/z2',
        isActive: false,
        menuId: 'lopa'),
    NavigationIcon(
        id: 'nl_z3',
        title: 'z3',
        icon: Icons.abc,
        route: '/app/z3',
        isActive: false,
        menuId: 'lopa'),
    NavigationIcon(
        id: 'nl_z4',
        title: 'z4',
        icon: Icons.abc,
        route: '/app/z4',
        isActive: false,
        menuId: 'lopa'),
    NavigationIcon(
        id: 'nl_z5',
        title: 'z5',
        icon: Icons.abc,
        route: '/app/z5',
        isActive: false,
        menuId: 'lopa'),
    NavigationIcon(
        id: 'nl_home',
        title: 'Global',
        icon: Icons.abc,
        route: '/app/home',
        isActive: false,
        menuId: 'lopa'),
    NavigationIcon(
        id: 'i1',
        title: 'Audio',
        icon: Icons.volume_up,
        route: '/app/audio',
        isActive: false,
        menuId: 'home'),
    NavigationIcon(
        id: 'i2',
        title: 'Video',
        icon: Icons.tv,
        route: '/app/video',
        isActive: false,
        menuId: 'home'),
    NavigationIcon(
        id: 'i3',
        title: 'LIGHTS',
        icon: Icons.lightbulb,
        route: '/app/lights',
        isActive: false,
        menuId: 'home'),
    NavigationIcon(
        id: 'i4',
        title: 'Temperature',
        icon: Icons.thermostat,
        route: '/app/temp',
        isActive: false,
        menuId: 'home'),
    NavigationIcon(
        id: 'i5',
        title: 'Shades',
        icon: Icons.roller_shades,
        route: '/app/shades',
        isActive: false,
        menuId: 'home'),
    NavigationIcon(
        id: 'i6',
        title: 'Settings',
        icon: Icons.settings,
        route: '/app/settings',
        isActive: false,
        menuId: 'home'),
    // NavigationIcon(
    //   id: 'i7',
    //   title: 'Games',
    //   icon: Icons.games,
    //   route: '/app/games',
    //   isActive: false,
    // ),
  ];

  final List<AppBarIcon> _appBarItems = [
    AppBarIcon(
      id: 'ai6',
      title: 'Call',
      symbol: Icons.notifications,
      isActive: false,
    )
  ];

  // getter
  List<NavigationIcon> get navigationItems {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._navItems];
  }

  List<AppBarIcon> get appBarItems {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._appBarItems];
  }

  void toggleNavActive(id) {
    for (var item in _navItems) {
      item.id == id
          ? item.toggleActiveStatus(true)
          : item.toggleActiveStatus(false);
    }
    // _navItems.forEach((element) {
    //   element.id == id
    //       ? element.toggleActiveStatus(true)
    //       : element.toggleActiveStatus(false);
    // });
  }
}
