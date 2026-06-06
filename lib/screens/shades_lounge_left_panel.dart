import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/cfg_image.dart';
import '../widgets/generic_selection_widget.dart';

class ShadesLoungeLeftPanel extends StatelessWidget {
  const ShadesLoungeLeftPanel({super.key});

  static const String _menuKey = 'shades_lounge_lounge_';
  static const String _prefix = 'shades_lounge_';

  // tady si řídíš šířku sloupce s tlačítky
  static const double panelWidth = 520;

  // vyber si, kam chceš ten sloupec umístit vpravo v panelu:
  // Alignment.centerRight / Alignment.center / Alignment.centerLeft
  static const Alignment panelAlignment = Alignment.center;

  @override
  Widget build(BuildContext context) {
    final myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    List<dynamic> menuItems = configItems['lounge_shades'] as List<dynamic>;

    GenericSelection shadesLHDown = menuItems?.firstWhere((element) => element.id == 'loungeShadesLHDown') as GenericSelection;
    GenericSelection shadesLHUp = menuItems?.firstWhere((element) => element.id == 'loungeShadesLHUp') as GenericSelection;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'LEFT',
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...[shadesLHDown].map(
                (item) => Padding(
                  padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                  child: Selector<CurrentStateProvider, int>(
                    selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(item.id.toString()),
                    builder: (context, currStateValue, child) {
                      return GenericSelectionWidget(
                        id: item.id,
                        title: item.title,
                        icons: item.icons,
                        iconSize: item.iconSize,
                        isMomentary: item.isMomentary,
                        onStateCallBack: () {},
                        offStateCallBack: () {},
                        height: item.height,
                        width: item.width,
                        textIconSpacing: 10,
                        states: item.states,
                        textStyle: myTheme.textTheme?.labelMedium,
                      );
                    },
                  ),
                ),
              ),
              const CfgImage(
                'assets/images/image_shade.png',
                width: 280,
                height: 270,
                fit: BoxFit.contain,
              ),
              ...[shadesLHUp].map(
                (item) => Padding(
                  padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                  child: Selector<CurrentStateProvider, int>(
                    selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(item.id.toString()),
                    builder: (context, currStateValue, child) {
                      return GenericSelectionWidget(
                        id: item.id,
                        title: item.title,
                        icons: item.icons,
                        iconSize: item.iconSize,
                        isMomentary: item.isMomentary,
                        onStateCallBack: () {},
                        offStateCallBack: () {},
                        height: item.height,
                        width: item.width,
                        textIconSpacing: 10,
                        states: item.states,
                        textStyle: myTheme.textTheme?.labelMedium,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
