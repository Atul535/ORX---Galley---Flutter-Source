import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/generic_selection_widget.dart';

class UvSterilizerFaultsPanel extends StatelessWidget {
  // Update this key to match your configItems structure.
  static const String _configKey = 'water';
  const UvSterilizerFaultsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final faultCodeSelections = _readFaultSelectionsFromConfig();

    return Column(
      children: [
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FaultColumn(items: _slice(faultCodeSelections, 0, 10)),
            const SizedBox(width: 50),
            _FaultColumn(items: _slice(faultCodeSelections, 10, 10)),
            const SizedBox(width: 50),
            _FaultColumn(items: _slice(faultCodeSelections, 20, 10)),
            const SizedBox(width: 50),
            _FaultColumn(items: _slice(faultCodeSelections, 30, 10)),
            const SizedBox(width: 50),
            _FaultColumn(items: _slice(faultCodeSelections, 40, 6)),
          ],
        ),
      ],
    );
  }

  // Reads GenericSelection list directly from configItems.
  // This is intentionally defensive: it tolerates nulls and mixed lists.
  static const String _faultPrefix = 'valve_faults_FaultCode';

  static List<GenericSelection> _readFaultSelectionsFromConfig() {
    final dynamic raw = configItems[_configKey];

    // Case 1: configItems[_configKey] is directly a List
    if (raw is List) {
      return raw
          .whereType<GenericSelection>()
          .where((e) => e.id?.contains(_faultPrefix) ?? false)
          .toList(growable: false);
    }

    // Case 2: configItems[_configKey] is a Map with an "items" list
    if (raw is Map && raw['items'] is List) {
      final List items = raw['items'];

      return items
          .whereType<GenericSelection>()
          .where((e) => e.id?.contains(_faultPrefix) ?? false)
          .toList(growable: false);
    }

    return const [];
  }

  // Returns [count] items from [start]. Safely clamps if list is shorter.
  static List<GenericSelection> _slice(List<GenericSelection> list, int start, int count) {
    if (start >= list.length) return const [];
    final end = (start + count) > list.length ? list.length : (start + count);
    return list.sublist(start, end);
  }
}

class _FaultColumn extends StatelessWidget {
  final List<GenericSelection> items;

  const _FaultColumn({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 13.0, top: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => _FaultRow(item: item)).toList(),
      ),
    );
  }
}

class _FaultRow extends StatelessWidget {
  final GenericSelection item;

  const _FaultRow({required this.item});

  String _labelFromTitle(String? title) {
    // Title should already be "Fault Code X". Fallback keeps UI robust.
    if (title == null || title.isEmpty) return 'Unknown Fault';
    return title;
  }

  @override
  Widget build(BuildContext context) {
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: Selector<CurrentStateProvider, int>(
              selector: (ctx, p) => p.getCurrentState(item.id.toString()),
              builder: (ctx, state, _) {
                // jestli už barvu řeší theme přes states, můžeš tohle odstranit

                return GenericSelectionWidget(
                  id: item.id,
                  title: '',
                  icons: item.icons,
                  iconSize: item.iconSize,
                  isMomentary: item.isMomentary,
                  onStateCallBack: () {},
                  offStateCallBack: () {},
                  height: 30,
                  width: 30,
                  textIconSpacing: item.textIconSpacing,
                  textStyle: myTheme.textTheme?.headlineSmall?.copyWith(fontSize: 0),
                  borderRadius: item.borderRadius,
                  states: {
                    if (item.states.containsKey(0)) 0: item.states[0]!,
                    if (item.states.containsKey(1)) 1: item.states[1]!,
                  },
                  customThemeKey: item.customThemeKey,
                  // touchDisabled: true, // read-only list
                );
              },
            ),
            // GenericSelectionWidget.fromSelection(item: item),
          ),
          const SizedBox(width: 16),
          Text(
            _labelFromTitle(item.title),
            style: myTheme.textTheme?.bodyMedium?.copyWith(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
