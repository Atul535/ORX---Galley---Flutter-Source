import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:math' as math;

import '../can-helpers/can_manager.dart';
import '../model/command.dart';
import '../model/component_state.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';

class _GlowConfig {
  final bool enabled;
  final Color? color;
  final double blurRadius;
  final double spreadRadius;

  const _GlowConfig({
    required this.enabled,
    required this.color,
    required this.blurRadius,
    required this.spreadRadius,
  });

  factory _GlowConfig.fromJson(
    Map<String, dynamic>? json, {
    required double defaultBlur,
    required double defaultSpread,
  }) {
    if (json == null) {
      return _GlowConfig(
        enabled: false,
        color: null,
        blurRadius: defaultBlur,
        spreadRadius: defaultSpread,
      );
    }
    Color? color;
    if (json['color'] != null) {
      final parsed = int.tryParse(json['color'].toString());
      if (parsed != null) color = Color(parsed);
    }
    return _GlowConfig(
      enabled: true,
      color: color,
      blurRadius: (json['blur_radius'] as num?)?.toDouble() ?? defaultBlur,
      spreadRadius: (json['spread_radius'] as num?)?.toDouble() ?? defaultSpread,
    );
  }

  Color resolve(Color fallback) => color ?? fallback;
}

class _ShadowConfig {
  final bool enabled;
  final Color? color;
  final double blurRadius;
  final double offsetX;
  final double offsetY;

  const _ShadowConfig({
    required this.enabled,
    required this.color,
    required this.blurRadius,
    required this.offsetX,
    required this.offsetY,
  });

  factory _ShadowConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const _ShadowConfig(
        enabled: false,
        color: null,
        blurRadius: 6,
        offsetX: 0,
        offsetY: 3,
      );
    }
    Color? color;
    if (json['color'] != null) {
      final parsed = int.tryParse(json['color'].toString());
      if (parsed != null) color = Color(parsed);
    }
    return _ShadowConfig(
      enabled: true,
      color: color,
      blurRadius: (json['blur_radius'] as num?)?.toDouble() ?? 6,
      offsetX: (json['offset_x'] as num?)?.toDouble() ?? 0,
      offsetY: (json['offset_y'] as num?)?.toDouble() ?? 3,
    );
  }

  Color resolve(Color fallback) => color ?? fallback;
}

class JoystickWidget extends StatefulWidget {
  final Map<String, dynamic>? json;
  // New config-based input
  final GenericSelection? item;

  // true = send directly to CAN like ColorPicker
  // false = only update CurrentStateProvider
  final bool sendDirectlyToCan;

  final Function(List<Command>, String)? sendCommandCallback;

  const JoystickWidget({
    super.key,
    this.json,
    this.item,
    this.sendDirectlyToCan = true,
    this.sendCommandCallback,
  });

  @override
  State<JoystickWidget> createState() => _JoystickWidgetState();
}

class _JoystickWidgetState extends State<JoystickWidget> with SingleTickerProviderStateMixin {
  File? _backgroundImageFile;
  File? _knobImageFile;

  Offset _knobOffset = Offset.zero;
  int? _currentStateId;

  late final double _outerRadius;
  late final double _knobRadius;
  late final double _deadZonePct;
  late final double _slowMaxPct;
  late final bool _springBack;
  late final Map<int, GenericSelectionState> _selectionStates;
  final CanManager _canManager = CanManager();
  late final bool _showKnobHighlight;

  late final _GlowConfig _outerGlow;
  late final _GlowConfig _knobGlow;
  late final _ShadowConfig _knobShadow;

  Map<String, dynamic>? _resetButton;

  late final AnimationController _snapCtrl;
  late Animation<Offset> _snapAnim;

  Offset? _widgetCenterGlobal;

  @override
  void initState() {
    super.initState();

    final double size = (widget.json?['size'] as num?)?.toDouble() ?? 300.0;
    final double knobSize = (widget.json?['knob_size'] as num?)?.toDouble() ?? 84.0;
    _outerRadius = size / 2;
    _knobRadius = knobSize / 2;
    _deadZonePct = (widget.json?['dead_zone'] as num?)?.toDouble() ?? 10.0;
    _slowMaxPct = (widget.json?['slow_max'] as num?)?.toDouble() ?? 50.0;
    _selectionStates = widget.item?.states ?? {};
    _springBack = widget.json?['spring_back'] as bool? ?? true;
    _showKnobHighlight = widget.json?['show_knob_highlight'] as bool? ?? false;

    _outerGlow = _GlowConfig.fromJson(
      widget.json?['outer_glow'] as Map<String, dynamic>?,
      defaultBlur: 20,
      defaultSpread: 4,
    );
    _knobGlow = _GlowConfig.fromJson(
      widget.json?['knob_glow'] as Map<String, dynamic>?,
      defaultBlur: 14,
      defaultSpread: 1,
    );
    _knobShadow = _ShadowConfig.fromJson(
      widget.json?['knob_shadow'] as Map<String, dynamic>?,
    );

    _resetButton = !_springBack ? (widget.json?['reset_button'] as Map<String, dynamic>?) : null;

    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _snapAnim = AlwaysStoppedAnimation(Offset.zero);
    _snapCtrl.addListener(() {
      setState(() => _knobOffset = _snapAnim.value);
    });

    final String? bgKey = widget.json?['background_image'] as String?;
    if (bgKey != null) {
      //TBD _backgroundImageFile = _imageDownloadController.resolveImage(bgKey);
    }
    final String? knobKey = widget.json?['knob_image'] as String?;
    if (knobKey != null) {
      //TBD _knobImageFile = _imageDownloadController.resolveImage(knobKey);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //TBD _commandController.updateWidgetJson(widgetJson: widget.json);
    });
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  void _handleReset() {
    _snapAnim = Tween<Offset>(
      begin: _knobOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutCubic));

    _snapCtrl.forward(from: 0.0);

    if (_currentStateId != 0) {
      _currentStateId = 0;
      _sendCommandsForState(0);
    }
  }

  int _resolveState(Offset clampedOffset) {
    final double distancePct = (clampedOffset.distance / _outerRadius) * 100.0;
    if (distancePct <= _deadZonePct) return 0;

    final double angleRad = math.atan2(clampedOffset.dy, clampedOffset.dx);
    double angleDeg = (angleRad * 180.0 / math.pi) + 90.0;
    if (angleDeg < 0) angleDeg += 360.0;
    if (angleDeg >= 360) angleDeg -= 360.0;

    final int sector = ((angleDeg + 22.5) / 45.0).floor() % 8;
    return distancePct <= _slowMaxPct ? sector + 1 : sector + 9;
  }

  void _dispatchCommands(List<Command> commands) {
    if (commands.isEmpty) return;

    final String originId = widget.item?.id ?? widget.json?['id']?.toString() ?? 'joystick';

    final List<Command> copiedCommands = commands
        .map(
          (command) => Command(
            id: command.id,
            canIdBF: command.canIdBF,
            data: List<int>.from(command.data),
          ),
        )
        .toList();

    if (widget.sendCommandCallback != null) {
      widget.sendCommandCallback!(copiedCommands, originId);
      return;
    }

    if (widget.sendDirectlyToCan) {
      _canManager.sendCommand(
        commands: copiedCommands,
        originId: originId,
      );
    }
  }

  void _sendCommandsForState(int stateId) {
    final String originId = widget.item?.id ?? widget.json?['id']?.toString() ?? 'joystick';

    Provider.of<CurrentStateProvider>(
      context,
      listen: false,
    ).setCurrentState(originId, stateId);

    if (!widget.sendDirectlyToCan) return;

    final GenericSelectionState? state = _selectionStates[stateId];
    if (state == null) {
      debugPrint('[Joystick] Missing config state $stateId for $originId');
      return;
    }

    _dispatchCommands(state.commands);
  }

  void _handlePanDown(DragDownDetails details) {
    _snapCtrl.stop();
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final size = box.size;
    _widgetCenterGlobal = box.localToGlobal(
      Offset(size.width / 2, size.height / 2),
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_widgetCenterGlobal == null) return;
    final Offset delta = details.globalPosition - _widgetCenterGlobal!;
    final Offset clamped = delta.distance <= _outerRadius ? delta : Offset.fromDirection(delta.direction, _outerRadius);

    setState(() => _knobOffset = clamped);

    final int matchedId = _resolveState(clamped);
    if (matchedId != _currentStateId) {
      _currentStateId = matchedId;
      debugPrint('[Joystick] → state $matchedId');
      _sendCommandsForState(matchedId);
    }
  }

  void _handlePanEnd(DragEndDetails _) {
    _widgetCenterGlobal = null;
    if (_springBack) {
      _snapAnim = Tween<Offset>(
        begin: _knobOffset,
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutCubic));
      _snapCtrl.forward(from: 0.0);
      if (_currentStateId != 0) {
        _currentStateId = 0;
        _sendCommandsForState(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double diameter = _outerRadius * 2;
    final double knobDiameter = _knobRadius * 2;

    Color.fromARGB(255, 95, 95, 95);

    final Color outerColor = Color(
      int.tryParse(widget.json?['outer_color'] ?? '0xFF313136') ?? 0xFF313136,
    );
    final Color knobColor = Color(
      int.tryParse(widget.json?['knob_color'] ?? '0xFF898989') ?? 0xFF898989,
    );
    final Color knobHighlightColor = Color(
      int.tryParse(widget.json?['knob_highlight_color'] ?? '0xFF5F5F5F') ?? 0xFF5F5F5F,
    );

    final Color outerGlowColor = _outerGlow.resolve(outerColor);
    final Color knobGlowColor = _knobGlow.resolve(knobColor);
    final Color knobShadowColor = _knobShadow.resolve(Colors.black);

    final bool showCrosshair = widget.json?['show_crosshair'] as bool? ?? true;
    final String? label = widget.json?['label'] as String?;
    final double slowRingFraction = _slowMaxPct / 100.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null && label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
        ],
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: _handlePanDown,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          onTapDown: (_) {
            if (_currentStateId != 0) {
              _currentStateId = 0;
              _sendCommandsForState(0);
            } else {
              // This also allows repeated center tap to send center command again.
              _sendCommandsForState(0);
            }
          },
          child: SizedBox(
            width: diameter,
            height: diameter,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _backgroundImageFile != null ? null : outerColor,
                      image: _backgroundImageFile != null
                          ? DecorationImage(
                              image: FileImage(_backgroundImageFile!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      border: _backgroundImageFile != null ? null : Border.all(color: outerColor, width: 2),
                      boxShadow: _outerGlow.enabled
                          ? [
                              BoxShadow(
                                color: outerGlowColor,
                                blurRadius: _outerGlow.blurRadius,
                                spreadRadius: _outerGlow.spreadRadius,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ClipOval(
                    child: CustomPaint(
                      painter: _JoystickGuidePainter(
                        color: outerColor,
                        deadZoneFraction: _deadZonePct / 100.0,
                        slowRingFraction: slowRingFraction,
                        showCrosshair: showCrosshair,
                      ),
                    ),
                  ),
                ),
                if (_currentStateId != null && _currentStateId != 0)
                  Positioned.fill(
                    child: ClipOval(
                      child: CustomPaint(
                        painter: _ActiveSectorPainter(
                          stateId: _currentStateId!,
                          slowRingFraction: slowRingFraction,
                          deadZoneFraction: _deadZonePct / 100.0,
                          color: knobHighlightColor,
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Center(
                    child: Transform.translate(
                      offset: _knobOffset,
                      child: Container(
                        width: knobDiameter,
                        height: knobDiameter,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: _knobImageFile != null
                              ? DecorationImage(
                                  image: FileImage(_knobImageFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          gradient: _knobImageFile != null
                              ? null
                              : RadialGradient(
                                  colors: [knobColor, knobColor],
                                  center: const Alignment(-0.3, -0.3),
                                ),
                          boxShadow: [
                            if (_knobGlow.enabled)
                              BoxShadow(
                                color: knobGlowColor,
                                blurRadius: _knobGlow.blurRadius,
                                spreadRadius: _knobGlow.spreadRadius,
                              ),
                            if (_knobShadow.enabled)
                              BoxShadow(
                                color: knobShadowColor,
                                blurRadius: _knobShadow.blurRadius,
                                offset: Offset(
                                  _knobShadow.offsetX,
                                  _knobShadow.offsetY,
                                ),
                              ),
                          ],
                        ),
                        child: _showKnobHighlight
                            ? Center(
                                child: Container(
                                  width: knobDiameter * 0.22,
                                  height: knobDiameter * 0.22,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_resetButton != null) ...[
          const SizedBox(height: 16),
          _ResetButton(
            width: widget.json?['size'] != null ? (widget.json?['size'] as num).toDouble() * 0.8 : 160.0,
            label: _resetButton!['label'] as String? ?? 'RESET',
            color: Color(
              int.tryParse(_resetButton!['color'] ?? '0xFF3B6ABA') ?? 0xFF3B6ABA,
            ),
            textColor: Color(
              int.tryParse(_resetButton!['text_color'] ?? '0xFFFFFFFF') ?? 0xFFFFFFFF,
            ),
            onTap: _handleReset,
          ),
        ],
      ],
    );
  }
}

class _ResetButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final double width;

  const _ResetButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.5),
          boxShadow: [BoxShadow(color: color, blurRadius: 10, spreadRadius: 1)],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _JoystickGuidePainter extends CustomPainter {
  final Color color;
  final double deadZoneFraction;
  final double slowRingFraction;
  final bool showCrosshair;

  const _JoystickGuidePainter({
    required this.color,
    required this.deadZoneFraction,
    required this.slowRingFraction,
    required this.showCrosshair,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;

    canvas.drawCircle(center, outerR * slowRingFraction, paint);

    if (showCrosshair) {
      canvas.drawCircle(center, outerR * deadZoneFraction, paint);

      canvas.drawLine(
        Offset(0, center.dy),
        Offset(size.width, center.dy),
        paint,
      );
      canvas.drawLine(
        Offset(center.dx, 0),
        Offset(center.dx, size.height),
        paint,
      );

      for (final angle in [45.0, 135.0, 225.0, 315.0]) {
        final rad = angle * math.pi / 180.0;
        canvas.drawLine(
          center,
          Offset(
            center.dx + outerR * math.cos(rad),
            center.dy + outerR * math.sin(rad),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_JoystickGuidePainter old) =>
      old.color != color || old.deadZoneFraction != deadZoneFraction || old.slowRingFraction != slowRingFraction || old.showCrosshair != showCrosshair;
}

class _ActiveSectorPainter extends CustomPainter {
  final int stateId;
  final double slowRingFraction;
  final double deadZoneFraction;
  final Color color;

  const _ActiveSectorPainter({
    required this.stateId,
    required this.slowRingFraction,
    required this.deadZoneFraction,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (stateId == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;

    final bool isFast = stateId >= 9;
    final int sectorIdx = isFast ? stateId - 9 : stateId - 1;

    final double innerR = isFast ? outerR * slowRingFraction : outerR * deadZoneFraction;
    final double outerRing = isFast ? outerR : outerR * slowRingFraction;

    final double startDeg = sectorIdx * 45.0 - 22.5 - 90.0;
    final double startRad = startDeg * math.pi / 180.0;
    const double sweepRad = 45.0 * math.pi / 180.0;
    final double endRad = startRad + sweepRad;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(
      center.dx + outerRing * math.cos(startRad),
      center.dy + outerRing * math.sin(startRad),
    );
    path.arcTo(
      Rect.fromCircle(center: center, radius: outerRing),
      startRad,
      sweepRad,
      false,
    );
    path.lineTo(
      center.dx + innerR * math.cos(endRad),
      center.dy + innerR * math.sin(endRad),
    );
    path.arcTo(
      Rect.fromCircle(center: center, radius: innerR),
      endRad,
      -sweepRad,
      false,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ActiveSectorPainter old) =>
      old.stateId != stateId || old.slowRingFraction != slowRingFraction || old.deadZoneFraction != deadZoneFraction || old.color != color;
}
