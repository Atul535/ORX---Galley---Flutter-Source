// time_display_widget.dart
//
// Display-only time widget (HH/MM/SS) backed by 3 bytes.
// - Default style: flat black background, no border/shadow.
// - If customThemeKey is provided, styling is resolved from your CustomTheme via resolveSelectionTheme()
//   (same pattern as GenericSelectionWidget).
//
// For now: TAP DOES NOTHING (no dialog, no CAN send).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/command.dart';
import '../providers/custom_theme_provider.dart';
import '../model/theme/item_theme.dart';

/// In this file, as requested.
enum TimeDisplayMode {
  hh,
  mm,
  ss,
  hhmm,
  mmss,
  hhmmss,
}

class TimeDisplayWidget extends StatefulWidget {
  final String id;

  // Kept for future (not used yet)
  final List<Command> commands;
  final String originId;
  final Function(List<Command>, String)? sendCommandCallback;
  final int throttleMs;

  /// Button size
  final List<double> buttonSize;

  /// Display label mode
  final TimeDisplayMode displayMode;

  /// initial time value (List<int> or String "HH:MM:SS"/"HH:MM" or Duration)
  final dynamic initialTime;

  /// Optional callback when [hh,mm,ss] changes (not used yet - display only)
  final Function(List<int>)? onTimeDataChanged;

  /// Theme hook similar to GenericSelectionWidget
  final String? customThemeKey;

  /// Optional override label text style (base). Final style will apply theme textColor + shadows.
  final TextStyle? textStyle;

  /// Hours range (default 0..23)
  final int maxHours;

  /// Clamp hh/mm/ss into ranges
  final bool clampToRanges;

  const TimeDisplayWidget({
    super.key,
    required this.id,
    required this.originId,
    this.commands = const [],
    this.sendCommandCallback,
    this.throttleMs = 75,
    this.buttonSize = const [200, 80],
    this.displayMode = TimeDisplayMode.hhmmss,
    this.initialTime = const <int>[0, 0, 0],
    this.onTimeDataChanged,
    this.customThemeKey,
    this.textStyle,
    this.maxHours = 23,
    this.clampToRanges = true,
  });

  @override
  State<TimeDisplayWidget> createState() => _TimeDisplayWidgetState();
}

class _TimeDisplayWidgetState extends State<TimeDisplayWidget> {
  int hh = 0, mm = 0, ss = 0;

  @override
  void initState() {
    super.initState();
    _parseInitialTime();
  }

  @override
  void didUpdateWidget(TimeDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_initialTimeChanged(oldWidget.initialTime, widget.initialTime)) {
      _parseInitialTime();
    }
  }

  bool _initialTimeChanged(dynamic oldVal, dynamic newVal) {
    if (newVal == null) return false;

    if (oldVal.runtimeType != newVal.runtimeType) return true;

    if (oldVal is Duration && newVal is Duration) return oldVal != newVal;
    if (oldVal is String && newVal is String) return oldVal != newVal;

    if (oldVal is List<int> && newVal is List<int>) {
      if (oldVal.length != newVal.length) return true;
      if (oldVal.length >= 3 && newVal.length >= 3) {
        return oldVal[oldVal.length - 3] != newVal[newVal.length - 3] ||
            oldVal[oldVal.length - 2] != newVal[newVal.length - 2] ||
            oldVal[oldVal.length - 1] != newVal[newVal.length - 1];
      }
      for (int i = 0; i < oldVal.length; i++) {
        if (oldVal[i] != newVal[i]) return true;
      }
      return false;
    }

    return true;
  }

  void _parseInitialTime() {
    int h = 0, m = 0, s = 0;

    final v = widget.initialTime;

    if (v is List<int>) {
      if (v.length >= 3) {
        h = v[v.length - 3];
        m = v[v.length - 2];
        s = v[v.length - 1];
      }
    } else if (v is String) {
      final parts = v.split(':').map((e) => e.trim()).toList();
      if (parts.isNotEmpty) h = int.tryParse(parts[0]) ?? 0;
      if (parts.length > 1) m = int.tryParse(parts[1]) ?? 0;
      if (parts.length > 2) s = int.tryParse(parts[2]) ?? 0;
    } else if (v is Duration) {
      final totalSeconds = v.inSeconds;
      h = totalSeconds ~/ 3600;
      m = (totalSeconds % 3600) ~/ 60;
      s = totalSeconds % 60;
    }

    final clamped = _sanitizeHms(h, m, s);

    setState(() {
      hh = clamped[0];
      mm = clamped[1];
      ss = clamped[2];
    });
  }

  List<int> _sanitizeHms(int h, int m, int s) {
    if (!widget.clampToRanges) return [h, m, s];
    return [
      h.clamp(0, widget.maxHours),
      m.clamp(0, 59),
      s.clamp(0, 59),
    ];
  }

  // ------------- label helpers -------------

  String _two(int v) => v.toString().padLeft(2, '0');

  String _label() {
    switch (widget.displayMode) {
      case TimeDisplayMode.hh:
        return _two(hh);
      case TimeDisplayMode.mm:
        return _two(mm);
      case TimeDisplayMode.ss:
        return _two(ss);
      case TimeDisplayMode.hhmm:
        return '${_two(hh)}:${_two(mm)}';
      case TimeDisplayMode.mmss:
        return '${_two(mm)}:${_two(ss)}';
      case TimeDisplayMode.hhmmss:
        return '${_two(hh)}:${_two(mm)}:${_two(ss)}';
    }
  }

  // ------------- default theme -------------

  ItemTheme _defaultItemTheme() => ItemTheme(
        id: 'time_default',
        backroundColor: Colors.black,
        textColor: Colors.white,
        border: null,
        gradient: null,
        boxShadow: const [],
        textShadows: const [],
        borderRadius: BorderRadius.circular(12),
      );

  // ------------- style helpers -------------

  BoxDecoration _decorationFrom(ItemTheme t, {required bool allowBorderShadow}) {
    final bg = (t.gradient == null) ? (t.backroundColor ?? Colors.black) : null;
    return BoxDecoration(
      color: bg,
      gradient: t.gradient,
      borderRadius: t.borderRadius ?? BorderRadius.circular(12),
      border: allowBorderShadow ? t.border : null,
      boxShadow: allowBorderShadow ? t.boxShadow : null,
    );
  }

  TextStyle _textStyleFrom(ItemTheme t, TextStyle fallback) {
    return fallback.copyWith(
      color: t.textColor ?? t.symbolColor ?? fallback.color ?? Colors.white,
      shadows: t.textShadows.isNotEmpty ? t.textShadows : fallback.shadows,
    );
  }

  // ------------- build -------------

  @override
  Widget build(BuildContext context) {
    final myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    final ItemTheme itemTheme = (widget.customThemeKey == null)
        ? _defaultItemTheme()
        : myTheme.resolveSelectionTheme(
            state: 0,
            themeKey: widget.customThemeKey!,
            override: null,
          );

    final bool allowBorderShadow = widget.customThemeKey != null;

    final TextStyle baseLabel = widget.textStyle ??
        myTheme.textTheme?.titleLarge ??
        const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

    final labelStyle = _textStyleFrom(itemTheme, baseLabel);

    return Container(
      width: widget.buttonSize[0],
      height: widget.buttonSize[1],
      alignment: Alignment.center,
      decoration: _decorationFrom(itemTheme, allowBorderShadow: allowBorderShadow),
      child: Text(_label(), style: labelStyle),
    );
  }
}
