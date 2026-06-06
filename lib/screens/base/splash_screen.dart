import 'dart:io';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final String mainScreenRoute;
  final String imagePath = "/home/nargouser/projects/images/splash_1080.png";
  const SplashScreen({
    super.key,
    required this.mainScreenRoute,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scaleAnimation;
  Animation<double>? _fadeAnimation;
  Animation<double>? _blackOverlayAnimation;
  bool _imageExists = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 4), // Adjusted duration for smoother effect
    );

    _checkImageAvailability(widget.imagePath);

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 0.5), weight: 20), // Initial growth
      TweenSequenceItem(
          tween: ConstantTween(0.5), weight: 35), // Pause for a brief time
      TweenSequenceItem(
          tween: Tween(begin: 0.5, end: 35.0),
          weight: 30), // Continue to grow larger
    ]).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    ));

    // Fade-in will now start shortly after the scale animation begins
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller!,
      curve: const Interval(0.1, 0.5,
          curve: Curves.easeIn), // Starts after 10% of the animation
    ));

    // Black overlay animation: Starts growing after the logo becomes too large
    _blackOverlayAnimation =
        Tween<double>(begin: 0.0, end: 7.0).animate(CurvedAnimation(
      parent: _controller!,
      curve: const Interval(0.60, 1.0, curve: Curves.easeInOut),
    ));

    _controller!.forward(); // Start the animation

    // Optionally navigate to home screen after the animation
    _controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Navigate to home screen
        Navigator.pushReplacementNamed(context, widget.mainScreenRoute);
      }
    });
  }

  void _checkImageAvailability(String imagePath) async {
    bool exists = await File(imagePath).exists();
    setState(() {
      _imageExists = exists;
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _controller!,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation!.value,
                  child: Opacity(
                    opacity: _fadeAnimation!.value,
                    child: _imageExists
                        ? Image(
                            image: FileImage(File(
                                widget.imagePath)), // Load from system path
                            fit: BoxFit.contain, // Ensures it stays centered
                          )
                        : const SizedBox.shrink(),
                  ),
                );
              },
            ),
          ),
          // Black square overlay that grows from the center as the logo grows too large
          AnimatedBuilder(
            animation: _blackOverlayAnimation!,
            builder: (context, child) {
              return Center(
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      _blackOverlayAnimation!.value,
                  height: MediaQuery.of(context).size.height *
                      _blackOverlayAnimation!.value,
                  color: Colors.black,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
