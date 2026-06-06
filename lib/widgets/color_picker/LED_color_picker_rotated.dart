import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A Flutter widget that creates a circular color picker specifically for LED lights.
/// This picker excludes very dark colors (no blacks) and uses a circular HSV-style interface.
class LEDColorPickerRotated extends StatefulWidget {
  /// Callback function that receives the selected RGB color as a list of integers [R, G, B].
  /// Each component is a 1-byte value (0-255).
  final Function(List<int>) onColorSelected;

  /// Size of the circular color picker.
  final double size;

  /// Minimum brightness value (0.0-1.0). Used to exclude dark colors/black.
  final double minBrightness;

  /// Rotation offset
  final double rotationOffset;

  /// Initial color to display
  final Color? initialColor;

  /// Text size
  final double textSize;

  /// TextStyle
  final TextStyle? textStyle;

  /// Should the color value text RGB and HEX to be shown
  final bool showColorValues;

  const LEDColorPickerRotated({
    super.key,
    required this.onColorSelected,
    this.size = 280.0,
    this.minBrightness = 0.5,
    this.rotationOffset = 0.0,
    this.initialColor,
    this.textStyle,
    this.textSize = 16.0,
    this.showColorValues = false,
  })  : assert(size > 0, 'Size must be greater than 0.'),
        assert(minBrightness >= 0 && minBrightness <= 1, 'Minimum brightness must be between 0.0 and 1.0.'),
        assert(rotationOffset >= 0 && rotationOffset <= 360, 'Rotation offset must be between 0 and 360 degrees.'),
        assert(textSize > 0, 'Text size must be greater than 0.'),
        assert(initialColor != null || minBrightness <= 1.0, 'Initial color cannot be null if minimum brightness is set to 1.0.');

  @override
  State<LEDColorPickerRotated> createState() => _LEDColorPickerRotatedState();
}

class _LEDColorPickerRotatedState extends State<LEDColorPickerRotated> {
  // HSV color values
  double hue = 0.0; // 0-360
  double saturation = 1.0; // 0-1
  double brightness = 1.0; // 0-1

  // RGB values (0-255)
  List<int> rgb = [255, 0, 0];

  @override
  void initState() {
    super.initState();

    // Initialize from initialColor if provided
    if (widget.initialColor != null) {
      _initializeFromColor(widget.initialColor!);
    }

    // Delay the update to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateRGBFromHSV();
    });
  }

  // Initialize HSV values from a Color
  void _initializeFromColor(Color color) {
    // Extract RGB components
    final red = color.red / 255.0;
    final green = color.green / 255.0;
    final blue = color.blue / 255.0;

    // Find max and min RGB components
    final maxComponent = math.max(red, math.max(green, blue));
    final minComponent = math.min(red, math.min(green, blue));
    final delta = maxComponent - minComponent;

    // Set brightness
    brightness = maxComponent;

    // Set saturation
    saturation = maxComponent == 0 ? 0 : delta / maxComponent;

    // Calculate hue
    if (delta == 0) {
      hue = 0; // Default to red hue for gray colors
    } else if (maxComponent == red) {
      hue = 60 * (((green - blue) / delta) % 6);
    } else if (maxComponent == green) {
      hue = 60 * (((blue - red) / delta) + 2);
    } else {
      // maxComponent == blue
      hue = 60 * (((red - green) / delta) + 4);
    }

    // Ensure hue is positive
    if (hue < 0) hue += 360;

    // Update RGB values to match
    rgb = [color.red, color.green, color.blue];
  }

  /// Convert HSV color to RGB values
  void _updateRGBFromHSV() {
    // Ensure brightness is never below minimum
    double actualBrightness = math.max(widget.minBrightness, brightness);

    // HSV to RGB conversion
    double c = actualBrightness * saturation;
    double x = c * (1 - (((hue / 60) % 2) - 1).abs());
    double m = actualBrightness - c;

    double r, g, b;

    if (hue < 60) {
      r = c;
      g = x;
      b = 0;
    } else if (hue < 120) {
      r = x;
      g = c;
      b = 0;
    } else if (hue < 180) {
      r = 0;
      g = c;
      b = x;
    } else if (hue < 240) {
      r = 0;
      g = x;
      b = c;
    } else if (hue < 300) {
      r = x;
      g = 0;
      b = c;
    } else {
      r = c;
      g = 0;
      b = x;
    }

    // Convert to 8-bit RGB values (0-255)
    rgb = [((r + m) * 255).round(), ((g + m) * 255).round(), ((b + m) * 255).round()];

    // Notify parent widget about the selected color
    widget.onColorSelected(rgb);
  }

  /// Calculate the HSV values based on the position in the color wheel
  void _updateHSVFromPosition(Offset position, Size size) {
    // Center of the wheel
    final center = Offset(size.width / 2, size.height / 2);

    // Calculate the vector from center to touch position
    final vector = position - center;

    // Calculate distance from center (for saturation)
    final radius = size.width / 2;
    final distance = vector.distance;

    // Normalize the distance to get saturation (0-1)
    saturation = math.min(1.0, distance / radius);

    // Calculate angle for hue (0-360)
    hue = (math.atan2(vector.dy, vector.dx) * 180 / math.pi + 360) % 360;

    _updateRGBFromHSV();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color.fromRGBO(rgb[0], rgb[1], rgb[2], 1.0),
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            if (widget.showColorValues) ...[
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "RGB: [${rgb[0]}, ${rgb[1]}, ${rgb[2]}]",
                    style: widget.textStyle ?? TextStyle(fontSize: widget.textSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "HEX: #${rgb[0].toRadixString(16).padLeft(2, '0')}"
                    "${rgb[1].toRadixString(16).padLeft(2, '0')}"
                    "${rgb[2].toRadixString(16).padLeft(2, '0')}",
                    style: widget.textStyle ?? TextStyle(fontSize: widget.textSize, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ],
        ),

        const SizedBox(height: 24),

        if (widget.minBrightness < 1.0) ...[
          Row(
            children: [
              const Text("Brightness:"),
              Expanded(
                child: Slider(
                  value: brightness,
                  min: widget.minBrightness,
                  max: 1.0,
                  onChanged: (value) {
                    setState(() {
                      brightness = value;
                      _updateRGBFromHSV();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // Color wheel
        GestureDetector(
          onPanDown: (details) {
            _handleColorSelection(details.localPosition);
          },
          onPanUpdate: (details) {
            _handleColorSelection(details.localPosition);
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: ColorWheelPainter(
                  hue: hue,
                  saturation: saturation,
                  brightness: math.max(widget.minBrightness, brightness),
                  minBrightness: widget.minBrightness,
                  rotationOffset: widget.rotationOffset,
                ),
              ),
            ),
          ),
        ),
        // Display current RGB values
      ],
    );
  }

  void _handleColorSelection(Offset localPosition) {
    final Size size = Size(widget.size, widget.size);

    // Calculate the center of the wheel
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Calculate distance from center
    final double radius = size.width / 2;
    final double distance = (localPosition - center).distance;

    // Check if the touch is inside the color wheel
    if (distance <= radius) {
      setState(() {
        _updateHSVFromPosition(localPosition, size);
      });
    }
  }
}

class ColorWheelPainter extends CustomPainter {
  final double hue;
  final double saturation;
  final double brightness;
  final double minBrightness;
  final double rotationOffset;

  ColorWheelPainter({
    required this.hue,
    required this.saturation,
    required this.brightness,
    required this.minBrightness,
    this.rotationOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    // Create the color wheel using a standard sweep gradient
    final List<Color> hueColors = [];
    for (int angle = 0; angle <= 360; angle += 10) {
      // Use more points for smoother gradient
      hueColors.add(HSVColor.fromAHSV(1.0, angle.toDouble(), 1.0, math.max(minBrightness, brightness)).toColor());
    }
    // Add the first color again to close the circle
    hueColors.add(hueColors.first);

    // Here's the key part - instead of changing the angle of the gradient,
    // we'll rotate the canvas itself before drawing
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationOffset * (math.pi / 180));
    canvas.translate(-center.dx, -center.dy);

    // Draw the gradient with fixed angles
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Paint huePaint = Paint()
      ..shader = SweepGradient(
        colors: hueColors,
        startAngle: 0,
        endAngle: math.pi * 2,
      ).createShader(rect);

    canvas.drawCircle(center, radius, huePaint);

    // Apply the saturation gradient
    final Paint saturationPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Colors.white, Color.fromARGB(0, 255, 255, 255)],
        stops: [0.0, 1.0],
      ).createShader(rect);

    canvas.drawCircle(center, radius, saturationPaint);

    // Restore the canvas to its original state
    canvas.restore();

    // Draw the selection indicator
    final double selectionRadians = hue * math.pi / 180;
    final double selectionDistance = saturation * radius;
    final Offset selectionOffset = Offset(
      center.dx + selectionDistance * math.cos(selectionRadians),
      center.dy + selectionDistance * math.sin(selectionRadians),
    );
    
    // Get the color for the selection indicator
    final Color selectionColor = HSVColor.fromAHSV(1.0, hue, saturation, brightness).toColor();

    // Draw shadow for selection indicator
    canvas.drawCircle(
      selectionOffset,
      14, // Slightly larger for shadow
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
    );

    // Draw outer white circle (border)
    canvas.drawCircle(
      selectionOffset,
      12,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    
    // Draw inner circle filled with the selected color
    canvas.drawCircle(
      selectionOffset,
      10,
      Paint()..color = selectionColor,
    );
  }

  @override
  bool shouldRepaint(ColorWheelPainter oldDelegate) {
    return hue != oldDelegate.hue ||
        saturation != oldDelegate.saturation ||
        brightness != oldDelegate.brightness ||
        minBrightness != oldDelegate.minBrightness ||
        rotationOffset != oldDelegate.rotationOffset;
  }
}
