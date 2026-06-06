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

class LightsBusinessDnwashPanel extends StatelessWidget {
  const LightsBusinessDnwashPanel({super.key});

  static const String _menuKey = 'lights_business_dnwash';
  static const String _prefix = 'business_dnwash';

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
    final GenericSelection washPwr = menuItems.firstWhere((e) => e.id == '${_prefix}_power') as GenericSelection;
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
          Text('DNWASH', style: myTheme.textTheme?.bodySmall),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 0),

              // POWER
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                ],
              ),

              const SizedBox(width: 60),

              // CONTROLS
              Column(
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
                        scale: 2.3,
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
            ],
          ),
        ],
      ),
    );
  }
}
