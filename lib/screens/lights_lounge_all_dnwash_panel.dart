import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/bargraph_model.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/bargraph.dart';
import '../widgets/color_picker.dart';
import '../widgets/generic_selection_widget.dart';

class LightsLoungeAllDnwashPanel extends StatelessWidget {
  const LightsLoungeAllDnwashPanel({super.key});

  static const String _menuKey = 'lounge_and_hallway_lights_all_dnwash';
  static const String _prefix = 'lounge_and_hallway_all_dnwash';

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

    final menuItems = configItems[_menuKey] as List<dynamic>;

    final BargraphModel washBrt = menuItems.firstWhere((e) => e.id == '${_prefix}_brt') as BargraphModel;
    final BargraphModel washTemp = menuItems.firstWhere((e) => e.id == '${_prefix}_temp') as BargraphModel;
    final GenericSelection washPwrOff = menuItems.firstWhere((e) => e.id == '${_prefix}_lights_off') as GenericSelection;
    final GenericSelection washPwrOn = menuItems.firstWhere((e) => e.id == '${_prefix}_lights_on') as GenericSelection;
    final GenericSelection colorPicker = menuItems.firstWhere((e) => e.id == '${_prefix}_colorPicker') as GenericSelection;

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
          Text('DOWNWASH', style: myTheme.textTheme?.bodySmall),
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 10),

              // POWER
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...[washPwrOn, washPwrOff].map(
                        (item) => Selector<CurrentStateProvider, int>(
                          selector: (context, p) => p.getCurrentState(item.id.toString()),
                          builder: (context, curr, _) {
                            return GenericSelectionWidget(
                              id: item.id,
                              title: item.title,
                              icons: item.icons,
                              iconSize: item.iconSize,
                              isMomentary: item.isMomentary,
                              onStateCallBack: () {},
                              offStateCallBack: () {},
                              height: item.height - 20,
                              width: item.width - 80,
                              textIconSpacing: 10,
                              states: item.states,
                              textStyle: myTheme.textTheme?.labelMedium,
                              removeBtnBackgroundStyling: true,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(width: 10),

              // CONTROLS
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBargraph(myTheme, item: washBrt, type: BargraphType.brightness),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(indent: 50, endIndent: 50, thickness: 1, color: Colors.white70),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBargraph(myTheme, item: washTemp, type: BargraphType.lightTemperature),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(indent: 50, endIndent: 50, thickness: 1, color: Colors.white70),
                    const SizedBox(height: 10),
                    Selector<CurrentStateProvider, List<int>>(
                      selector: (context, provider) => provider.getCurrentStateObject(colorPicker.id.toString()).data,
                      shouldRebuild: (prev, curr) {
                        if (prev.length != curr.length) return true;
                        if (prev.length >= 3 && curr.length >= 3) {
                          return prev[prev.length - 3] != curr[curr.length - 3] || prev[prev.length - 2] != curr[curr.length - 2] || prev[prev.length - 1] != curr[curr.length - 1];
                        }
                        return true;
                      },
                      builder: (context, data, child) {
                        Provider.of<CurrentStateProvider>(context, listen: false).setCurrentState(colorPicker.id.toString(), 0, silently: true);

                        return ColorPicker(
                          id: colorPicker.id,
                          commands: colorPicker.states[1]!.commands,
                          initialColor: data,
                          scale: 2.0,
                          textScale: 0.5,
                          buttonSize: [colorPicker.width, colorPicker.height],
                          textStyle: myTheme.textTheme?.labelMedium,
                          onColorDataChanged: (colorData) {
                            Provider.of<CurrentStateProvider>(context, listen: false).setCurrentState(colorPicker.id, 0, data: colorData);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
