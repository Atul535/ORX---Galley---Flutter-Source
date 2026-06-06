import 'package:flutter/material.dart';

class VideoSelection with ChangeNotifier {
  final String? id;
  final String? title;
  final IconData? icon;
  double iconSize;
  double height;
  double width;
  double textIconSpacing;
  bool isActive;

  VideoSelection(
      {required this.id,
      required this.title,
      required this.icon,
      this.height = 150,
      this.width = 150,
      this.isActive = false,
      this.iconSize = 80,
      this.textIconSpacing = 20});

  void toggleActiveStatus([status]) {
    if (status == null) {
      isActive = !isActive;
      notifyListeners();
    } else if (status != isActive) {
      isActive = status;
      notifyListeners();
    }
  }
}

class VideoItemsFwd with ChangeNotifier {
  final _videoItems = [
    VideoSelection(
      id: 'asa1',
      title: 'Map',
      icon: Icons.public,
      isActive: true,
    ),
    VideoSelection(
      id: 'asa2',
      title: 'HDMI',
      icon: Icons.settings_input_hdmi,
      isActive: false,
    ),
  ];

  // getter
  List<VideoSelection> get videoItems {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._videoItems];
  }

  void toggleActive(id) {
    for (var item in _videoItems) {
      item.id == id
          ? item.toggleActiveStatus(true)
          : item.toggleActiveStatus(false);
    }
    // _videoItems.forEach((element) {
    //   element.id == id
    //       ? element.toggleActiveStatus(true)
    //       : element.toggleActiveStatus(false);
    // });
    notifyListeners();
  }

  int getActiveIndex() {
    return _videoItems.indexWhere((element) => element.isActive == true);
  }
}

class VideoItemsAft with ChangeNotifier {
  final _videoItems = [
    VideoSelection(
      id: 'asa1',
      title: 'HDMI 1',
      icon: Icons.settings_input_hdmi,
      isActive: false,
    ),
    VideoSelection(
      id: 'asa2',
      title: 'HDMI 2',
      icon: Icons.settings_input_hdmi,
      isActive: false,
    ),
    VideoSelection(
      id: 'asa3',
      title: 'HDMI 3',
      icon: Icons.settings_input_hdmi,
      isActive: true,
    ),
    VideoSelection(
      id: 'as5',
      title: 'Apple TV 1',
      icon: Icons.connected_tv,
      isActive: false,
    ),
    VideoSelection(
      id: 'asa6',
      title: 'Apple TV 2',
      icon: Icons.connected_tv,
      isActive: false,
    ),
    VideoSelection(
      id: 'asa7',
      title: 'USB 1',
      icon: Icons.usb,
      isActive: false,
    ),
    VideoSelection(
      id: 'asa8',
      title: 'USB 2',
      icon: Icons.usb,
      isActive: false,
    ),
    VideoSelection(
      id: 'asa9',
      title: 'USB 3',
      icon: Icons.usb,
      isActive: false,
    )
  ];

  // getter
  List<VideoSelection> get videoItems {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._videoItems];
  }

  void toggleActive(id) {
    for (var item in _videoItems) {
      item.id == id
          ? item.toggleActiveStatus(true)
          : item.toggleActiveStatus(false);
    }
    // _videoItems.forEach((element) {
    //   element.id == id
    //       ? element.toggleActiveStatus(true)
    //       : element.toggleActiveStatus(false);
    // });
  }

  int getActiveIndex() {
    return _videoItems.indexWhere((element) => element.isActive == true);
  }
}

class VideoItemsMaster with ChangeNotifier {
  final _videoItems = [
    VideoSelection(
      id: 'asa1',
      title: 'HDMI 1',
      icon: Icons.settings_input_hdmi,
      isActive: false,
    ),
    VideoSelection(
      id: 'asa2',
      title: 'HDMI 2',
      icon: Icons.settings_input_hdmi,
      isActive: false,
    ),
    VideoSelection(
      id: 'asa3',
      title: 'HDMI 3',
      icon: Icons.settings_input_hdmi,
      isActive: true,
    ),
    VideoSelection(
      id: 'as5',
      title: 'Apple TV 1',
      icon: Icons.connected_tv,
      isActive: false,
    ),
    VideoSelection(
      id: 'asa6',
      title: 'Apple TV 2',
      icon: Icons.connected_tv,
      isActive: false,
    ),
    VideoSelection(
      id: 'asa7',
      title: 'USB 1',
      icon: Icons.usb,
      isActive: false,
    ),
    VideoSelection(
      id: 'asa8',
      title: 'USB 2',
      icon: Icons.usb,
      isActive: false,
    ),
    VideoSelection(
      id: 'asa9',
      title: 'USB 3',
      icon: Icons.usb,
      isActive: false,
    )
  ];

  // getter
  List<VideoSelection> get videoItems {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._videoItems];
  }

  void toggleActive(id) {
    for (var item in _videoItems) {
      item.id == id
          ? item.toggleActiveStatus(true)
          : item.toggleActiveStatus(false);
    }
    // _videoItems.forEach((element) {
    //   element.id == id
    //       ? element.toggleActiveStatus(true)
    //       : element.toggleActiveStatus(false);
    // });
  }

  int getActiveIndex() {
    return _videoItems.indexWhere((element) => element.isActive == true);
  }
}
