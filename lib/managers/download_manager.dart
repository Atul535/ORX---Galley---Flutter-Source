import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/config_items.dart';
import '../providers/socket_provider.dart';
import '../screens/home_screen.dart';
import '../screens/loading_screen.dart';
import '../utils/logger.dart';


class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  bool _wasDownloadStarted = false; // 🔥 Track previous state

  void init(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socketProvider =
          Provider.of<SocketProvider>(context, listen: false);

      // Listen for download state changes
      socketProvider.addListener(() {
        // 🔥 Only trigger actions when `isDownloadStarted` changes
        if (socketProvider.isDownloadStarted && !_wasDownloadStarted) {
          _wasDownloadStarted = true; // Update state tracking

          logDebug("DownloadManager",
              "Download started, navigating & showing UI...");
          _navigateToHomeScreen();
          _showDownloadProgressPopup();
        }

        // Reset tracking when download is done
        if (!socketProvider.isDownloadStarted && _wasDownloadStarted) {
          logDebug("DownloadManager", "Download finished, resetting state.");
          _wasDownloadStarted = false;
        }
      });
    });
  }

  void _navigateToHomeScreen() {
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      logDebug("DownloadManager", "Navigating to HomeScreen...");
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false, // Removes all previous screens
      );
    }
  }

  void _showDownloadProgressPopup() {
    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    logDebug("DownloadManager", "Opening Download Progress Popup...");
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const LoadingScreen(),
      ),
    );
  }
}
