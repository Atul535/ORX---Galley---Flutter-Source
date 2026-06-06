import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/cfg_image.dart';
import '../widgets/generic_selection_widget.dart';

class ShadesDiningAllPanel extends StatelessWidget {
  const ShadesDiningAllPanel({super.key});

  // tady si řídíš šířku sloupce s tlačítky
  static const double panelWidth = 520;

  // vyber si, kam chceš ten sloupec umístit vpravo v panelu:
  // Alignment.centerRight / Alignment.center / Alignment.centerLeft
  static const Alignment panelAlignment = Alignment.center;

  @override
  Widget build(BuildContext context) {
    final myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    List<dynamic> menuItems = configItems['dining_shades'] as List<dynamic>;

    GenericSelection shadesAllDown = menuItems?.firstWhere((element) => element.id == 'dining_globalShadesAllDown') as GenericSelection;
    GenericSelection shadesAllUp = menuItems?.firstWhere((element) => element.id == 'dining_globalShadesAllUp') as GenericSelection;

    // final raw = configItems[_menuKey];
    // if (raw is! List) {
    //   return Center(
    //     child: Text(
    //       'Config key "$_menuKey" not found or is not a List',
    //       style: myTheme.textTheme?.bodyMedium?.copyWith(color: Colors.white70),
    //     ),
    //   );
    // }

    // menuItems = raw.cast<dynamic>();

    // GenericSelection _getItem(String suffix) {
    //   final id = '$_prefix$suffix';
    //   final found = menuItems.where((e) => e is GenericSelection && e.id == id).toList();
    //   if (found.isEmpty) {
    //     throw Exception('Missing GenericSelection id="$id" in "$_menuKey"');
    //   }
    //   return found.first as GenericSelection;
    // }

    // late final GenericSelection ceilingOff;
    // late final GenericSelection ceilingDim;
    // late final GenericSelection ceilingMid;
    // late final GenericSelection ceilingBrt;

    // try {
    //   ceilingOff = _getItem('Off2');
    //   ceilingDim = _getItem('Dim2');
    //   ceilingMid = _getItem('Mid2');
    //   ceilingBrt = _getItem('Brt2');
    // } catch (e) {
    //   return Center(
    //     child: Text(
    //       e.toString(),
    //       style: myTheme.textTheme?.bodyMedium?.copyWith(color: Colors.redAccent),
    //       textAlign: TextAlign.right,
    //     ),
    //   );
    // }

    // final items = <GenericSelection>[ceilingBrt, ceilingMid, ceilingDim, ceilingOff];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'ALL',
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...[shadesAllDown].map(
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
              ...[shadesAllUp].map(
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
