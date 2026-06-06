import 'package:flutter/material.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../model/image_state.dart';
import '../widgets/cfg_image.dart';
import '../widgets/generic_selection_widget.dart';
import '../widgets/popup_trigger.dart';
import 'ecbu_popup_content.dart';

/// ECBU tab content (DC1..DC8 / AC1..AC4)
class EcbuTabContent extends StatelessWidget {
  final String ecbuId; // "dc1"
  final String groupKeyPage; // "ecbu-dc1"
  final String groupKeyActions; // "ecbu-dc1-actions"
  final String? backgroundAsset; // allow null/empty

  const EcbuTabContent({
    super.key,
    required this.ecbuId,
    required this.groupKeyPage,
    required this.groupKeyActions,
    this.backgroundAsset,
  });

  @override
  Widget build(BuildContext context) {
    final rawPage = configItems[groupKeyPage] ?? const [];

    // Parse page items into:
    // - indicatorByCb: cb -> GenericSelection indicator
    // - triggerByCb:   cb -> GenericSelection trigger (optional)
    // - metaByCb:      cb -> (label, insideText, enabled)
    final indicatorByCb = <int, GenericSelection>{};
    final triggerByCb = <int, GenericSelection>{};
    final labelByCb = <int, String>{};
    final insideTextByCb = <int, String>{};
    final enabledByCb = <int, bool>{};

    for (final e in rawPage) {
      if (e is GenericSelection) {
        final id = e.id ?? '';
        final cb = _extractCbFromId(id);
        if (cb == null) continue;

        final cbNum = int.tryParse(cb);
        if (cbNum == null) continue;

        if (id.contains('_indicator')) indicatorByCb[cbNum] = e;
        if (id.contains('_trigger')) triggerByCb[cbNum] = e;
      } else if (e is Map) {
        if (e['type'] == 'cb_meta') {
          final cb = (e['cb'] as int?) ?? -1;
          if (cb > 0) {
            labelByCb[cb] = (e['label'] as String?) ?? '';
            insideTextByCb[cb] = (e['insideText'] as String?) ?? '';
            enabledByCb[cb] = (e['popupEnabled'] as bool?) ?? false;
          }
        }
      }
    }

    final isDc = ecbuId.startsWith('dc');
    final cbCount = isDc ? 32 : 9;

    return Stack(
      children: [
        // Optional background image
        if (backgroundAsset != null && backgroundAsset!.trim().isNotEmpty)
          Positioned.fill(
            child: CfgImage(
              backgroundAsset!,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),

        // CB area
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 160, 110),
            child: isDc
                ? _buildDcGrid(
                    context: context,
                    cbCount: cbCount,
                    indicatorByCb: indicatorByCb,
                    triggerByCb: triggerByCb,
                    labelByCb: labelByCb,
                    insideTextByCb: insideTextByCb,
                    enabledByCb: enabledByCb,
                  )
                : _buildAcRow(
                    context: context,
                    cbCount: cbCount,
                    indicatorByCb: indicatorByCb,
                    triggerByCb: triggerByCb,
                    labelByCb: labelByCb,
                    insideTextByCb: insideTextByCb,
                    enabledByCb: enabledByCb,
                  ),
          ),
        ),

        // Fault icons on the right (fixed column)
        Positioned(
          right: 24,
          top: 190,
          child: _buildFaultColumn(context),
        ),

        // Legend bottom row
        Positioned(
          left: 30,
          right: 30,
          bottom: 18,
          child: _buildLegendRow(context),
        ),
      ],
    );
  }

  /// DC: 4 rows x 8 columns (32 items)
  Widget _buildDcGrid({
    required BuildContext context,
    required int cbCount,
    required Map<int, GenericSelection> indicatorByCb,
    required Map<int, GenericSelection> triggerByCb,
    required Map<int, String> labelByCb,
    required Map<int, String> insideTextByCb,
    required Map<int, bool> enabledByCb,
  }) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 8,
      mainAxisSpacing: 50,
      crossAxisSpacing: 0,
      // a bit taller because label is below
      childAspectRatio: 0.85,
      children: List.generate(cbCount, (i) {
        final cb = i + 1;
        return _buildCbTile(
          context: context,
          cb: cb,
          indicatorByCb: indicatorByCb,
          triggerByCb: triggerByCb,
          label: labelByCb[cb] ?? '',
          insideText: insideTextByCb[cb] ?? '',
          enabled: enabledByCb[cb] ?? false,
        );
      }),
    );
  }

  /// AC: 1 row of 9 items
  Widget _buildAcRow({
    required BuildContext context,
    required int cbCount,
    required Map<int, GenericSelection> indicatorByCb,
    required Map<int, GenericSelection> triggerByCb,
    required Map<int, String> labelByCb,
    required Map<int, String> insideTextByCb,
    required Map<int, bool> enabledByCb,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(cbCount, (i) {
        final cb = i + 1;
        return Expanded(
          child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(flex: 1, child: Container()), // top spacer
              Flexible(
                flex: 1,
                child: _buildCbTile(
                  context: context,
                  cb: cb,
                  indicatorByCb: indicatorByCb,
                  triggerByCb: triggerByCb,
                  label: labelByCb[cb] ?? '',
                  insideText: insideTextByCb[cb] ?? '',
                  enabled: enabledByCb[cb] ?? false,
                ),
              ),
              Flexible(flex: 1, child: Container()), // top spacer
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCbTile({
    required BuildContext context,
    required int cb,
    required Map<int, GenericSelection> indicatorByCb,
    required Map<int, GenericSelection> triggerByCb,
    required String label,
    required String insideText,
    required bool enabled,
  }) {
    final indicatorItem = indicatorByCb[cb];
    if (indicatorItem == null) return const SizedBox.shrink();

    Widget? overlay;

    // Only enable popup if enabled==true and trigger exists
    if (enabled) {
      final triggerItem = triggerByCb[cb];
      if (triggerItem != null) {
        final cbStr = cb.toString().padLeft(2, '0');

        overlay = PopupTrigger(
          width: 800,
          height: 500,
          backgroundColor: const Color.fromARGB(255, 70, 70, 70).withOpacity(0.85),
          showCloseButton: true,
          barrierDismissible: true,
          canPop: true,
          barrierColor: Colors.black.withOpacity(0.55),
          barrierBlurSigma: 4,
          contentBuilder: (_) {
            return EcbuCbPopupContent(
              ecbuId: ecbuId,
              cb: cbStr,
              actionsGroupKey: groupKeyActions,
              titleText: label.isNotEmpty ? 'CB $cbStr\n-\n$label' : 'CB $cbStr',
            );
          },
          // hitbox overlay only
          child: const SizedBox.expand(),
        );
      }
    }

    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: EcbuCbTile(
        indicatorItem: indicatorItem,
        triggerOverlay: overlay,
        labelBelow: label,
        centerText: insideText,
        cornerIndexText: cb.toString(),
      ),
    );
  }

  Widget _buildFaultColumn(BuildContext context) {
    final rawPage = configItems[groupKeyPage] ?? const [];
    final faultItems = rawPage.whereType<GenericSelection>().where((e) => (e.id ?? '').contains('_fault_')).toList(growable: false);

    return Column(
      children: faultItems.map((f) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: SizedBox(
            width: 100,
            height: 160,
            child: GenericSelectionWidget.fromSelection(
              item: f,
              removeBtnBackgroundStyling: true,
              textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 20),
              onStateCallBack: () {},
              offStateCallBack: () {},
            ),
          ),
        );
      }).toList(growable: false),
    );
  }

  /// Legend: icon on the left, label on the right (visible!)
  Widget _buildLegendRow(BuildContext context) {
    final raw = configItems['ecbu-common'] ?? const [];
    final items = raw.whereType<GenericSelection>().toList(growable: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items.map((it) {
        // Prefer config title, fallback to state title
        final label = (it.title ?? '').trim().isNotEmpty ? (it.title ?? '') : _extractLegendTitle(it);

        final iconPath = _extractLegendIconPath(it);
        return SizedBox(
          width: 260,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconPath != null)
                CfgImage(
                  iconPath,
                  height: 45,
                  fit: BoxFit.contain,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }

  String _extractLegendTitle(GenericSelection it) {
    final s0 = it.states?[0];
    return (s0?.title ?? '').trim();
  }

  String? _extractLegendIconPath(GenericSelection it) {
    final s0 = it.states?[0];
    final img = s0?.imageState;
    if (img == null || img.isEmpty) return null;
    return img.first.imagePath;
  }
}

/// Extracts "07" from "..._cb07_..."
String? _extractCbFromId(String id) {
  final idx = id.indexOf('_cb');
  if (idx < 0) return null;

  final start = idx + 3; // after "_cb"
  if (start + 2 > id.length) return null;

  final two = id.substring(start, start + 2);
  if (int.tryParse(two) == null) return null;
  return two;
}

/// CB Tile: ring icon + center text + label below + optional popup overlay
class EcbuCbTile extends StatelessWidget {
  final GenericSelection indicatorItem;
  final Widget? triggerOverlay;
  final String labelBelow;
  final String centerText;
  final String cornerIndexText; // CB order number (top-left)

  const EcbuCbTile({
    super.key,
    required this.indicatorItem,
    required this.labelBelow,
    required this.centerText,
    this.triggerOverlay,
    this.cornerIndexText = '',
  });

  @override
  Widget build(BuildContext context) {
    final double w = indicatorItem.width ?? 86;
    final double h = indicatorItem.height ?? 86;

    // Calculate optimal font size for multi-line label
    double fontSize = _calculateOptimalFontSize(labelBelow, w + 65);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: w,
          height: h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              GenericSelectionWidget.fromSelection(
                item: indicatorItem,
                onStateCallBack: () {},
                offStateCallBack: () {},
              ),
              // top-left small CB index number
              if (cornerIndexText.trim().isNotEmpty)
                Positioned(
                  left: 0,
                  top: 4,
                  child: IgnorePointer(
                    child: Text(
                      cornerIndexText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              if (centerText.trim().isNotEmpty)
                IgnorePointer(
                  child: Text(
                    centerText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (triggerOverlay != null) Positioned.fill(child: triggerOverlay!),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (labelBelow.trim().isNotEmpty)
          SizedBox(
            width: w + 65,
            child: Text(
              labelBelow,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                height: 1.20,
              ),
            ),
          ),
      ],
    );
  }
}

/// Calculate optimal font size based on longest line in multi-line text
double _calculateOptimalFontSize(String text, double maxWidth) {
  if (text.trim().isEmpty) return 18.0;

  // Split by \n to get individual lines
  final lines = text.split('\n');

  // Find the longest line by character count
  int maxLineLength = 0;
  for (final line in lines) {
    if (line.trim().length > maxLineLength) {
      maxLineLength = line.trim().length;
    }
  }

  // Calculate font size based on longest line
  // These thresholds are tuned for typical monospace-ish labels
  if (maxLineLength <= 14) {
    return 19.0;
  } else if (maxLineLength <= 17) {
    return 16.0;
  } else if (maxLineLength <= 18) {
    return 15.0;
  } else {
    return 18.0;
  }
}
