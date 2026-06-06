import 'package:flutter/material.dart';

class EthernetInfo {
  String type;
  bool connected;
  String ip;
  String netmask;
  String broadcast;
  String rx;
  String tx;

  EthernetInfo({
    required this.type,
    required this.connected,
    required this.ip,
    required this.netmask,
    required this.broadcast,
    required this.rx,
    required this.tx,
  });
}

class EthernetInfoProvider extends ChangeNotifier {
  final List<EthernetInfo> _ethernetInfo = <EthernetInfo>[
    EthernetInfo(
      type: 'Ethernet',
      connected: false,
      ip: '',
      netmask: '',
      broadcast: '',
      rx: '',
      tx: '',
    ),
    EthernetInfo(
      type: 'Wi-Fi',
      connected: false,
      ip: '',
      netmask: '',
      broadcast: '',
      rx: '',
      tx: '',
    ),
  ];

  // bool _connected = false;
  // String _ip = '';
  // String _netmask = '';
  // String _broadcast = '';
  // String _rx = '';
  // String _tx = '';

  // //getters
  // bool get connected => _connected;
  // String get ip => _ip;
  // String get netmask => _netmask;
  // String get broadcast => _broadcast;
  // String get rx => _rx;
  // String get tx => _tx;

  //getters
  EthernetInfo get ethernetInfo => _ethernetInfo[0];
  EthernetInfo get wifiInfo => _ethernetInfo[1];
  

  void updateInfo(Map<String, dynamic> ethInfo, String type) {

    // lets update the ethernet info based on type, but only if there is a change, otherwise dont notify listeners
    if (type == 'Ethernet') {
      if (ethInfo['connected'] != _ethernetInfo[0].connected ||
          ethInfo['ip'] != _ethernetInfo[0].ip ||
          ethInfo['netmask'] != _ethernetInfo[0].netmask ||
          ethInfo['broadcast'] != _ethernetInfo[0].broadcast ||
          ethInfo['rx'] != _ethernetInfo[0].rx ||
          ethInfo['tx'] != _ethernetInfo[0].tx) {
        _ethernetInfo[0].connected = ethInfo['connected'] as bool;
        _ethernetInfo[0].ip = ethInfo['ip'] as String;
        _ethernetInfo[0].netmask = ethInfo['netmask'] as String;
        _ethernetInfo[0].broadcast = ethInfo['broadcast'] as String;
        _ethernetInfo[0].rx = ethInfo['rx'] as String;
        _ethernetInfo[0].tx = ethInfo['tx'] as String;
        notifyListeners(); // Notify listeners when settings change
      }
    } else if (type == 'Wi-Fi') {
      if (ethInfo['connected'] != _ethernetInfo[1].connected ||
          ethInfo['ip'] != _ethernetInfo[1].ip ||
          ethInfo['netmask'] != _ethernetInfo[1].netmask ||
          ethInfo['broadcast'] != _ethernetInfo[1].broadcast ||
          ethInfo['rx'] != _ethernetInfo[1].rx ||
          ethInfo['tx'] != _ethernetInfo[1].tx) {
        _ethernetInfo[1].connected = ethInfo['connected'] as bool;
        _ethernetInfo[1].ip = ethInfo['ip'] as String;
        _ethernetInfo[1].netmask = ethInfo['netmask'] as String;
        _ethernetInfo[1].broadcast = ethInfo['broadcast'] as String;
        _ethernetInfo[1].rx = ethInfo['rx'] as String;
        _ethernetInfo[1].tx = ethInfo['tx'] as String;
        notifyListeners(); // Notify listeners when settings change
      }
    }

    // // if received ethInfo items are different from current items, notify Listeners
    // if (ethInfo['connected'] != _connected ||
    //     ethInfo['ip'] != _ip ||
    //     ethInfo['netmask'] != _netmask ||
    //     ethInfo['broadcast'] != _broadcast ||
    //     ethInfo['rx'] != _rx ||
    //     ethInfo['tx'] != _tx) {
    //   _connected = ethInfo['connected'] as bool;
    //   _ip = ethInfo['ip'] as String;
    //   _netmask = ethInfo['netmask'] as String;
    //   _broadcast = ethInfo['broadcast'] as String;
    //   _rx = ethInfo['rx'] as String;
    //   _tx = ethInfo['tx'] as String;
    //   notifyListeners(); // Notify listeners when settings change
    // }
  }
}
