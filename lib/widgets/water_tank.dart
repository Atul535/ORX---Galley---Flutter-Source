import 'dart:async';
import 'package:flutter/material.dart';

class WaterTank extends StatefulWidget {
  final int value; // value from 0 to 100
  final Color borderColor, backgroundColor, waterColor, textColor;
  final double width, height; // Animation control
  final bool animate, showText;
  final double fontSizeScaleFactor;
  final double cornerRadius, borderSize;

  const WaterTank({
    Key? key,
    this.value = 0,
    this.borderColor = Colors.transparent,
    this.backgroundColor = const Color(0xff2B2C56),
    this.waterColor = const Color(0xff3B6ABA),
    this.textColor = Colors.white,
    this.width = 100,
    this.height = 200,
    this.animate = true,
    this.fontSizeScaleFactor = 1.0,
    this.cornerRadius = 0.0,
    this.borderSize = 0.0,
    this.showText = true,
  }) : super(key: key);
  // const WaterTank({Key? key}) : super(key: key);

  @override
  State<WaterTank> createState() => _WaterTankState();
}

class _WaterTankState extends State<WaterTank> with TickerProviderStateMixin {
  late AnimationController firstController;
  late Animation<double> firstAnimation;

  late AnimationController secondController;
  late Animation<double> secondAnimation;

  late AnimationController thirdController;
  late Animation<double> thirdAnimation;

  late AnimationController fourthController;
  late Animation<double> fourthAnimation;

  @override
  void initState() {
    super.initState();

    firstController = AnimationController(
        vsync: this,
        duration: widget.animate
            ? const Duration(milliseconds: 1500)
            : Duration.zero);
    firstAnimation = Tween<double>(begin: 1.9, end: 2.1).animate(
        CurvedAnimation(parent: firstController, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          firstController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          firstController.forward();
        }
      });

    secondController = AnimationController(
        vsync: this,
        duration: widget.animate
            ? const Duration(milliseconds: 1500)
            : Duration.zero);
    secondAnimation = Tween<double>(begin: 1.8, end: 2.4).animate(
        CurvedAnimation(parent: secondController, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          secondController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          secondController.forward();
        }
      });

    thirdController = AnimationController(
        vsync: this,
        duration: widget.animate
            ? const Duration(milliseconds: 1500)
            : Duration.zero);
    thirdAnimation = Tween<double>(begin: 1.8, end: 2.4).animate(
        CurvedAnimation(parent: thirdController, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          thirdController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          thirdController.forward();
        }
      });

    fourthController = AnimationController(
        vsync: this,
        duration: widget.animate
            ? const Duration(milliseconds: 1500)
            : Duration.zero);
    fourthAnimation = Tween<double>(begin: 1.9, end: 2.1).animate(
        CurvedAnimation(parent: fourthController, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          fourthController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          fourthController.forward();
        }
      });

    if (widget.animate) {
      Timer(const Duration(seconds: 2), () {
        firstController.forward();
      });

      Timer(const Duration(milliseconds: 1600), () {
        secondController.forward();
      });

      Timer(const Duration(milliseconds: 800), () {
        thirdController.forward();
      });

      fourthController.forward();
    }
  }

  @override
  void dispose() {
    firstController.dispose();
    secondController.dispose();
    thirdController.dispose();
    fourthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
          color: widget.backgroundColor,
          border: Border.all(
              color: widget.borderColor,
              width: widget.borderSize,
              strokeAlign: BorderSide.strokeAlignOutside),
          borderRadius: BorderRadius.circular(widget.cornerRadius),
          backgroundBlendMode: BlendMode.darken),
      child: Stack(
        children: [
          Center(
            child: Align(
              alignment: Alignment.center,
              child: widget.showText
                  ? Text(
                      '${widget.value} %',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          wordSpacing: 2,
                          color: widget.textColor),
                      textScaleFactor: widget.fontSizeScaleFactor,
                    )
                  : Container(),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.cornerRadius),
            child: CustomPaint(
              painter: MyPainter(
                firstAnimation.value,
                secondAnimation.value,
                thirdAnimation.value,
                fourthAnimation.value,
                widget.waterColor,
                widget.value.toDouble(),
                animate: widget.animate,
              ),
              child: SizedBox(
                height: size.height,
                width: size.width,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final double firstValue;
  final double secondValue;
  final double thirdValue;
  final double fourthValue;
  final Color waterColor;
  final double waterLevel;
  bool animate;

  MyPainter(this.firstValue, this.secondValue, this.thirdValue,
      this.fourthValue, this.waterColor, this.waterLevel,
      {this.animate = true});

  @override
  void paint(Canvas canvas, Size size) {
    if (waterLevel >= 100 || waterLevel <= 0) {
      animate = false;
    }

    var paint = Paint()
      ..color = waterColor
      ..style = PaintingStyle.fill;

    firstValue > 100 ? 100 : firstValue;
    secondValue > 100 ? 100 : secondValue;
    thirdValue > 100 ? 100 : thirdValue;
    fourthValue > 100 ? 100 : fourthValue;

    Path path;

    if (animate) {
      var actualHeight = size.height * (1 - (waterLevel / 100));

      path = Path()
        ..moveTo(0, actualHeight.clamp(0.0, size.height))
        ..cubicTo(
          size.width * .4,
          (actualHeight - size.height / 10 * (secondValue - 2))
              .clamp(0.0, size.height),
          size.width * .7,
          (actualHeight - size.height / 10 * (thirdValue - 2))
              .clamp(0.0, size.height),
          size.width,
          (actualHeight - size.height / 10 * (fourthValue - 2))
              .clamp(0.0, size.height),
        )
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height);
    } else {
      path = Path()
        ..moveTo(0, size.height * (1 - waterLevel / 100))
        ..lineTo(size.width, size.height * (1 - waterLevel / 100))
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
