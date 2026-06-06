import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../can-helpers/can_interface.dart';
import '../providers/socket_provider.dart';
import '../widgets/percent_indicator/percent_indicator.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final CanInterface canInterface1 = CanInterface("can1"); // 🚀 CAN Interface
  final CanInterface canInterface2 = CanInterface("can2");
  final String gifPath = "/home/nargouser/projects/images/loading.gif";
  bool _gifExists = false;

  @override
  void initState() {
    super.initState();
    _pauseBackgroundProcessing();
    _checkGifAvailability();
  }

  void _checkGifAvailability() async {
    bool exists = await File(gifPath).exists();
    setState(() {
      _gifExists = exists;
    });
  }

  @override
  void dispose() {
    _resumeBackgroundProcessing();
    super.dispose();
  }

  // Pause CAN Processing when Loading Screen is shown
  void _pauseBackgroundProcessing() {
    // canInterface1.pauseReceiving();
    // canInterface2.pauseReceiving();
  }

  // Resume CAN Processing when exiting Loading Screen
  void _resumeBackgroundProcessing() {
    // canInterface1.resumeReceiving();
    // canInterface2.resumeReceiving();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Full black background
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🚀 Background Loading GIF
            _gifExists
                ? Image(
                    image: FileImage(File(gifPath)), // Load from system path
                    fit: BoxFit.contain, // Ensures it stays centered
                  )
                : const SizedBox(),

            // 🚀 Overlayed Percentage in Middle
            Selector<SocketProvider, double>(
              selector: (_, provider) => provider.downloadProgress,
              builder: (context, progress, child) {
                return CircularPercentIndicator(
                  radius: 205.0, //160
                  lineWidth: 18.0,
                  percent: progress, // Progress from 0.0 to 1.0
                  center: Text(
                    "${(progress * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.bold),
                  ),
                  // progressColor: Colors.blue,
                  // backgroundColor: Colors.grey[800]!,
                  progressColor: Colors.blue.withOpacity(0.6),
                  backgroundColor: Colors.grey[800]!.withOpacity(0.3),
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: false,
                  animationDuration: 500,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../can-helpers/can_interface.dart';
// import '../providers/socket_provider.dart';
// import '../utils/logger.dart';

// class LoadingScreen extends StatefulWidget {
//   const LoadingScreen({super.key});

//   @override
//   State<LoadingScreen> createState() => _LoadingScreenState();
// }

// class _LoadingScreenState extends State<LoadingScreen> {
//   final CanInterface canInterface = CanInterface("can1"); // 🚀 CAN Interface

//   @override
//   void initState() {
//     super.initState();
//     _pauseBackgroundProcessing();
//   }

//   @override
//   void dispose() {
//     _resumeBackgroundProcessing();
//     super.dispose();
//   }

//   // 🚀 Pause CAN Processing when Loading Screen is shown
//   void _pauseBackgroundProcessing() {
//     canInterface.pauseReceiving();
//   }

//   // 🚀 Resume CAN Processing when exiting Loading Screen
//   void _resumeBackgroundProcessing() {
//     canInterface.resumeReceiving();
//   }

//   @override
//   Widget build(BuildContext context) {
//     logInfo('LoadingScreen', 'Building Loading Screen...');

//     return Scaffold(
//       backgroundColor: Colors.black, // Full black background
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // 🚀 Static Loading Image (GIF)
//             const Image(
//               image: AssetImage('assets/loading3.gif'),
//               fit: BoxFit.cover,
//             ),
//             const SizedBox(height: 20),

//             // 🚀 Static Text
//             const Text(
//               "Downloading...",
//               style: TextStyle(color: Colors.white, fontSize: 20),
//             ),
//             const SizedBox(height: 10),

//             // 🚀 Dynamic Progress Bar
//             Selector<SocketProvider, double>(
//               selector: (_, provider) =>
//                   provider.downloadProgress, // Only watch progress
//               builder: (context, progress, child) {
//                 return Padding(
//                   padding: const EdgeInsets.all(50.0),
//                   child: Column(
//                     children: [
//                       LinearProgressIndicator(
//                         value: progress,
//                         backgroundColor: Colors.grey[700],
//                         color: progress == 1.0 ? Colors.green : Colors.blue,
//                         minHeight: 8,
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         "${(progress * 100).toStringAsFixed(1)}%",
//                         style:
//                             const TextStyle(color: Colors.white, fontSize: 18),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
