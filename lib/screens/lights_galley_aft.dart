import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/generic_selection_widget.dart';

class LightGalleyAftScreen extends StatefulWidget {
  const LightGalleyAftScreen({super.key, title});

  @override
  State<LightGalleyAftScreen> createState() => _LightGalleyAftScreenState();
}

class _LightGalleyAftScreenState extends State<LightGalleyAftScreen> with TickerProviderStateMixin {
  static const String _menuKey = 'lights_lounge_lounge_ceiling';
  static const String _prefix = 'lounge_lounge_ceiling_';

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
      ceilingOff = _getItem('Off2');
      ceilingDim = _getItem('Dim2');
      ceilingMid = _getItem('Mid2');
      ceilingBrt = _getItem('Brt2');
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

    final GenericSelection washPwr = configItems['lights_lounge_lounge_toekick']?.firstWhere((e) => e.id == 'lounge_lounge_toekick_power') as GenericSelection;

    return ActivityDetector(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Flex(
            direction: Axis.horizontal,
            // mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Expanded(
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
                ),
              ),
              VerticalDivider(thickness: 1, endIndent: 20, indent: 20, color: Colors.white.withOpacity(0.5)),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Expanded(
                  // místo Flexible + Expanded
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ATTENDANT READ', style: myTheme.textTheme?.bodySmall),
                      const SizedBox(height: 10),

                      // ✅ zbytek výšky -> vycentruj washPwr
                      Expanded(
                        child: Center(
                          child: Selector<CurrentStateProvider, int>(
                            selector: (context, p) => p.getCurrentState(washPwr.id.toString()),
                            builder: (context, curr, _) {
                              return SizedBox(
                                // pokud washPwr.width/height občas bývá null/0, dej fallback:
                                width: (washPwr.width ?? 320).toDouble(),
                                height: (washPwr.height ?? 160).toDouble(),
                                child: GenericSelectionWidget(
                                  id: washPwr.id,
                                  title: washPwr.title,
                                  icons: washPwr.icons,
                                  iconSize: washPwr.iconSize,
                                  isMomentary: washPwr.isMomentary,
                                  onStateCallBack: () {},
                                  offStateCallBack: () {},
                                  // tady už není potřeba posílat height/width, když je to v SizedBoxu,
                                  // ale pokud widget očekává, nech:
                                  height: (washPwr.height ?? 160).toDouble(),
                                  width: (washPwr.width ?? 320).toDouble(),
                                  textIconSpacing: 10,
                                  states: washPwr.states,
                                  textStyle: myTheme.textTheme?.labelMedium,
                                  removeBtnBackgroundStyling: true,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
