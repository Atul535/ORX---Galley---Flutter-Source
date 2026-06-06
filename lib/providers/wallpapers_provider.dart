import 'package:flutter/material.dart';

class WallpaperInfo {
  String name;
  String filePath;
  bool isActive;

  WallpaperInfo({required this.name, this.isActive = false, required this.filePath});
}

class Wallpapers with ChangeNotifier {
  Wallpapers() {
    setActiveWallpaper('carpet beige realistic');
  }

  final List<WallpaperInfo> _wallpapers = <WallpaperInfo>[
    WallpaperInfo(
      name: 'no wallpaper',
      filePath: '',
      isActive: false,
    ),
    WallpaperInfo(
      name: 'carpet light',
      filePath: 'assets/wallpaper0_0.png',
      isActive: false,
    ),
    WallpaperInfo(
      name: 'carpet inverted',
      filePath: 'assets/wallpaper0_1.png',
      isActive: false,
    ),
    WallpaperInfo(
      name: 'carpet dark',
      filePath: 'assets/wallpaper0_2.png',
      isActive: false,
    ),
    WallpaperInfo(
      name: 'carpet beige realistic',
      filePath: 'assets/wallpaper0_3.png',
      isActive: false,
    ),
    WallpaperInfo(
      name: 'carpet brown realistic',
      filePath: 'assets/wallpaper0_4.png',
      isActive: false,
    ),
    WallpaperInfo(
      name: 'carpet inverted realistic',
      filePath: 'assets/wallpaper0_5.png',
      isActive: false,
    ),
    WallpaperInfo(
      name: 'carpet dark realistic',
      filePath: 'assets/wallpaper0_6.png',
      isActive: false,
    ),
     WallpaperInfo(
      name: 'carpet mono realistic',
      filePath: 'assets/wallpaper0_7.png',
      isActive: false,
    ),
    WallpaperInfo(
      name: 'carpet dark gold realistic',
      filePath: 'assets/wallpaper0_8.png',
      isActive: false,
    ),
  ];

  List<Object> get wallpapers => _wallpapers;

  void setActiveWallpaper(String wallpaperName) {
    _clearActive();
    _wallpapers.firstWhere((obj) => obj.name == wallpaperName).isActive = true;
    notifyListeners();
  }

  void _clearActive() {
    try {
      _wallpapers.firstWhere((obj) => obj.isActive == true).isActive = false;
    } catch (e) {
      // no active wallpaper found
    }
  }

  String getActive() {
    return _wallpapers.firstWhere((obj) => obj.isActive == true).name;
  }

  List<String> get getWallpaperNames {
    List<String> wallpaperNames = [];
    for (var wallpaper in _wallpapers) {
      wallpaperNames.add(wallpaper.name);
    }
    // _wallpapers.forEach((element) {
    //   wallpaperNames.add(element.name);
    // });
    return wallpaperNames;
  }

  String getWallpaperFilePathByName(wallpaperName) {
    return _wallpapers.firstWhere((obj) => obj.name == wallpaperName).filePath;
  }
}
