import 'dart:async';

import 'package:ORX_Galley/screens/water_screen_valve_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/enum_generic_selection_icon_text_side.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
// import '../providers/custom_theme_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../utils/logger.dart';
import '../widgets/activity_detector.dart';
import '../widgets/generic_selection_widget.dart';
import '../widgets/popup_dialog.dart';
import '../widgets/simple_tank_3d.dart';
import '../widgets/time_display_widget.dart';
import 'water_screen_advanced_popup.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key, title});

  static const routeName = '/app/water';

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  int level = 100;
  Radius iconsBorderRadius = const Radius.circular(15);

  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // title = ModalRoute.of(context)?.settings.arguments as String;
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    List<String> items = [
      'waterTank1_level',
      'waterTank2_level',
      'sterilizer1_indicator_functional',
      'sterilizer1_indicator_fail',
      'sterilizer1_indicator_service',
      'sterilizer1_indicator_uvLamp',
      'sterilizer1_resetCounter',
      'sterilizer2_indicator_functional',
      'sterilizer2_indicator_fail',
      'sterilizer2_indicator_service',
      'sterilizer2_indicator_uvLamp',
      'sterilizer2_resetCounter',
      'heater1_pwr',
      'heater2_pwr',
      'tank_low_indicator',
      'heater1',
      'heater2',
      'valve_status',
      'sterilizer1_advanced',
      'sterilizer2_advanced',
      'sterilizer1_timeDisplay',
      'sterilizer2_timeDisplay',
    ];

    Map<String, GenericSelection> itemObjects = {};

    for (var itemId in items) {
      try {
        GenericSelection item = configItems['water']?.firstWhere((element) => element.id == itemId) as GenericSelection;
        itemObjects[itemId] = item;
        logDebug('HumidifierScreen', 'Loaded item: ${itemId}');
      } catch (e) {
        logError('HumidifierScreen', 'Error loading item ${itemId}: $e');
      }
    }

    return ActivityDetector(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, kToolbarHeight + 10, 10, 10),
          child: Container(
            // color: myTheme.overlayColor,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// -------- LEFT → TANKS --------
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'POTABLE TANK\n1',
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 50),
                                  [itemObjects['waterTank1_level']]
                                      .map(
                                        (item) => Padding(
                                          padding: const EdgeInsets.only(left: 50, right: 50, top: 0, bottom: 0),
                                          child: Selector<CurrentStateProvider, int>(
                                            selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(item!.id.toString()),
                                            builder: (context, currStateValue, child) {
                                              int tankLevel = currStateValue;

                                              // currStateValue = 4;

                                              // switch (currStateValue) {
                                              //   case 0:
                                              //     tankLevel = 0;
                                              //     break;

                                              //   case 1:
                                              //     tankLevel = 10;
                                              //     break;

                                              //   case 2:
                                              //     tankLevel = 30;
                                              //     break;

                                              //   case 3:
                                              //     tankLevel = 60;
                                              //     break;

                                              //   case 4:
                                              //     tankLevel = 80;
                                              //     break;

                                              //   case 5:
                                              //     tankLevel = 100;
                                              //     break;

                                              //   default:
                                              //     tankLevel = 0;
                                              // }

                                              // logDebug('WaterScreen', 'WaterTank - new state currStateValue: $currStateValue, tankLevel: $tankLevel');

                                              return SimpleTank3D(
                                                // useQuaterLevels: true,
                                                height: 600,
                                                width: 250,
                                                backgroundColor: const Color.fromARGB(255, 1, 12, 49).withOpacity(0.65),
                                                borderColor: const Color.fromARGB(255, 160, 160, 160).withOpacity(0.9),
                                                borderSize: 2,
                                                showText: true,
                                                fontSizeScaleFactor: 1.7,
                                                animate: true,
                                                value: tankLevel,
                                                waterColor: Colors.blue.withOpacity(0.5),
                                                // cornerRadius: 10,

                                                // optional tuning:
                                                // topRimHeight: 80,
                                                // topRimCurve: 0.1,
                                                // bottomRoundness: 1.0,
                                                gridColor: Colors.white,
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                      .first,
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'POTABLE TANK\n2',
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 50),
                                  [itemObjects['waterTank2_level']]
                                      .map(
                                        (item) => Padding(
                                          padding: const EdgeInsets.only(left: 50, right: 50, top: 0, bottom: 0),
                                          child: Selector<CurrentStateProvider, int>(
                                            selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(item!.id.toString()),
                                            builder: (context, currStateValue, child) {
                                              int tankLevel = currStateValue;

                                              // logDebug('WaterScreen', 'WaterTank - new state currStateValue: $currStateValue');

                                              // switch (currStateValue) {
                                              //   case 0:
                                              //     tankLevel = 0;
                                              //     break;

                                              //   case 1:
                                              //     tankLevel = 30;
                                              //     break;

                                              //   case 2:
                                              //     tankLevel = 60;
                                              //     break;

                                              //   case 3:
                                              //     tankLevel = 80;
                                              //     break;

                                              //   case 4:
                                              //     tankLevel = 100;
                                              //     break;

                                              //   default:
                                              //     tankLevel = 0;
                                              // }

                                              // logDebug('WaterScreen', 'WasteTank - new state currStateValue: $currStateValue, tankLevel: $tankLevel');

                                              return SimpleTank3D(
                                                // useQuaterLevels: true,
                                                height: 600,
                                                width: 250,
                                                backgroundColor: const Color.fromARGB(255, 1, 12, 49).withOpacity(0.65),
                                                borderColor: const Color.fromARGB(255, 160, 160, 160).withOpacity(0.9),
                                                borderSize: 2,
                                                showText: true,
                                                fontSizeScaleFactor: 1.7,
                                                animate: true,
                                                value: tankLevel,
                                                waterColor: Colors.blue.withOpacity(0.5),

                                                gridColor: Colors.white,
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                      .first,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      Flexible(
                        flex: 4,
                        child: Column(
                          children: [
                            // lets add indicator for low water indication
                            itemObjects['tank_low_indicator'] != null
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 50, right: 50, top: 20, bottom: 0),
                                    child: Selector<CurrentStateProvider, int>(
                                      selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(itemObjects['tank_low_indicator']!.id.toString()),
                                      builder: (context, currStateValue, child) {
                                        return GenericSelectionWidget(
                                          id: itemObjects['tank_low_indicator']!.id,
                                          title: 'TANK LOW',
                                          iconTextInline: true,
                                          iconTextSide: GenericSelectionIconTextSide.left,
                                          icons: itemObjects['tank_low_indicator']!.icons,
                                          iconSize: 40,
                                          isMomentary: itemObjects['tank_low_indicator']!.isMomentary,
                                          onStateCallBack: () {},
                                          offStateCallBack: () {},
                                          height: itemObjects['tank_low_indicator']!.height,
                                          width: itemObjects['tank_low_indicator']!.width,
                                          textIconSpacing: 5,
                                          textStyle: myTheme.textTheme?.labelMedium,
                                          borderRadius: itemObjects['tank_low_indicator']!.borderRadius,
                                          states: itemObjects['tank_low_indicator']!.states,
                                          customThemeKey: itemObjects['tank_low_indicator']!.customThemeKey, // ✅ z configu
                                        );
                                      },
                                    ),
                                  )
                                : SizedBox(),
                            Flexible(
                              flex: 4,
                              fit: FlexFit.tight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                                    ),
                                    child: Builder(
                                      builder: (context) {
                                        // ---------- helpers ----------
                                        Widget cellLabel(String text) => Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(text, style: myTheme.textTheme?.headlineSmall),
                                              ),
                                            );

                                        Widget cellHeader(String text) => Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                              child: Center(
                                                child: Text(text, style: myTheme.textTheme?.headlineSmall?.copyWith(fontSize: 30), textAlign: TextAlign.center),
                                              ),
                                            );

                                        Widget buildIndicatorCell(String key, {bool showStateText = false}) {
                                          final item = itemObjects[key];
                                          if (item == null) return const SizedBox.shrink();

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                            child: Selector<CurrentStateProvider, int>(
                                              selector: (context, p) => p.getCurrentState(item.id.toString()),
                                              builder: (context, currStateValue, child) {
                                                final color = switch (currStateValue) {
                                                  0 => Colors.black54,
                                                  1 => Colors.green,
                                                  _ => Colors.amber,
                                                };

                                                final stateText = switch (currStateValue) {
                                                  0 => 'INACTIVE',
                                                  1 => 'ACTIVE',
                                                  _ => 'FAULT',
                                                };

                                                return Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    GenericSelectionWidget(
                                                      id: item.id,
                                                      title: '',
                                                      icons: item.icons,
                                                      iconSize: item.iconSize,
                                                      isMomentary: item.isMomentary,
                                                      onStateCallBack: () {},
                                                      offStateCallBack: () {},
                                                      height: item.height,
                                                      width: item.width,
                                                      textIconSpacing: item.textIconSpacing,
                                                      textStyle: myTheme.textTheme?.labelMedium,
                                                      borderRadius: item.borderRadius,
                                                      states: item.states,
                                                      customThemeKey: item.customThemeKey, // ✅ z configu
                                                      color: color,
                                                    ),
                                                    if (showStateText) ...[
                                                      const SizedBox(height: 8),
                                                      Text(stateText, style: myTheme.textTheme?.labelLarge),
                                                    ],
                                                  ],
                                                );
                                              },
                                            ),
                                          );
                                        }

                                        Widget buildResetButtonCell(String key, {bool removeBackgroundStyling = false}) {
                                          final item = itemObjects[key];
                                          if (item == null) return const SizedBox.shrink();

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                            child: Center(
                                              child: GenericSelectionWidget(
                                                id: item.id,
                                                title: item.title ?? 'RESET',
                                                icons: item.icons,
                                                iconSize: item.iconSize,
                                                isMomentary: item.isMomentary,
                                                onStateCallBack: () {},
                                                offStateCallBack: () {},
                                                height: 80,
                                                width: item.width,
                                                textIconSpacing: item.textIconSpacing,
                                                textStyle: myTheme.textTheme?.labelMedium?.copyWith(fontSize: 25),
                                                borderRadius: item.borderRadius,
                                                states: item.states,
                                                customThemeKey: item.customThemeKey, // ✅ z configu
                                                removeBtnBackgroundStyling: removeBackgroundStyling,
                                              ),
                                            ),
                                          );
                                        }

                                        Widget buildTimeDisplayCell(String key) {
                                          final item = itemObjects[key];
                                          if (item == null) return const SizedBox.shrink();

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                            child: Center(
                                              child: Selector<CurrentStateProvider, List<int>>(
                                                selector: (context, provider) => provider.getCurrentStateObject(item.id.toString()).data,
                                                shouldRebuild: (prev, curr) {
                                                  if (prev.length != curr.length) return true;

                                                  // Compare last 3 bytes (HH, MM, SS)
                                                  if (prev.length >= 3 && curr.length >= 3) {
                                                    return prev[prev.length - 3] != curr[curr.length - 3] ||
                                                        prev[prev.length - 2] != curr[curr.length - 2] ||
                                                        prev[prev.length - 1] != curr[curr.length - 1];
                                                  }

                                                  // If data shorter than 3 bytes, rebuild defensively
                                                  return true;
                                                },
                                                builder: (context, data, child) {
                                                  // Optional: ensure state exists (mirrors your ColorPicker pattern)
                                                  Provider.of<CurrentStateProvider>(context, listen: false).setCurrentState(item.id.toString(), 0, silently: true);

                                                  return TimeDisplayWidget(
                                                    id: item.id,
                                                    originId: item.id, // you can keep it or remove later
                                                    commands: item.states[1]!.commands,
                                                    initialTime: data, // ✅ comes from provider
                                                    displayMode: TimeDisplayMode.hhmm,
                                                    buttonSize: const [220, 90],
                                                    customThemeKey: item.customThemeKey, // ✅ from config
                                                    textStyle: myTheme.textTheme?.labelLarge,
                                                    onTimeDataChanged: (hms) {
                                                      // ✅ keep provider in sync so UI updates immediately + other widgets can react
                                                      Provider.of<CurrentStateProvider>(context, listen: false).setCurrentState(item.id.toString(), 0, data: hms);
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        }

                                        // ---------- table ----------
                                        return Table(
                                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                          columnWidths: const {
                                            0: FlexColumnWidth(1.2), // label column
                                            1: FlexColumnWidth(1.0),
                                            2: FlexColumnWidth(0.1),
                                            3: FlexColumnWidth(1.0),
                                          },
                                          children: [
                                            // Row 1: headers
                                            TableRow(
                                              children: [
                                                const SizedBox.shrink(),
                                                cellHeader('STERILIZER 1'),
                                                const SizedBox.shrink(),
                                                cellHeader('STERILIZER 2'),
                                              ],
                                            ),

                                            // Row 2: FUNCTIONAL
                                            // TableRow(
                                            //   children: [
                                            //     cellLabel('FUNCTIONAL'),
                                            //     buildIndicatorCell('sterilizer1_indicator_functional'),
                                            //     buildIndicatorCell('sterilizer2_indicator_functional'),
                                            //   ],
                                            // ),

                                            // Row 3: FAIL
                                            TableRow(
                                              children: [
                                                cellLabel(''),
                                                buildResetButtonCell('sterilizer1_indicator_fail', removeBackgroundStyling: true),
                                                cellLabel(''),
                                                buildResetButtonCell('sterilizer2_indicator_fail', removeBackgroundStyling: true),
                                              ],
                                            ),

                                            // Row 4: SERVICE
                                            TableRow(
                                              children: [
                                                cellLabel(''),
                                                itemObjects['sterilizer1_advanced'] != null
                                                    ? Padding(
                                                        padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                                                        child: Selector<CurrentStateProvider, int>(
                                                          selector: (context, currentStateNotifier) =>
                                                              currentStateNotifier.getCurrentState(itemObjects['sterilizer1_advanced']!.id.toString()),
                                                          builder: (context, currStateValue, child) {
                                                            return GenericSelectionWidget(
                                                              id: itemObjects['sterilizer1_advanced']!.id,
                                                              // iconTextInline: false,
                                                              // iconTextSide: GenericSelectionIconTextSide.left,
                                                              title: itemObjects['sterilizer1_advanced']!.title ?? 'ADVANCED',
                                                              icons: itemObjects['sterilizer1_advanced']!.icons,
                                                              // iconSize: 0,
                                                              isMomentary: itemObjects['sterilizer1_advanced']!.isMomentary,

                                                              // ✅ otevře popup, a tím pádem už se neprovede default toggle logika

                                                              // původní callbacky můžeš nechat prázdné, když se klik přesměruje
                                                              onStateCallBack: () {},
                                                              offStateCallBack: () {
                                                                PopupDialog.show(
                                                                  context: context,

                                                                  // chování okna
                                                                  barrierDismissible: true, // klik mimo zavře
                                                                  canPop: true, // ESC/back zavře
                                                                  barrierColor: Colors.black.withOpacity(0.55),
                                                                  barrierBlurSigma: 4,

                                                                  // vzhled okna
                                                                  title: 'UV STERILIZER 1 - FAULTS',
                                                                  width: 1700,
                                                                  height: 700,
                                                                  backgroundColor: Colors.black.withOpacity(0.75),
                                                                  borderRadius: BorderRadius.circular(18),
                                                                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                                                                  padding: const EdgeInsets.all(16),
                                                                  showCloseButton: true,

                                                                  // ✅ content stránka (libovolný widget)
                                                                  content: UvSterilizerFaultsPanel(),
                                                                );
                                                              },

                                                              height: itemObjects['sterilizer1_advanced']!.height,
                                                              width: itemObjects['sterilizer1_advanced']!.width,
                                                              textIconSpacing: 0,
                                                              textStyle: myTheme.textTheme?.bodyMedium?.copyWith(fontSize: 30),
                                                              borderRadius: itemObjects['sterilizer1_advanced']!.borderRadius,
                                                              states: itemObjects['sterilizer1_advanced']!.states,
                                                              customThemeKey: itemObjects['sterilizer1_advanced']!.customThemeKey,
                                                            );
                                                          },
                                                        ),
                                                      )
                                                    : const SizedBox.shrink(),
                                                const SizedBox.shrink(),
                                                itemObjects['sterilizer2_advanced'] != null
                                                    ? Padding(
                                                        padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                                                        child: Selector<CurrentStateProvider, int>(
                                                          selector: (context, currentStateNotifier) =>
                                                              currentStateNotifier.getCurrentState(itemObjects['sterilizer2_advanced']!.id.toString()),
                                                          builder: (context, currStateValue, child) {
                                                            return GenericSelectionWidget(
                                                              id: itemObjects['sterilizer2_advanced']!.id,
                                                              iconTextInline: true,
                                                              iconTextSide: GenericSelectionIconTextSide.left,
                                                              title: 'STERILIZER 2 ADVANCED',
                                                              icons: itemObjects['sterilizer2_advanced']!.icons,
                                                              iconSize: 45,
                                                              isMomentary: itemObjects['sterilizer2_advanced']!.isMomentary,

                                                              // ✅ otevře popup, a tím pádem už se neprovede default toggle logika

                                                              // původní callbacky můžeš nechat prázdné, když se klik přesměruje
                                                              onStateCallBack: () {},
                                                              offStateCallBack: () {
                                                                PopupDialog.show(
                                                                  context: context,

                                                                  // chování okna
                                                                  barrierDismissible: true, // klik mimo zavře
                                                                  canPop: true, // ESC/back zavře
                                                                  barrierColor: Colors.black.withOpacity(0.55),
                                                                  barrierBlurSigma: 4,

                                                                  // vzhled okna
                                                                  width: 1700,
                                                                  height: 950,
                                                                  backgroundColor: Colors.black.withOpacity(0.75),
                                                                  borderRadius: BorderRadius.circular(18),
                                                                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                                                                  padding: const EdgeInsets.all(16),
                                                                  showCloseButton: true,
                                                                  title: 'UV STERILIZER 2 - FAULTS',

                                                                  // ✅ content stránka (libovolný widget)
                                                                  content: UvSterilizerFaultsPanel(),
                                                                );
                                                              },

                                                              height: itemObjects['sterilizer2_advanced']!.height,
                                                              width: itemObjects['sterilizer2_advanced']!.width,
                                                              textIconSpacing: 15,
                                                              textStyle: myTheme.textTheme?.bodyMedium?.copyWith(fontSize: 30),
                                                              borderRadius: itemObjects['sterilizer2_advanced']!.borderRadius,
                                                              states: itemObjects['sterilizer2_advanced']!.states,
                                                              customThemeKey: itemObjects['sterilizer2_advanced']!.customThemeKey,
                                                            );
                                                          },
                                                        ),
                                                      )
                                                    : const SizedBox.shrink(),
                                              ],
                                            ),

                                            // Row 5: UV LAMP
                                            TableRow(
                                              children: [
                                                cellLabel('UV LAMP'),
                                                buildIndicatorCell('sterilizer1_indicator_uvLamp'),
                                                cellLabel(''),
                                                buildIndicatorCell('sterilizer2_indicator_uvLamp'),
                                              ],
                                            ),

                                            // Row 6: REMAINING UV LAMP + reset buttons
                                            TableRow(
                                              children: [
                                                cellLabel('REMAINING UV LAMP'),
                                                buildTimeDisplayCell('sterilizer1_timeDisplay'),
                                                cellLabel(''),
                                                buildTimeDisplayCell('sterilizer2_timeDisplay'),
                                              ],
                                            ),

                                            // Row 7: REMAINING UV LAMP + reset buttons
                                            TableRow(
                                              children: [
                                                cellLabel(''),
                                                buildResetButtonCell('sterilizer1_resetCounter'),
                                                cellLabel(''),
                                                buildResetButtonCell('sterilizer2_resetCounter'),
                                              ],
                                            ),
                                            // Row 8: REMAINING UV LAMP + reset buttons

                                            // Row 9: REMAINING UV LAMP + reset buttons
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  if (itemObjects['valve_status'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 50, right: 50, top: 20),
                                      child: Selector<CurrentStateProvider, int>(
                                        selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(itemObjects['valve_status']!.id.toString()),
                                        builder: (context, currStateValue, child) {
                                          return GenericSelectionWidget(
                                            id: itemObjects['valve_status']!.id,
                                            iconTextInline: true,
                                            iconTextSide: GenericSelectionIconTextSide.left,
                                            title: 'VALVE STATUS',
                                            icons: itemObjects['valve_status']!.icons,
                                            iconSize: 45,
                                            isMomentary: itemObjects['valve_status']!.isMomentary,
                                            onStateCallBack: () {},
                                            offStateCallBack: () {
                                              PopupDialog.show(
                                                context: context,
                                                barrierDismissible: true,
                                                canPop: true,
                                                barrierColor: Colors.black.withOpacity(0.55),
                                                barrierBlurSigma: 4,
                                                width: 1400,
                                                height: 850,
                                                backgroundColor: Colors.black.withOpacity(0.75),
                                                borderRadius: BorderRadius.circular(18),
                                                border: Border.all(color: Colors.white.withOpacity(0.25)),
                                                padding: const EdgeInsets.all(16),
                                                showCloseButton: true,
                                                title: 'VALVE FAULTS',
                                                content: ValveStatusPopupContent(
                                                  itemId: itemObjects['valve_status']!.id.toString(),
                                                  theme: myTheme,
                                                ),
                                              );
                                            },
                                            height: itemObjects['valve_status']!.height,
                                            width: itemObjects['valve_status']!.width,
                                            textIconSpacing: 15,
                                            textStyle: myTheme.textTheme?.bodyMedium?.copyWith(fontSize: 30),
                                            borderRadius: itemObjects['valve_status']!.borderRadius,
                                            states: itemObjects['valve_status']!.states,
                                            customThemeKey: itemObjects['valve_status']!.customThemeKey,
                                          );
                                        },
                                      ),
                                    ),
                                  const SizedBox(height: 40),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (itemObjects['heater1'] != null)
                                        Selector<CurrentStateProvider, int>(
                                          selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(itemObjects['heater1']!.id.toString()),
                                          builder: (context, currStateValue, child) {
                                            return GenericSelectionWidget(
                                              id: itemObjects['heater1']!.id,
                                              title: 'Primary',
                                              iconTextInline: true,
                                              iconTextSide: GenericSelectionIconTextSide.left,
                                              icons: itemObjects['heater1']!.icons,
                                              iconSize: 40,
                                              isMomentary: itemObjects['heater1']!.isMomentary,
                                              onStateCallBack: () {},
                                              offStateCallBack: () {},
                                              height: itemObjects['heater1']!.height,
                                              width: itemObjects['heater1']!.width,
                                              textIconSpacing: 5,
                                              textStyle: myTheme.textTheme?.labelMedium,
                                              borderRadius: itemObjects['heater1']!.borderRadius,
                                              states: itemObjects['heater1']!.states,
                                              customThemeKey: itemObjects['heater1']!.customThemeKey,
                                            );
                                          },
                                        ),
                                      if (itemObjects['heater2'] != null)
                                        Selector<CurrentStateProvider, int>(
                                          selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(itemObjects['heater2']!.id.toString()),
                                          builder: (context, currStateValue, child) {
                                            return GenericSelectionWidget(
                                              id: itemObjects['heater2']!.id,
                                              title: 'Backup',
                                              iconTextInline: true,
                                              iconTextSide: GenericSelectionIconTextSide.left,
                                              icons: itemObjects['heater2']!.icons,
                                              iconSize: 40,
                                              isMomentary: itemObjects['heater2']!.isMomentary,
                                              onStateCallBack: () {},
                                              offStateCallBack: () {},
                                              height: itemObjects['heater2']!.height,
                                              width: itemObjects['heater2']!.width,
                                              textIconSpacing: 5,
                                              textStyle: myTheme.textTheme?.labelMedium,
                                              borderRadius: itemObjects['heater2']!.borderRadius,
                                              states: itemObjects['heater2']!.states,
                                              customThemeKey: itemObjects['heater2']!.customThemeKey,
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                  // Wrap(
                                  //   alignment: WrapAlignment.center,
                                  //   spacing: 20,
                                  //   runSpacing: 10,
                                  //   children: [
                                  //     if (itemObjects['heater1'] != null)
                                  //       Padding(
                                  //         padding: const EdgeInsets.only(left: 50),
                                  //         child: Selector<CurrentStateProvider, int>(
                                  //           selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(itemObjects['heater1']!.id.toString()),
                                  //           builder: (context, currStateValue, child) {
                                  //             return GenericSelectionWidget(
                                  //               id: itemObjects['heater1']!.id,
                                  //               title: 'Primary',
                                  //               iconTextInline: true,
                                  //               iconTextSide: GenericSelectionIconTextSide.left,
                                  //               icons: itemObjects['heater1']!.icons,
                                  //               iconSize: 40,
                                  //               isMomentary: itemObjects['heater1']!.isMomentary,
                                  //               onStateCallBack: () {},
                                  //               offStateCallBack: () {},
                                  //               height: itemObjects['heater1']!.height,
                                  //               width: itemObjects['heater1']!.width,
                                  //               textIconSpacing: 5,
                                  //               textStyle: myTheme.textTheme?.labelMedium,
                                  //               borderRadius: itemObjects['heater1']!.borderRadius,
                                  //               states: itemObjects['heater1']!.states,
                                  //               customThemeKey: itemObjects['heater1']!.customThemeKey,
                                  //             );
                                  //           },
                                  //         ),
                                  //       ),
                                  //     if (itemObjects['heater2'] != null)
                                  //       Padding(
                                  //         padding: const EdgeInsets.only(left: 50),
                                  //         child: Selector<CurrentStateProvider, int>(
                                  //           selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(itemObjects['heater2']!.id.toString()),
                                  //           builder: (context, currStateValue, child) {
                                  //             return GenericSelectionWidget(
                                  //               id: itemObjects['heater2']!.id,
                                  //               title: 'Backup',
                                  //               iconTextInline: true,
                                  //               iconTextSide: GenericSelectionIconTextSide.left,
                                  //               icons: itemObjects['heater2']!.icons,
                                  //               iconSize: 40,
                                  //               isMomentary: itemObjects['heater2']!.isMomentary,
                                  //               onStateCallBack: () {},
                                  //               offStateCallBack: () {},
                                  //               height: itemObjects['heater2']!.height,
                                  //               width: itemObjects['heater2']!.width,
                                  //               textIconSpacing: 5,
                                  //               textStyle: myTheme.textTheme?.labelMedium,
                                  //               borderRadius: itemObjects['heater2']!.borderRadius,
                                  //               states: itemObjects['heater2']!.states,
                                  //               customThemeKey: itemObjects['heater2']!.customThemeKey,
                                  //             );
                                  //           },
                                  //         ),
                                  //       ),
                                  //   ],
                                  // ),

                                  const SizedBox(height: 20),
                                  // Potable Tanks
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
