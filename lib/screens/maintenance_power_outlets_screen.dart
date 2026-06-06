import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../model/position_model.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/cfg_image.dart';
import '../widgets/generic_selection_widget.dart';

class MaintenancePowerOutletsScreen extends StatelessWidget {
  const MaintenancePowerOutletsScreen({super.key});

  static const Size _kImageLogicalSize = Size(1920, 1080); // MUSÍ odpovídat config position systému

  @override
  Widget build(BuildContext context) {
    return const _PowerOutletsBody();
  }
}

class _PowerOutletsBody extends StatelessWidget {
  const _PowerOutletsBody();

  @override
  Widget build(BuildContext context) {
    final CustomTheme myTheme = context.watch<CustomThemes>().getActiveTheme();

    final List<GenericSelection> all = (configItems['power_outlets'] as List?)?.whereType<GenericSelection>().toList(growable: false) ?? const [];

    final GenericSelection? outletsOnOff = all.cast<GenericSelection?>().firstWhere(
          (e) => e?.id == 'outlets_onff',
          orElse: () => null,
        );

    // 35 zásuvek = všechny, co začínají "outlet_"
    final List<GenericSelection> outlets = all.where((e) => e.id.startsWith('outlet_')).toList(growable: false);

    return ActivityDetector(
      child: Stack(
        children: [
          // ---- Plánek + overlay indikátory ----
          Padding(
            padding: const EdgeInsets.fromLTRB(10, kToolbarHeight + 10, 10, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.5)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final rect = _containRect(
                    container: Size(constraints.maxWidth, constraints.maxHeight),
                    image: MaintenancePowerOutletsScreen._kImageLogicalSize,
                  );

                  final scale = rect.width / MaintenancePowerOutletsScreen._kImageLogicalSize.width;

                  return Stack(
                    children: [
                      // Image (ve stejném rectu jako overlay)
                      Positioned(
                        left: rect.left,
                        top: rect.top,
                        width: rect.width,
                        height: rect.height,
                        child: CfgImage(
                          'assets/YG039-LOPA_Final.png',
                          fit: BoxFit.contain, // důležité: fill do už spočítaného rectu
                          // gaplessPlayback: true,
                        ),
                      ),

                      // Overlay indikátory zásuvek
                      for (final outlet in outlets)
                        _OutletIndicator(
                          outlet: outlet,
                          rect: rect,
                          scale: scale,
                          textStyle: myTheme.textTheme?.bodyMedium,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ---- ON/OFF tlačítko dole ----
          if (outletsOnOff != null)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 250),
                child: Selector<CurrentStateProvider, int>(
                  selector: (context, provider) => provider.getCurrentState(outletsOnOff.id.toString()),
                  builder: (context, currStateValue, child) {
                    return GenericSelectionWidget(
                      id: outletsOnOff.id,
                      title: outletsOnOff.title,
                      icons: outletsOnOff.icons,
                      iconSize: outletsOnOff.iconSize,
                      isMomentary: outletsOnOff.isMomentary,
                      states: outletsOnOff.states,
                      position: outletsOnOff.position,

                      // removeBtnBackgroundStyling: true,
                      onStateCallBack: () {
                        // Reset všech zásuvek do 0 (pokud byly 1)
                        final provider = Provider.of<CurrentStateProvider>(context, listen: false);
                        for (final outlet in outlets) {
                          final callId = outlet.id.toString();
                          final state = provider.getCurrentState(callId);
                          if (state == 1) provider.setCurrentState(callId, 0);
                        }
                      },
                      offStateCallBack: () {},
                      customThemeKey: 'simpleButton2',
                      height: outletsOnOff.height + 50,
                      width: outletsOnOff.width,
                      textIconSpacing: 10,
                      textStyle: myTheme.textTheme?.bodyMedium?.copyWith(fontSize: 30),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Spočítá obdélník (v souřadnicích containeru), kam se obrázek vejde při BoxFit.contain
  Rect _containRect({required Size container, required Size image}) {
    final sx = container.width / image.width;
    final sy = container.height / image.height;
    final s = math.min(sx, sy);

    final w = image.width * s;
    final h = image.height * s;
    final dx = (container.width - w) / 2.0;
    final dy = (container.height - h) / 2.0;
    return Rect.fromLTWH(dx, dy, w, h);
  }
}

class _OutletIndicator extends StatefulWidget {
  final GenericSelection outlet;
  final Rect rect;
  final double scale;
  final TextStyle? textStyle;

  const _OutletIndicator({
    required this.outlet,
    required this.rect,
    required this.scale,
    required this.textStyle,
  });

  @override
  State<_OutletIndicator> createState() => _OutletIndicatorState();
}

class _OutletIndicatorState extends State<_OutletIndicator> {
  @override
  void initState() {
    super.initState();
    // ✅ Bezpečné místo pro inicializaci stavu — MIMO build fázi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = Provider.of<CurrentStateProvider>(context, listen: false);
      // Nastav na 1 pouze pokud ještě není nastaven (neprepisuj existující stav)
      final currentState = provider.getCurrentState(widget.outlet.id.toString());
      if (currentState != 1) {
        provider.setCurrentState(widget.outlet.id.toString(), 1, triggersSendCmd: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Position pos = widget.outlet.position ?? Position(x: 0, y: 0);

    final left = widget.rect.left + pos.x * widget.scale - (widget.outlet.width / 2);
    final top = widget.rect.top + pos.y * widget.scale - (widget.outlet.height / 2);

    return Positioned(
      left: left,
      top: top,
      width: widget.outlet.width,
      height: widget.outlet.height,
      child: Selector<CurrentStateProvider, int>(
        selector: (context, provider) => provider.getCurrentState(widget.outlet.id.toString()),
        builder: (context, currStateValue, child) {
          // ✅ ŽÁDNÉ volání setCurrentState zde!
          return GenericSelectionWidget(
            id: widget.outlet.id,
            title: widget.outlet.title,
            icons: const [],
            iconSize: 0,
            isMomentary: widget.outlet.isMomentary,
            states: widget.outlet.states,
            onStateCallBack: () {},
            offStateCallBack: () {},
            customThemeKey: widget.outlet.customThemeKey,
            height: widget.outlet.height,
            width: widget.outlet.width,
            textIconSpacing: widget.outlet.textIconSpacing,
            removeBtnBackgroundStyling: true,
            textStyle: widget.textStyle,
          );
        },
      ),
    );
  }
}
