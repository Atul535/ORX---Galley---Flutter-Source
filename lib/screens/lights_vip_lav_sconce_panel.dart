import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/bargraph_model.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/bargraph.dart';
import '../widgets/generic_selection_widget.dart';

class LightsVipLavSconcePanel extends StatelessWidget {
  const LightsVipLavSconcePanel({super.key});

  static const String _menuKey = 'lights_vip_lav_sconce';
  static const String _prefix = 'vip_lav_sconce';

  @override
  Widget build(BuildContext context) {
    final myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    final menuItems = configItems[_menuKey] as List<dynamic>;

    final GenericSelection washPwr = menuItems.firstWhere((e) => e.id == '${_prefix}_power') as GenericSelection;

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
          Text('SCONCE', style: myTheme.textTheme?.bodySmall),
          const SizedBox(height: 25),
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
            ],
          ),
        ],
      ),
    );
  }
}
