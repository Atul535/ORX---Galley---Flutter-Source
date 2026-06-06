import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/generic_selection_widget.dart';

class ValveStatusPopupContent extends StatelessWidget {
  const ValveStatusPopupContent({
    super.key,
    required this.itemId,
    required this.theme,
  });

  final String itemId; // (zatím nevyužito, můžeš smazat)
  final CustomTheme theme;

  static const _leftColumn = <_ValveRowSpec>[
    _ValveRowSpec('VIP LAV', 'valve_faults_VIPLavValve_open', 'valve_faults_VIPLavValve_close'),
    _ValveRowSpec('MASTER LAV', 'valve_faults_MasterLavValve_open', 'valve_faults_MasterLavValve_close'),
    _ValveRowSpec('AFT LAV LH', 'valve_faults_aft_lov_lh_open', 'valve_faults_aft_lov_lh_close'),
    _ValveRowSpec('AFT LAV RH', 'valve_faults_aft_lov_rh_open', 'valve_faults_aft_lov_rh_close'),
    _ValveRowSpec('MASTER SUPPLY', 'valve_faults_master_supply_open', 'valve_faults_master_supply_close'),
    _ValveRowSpec('OVERFLOW', 'valve_faults_overflow_open', 'valve_faults_overflow_close'),
  ];

  @override
  Widget build(BuildContext context) {
    // 1) načti config objekty jen pro ids, co chceme renderovat
    final ids = <String>{
      for (final e in _leftColumn) ...[e.openId, e.closeId]
    };

    final Map<String, GenericSelection> itemObjects = {};

    for (final id in ids) {
      final item = configItems['water']?.whereType<GenericSelection>().firstWhereOrNull((e) => e.id == id);

      if (item != null) {
        itemObjects[id] = item;
      } else {
        debugPrint('Missing config id: $id');
      }
    }

    Widget buildRow(_ValveRowSpec spec) {
      final openItem = itemObjects[spec.openId];
      final closeItem = itemObjects[spec.closeId];

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // LABEL
            Expanded(
              flex: 3,
              child: Text(
                spec.label,
                style: theme.textTheme?.labelLarge,
              ),
            ),

            // OPEN
            Expanded(
              flex: 4,
              child: Center(
                child: openItem == null
                    ? const Text('Missing')
                    : Selector<CurrentStateProvider, int>(
                        selector: (ctx, p) => p.getCurrentState(openItem.id.toString()),
                        builder: (ctx, state, _) {
                          return GenericSelectionWidget(
                            id: openItem.id,
                            title: '',
                            icons: openItem.icons,
                            iconSize: openItem.iconSize,
                            isMomentary: openItem.isMomentary,
                            onStateCallBack: () {},
                            offStateCallBack: () {},
                            height: openItem.height,
                            width: openItem.width,
                            textIconSpacing: openItem.textIconSpacing,
                            textStyle: theme.textTheme?.headlineSmall,
                            borderRadius: openItem.borderRadius,
                            states: {
                              if (openItem.states.containsKey(0)) 0: openItem.states[0]!,
                              if (openItem.states.containsKey(1)) 1: openItem.states[1]!,
                            },
                            customThemeKey: openItem.customThemeKey,
                          );
                        },
                      ),
              ),
            ),

            // CLOSE
            Expanded(
              flex: 4,
              child: Center(
                child: closeItem == null
                    ? const Text('Missing')
                    : Selector<CurrentStateProvider, int>(
                        selector: (ctx, p) => p.getCurrentState(closeItem.id.toString()),
                        builder: (ctx, state, _) {
                          return GenericSelectionWidget(
                            id: closeItem.id,
                            title: '',
                            icons: closeItem.icons,
                            iconSize: closeItem.iconSize,
                            isMomentary: closeItem.isMomentary,
                            onStateCallBack: () {},
                            offStateCallBack: () {},
                            height: closeItem.height,
                            width: closeItem.width,
                            textIconSpacing: closeItem.textIconSpacing,
                            textStyle: theme.textTheme?.headlineSmall,
                            borderRadius: closeItem.borderRadius,
                            states: {
                              if (closeItem.states.containsKey(0)) 0: closeItem.states[0]!,
                              if (closeItem.states.containsKey(1)) 1: closeItem.states[1]!,
                            },
                            customThemeKey: closeItem.customThemeKey,
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // horní “header” (v tvém PopupDialog už máš close button)
        // Text('VALVE FAULTS', style: theme.textTheme?.headlineMedium),
        const SizedBox(height: 50),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              const Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text('Location'),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Center(child: Text('Open')),
              ),
              const Expanded(
                flex: 4,
                child: Center(child: Text('Closed')),
              ),
            ],
          ),
        ),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              // levý sloupec
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    ..._leftColumn.map(buildRow),
                  ],
                ),
              ),

              const SizedBox(width: 80),
            ],
          ),
        ),
      ],
    );
  }
}

class _ValveRowSpec {
  const _ValveRowSpec(this.label, this.openId, this.closeId);

  final String label;
  final String openId;
  final String closeId;
}
