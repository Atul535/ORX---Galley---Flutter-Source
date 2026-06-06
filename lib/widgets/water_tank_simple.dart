import 'dart:math' as math;
import 'package:flutter/material.dart';

class MyWavePainter extends CustomPainter {
  final double amplitude;
  final Color waterColor;
  final double waterLevel;
  final bool animate;

  MyWavePainter(this.amplitude, this.waterColor, this.waterLevel, this.animate);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = waterColor
      ..style = PaintingStyle.fill;

    var actualHeight = size.height * (1 - (waterLevel / 100));
    Path path = Path()..moveTo(0, actualHeight);

    // Only animate if the flag is true and the level is between 1 and 99
    if (animate && waterLevel > 0 && waterLevel < 100) {
      for (double i = 0; i <= size.width; i += 1) {
        path.lineTo(
          i,
          actualHeight + amplitude * math.sin((i / size.width * 2 * math.pi)),
        );
      }
    } else {
      // Flat water surface
      path.lineTo(size.width, actualHeight);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class WaterTankSimple extends StatefulWidget {
  final int value; // value from 0 to 100
  final Color borderColor, backgroundColor, waterColor, textColor;
  final double width, height;
  final bool animate, showText;
  final double fontSizeScaleFactor;
  final double cornerRadius, borderSize;
  final double maxAmplitude; // Maximum amplitude as a percentage of height
  final bool useQuaterLevels;
  final bool skipLow;

  const WaterTankSimple({
    Key? key,
    this.value = 0,
    this.borderColor = Colors.transparent,
    this.backgroundColor = const Color(0xff2B2C56),
    this.waterColor = const Color(0xff3B6ABA),
    this.textColor = Colors.white,
    this.width = 100,
    this.height = 200,
    this.animate = false,
    this.fontSizeScaleFactor = 1.0,
    this.cornerRadius = 0.0,
    this.borderSize = 0.0,
    this.showText = true,
    this.maxAmplitude = 0.02, // 1% up and down, making 2% total oscillation
    this.useQuaterLevels = false,
    this.skipLow = false,
  }) : super(key: key);

  @override
  State<WaterTankSimple> createState() => _WaterTankSimpleState();
}

class _WaterTankSimpleState extends State<WaterTankSimple> with TickerProviderStateMixin {
  late AnimationController amplitudeController;
  late Animation<double> amplitudeAnimation;

  late AnimationController waterLevelController;
  late Animation<double> waterLevelAnimation;

  @override
  @override
  void initState() {
    super.initState();

    final initialLevel = widget.useQuaterLevels ? _quarterLevel(widget.value) : widget.value;

    if (widget.animate) {
      // Amplitude animation setup remains the same...
      amplitudeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
      amplitudeAnimation = Tween<double>(
        begin: widget.height * -widget.maxAmplitude,
        end: widget.height * widget.maxAmplitude,
      ).animate(CurvedAnimation(parent: amplitudeController, curve: Curves.easeInOut))
        ..addListener(() {
          setState(() {});
        })
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            amplitudeController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            amplitudeController.forward();
          }
        });

      waterLevelController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      );

      waterLevelAnimation = Tween<double>(
        begin: initialLevel.toDouble(),
        end: initialLevel.toDouble(),
      ).animate(
        CurvedAnimation(parent: waterLevelController, curve: Curves.easeInOut),
      );

      amplitudeController.forward();
    } else {
      amplitudeAnimation = const AlwaysStoppedAnimation(0);
      waterLevelAnimation = AlwaysStoppedAnimation(initialLevel.toDouble());
    }
  }

  @override
  void didUpdateWidget(WaterTankSimple oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animate && oldWidget.value != widget.value) {
      // Determine the next quarter level target if needed
      final newTarget = widget.useQuaterLevels ? _quarterLevel(widget.value) : widget.value;

      waterLevelAnimation = Tween<double>(
        begin: waterLevelAnimation.value,
        end: newTarget.toDouble(),
      ).animate(
        CurvedAnimation(parent: waterLevelController, curve: Curves.easeInOut),
      );
      waterLevelController.forward(from: 0.0);
    } else if (!widget.animate) {
      final instantLevel = widget.useQuaterLevels ? _quarterLevel(widget.value) : widget.value;
      setState(() {
        waterLevelAnimation = AlwaysStoppedAnimation(instantLevel.toDouble());
      });
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      amplitudeController.dispose();
      waterLevelController.dispose();
    }
    super.dispose();
  }

  int _quarterLevel(int value) {
    if (value > 90) return 100;
    if (value > 70) return 75;
    if (value > 50) return 50;
    if (value > 25) return 25;
    if (!widget.skipLow && value > 10) return 10;
    return 0;
  }

  @override
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Determine the appropriate quarter level and label
    int quarterValue = widget.value;
    String text = '${widget.value} %';

    if (widget.useQuaterLevels) {
      quarterValue = _quarterLevel(widget.value);
      switch (quarterValue) {
        case 100:
          text = 'FULL';
          break;
        case 75:
          text = '3/4';
          break;
        case 50:
          text = '1/2';
          break;
        case 25:
          text = '1/4';
          break;
        case 10:
          text = 'LOW';
          break;
        case 0:
          text = 'EMPTY';
          break;
        default:
          text = '$quarterValue %';
      }
    }

    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
          color: widget.backgroundColor,
          border: Border.all(color: widget.borderColor, width: widget.borderSize, strokeAlign: BorderSide.strokeAlignOutside),
          borderRadius: BorderRadius.circular(widget.cornerRadius),
          backgroundBlendMode: BlendMode.darken),
      child: Stack(
        children: [
          Center(
            child: Align(
              alignment: Alignment.center,
              child: widget.showText
                  ? Text(
                      text,
                      style: TextStyle(fontWeight: FontWeight.w600, wordSpacing: 2, color: widget.textColor),
                      textScaleFactor: widget.fontSizeScaleFactor,
                    )
                  : Container(),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.cornerRadius),
            child: AnimatedBuilder(
              animation: Listenable.merge([amplitudeAnimation, waterLevelAnimation]),
              builder: (context, child) {
                return CustomPaint(
                  painter: MyWavePainter(
                    amplitudeAnimation.value,
                    widget.waterColor,
                    // Use quarterValue for water level if quarter levels are enabled
                    widget.useQuaterLevels ? quarterValue.toDouble() : waterLevelAnimation.value,
                    widget.animate,
                  ),
                  child: SizedBox(
                    height: size.height,
                    width: size.width,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
