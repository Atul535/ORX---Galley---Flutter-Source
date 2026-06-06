import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ethernet_info_provider.dart';
import '../utils/logger.dart';

class MonitoringService {
  final int monitorPeriod = 2000;
  Timer? _monitoringTimer;

  void startMonitoring(BuildContext context) async {
    // Main monitoring service method
    logDebug('MonitoringService - startMonitoring', 'Starting monitoring service');

    _monitoringTimer = Timer.periodic(Duration(milliseconds: monitorPeriod), (Timer t) async {
      if (Platform.isLinux && _monitoringTimer != null) {
        var result;

        try {
          // monitor ethernet
          result = await Process.run('/bin/bash', ['-c', 'ifconfig eth0 | grep -E "RUNNING|inet|packets"']);
          var ethernetPort = parseEthernetInfo(result.stdout);
          // Update the ethernet port info using the notifier
          if (_monitoringTimer != null) {
            Provider.of<EthernetInfoProvider>(context, listen: false).updateInfo(ethernetPort, 'Ethernet');
          }
        } catch (e) {
          logError('MonitoringService - startMonitoring - Ethernet', 'Error: $e');
        }

        try {
          // monitor ethernet
          result = await Process.run('/bin/bash', ['-c', 'ifconfig wlan0 | grep -E "RUNNING|inet|packets"']);
          var ethernetPort = parseEthernetInfo(result.stdout);
          // Update the ethernet port info using the notifier
          if (_monitoringTimer != null) {
            Provider.of<EthernetInfoProvider>(context, listen: false).updateInfo(ethernetPort, 'Wi-Fi');
          }
        } catch (e) {
          logError('MonitoringService - startMonitoring - Ethernet', 'Error: $e');
        }
      }
    });
  }

  //parse Ethernet data
  static Map<String, dynamic> parseEthernetInfo(String output) {
    Map<String, dynamic> ethInfo = {
      'connected': false,
      'ip': "",
      'netmask': "",
      'broadcast': "",
      'tx': "",
      'rx': "",
    };

    if (output.contains('RUNNING')) {
      ethInfo['connected'] = true;
    } else {
      ethInfo['connected'] = false;
      return ethInfo;
    }

    var lines = output.split('\n');
    for (var line in lines) {
      if (line.trimLeft().startsWith('inet ')) {
        RegExp regExp = RegExp(r'inet\s+(\S+)\s+netmask\s+(\S+)\s+broadcast\s+(\S+)');
        var match = regExp.firstMatch(line);

        if (match != null) {
          ethInfo['ip'] = match.group(1);
          ethInfo['netmask'] = match.group(2);
          ethInfo['broadcast'] = match.group(3);
        }
      } else if (line.trimLeft().startsWith('RX packets')) {
        RegExp regExp = RegExp(r'\(([^)]+)\)');
        var matches = regExp.allMatches(line);

        if (matches.isNotEmpty) {
          var matchedText = matches.first.group(1);
          ethInfo['rx'] = matchedText;
        }
      } else if (line.trimLeft().startsWith('TX packets')) {
        RegExp regExp = RegExp(r'\(([^)]+)\)');
        var matches = regExp.allMatches(line);

        if (matches.isNotEmpty) {
          var matchedText = matches.first.group(1);
          ethInfo['tx'] = matchedText;
        }
      }
    }

    return ethInfo;
  }

  static Map<String, bool> parseUsbPorts(String output) {
    Map<String, bool> usbPorts = {
      'usb1': false,
      'usb2': false,
      'usb4': false,
      'usb3': false,
    };

    var lines = output.split('\n');
    for (var line in lines) {
      if (line.contains('Port=00')) {
        usbPorts['usb1'] = true;
      } else if (line.contains('Port=01')) {
        usbPorts['usb2'] = true;
      } else if (line.contains('Port=02')) {
        usbPorts['usb3'] = true;
      } else if (line.contains('Port=03')) {
        usbPorts['usb4'] = true;
      }
    }

    return usbPorts;
  }

  Future<void> executeAsyncActions() async {
    try {
      var result;
      // Execute the first command: v4l2-ctl --query-dv-timings
      result = await Process.run('v4l2-ctl', ['--query-dv-timings']);

      // Execute the second command: v4l2-ctl --set-dv-bt-timings query
      result = await Process.run('v4l2-ctl', ['--set-dv-bt-timings', 'query']);

      // Execute the fourth command: v4l2-ctl -v pixelformat=UYVY
      result = await Process.run('v4l2-ctl', ['-v', 'pixelformat=UYVY']);
    } catch (e) {
      // Handle exceptions that may occur during command execution
      logError('MonitoringService', 'Error: $e');
    }
  }

  void dispose() {
    // Stop the monitoring service
    logDebug('MonitoringService - stopMonitoring', 'Stopping monitoring service');
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }
}
