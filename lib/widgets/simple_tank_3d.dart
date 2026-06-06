import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ===========================================================================
/// SimpleTank3D
/// - Top: full ellipse rim (visual 3D opening)
/// - Body: vertical sides + top half-ellipse + bottom half-ellipse (clip shape)
/// - Inside: 10% grid lines
/// - Water: wave painter clipped to the body shape
/// - Optional: quarter level labels (FULL, 3/4, 1/2, 1/4, LOW, EMPTY)
/// ===========================================================================

/// ---------------------------------------------------------------------------
/// 1) Wave painter (water surface)
/// ---------------------------------------------------------------------------
class MyWavePainter extends CustomPainter {
  final double amplitude; // px
  final double phase; // rad
  final double cycles; // počet period přes width (např. 1.1, 1.6)
  final Color waterColor;
  final double waterLevel; // 0..100
  final bool animate;

  MyWavePainter({
    required this.amplitude,
    required this.phase,
    required this.cycles,
    required this.waterColor,
    required this.waterLevel,
    required this.animate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waterColor
      ..style = PaintingStyle.fill;

    final actualHeight = size.height * (1 - (waterLevel / 100.0));
    final path = Path()..moveTo(0, actualHeight);

    if (animate && waterLevel > 0 && waterLevel < 100) {
      final k = 2 * math.pi * cycles; // kolik radiánů přes šířku
      for (double x = 0; x <= size.width; x += 1) {
        final nx = x / size.width; // 0..1
        final y = actualHeight + amplitude * math.sin(k * nx + phase);
        path.lineTo(x, y);
      }
    } else {
      path.lineTo(size.width, actualHeight);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MyWavePainter old) {
    return old.amplitude != amplitude || old.phase != phase || old.cycles != cycles || old.waterColor != waterColor || old.waterLevel != waterLevel || old.animate != animate;
  }
}

/// ---------------------------------------------------------------------------
/// 2) Body clipper: vertical sides + top half ellipse + bottom half ellipse
/// - The top rim ellipse is drawn separately (full ellipse).
/// - The body uses top half-ellipse (upper arc) as its "roof" so it closes nicely.
/// - Joins happen at left/right widest points of ellipses => vertical tangents.
/// ---------------------------------------------------------------------------
class EllipseTankClipper extends CustomClipper<Path> {
  final double topEllipseHeight; // px
  final double bottomEllipseHeight; // px

  const EllipseTankClipper({
    this.topEllipseHeight = 28,
    this.bottomEllipseHeight = 56,
  });

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final topH = topEllipseHeight.clamp(6.0, h * 0.40);
    final bottomH = bottomEllipseHeight.clamp(6.0, h * 0.60);

    final topOval = Rect.fromLTWH(0, 0, w, topH);
    final bottomOval = Rect.fromLTWH(0, h - bottomH, w, bottomH);

    // JOIN body points derived from Rect centers (exactly matches arc math)
    final yTopJoin = topOval.center.dy; // topH/2
    final yBottomJoin = bottomOval.center.dy; // h - bottomH/2

    final path = Path();

    // Start at left widest point of top ellipse
    path.moveTo(topOval.left, yTopJoin);

    // Top of body: upper half ellipse (left -> right)
    // arcTo will NOT create a new subpath like addArc can.
    path.arcTo(topOval, math.pi, math.pi, false);

    // Right wall down to right widest point of bottom ellipse
    path.lineTo(bottomOval.right, yBottomJoin);

    // Bottom of body: lower half ellipse (right -> left)
    path.arcTo(bottomOval, 0, math.pi, false);

    // Left wall up
    path.lineTo(topOval.left, yTopJoin);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant EllipseTankClipper oldClipper) {
    return oldClipper.topEllipseHeight != topEllipseHeight || oldClipper.bottomEllipseHeight != bottomEllipseHeight;
  }
}

/// ---------------------------------------------------------------------------
/// 3) Decoration painter:
/// - fills body background
/// - draws 10% grid lines (clipped)
/// - draws subtle top highlight (clipped)
/// - draws body border
/// - draws TOP FULL ellipse rim + inner ellipse (rim thickness)
/// - draws tiny inner shadow on sides (clipped) for "3D glass"
/// ---------------------------------------------------------------------------
class EllipseTankDecorationPainter extends CustomPainter {
  final Path bodyPath;

  final Color backgroundColor;
  final Color borderColor;
  final double borderSize;

  final double topEllipseHeight;
  final double bottomEllipseHeight;

  final Color gridColor;
  final double rimThickness;

  const EllipseTankDecorationPainter({
    required this.bodyPath,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderSize,
    required this.topEllipseHeight,
    required this.bottomEllipseHeight,
    required this.gridColor,
    this.rimThickness = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final topH = topEllipseHeight.clamp(6.0, h * 0.40);
    final bottomH = bottomEllipseHeight.clamp(6.0, h * 0.60);

    final topOval = Rect.fromLTWH(0, 0, w, topH);

    // Body fill
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;

    canvas.drawPath(bodyPath, fillPaint);

    // Inside effects clipped to body
    canvas.save();
    canvas.clipPath(bodyPath);

    // // 10% grid lines - curved
    // final gridPaint = Paint()
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 2
    //   ..color = gridColor;

    // final left = w * 0.10;
    // final right = w * 0.90;
    // final arcW = right - left;

    // final baseArcH = (topH * 0.55).clamp(8.0, 18.0);

    // for (int i = 1; i <= 9; i++) {
    //   final y = h * (1 - i / 10.0);

    //   final t = i / 10.0; // 0.1..0.9
    //   final arcH = gridLineCurveSwapped ? (baseArcH * (0.75 + 0.35 * (1 - t))).clamp(6.0, 22.0) : (baseArcH * (0.75 + 0.45 * t)).clamp(6.0, 24.0);

    //   final arcRect = Rect.fromCenter(
    //     center: Offset((left + right) / 2.0, y),
    //     width: arcW,
    //     height: arcH,
    //   );

    //   // Top half-ellipse (hump up)
    //   gridLineCurveSwapped ? canvas.drawArc(arcRect, math.pi, math.pi, false, gridPaint) : canvas.drawArc(arcRect, 0, math.pi, false, gridPaint);
    // }

    // Top highlight (gives “rim light”)
    final rimRect = Rect.fromLTWH(0, 0, w, topH);
    final rimPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.16),
          Colors.white.withOpacity(0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rimRect);

    canvas.drawRect(rimRect, rimPaint);

    // Side inner shading for 3D feel
    final leftShadeRect = Rect.fromLTWH(0, 0, w * 0.18, h);
    final leftShadePaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withOpacity(0.07),
          Colors.transparent,
        ],
      ).createShader(leftShadeRect);
    canvas.drawRect(leftShadeRect, leftShadePaint);

    final rightShadeRect = Rect.fromLTWH(w * 0.82, 0, w * 0.18, h);
    final rightShadePaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          Colors.black.withOpacity(0.10),
          Colors.transparent,
        ],
      ).createShader(rightShadeRect);
    canvas.drawRect(rightShadeRect, rightShadePaint);

    canvas.restore();

    // Body border
    if (borderSize > 0) {
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderSize
        ..color = borderColor;

      canvas.drawPath(bodyPath, borderPaint);
    }

    // Top FULL ellipse rim (outer)
    final rimStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, borderSize)
      ..color = borderColor.withOpacity(0.95);

    canvas.drawOval(topOval, rimStroke);

    // Inner ellipse rim (thickness)
    final t = rimThickness.clamp(0.0, topH * 0.45);
    if (t > 0.0) {
      final innerTopOval = Rect.fromLTWH(
        t,
        t * 0.60,
        w - 2 * t,
        topH - 2 * t * 0.90,
      );

      // Inner bright line
      final innerStroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withOpacity(0.20);

      // canvas.drawOval(innerTopOval, innerStroke);

      // Slight shadow under inner rim to imply depth
      final innerShadowRect = Rect.fromLTWH(0, topH * 0.52, w, topH * 0.55);
      final innerShadowPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.10),
            Colors.transparent,
          ],
        ).createShader(innerShadowRect);

      canvas.save();
      canvas.clipPath(bodyPath);
      canvas.drawRect(innerShadowRect, innerShadowPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant EllipseTankDecorationPainter old) {
    return old.bodyPath != bodyPath ||
        old.backgroundColor != backgroundColor ||
        old.borderColor != borderColor ||
        old.borderSize != borderSize ||
        old.topEllipseHeight != topEllipseHeight ||
        old.bottomEllipseHeight != bottomEllipseHeight ||
        old.gridColor != gridColor ||
        old.rimThickness != rimThickness;
  }
}

class TankGridPainter extends CustomPainter {
  final double topEllipseHeight;
  final Color gridColor;

  TankGridPainter({
    required this.topEllipseHeight,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final topH = topEllipseHeight;

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = gridColor;

    final left = w * 0.12;
    final right = w * 0.88;
    final arcW = right - left;

    final baseArcH = (topH * 0.6).clamp(8.0, 20.0);

    for (int i = 1; i <= 9; i++) {
      final y = h * (1 - i / 10.0);

      final arcRect = Rect.fromCenter(
        center: Offset((left + right) / 2, y),
        width: arcW,
        height: baseArcH,
      );

      // spodní půlelipsa
      canvas.drawArc(arcRect, 0, math.pi, false, gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TankGridPainter oldDelegate) {
    return oldDelegate.gridColor != gridColor || oldDelegate.topEllipseHeight != topEllipseHeight;
  }
}

/// ---------------------------------------------------------------------------
/// 4) SimpleTank3D widget
/// ---------------------------------------------------------------------------
class SimpleTank3D extends StatefulWidget {
  final int value; // 0..100

  final Color borderColor;
  final Color backgroundColor;
  final Color waterColor;
  final Color textColor;

  final double width;
  final double height;

  final bool animate;
  final bool showText;

  final double fontSizeScaleFactor;

  /// Border stroke width for body
  final double borderSize;

  /// Max wave amplitude as percentage of height (e.g. 0.02)
  final double maxAmplitude;

  /// If true, show FULL/3/4/1/2/1/4/LOW/EMPTY and snap fill to those.
  final bool useQuarterLevels;

  /// If true, LOW level is skipped (goes 25 -> 0)
  final bool skipLow;

  /// Shape tuning
  final double topEllipseHeight;
  final double bottomEllipseHeight;

  /// Rim tuning
  final double rimThickness;

  /// Grid opacity/color
  final Color gridColor;

  /// Swapping the curvature of grid lines (top more curved vs bottom more curved)
  final bool gridLineCurveSwapped;

  const SimpleTank3D({
    super.key,
    this.value = 0,
    this.borderColor = Colors.transparent,
    this.backgroundColor = const Color(0xff2B2C56),
    this.waterColor = const Color(0xff3B6ABA),
    this.textColor = Colors.white,
    this.width = 120,
    this.height = 240,
    this.animate = false,
    this.showText = true,
    this.fontSizeScaleFactor = 1.0,
    this.borderSize = 2.0,
    this.maxAmplitude = 0.02,
    this.useQuarterLevels = false,
    this.skipLow = false,
    this.topEllipseHeight = 28,
    this.bottomEllipseHeight = 56,
    this.rimThickness = 6,
    this.gridColor = const Color(0xFFFFFFFF),
    this.gridLineCurveSwapped = false,
  });

  @override
  State<SimpleTank3D> createState() => _SimpleTank3DState();
}

class _SimpleTank3DState extends State<SimpleTank3D> with TickerProviderStateMixin {
  late final AnimationController _ampCtrl;
  late final Animation<double> _ampAnim;

  late final AnimationController _levelCtrl;
  late Animation<double> _levelAnim;
  late final AnimationController _phaseCtrl;

  @override
  void initState() {
    super.initState();

    final initial = widget.useQuarterLevels ? _quarterLevel(widget.value) : widget.value;

    if (widget.animate) {
      _ampCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
      _phaseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();

      _ampAnim = Tween<double>(
        begin: widget.height * -widget.maxAmplitude,
        end: widget.height * widget.maxAmplitude,
      ).animate(CurvedAnimation(parent: _ampCtrl, curve: Curves.easeInOut))
        ..addListener(() => setState(() {}))
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _ampCtrl.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _ampCtrl.forward();
          }
        });

      _levelCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
      _levelAnim = AlwaysStoppedAnimation(initial.toDouble());

      _ampCtrl.forward();
    } else {
      _ampCtrl = AnimationController(vsync: this, duration: Duration.zero);
      _phaseCtrl = AnimationController(vsync: this, duration: Duration.zero);
      _ampAnim = const AlwaysStoppedAnimation(0);
      _levelCtrl = AnimationController(vsync: this, duration: Duration.zero);
      _levelAnim = AlwaysStoppedAnimation(initial.toDouble());
    }
  }

  @override
  void didUpdateWidget(covariant SimpleTank3D oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newTarget = widget.useQuarterLevels ? _quarterLevel(widget.value) : widget.value;

    if (widget.animate) {
      if (oldWidget.value != widget.value || oldWidget.useQuarterLevels != widget.useQuarterLevels || oldWidget.skipLow != widget.skipLow) {
        _levelAnim = Tween<double>(
          begin: _levelAnim.value,
          end: newTarget.toDouble(),
        ).animate(CurvedAnimation(parent: _levelCtrl, curve: Curves.easeInOut));

        _levelCtrl.forward(from: 0.0);
      }
    } else {
      setState(() {
        _levelAnim = AlwaysStoppedAnimation(newTarget.toDouble());
      });
    }
  }

  @override
  void dispose() {
    _ampCtrl.dispose();
    _phaseCtrl.dispose();
    _levelCtrl.dispose();
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

  String _labelFor(int rawValue, int snappedValue) {
    if (!widget.useQuarterLevels) return '$rawValue %';

    switch (snappedValue) {
      case 100:
        return 'FULL';
      case 75:
        return '3/4';
      case 50:
        return '1/2';
      case 25:
        return '1/4';
      case 10:
        return 'LOW';
      case 0:
        return 'EMPTY';
      default:
        return '$snappedValue %';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tankSize = Size(widget.width, widget.height);

    final snapped = widget.useQuarterLevels ? _quarterLevel(widget.value) : widget.value;
    final label = _labelFor(widget.value, snapped);

    final clipper = EllipseTankClipper(
      topEllipseHeight: widget.topEllipseHeight,
      bottomEllipseHeight: widget.bottomEllipseHeight,
    );

    final bodyPath = clipper.getClip(tankSize);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // Decoration behind the water
          CustomPaint(
            size: tankSize,
            painter: EllipseTankDecorationPainter(
              bodyPath: bodyPath,
              backgroundColor: widget.backgroundColor,
              borderColor: widget.borderColor,
              borderSize: widget.borderSize,
              topEllipseHeight: widget.topEllipseHeight,
              bottomEllipseHeight: widget.bottomEllipseHeight,
              gridColor: widget.gridColor.withOpacity(0.10),
              rimThickness: widget.rimThickness,
            ),
          ),

          // Water clipped to body shape
          ClipPath(
            clipper: clipper,
            child: AnimatedBuilder(
              animation: Listenable.merge([_ampAnim, _levelAnim, _phaseCtrl]),
              builder: (context, child) {
                final level = widget.useQuarterLevels ? snapped.toDouble() : _levelAnim.value;

                final phaseBase = _phaseCtrl.value * 2 * math.pi; // 0..2π

                return Stack(
                  children: [
                    CustomPaint(
                      size: tankSize,
                      painter: MyWavePainter(
                        amplitude: _ampAnim.value * 0.95,
                        phase: phaseBase + math.pi / 0.5, // jen offset
                        cycles: 0.95,
                        waterColor: widget.waterColor.withOpacity(0.28),
                        waterLevel: level,
                        animate: widget.animate,
                      ),
                    ),
                    CustomPaint(
                      size: tankSize,
                      painter: MyWavePainter(
                        amplitude: _ampAnim.value * 0.85,
                        phase: phaseBase,
                        cycles: 1.35,
                        waterColor: widget.waterColor,
                        waterLevel: level,
                        animate: widget.animate,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Grid
          CustomPaint(
            size: tankSize,
            painter: TankGridPainter(
              topEllipseHeight: widget.topEllipseHeight,
              gridColor: widget.gridColor.withOpacity(0.15),
            ),
          ),

          // Text overlay
          if (widget.showText)
            Center(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  wordSpacing: 2,
                  color: widget.textColor,
                ),
                textScaleFactor: widget.fontSizeScaleFactor,
              ),
            ),
        ],
      ),
    );
  }
}
