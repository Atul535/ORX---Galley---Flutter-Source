import 'dart:async';
import 'package:flutter/material.dart';

import '../widgets/cfg_image.dart';

class LogoScreen extends StatefulWidget {
  final String imagePath;
  final Duration speed;
  static const routeName = '/app/logo-screen';

  const LogoScreen({super.key, this.imagePath = "assets/logo.png", this.speed = const Duration(milliseconds: 5)});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  late Size imageSize;
  Offset position = Offset.zero;
  Offset velocity = const Offset(1, 1);
  Timer? timer;

  Future<void> initializeImage() async {
    final ImageStream stream = AssetImage(widget.imagePath).resolve(ImageConfiguration.empty);
    final Completer<ImageInfo> completer = Completer<ImageInfo>();
    ImageStreamListener? listener;
    listener = ImageStreamListener((ImageInfo info, bool _) {
      if (!completer.isCompleted) {
        completer.complete(info);
        stream.removeListener(listener!);
      }
    });
    stream.addListener(listener);
    final ImageInfo info = await completer.future;
    imageSize = Size(info.image.width.toDouble(), info.image.height.toDouble());
  }

  @override
  void initState() {
    super.initState();
    initializeImage().then((_) {
      timer = Timer.periodic(widget.speed, (timer) {
        setState(() {
          position += velocity;

          if (position.dx < 0 || position.dx > MediaQuery.of(context).size.width - imageSize.width) {
            velocity = Offset(-velocity.dx, velocity.dy);
          }

          if (position.dy < 0 || position.dy > MediaQuery.of(context).size.height - imageSize.height) {
            velocity = Offset(velocity.dx, -velocity.dy);
          }
        });
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onPanDown: (det) {
            Navigator.of(context).pop();
          },
          child: Container(color: Colors.black),
        ),
        AnimatedPositioned(
          duration: widget.speed,
          left: position.dx,
          top: position.dy,
          child: CfgImage(widget.imagePath),
        ),
      ],
    );
  }
}
