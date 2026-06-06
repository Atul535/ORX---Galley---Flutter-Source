import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/current_state.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../utils/logger.dart';

enum BargraphType { none, temperature, brightness, volume, lightTemperature }

enum BargraphTitlePosition { top, bottom }

typedef OnValueChangeCallback = void Function(double value);

class Bargraph extends StatefulWidget {
  final String? id;
  final String? title;
  final double minValue;
  final double maxValue;
  final int steps;
  final double? height;
  final double? width;
  final double spacing;
  final int throttleMs;
  final BargraphType bargraphType;
  final BargraphTitlePosition titlePosition;
  final TextStyle? titleStyle;
  final Color? thumbColorOverride;
  final OnValueChangeCallback? onValueChangeCallback;
  final int? titleRotationQuarterTurns;

  const Bargraph({
    super.key,
    this.id,
    this.title,
    this.minValue = 0,
    this.maxValue = 100,
    this.steps = 10,
    this.height,
    this.width,
    this.spacing = 10,
    this.throttleMs = 100,
    this.bargraphType = BargraphType.none,
    this.titlePosition = BargraphTitlePosition.bottom,
    this.titleStyle,
    this.thumbColorOverride,
    this.onValueChangeCallback,
    this.titleRotationQuarterTurns,
  });

  @override
  State<Bargraph> createState() => _BargraphState();
}

class _BargraphState extends State<Bargraph> {
  // Local state to reflect immediate slider changes
  double _sliderValue = 0;

  // For throttling updates
  DateTime _lastUpdateTime = DateTime.now();

  // For detecting triple-taps
  int _tapCount = 0;
  DateTime _lastTapTime = DateTime.now();
  // Time window in which multiple taps count toward triple-click
  final Duration _tripleClickThreshold = const Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    // Initialize the local slider value from the provider's current state
    final initialValue =
        context.read<CurrentStateProvider>().getCurrentState(widget.id ?? '');
    _sliderValue = initialValue.toDouble();

    // Make the first throttled update possible immediately
    _lastUpdateTime = DateTime.now().subtract(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    // We only need the theme as a snapshot, no need to rebuild on theme changes
    final myTheme =
        Provider.of<CustomThemes>(context, listen: false).getActiveTheme();

    SliderThemeData bargraphTheme = myTheme.bargraphTheme as SliderThemeData;

    if (widget.bargraphType == BargraphType.temperature ||
        widget.bargraphType == BargraphType.lightTemperature ||
        widget.bargraphType == BargraphType.brightness) {
      var gradient;

      switch (widget.bargraphType) {
        case BargraphType.temperature:
          gradient = const LinearGradient(
            colors: [
              Colors.blue,
              Colors.red,
            ],
          );
          break;
        case BargraphType.lightTemperature:
          gradient = const LinearGradient(
            colors: [
              Color.fromARGB(255, 154, 209, 255),
              Colors.white,
              Color.fromARGB(255, 255, 245, 159),
            ],
          );
          break;
        case BargraphType.brightness:
          gradient = const LinearGradient(
            colors: [
              Colors.black,
              Colors.white,
            ],
          );
          break;
        default:
          gradient = const LinearGradient(
            colors: [
              Colors.blue,
              Colors.red,
            ],
          );
      }

      bargraphTheme = SliderTheme.of(context).copyWith(
        showValueIndicator: myTheme.bargraphTheme?.showValueIndicator ??
            ShowValueIndicator.never,
        trackHeight: myTheme.bargraphTheme?.trackHeight ?? 40.0,
        trackShape: CustomGradientRectSliderTrackShape(
          gradient: gradient,
        ),
        activeTrackColor:
            myTheme.bargraphTheme?.activeTrackColor ?? Colors.white54,
        inactiveTrackColor:
            myTheme.bargraphTheme?.inactiveTrackColor ?? Colors.white54,
        thumbShape: myTheme.bargraphTheme?.thumbShape ??
            const RoundSliderThumbShape(
              enabledThumbRadius: 40.0,
              pressedElevation: 8.0,
              elevation: 5.0,
            ),
        thumbColor: widget.thumbColorOverride ??
            myTheme.bargraphTheme?.thumbColor ??
            Colors.white,
        overlayColor:
            myTheme.bargraphTheme?.overlayColor ?? Colors.orangeAccent,
        overlayShape: myTheme.bargraphTheme?.overlayShape ??
            const RoundSliderOverlayShape(overlayRadius: 32.0),
        tickMarkShape: myTheme.bargraphTheme?.tickMarkShape ??
            const RoundSliderTickMarkShape(),
        activeTickMarkColor:
            myTheme.bargraphTheme?.activeTickMarkColor ?? Colors.pinkAccent,
        inactiveTickMarkColor:
            myTheme.bargraphTheme?.inactiveTickMarkColor ?? Colors.white,
        valueIndicatorShape: myTheme.bargraphTheme?.valueIndicatorShape ??
            const PaddleSliderValueIndicatorShape(),
        valueIndicatorColor:
            myTheme.bargraphTheme?.valueIndicatorColor ?? Colors.black,
        valueIndicatorTextStyle:
            myTheme.bargraphTheme?.valueIndicatorTextStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
      );
    }

    return Selector<CurrentStateProvider, ({int state, bool isInhibited})>(
      selector: (context, provider) {
        final stateObject = provider.getCurrentStateObject(widget.id ?? '');
        return (
          state: stateObject.currentState,
          isInhibited: stateObject.isInhibited
        );
      },
      builder: (context, values, child) {
        final int providerValue = values.state;
        final bool isInhibited = values.isInhibited;

        // Ensure UI stays in sync with provider
        final double newValue = providerValue.toDouble();
        if (newValue != _sliderValue) {
          _sliderValue = newValue;
        }

        return Column(
          children: <Widget>[
            if (widget.titlePosition == BargraphTitlePosition.top) ...[
              FittedBox(
                // ⭐ Automaticky přizpůsobí velikost
                fit: BoxFit.contain,
                child: RotatedBox(
                  quarterTurns: widget.titleRotationQuarterTurns ?? 0,
                  child: Text(
                    widget.title.toString(),
                    style: widget.titleStyle ?? Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: widget.spacing),
            ],

            // Wrap the Slider in a GestureDetector to detect triple taps.
            Listener(
              onPointerMove: (event) {
                if (isInhibited) {
                  GestureBinding.instance.cancelPointer(event.pointer);
                }
              },
              child: AbsorbPointer(
                absorbing: isInhibited,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // 'opaque' ensures we receive taps even if they don't land directly on the thumb

                  onTapDown: (TapDownDetails details) {
                    // Check for triple-tap logic:
                    final now = DateTime.now();
                    if (now.difference(_lastTapTime) < _tripleClickThreshold) {
                      _tapCount++;
                    } else {
                      // It's been too long since last tap, reset count
                      _tapCount = 1;
                    }
                    _lastTapTime = now;

                    if (_tapCount >= 3) {
                      // TRIPLE-CLICK DETECTED!
                      _tapCount = 0; // reset
                      _jumpToMax(); // Jump to some "max" or special value
                    }
                  },

                  child: SizedBox(
                    width: widget.width ?? double.infinity,
                    height: widget.height ?? double.infinity,
                    child: SliderTheme(
                      data: bargraphTheme,
                      child: Slider(
                        min: widget.minValue,
                        max: widget.maxValue,
                        divisions: widget.steps,
                        label: _sliderValue.round().toString(),
                        value: _sliderValue,
                        onChanged: isInhibited
                            ? null
                            : (val) {
                                setState(() {
                                  _sliderValue = val;
                                });

                                // Throttling logic:
                                final now = DateTime.now();
                                final elapsed = now
                                    .difference(_lastUpdateTime)
                                    .inMilliseconds;

                                if (elapsed >= widget.throttleMs) {
                                  _lastUpdateTime = now;
                                  // Update the provider no more than once every _throttleMs
                                  context
                                      .read<CurrentStateProvider>()
                                      .setCurrentState(
                                        widget.id ?? '',
                                        val.ceil(),
                                      );
                                  widget.onValueChangeCallback?.call(val);
                                }
                              },
                        onChangeEnd: (val) {
                          // Optionally do a final update to ensure the final slider value is saved
                          widget.onValueChangeCallback?.call(val);
                          context.read<CurrentStateProvider>().setCurrentState(
                                widget.id ?? '',
                                val.ceil(),
                              );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.titlePosition == BargraphTitlePosition.bottom) ...[
              SizedBox(height: widget.spacing),
              FittedBox(
                // ⭐ Automaticky přizpůsobí velikost
                fit: BoxFit.contain,
                child: RotatedBox(
                  quarterTurns: widget.titleRotationQuarterTurns ?? 0,
                  child: Text(
                    widget.title.toString(),
                    style: widget.titleStyle ?? Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// When triple-tap is detected, we do a "jump" to the max slider value (or another behavior).
  void _jumpToMax() {
    final maxVal = widget.maxValue.round();
    setState(() {
      _sliderValue = widget.maxValue;
    });

    context
        .read<CurrentStateProvider>()
        .setCurrentState(widget.id ?? '', maxVal);
  }
}

class CustomGradientRectSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  const CustomGradientRectSliderTrackShape({
    this.gradient = const LinearGradient(
      colors: [
        Colors.blue,
        Colors.red,
      ],
    ),
    this.darkenInactive = false,
  });

  final LinearGradient gradient;
  final bool darkenInactive;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(sliderTheme.trackHeight != null && sliderTheme.trackHeight! > 0);

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final activeGradientRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
    );

    final ColorTween activeTrackColorTween = ColorTween(
      begin: sliderTheme.disabledActiveTrackColor,
      end: sliderTheme.activeTrackColor,
    );
    final ColorTween inactiveTrackColorTween = darkenInactive
        ? ColorTween(
            begin: sliderTheme.disabledInactiveTrackColor,
            end: sliderTheme.inactiveTrackColor,
          )
        : activeTrackColorTween;

    final Paint activePaint = Paint()
      ..shader = gradient.createShader(activeGradientRect)
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;

    final Paint inactivePaint = Paint()
      ..shader = gradient.createShader(activeGradientRect)
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;

    final Paint leftTrackPaint;
    final Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    final Radius trackRadius = Radius.circular(trackRect.height / 2);
    final Radius activeTrackRadius = Radius.circular(trackRect.height / 2 + 1);

    // Paint the "active" side of the track
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left,
        (textDirection == TextDirection.ltr)
            ? trackRect.top - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        thumbCenter.dx,
        (textDirection == TextDirection.ltr)
            ? trackRect.bottom + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        topLeft: (textDirection == TextDirection.ltr)
            ? activeTrackRadius
            : trackRadius,
        bottomLeft: (textDirection == TextDirection.ltr)
            ? activeTrackRadius
            : trackRadius,
      ),
      leftTrackPaint,
    );

    // Paint the "inactive" side of the track
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        thumbCenter.dx,
        (textDirection == TextDirection.rtl)
            ? trackRect.top - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        trackRect.right,
        (textDirection == TextDirection.rtl)
            ? trackRect.bottom + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        topRight: (textDirection == TextDirection.rtl)
            ? activeTrackRadius
            : trackRadius,
        bottomRight: (textDirection == TextDirection.rtl)
            ? activeTrackRadius
            : trackRadius,
      ),
      rightTrackPaint,
    );
  }
}
