import 'package:ORX_Galley/model/bargraph_model.dart';
import 'package:ORX_Galley/model/current_state.dart';
import 'package:ORX_Galley/widgets/bargraph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/generic_selection_widget.dart';

class LightsLoungeAllAccentPanel extends StatelessWidget {
  const LightsLoungeAllAccentPanel({super.key});

  static const String _menuKey = 'lights_lounge_accent';
  static const String _prefix = 'lounge_accent';

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

    final GenericSelection washPwrOff = menuItems.firstWhere((e) => e.id == '${_prefix}_all_lights_off') as GenericSelection;
    final GenericSelection washPwrOn = menuItems.firstWhere((e) => e.id == '${_prefix}_all_lights_on') as GenericSelection;

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
              const SizedBox(width: 10),

              // POWER
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
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
            ],
          ),
        ],
      ),
    );
  }
}
