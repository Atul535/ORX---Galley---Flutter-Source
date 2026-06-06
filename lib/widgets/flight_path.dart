import 'package:flutter/material.dart';
import 'dart:math';

class FlightPath extends StatefulWidget {
  const FlightPath({super.key});

  @override
  State<FlightPath> createState() => _FlightPathState();
}

class _FlightPathState extends State<FlightPath>
    with SingleTickerProviderStateMixin {
  // Animation related variables
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(
          seconds: 20), // Adjust the duration to control the speed
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController!)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        painter: FlightPathPainter(_animation!.value),
        child: const SizedBox(
          width: double.infinity,
          height: 300,
        ),
      ),
    );
  }
}

class FlightPathPainter extends CustomPainter {
  final double progress;

  FlightPathPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const controlY = 00.0; // control the size of the hill

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, controlY, size.width, size.height);

    canvas.drawPath(path, paint);

    // Calculate the x-coordinate of the moving widget
    final x = progress * size.width;

    // Calculate the y-coordinate of the moving widget
    final t = progress;
    final startY = size.height;

    final endY = size.height;
    final y =
        pow(1 - t, 2) * startY + 2 * (1 - t) * t * controlY + pow(t, 2) * endY;

    // Calculate the angle of the curve
    final dx = 2 * (1 - t) * (controlY - startY) + 2 * t * (endY - controlY);
    final dy = 2 * (1 - t) * (size.width / 2 - 0) +
        2 * t * (size.width - size.width / 2);
    double angle = atan2(dx, dy);

    final double progressPercent = progress * 100;

    // Draw the icon
    IconData? iconWidget;
    if (progressPercent >= 0 && progressPercent <= 10) {
      iconWidget = Icons.flight_takeoff;
      angle = angle - pi / 2;
    } else if (progressPercent >= 90 && progressPercent <= 100) {
      iconWidget = Icons.flight_land;
      angle = angle - pi / 1.5;
    } else {
      iconWidget = Icons.flight;
    }
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconWidget.codePoint),
        style: TextStyle(
          color: Colors.white,
          fontSize: 80.0,
          fontFamily: iconWidget.fontFamily,
          package: iconWidget.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(
        angle + pi / 2); // Add math.pi / 2 to rotate the icon by 90 degrees
    iconPainter.paint(
        canvas, Offset(-iconPainter.width / 2, -iconPainter.height / 2));
    canvas.restore();

    // Draw percentage text
    final textPainter = TextPainter(
      text: TextSpan(
        text: ' ${(progressPercent).toStringAsFixed(0)}% ',
        style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            backgroundColor: Colors.black87,
            shadows: [Shadow(color: Colors.black87, blurRadius: 2)]),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(size.width / 2 - textPainter.width / 2,
            size.height / 2 - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
