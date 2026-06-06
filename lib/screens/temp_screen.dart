import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/bargraph_model.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../utils/utils.dart';
import '../widgets/activity_detector.dart';
import '../widgets/bargraph.dart';
import '../widgets/generic_selection_widget.dart';

class TempScreen extends StatefulWidget {
  static const routeName = '/app/temp';
  const TempScreen({super.key, title});

  @override
  State<TempScreen> createState() => _TempScreenState();
}

class _TempScreenState extends State<TempScreen> {
  String title = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    var menuItems = configItems['bedroom_temperature'] as List<dynamic>;
    GenericSelection? bedroomAuxHeater;
    GenericSelection? auxHeaterIndicator;
    GenericSelection? auxHeaterFault;
    GenericSelection? auxHeaterReset;
    BargraphModel? tempBargraph;

    try {
      bedroomAuxHeater = menuItems.firstWhere((element) => element.id == 'heaterOnOff') as GenericSelection;
      auxHeaterIndicator = menuItems.firstWhere((element) => element.id == 'heaterStatus') as GenericSelection;
      auxHeaterFault = menuItems.firstWhere((element) => element.id == 'heaterLowFlow') as GenericSelection;
      auxHeaterReset = menuItems.firstWhere((element) => element.id == 'resetHeater') as GenericSelection;
      tempBargraph = menuItems.firstWhere((element) => element.id == 'temp-fwd') as BargraphModel;
    } catch (e) {
      debugPrint('Error finding items in TempScreen: $e');
    }

    return ActivityDetector(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, kToolbarHeight + 10, 10, 10),
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            ),
            // ✅ Row musí mít crossAxisAlignment a výška je dána parentem
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Expanded - každý Column dostane half width
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text('AUX HEATER', style: myTheme.textTheme?.labelLarge),
                      const SizedBox(height: 60),
                      if (bedroomAuxHeater != null)
                        Selector<CurrentStateProvider, int>(
                          selector: (context, provider) => provider.getCurrentState(bedroomAuxHeater!.id.toString()),
                          builder: (context, currStateValue, child) {
                            return GenericSelectionWidget(
                              id: bedroomAuxHeater!.id,
                              title: '',
                              icons: bedroomAuxHeater!.icons,
                              iconSize: bedroomAuxHeater!.iconSize,
                              isMomentary: bedroomAuxHeater!.isMomentary,
                              onStateCallBack: () {},
                              offStateCallBack: () {},
                              height: bedroomAuxHeater!.height,
                              width: bedroomAuxHeater!.width,
                              textIconSpacing: bedroomAuxHeater!.textIconSpacing,
                              textStyle: myTheme.textTheme?.labelMedium,
                              borderRadius: bedroomAuxHeater!.borderRadius,
                              states: bedroomAuxHeater!.states,
                              removeBtnBackgroundStyling: true,
                            );
                          },
                        ),
                      const SizedBox(height: 40),
                      if (tempBargraph != null)
                        SizedBox(
                          width: 470,
                          // height: 150,
                          child: buildBargraph(
                            item: tempBargraph,
                            title: ' ',
                            titleStyle: myTheme.textTheme?.headlineMedium,
                            type: BargraphType.temperature,
                            thumbColorOverride: Colors.white,
                            titlePosition: BargraphTitlePosition.top,
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                // ✅ Vertical divider mezi sekcemi
                const VerticalDivider(color: Colors.white24, thickness: 1, width: 1),
                // ✅ Expanded - druhý Column
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text('STATUS', style: myTheme.textTheme?.labelLarge),
                      const SizedBox(height: 20),
                      if (auxHeaterFault != null && auxHeaterIndicator != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Selector<CurrentStateProvider, int>(
                              selector: (context, provider) => provider.getCurrentState(auxHeaterFault!.id.toString()),
                              builder: (context, currStateValue, child) {
                                return GenericSelectionWidget(
                                  id: auxHeaterFault!.id,
                                  // title: '',
                                  icons: auxHeaterFault!.icons,
                                  iconSize: auxHeaterFault!.iconSize,
                                  isMomentary: auxHeaterFault!.isMomentary,
                                  onStateCallBack: () {},
                                  offStateCallBack: () {},
                                  height: auxHeaterFault!.height + 100,
                                  width: auxHeaterFault!.width + 100,
                                  textIconSpacing: auxHeaterFault!.textIconSpacing,
                                  textStyle: myTheme.textTheme?.labelMedium,
                                  borderRadius: auxHeaterFault!.borderRadius,
                                  states: auxHeaterFault!.states,
                                  removeBtnBackgroundStyling: true,
                                  // customThemeKey: 'indicator2',
                                );
                              },
                            ),
                            Selector<CurrentStateProvider, int>(
                              selector: (context, provider) => provider.getCurrentState(auxHeaterIndicator!.id.toString()),
                              builder: (context, currStateValue, child) {
                                return GenericSelectionWidget(
                                  id: auxHeaterIndicator!.id,
                                  // title: '',
                                  icons: auxHeaterIndicator!.icons,
                                  iconSize: auxHeaterIndicator!.iconSize,
                                  isMomentary: auxHeaterIndicator!.isMomentary,
                                  onStateCallBack: () {},
                                  offStateCallBack: () {},
                                  height: auxHeaterIndicator!.height + 150,
                                  width: auxHeaterIndicator!.width + 100,
                                  imageSize: [50, 50],
                                  textIconSpacing: auxHeaterIndicator!.textIconSpacing,
                                  textStyle: myTheme.textTheme?.labelMedium,
                                  borderRadius: auxHeaterIndicator!.borderRadius,
                                  states: auxHeaterIndicator!.states,
                                  removeBtnBackgroundStyling: true,
                                  // customThemeKey: 'indicator2',
                                );
                              },
                            ),
                          ],
                        ),
                      const SizedBox(height: 150),
                      if (auxHeaterReset != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...[auxHeaterReset].map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
                                child: GenericSelectionWidget(
                                  id: item?.id,
                                  title: item?.title,
                                  icons: item?.icons,
                                  iconSize: 40,
                                  iconTextInline: true,

                                  isMomentary: item!.isMomentary,
                                  onStateCallBack: () {},
                                  offStateCallBack: () {},
                                  height: 100,
                                  width: 250,
                                  textIconSpacing: 0,
                                  states: item.states,
                                  // customThemeKey: item.customThemeKey,
                                  customThemeKey: 'simpleButton2',
                                  textStyle: myTheme.textTheme?.bodyMedium?.copyWith(fontSize: 30),
                                ),
                              ),
                            ),
                          ],
                        ),
                      // Padding(
                      //                   padding: const EdgeInsets.only(left: 50, right: 50, top: 20, bottom: 0),
                      //                   child: Selector<CurrentStateProvider, int>(
                      //                     selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(itemObjects['heater1']!.id.toString()),
                      //                     builder: (context, currStateValue, child) {
                      //                       return GenericSelectionWidget(
                      //                         id: itemObjects['heater1']!.id,
                      //                         title: 'HEATER 1',
                      //                         iconTextInline: true,
                      //                         iconTextSide: GenericSelectionIconTextSide.left,
                      //                         icons: itemObjects['heater1']!.icons,
                      //                         iconSize: 40,
                      //                         isMomentary: itemObjects['heater1']!.isMomentary,
                      //                         onStateCallBack: () {},
                      //                         offStateCallBack: () {},
                      //                         height: itemObjects['heater1']!.height,
                      //                         width: itemObjects['heater1']!.width,
                      //                         textIconSpacing: 5,
                      //                         textStyle: myTheme.textTheme?.labelMedium,
                      //                         borderRadius: itemObjects['heater1']!.borderRadius,
                      //                         states: itemObjects['heater1']!.states,
                      //                         customThemeKey: itemObjects['heater1']!.customThemeKey, // ✅ z configu
                      //                       );
                      //                     },
                      //                   ),
                      //                 )
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
