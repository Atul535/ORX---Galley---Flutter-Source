import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/generic_selection_widget.dart';

class LightsMasterLavCeilingPanel extends StatelessWidget {
  const LightsMasterLavCeilingPanel({super.key});

  static const String _menuKey = 'lights_master_lav_ceiling';
  static const String _prefix = 'master_lav_ceiling_';

  // tady si řídíš šířku sloupce s tlačítky
  static const double panelWidth = 520;

  // vyber si, kam chceš ten sloupec umístit vpravo v panelu:
  // Alignment.centerRight / Alignment.center / Alignment.centerLeft
  static const Alignment panelAlignment = Alignment.center;

  @override
  Widget build(BuildContext context) {
    final myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    final raw = configItems[_menuKey];
    if (raw is! List) {
      return Center(
        child: Text(
          'Config key "$_menuKey" not found or is not a List',
          style: myTheme.textTheme?.bodyMedium?.copyWith(color: Colors.white70),
        ),
      );
    }

    final menuItems = raw.cast<dynamic>();

    GenericSelection _getItem(String suffix) {
      final id = '$_prefix$suffix';
      final found = menuItems.where((e) => e is GenericSelection && e.id == id).toList();
      if (found.isEmpty) {
        throw Exception('Missing GenericSelection id="$id" in "$_menuKey"');
      }
      return found.first as GenericSelection;
    }

    late final GenericSelection ceilingOff;
    late final GenericSelection ceilingDim;
    late final GenericSelection ceilingMid;
    late final GenericSelection ceilingBrt;

    try {
      ceilingOff = _getItem('off2');
      ceilingDim = _getItem('dim2');
      ceilingMid = _getItem('mid2');
      ceilingBrt = _getItem('brt2');
    } catch (e) {
      return Center(
        child: Text(
          e.toString(),
          style: myTheme.textTheme?.bodyMedium?.copyWith(color: Colors.redAccent),
          textAlign: TextAlign.right,
        ),
      );
    }

    final items = <GenericSelection>[ceilingBrt, ceilingMid, ceilingDim, ceilingOff];

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
          Text('CEILING', style: myTheme.textTheme?.bodySmall),
          const SizedBox(height: 10),

          // zbytek prostoru = tlačítka
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // dostupná výška pro celý blok tlačítek
                final totalH = constraints.maxHeight;

                const gap = 0.0; // mezera mezi tlačítky
                final totalGaps = gap * (items.length - 1);

                // výška jednoho tlačítka
                final buttonH = ((totalH - totalGaps) / items.length).clamp(60.0, 99999.0);

                return Align(
                  alignment: panelAlignment,
                  child: SizedBox(
                    width: panelWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        for (int i = 0; i < items.length; i++) ...[
                          SizedBox(
                            height: buttonH,
                            width: double.infinity,
                            child: Selector<CurrentStateProvider, int>(
                              selector: (context, p) => p.getCurrentState(items[i].id.toString()),
                              builder: (context, currStateValue, child) {
                                final item = items[i];
                                return GenericSelectionWidget(
                                  id: item.id,
                                  borderRadius: BorderRadius.circular(0),
                                  title: item.title,
                                  icons: item.icons,
                                  iconSize: item.iconSize,
                                  isMomentary: item.isMomentary,
                                  onStateCallBack: () {},
                                  offStateCallBack: () {},
                                  height: buttonH,
                                  width: double.infinity,
                                  textIconSpacing: 10,
                                  textAlignment: Alignment.bottomRight,
                                  states: item.states,
                                  textStyle: myTheme.textTheme?.titleLarge?.copyWith(fontSize: 31),
                                  backgroundImage: item.backgroundImage,
                                  grayscaleWhenOff: true,
                                  imageOverlayGradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.3),
                                      Colors.black.withOpacity(0.0),
                                    ],
                                    stops: const [0.2, 0.9],
                                  ),
                                  imageOverlayGradientActive: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.3),
                                      Colors.black.withOpacity(0.0),
                                    ],
                                    stops: const [0.2, 0.9],
                                  ),
                                  imageOverlayGradientInactive: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.4),
                                      Colors.black.withOpacity(0.0),
                                    ],
                                    stops: const [0.2, 0.9],
                                  ),
                                );
                              },
                            ),
                          ),
                          if (i != items.length - 1) const SizedBox(height: gap),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
