import 'package:ORX_Galley/model/current_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/bargraph_model.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/bargraph.dart';
import '../widgets/generic_selection_widget.dart';

class LightsLoungeLoungeAccentPanel extends StatefulWidget {
  const LightsLoungeLoungeAccentPanel({super.key});

  static const String _menuKey = 'lights_lounge_accent';
  static const String _prefix = 'lounge_accent';

  @override
  State<LightsLoungeLoungeAccentPanel> createState() => _LightsLoungeLoungeAccentPanelState();
}

class _LightsLoungeLoungeAccentPanelState extends State<LightsLoungeLoungeAccentPanel> {
  List<dynamic> menuItems = [];

  @override
  void initState() {
    super.initState();

    menuItems = configItems[LightsLoungeLoungeAccentPanel._menuKey] ?? [];

    Future.microtask(() {
      final provider = context.read<CurrentStateProvider>();

      for (var item in menuItems) {
        try {
          if (item is GenericSelection || item is BargraphModel) {
            provider.getCurrentStateObject(item.id);
          }
        } catch (_) {
          provider.addState(
            CurrentState(
              id: item.id,
              currentState: (item is BargraphModel ? item.defaultState : 0) ?? 0,
              isInhibited: false,
            ),
          );
        }
      }
    });
  }

  T? _findItem<T>(String id) {
    try {
      return menuItems.whereType<T>().firstWhere((e) => (e as dynamic).id == id);
    } catch (_) {
      return null;
    }
  }

  Widget _buildBargraph(CustomTheme myTheme, {required BargraphModel item, required BargraphType type}) {
    return Bargraph(
      bargraphType: type,
      width: item.width,
      height: item.height,
      id: item.id,
      maxValue: item.maxValue,
      minValue: item.minValue,
      steps: item.steps,
      title: item.title,
      titlePosition: BargraphTitlePosition.bottom,
      titleStyle: myTheme.textTheme?.labelMedium,
      spacing: item.spacing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    // final washBrt = _findItem<BargraphModel>('${LightsLoungeLoungeAccentPanel._prefix}_brt');
    final washPwr = _findItem<GenericSelection>('${LightsLoungeLoungeAccentPanel._prefix}_power');

    if (washPwr == null) {
      return const Center(child: Text('Configuration missing'));
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('ACCENT', style: myTheme.textTheme?.bodySmall),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 40),
              Selector<CurrentStateProvider, int>(
                selector: (context, p) => p.getCurrentState(washPwr.id.toString()),
                builder: (context, curr, _) {
                  return GenericSelectionWidget(
                    id: washPwr.id,
                    title: washPwr.title,
                    icons: washPwr.icons,
                    iconSize: washPwr.iconSize,
                    isMomentary: washPwr.isMomentary,
                    onStateCallBack: () {},
                    offStateCallBack: () {},
                    height: washPwr.height,
                    width: washPwr.width,
                    textIconSpacing: 10,
                    states: washPwr.states,
                    textStyle: myTheme.textTheme?.labelMedium,
                    removeBtnBackgroundStyling: true,
                  );
                },
              ),
              // const SizedBox(width: 60),
              // Expanded(
              //   child: Column(
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           _buildBargraph(myTheme, item: washBrt, type: BargraphType.brightness),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
