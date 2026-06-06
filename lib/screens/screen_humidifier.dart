import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
// import '../providers/custom_theme_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../utils/logger.dart';
import '../widgets/activity_detector.dart';
import '../widgets/generic_selection_widget.dart';

class HumidifierScreen extends StatefulWidget {
  const HumidifierScreen({super.key, title});

  static const routeName = '/app/water';

  @override
  State<HumidifierScreen> createState() => _HumidifierScreenState();
}

class _HumidifierScreenState extends State<HumidifierScreen> {
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
      'humidifier1_on',
      'humidifier1_off',
      'humidifier1_indicator',
      'humidifier1_min',
      'humidifier1_mid',
      'humidifier1_max',
      'humidifier2_on',
      'humidifier2_off',
      'humidifier2_indicator',
      'humidifier2_min',
      'humidifier2_mid',
      'humidifier2_max',
      'dryer_on',
      'dryer_off',
      'dryer_test',
      'dryer_reset',
      'dryer_indicator',
    ];

    Map<String, GenericSelection> itemObjects = {};

    for (var itemId in items) {
      try {
        GenericSelection item = configItems['global-humidifier']?.firstWhere((element) => element.id == itemId) as GenericSelection;
        itemObjects[itemId] = item;
        logDebug('HumidifierScreen', 'Loaded item: ${itemId}');
      } catch (e) {
        logError('HumidifierScreen', 'Error loading item ${itemId}: $e');
      }
    }

    // GenericSelection humidifier1On = configItems['global-humidifier']?.firstWhere((element) => element.id == 'humidifier1_on') as GenericSelection;
    // GenericSelection humidifier1Off = configItems['global-humidifier']?.firstWhere((element) => element.id == 'humidifier1_off') as GenericSelection;
    // GenericSelection humidifier1Indicator = configItems['global-humidifier']?.firstWhere((element) => element.id == 'humidifier1_indicator') as GenericSelection;
    // GenericSelection humidifier1Min = configItems['global-humidifier']?.firstWhere((element) => element.id == 'humidifier1_min') as GenericSelection;
    // GenericSelection humidifier1Mid = configItems['global-humidifier']?.firstWhere((element) => element.id == 'humidifier1_mid') as GenericSelection;
    // GenericSelection humidifier1Max = configItems['global-humidifier']?.firstWhere((element) => element.id == 'humidifier1_max') as GenericSelection;

    return ActivityDetector(
      child: SafeArea(
        child: Padding(
          // padding: const EdgeInsets.fromLTRB(10, kToolbarHeight + 10, 10, 10),
          padding: const EdgeInsets.fromLTRB(10, kToolbarHeight + 10, 10, 10), // ⭐ Celá stránka odsazená
          child: Container(
            // decoration: BoxDecoration(
            //   color: Colors.white.withOpacity(0.2),
            //   borderRadius: BorderRadius.circular(12),
            //   border: Border.all(color: Colors.white.withOpacity(0.5)),
            // ),
            // color: myTheme.primaryColor,
            height: double.infinity,
            width: double.infinity,
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 05.0, vertical: 20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('FWD HUMIDIFIER', style: myTheme.textTheme?.bodyMedium),
                                      const SizedBox(height: 50),
                                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        if (itemObjects['humidifier1_indicator'] != null)
                                          ...[
                                            itemObjects['humidifier1_indicator'],
                                          ].map(
                                            (item) => Padding(
                                              padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                                              child: Selector<CurrentStateProvider, int>(
                                                selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(item!.id.toString()),
                                                builder: (context, currStateValue, child) {
                                                  return Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      GenericSelectionWidget(
                                                        id: item!.id,
                                                        title: '',
                                                        icons: item.icons,
                                                        iconSize: item.iconSize,
                                                        isMomentary: item.isMomentary,
                                                        onStateCallBack: () {},
                                                        offStateCallBack: () {},
                                                        height: item.height,
                                                        width: item.width,
                                                        textIconSpacing: item.textIconSpacing + 50,
                                                        textStyle: myTheme.textTheme?.labelMedium,
                                                        borderRadius: item.borderRadius,
                                                        states: item.states,
                                                        // customThemeKey: item.customThemeKey,
                                                        customThemeKey: 'indicator2',
                                                        color: switch (currStateValue) {
                                                          0 => Colors.black54,
                                                          1 => Colors.green,
                                                          _ => Colors.amber,
                                                        },
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Text(
                                                        switch (currStateValue) {
                                                          0 => 'INACTIVE',
                                                          1 => 'ACTIVE',
                                                          _ => 'FAULT',
                                                        },
                                                        style: myTheme.textTheme?.headlineSmall,
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                      ]),
                                      const SizedBox(height: 100),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ...[itemObjects['humidifier1_off'], itemObjects['humidifier1_on']].map(
                                            (item) => Padding(
                                              padding: const EdgeInsets.only(left: 3, right: 3, top: 0, bottom: 0),
                                              child: GenericSelectionWidget(
                                                id: item?.id,
                                                title: item?.title,
                                                icons: item?.icons,
                                                iconSize: item!.iconSize,
                                                isMomentary: item.isMomentary,
                                                onStateCallBack: () {},
                                                offStateCallBack: () {},
                                                height: 100,
                                                width: 200,
                                                textIconSpacing: 5,
                                                states: item.states,
                                                // customThemeKey: item.customThemeKey,
                                                customThemeKey: 'simpleButton2',
                                                textStyle: myTheme.textTheme?.bodyMedium,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 80),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ...[itemObjects['humidifier1_min'], itemObjects['humidifier1_mid'], itemObjects['humidifier1_max']].map(
                                            (item) => Padding(
                                              padding: const EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
                                              child: GenericSelectionWidget(
                                                id: item?.id,
                                                // title: item?.title,
                                                icons: item?.icons,
                                                iconSize: 60,
                                                isMomentary: item!.isMomentary,
                                                onStateCallBack: () {},
                                                offStateCallBack: () {},
                                                height: 100,
                                                width: 150,
                                                textIconSpacing: 0,
                                                states: item.states,
                                                // customThemeKey: item.customThemeKey,
                                                customThemeKey: 'simpleButton2',
                                                textStyle: myTheme.textTheme?.bodyMedium,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 05.0, vertical: 20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('AFT HUMIDIFIER', style: myTheme.textTheme?.bodyMedium),
                                      const SizedBox(height: 50),
                                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        if (itemObjects['humidifier2_indicator'] != null)
                                          ...[
                                            itemObjects['humidifier2_indicator'],
                                          ].map(
                                            (item) => Padding(
                                              padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                                              child: Selector<CurrentStateProvider, int>(
                                                selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(item!.id.toString()),
                                                builder: (context, currStateValue, child) {
                                                  return Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      GenericSelectionWidget(
                                                        id: item!.id,
                                                        title: '',
                                                        icons: item.icons,
                                                        iconSize: item.iconSize,
                                                        isMomentary: item.isMomentary,
                                                        onStateCallBack: () {},
                                                        offStateCallBack: () {},
                                                        height: item.height,
                                                        width: item.width,
                                                        textIconSpacing: item.textIconSpacing + 50,
                                                        textStyle: myTheme.textTheme?.labelMedium,
                                                        borderRadius: item.borderRadius,
                                                        states: item.states,
                                                        // customThemeKey: item.customThemeKey,
                                                        customThemeKey: 'indicator2',
                                                        color: switch (currStateValue) {
                                                          0 => Colors.black54,
                                                          1 => Colors.green,
                                                          _ => Colors.amber,
                                                        },
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Text(
                                                        switch (currStateValue) {
                                                          0 => 'INACTIVE',
                                                          1 => 'ACTIVE',
                                                          _ => 'FAULT',
                                                        },
                                                        style: myTheme.textTheme?.headlineSmall,
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                      ]),
                                      const SizedBox(height: 100),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ...[itemObjects['humidifier2_off'], itemObjects['humidifier2_on']].map(
                                            (item) => Padding(
                                              padding: const EdgeInsets.only(left: 3, right: 3, top: 0, bottom: 0),
                                              child: GenericSelectionWidget(
                                                id: item?.id,
                                                title: item?.title,
                                                icons: item?.icons,
                                                iconSize: item!.iconSize,
                                                isMomentary: item.isMomentary,
                                                onStateCallBack: () {},
                                                offStateCallBack: () {},
                                                height: 100,
                                                width: 200,
                                                textIconSpacing: 5,
                                                states: item.states,
                                                // customThemeKey: item.customThemeKey,
                                                customThemeKey: 'simpleButton2',
                                                textStyle: myTheme.textTheme?.bodyMedium,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 80),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ...[itemObjects['humidifier2_min'], itemObjects['humidifier2_mid'], itemObjects['humidifier2_max']].map(
                                            (item) => Padding(
                                              padding: const EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
                                              child: GenericSelectionWidget(
                                                id: item?.id,
                                                title: item?.title,
                                                icons: item?.icons,
                                                iconSize: 60,
                                                isMomentary: item!.isMomentary,
                                                onStateCallBack: () {},
                                                offStateCallBack: () {},
                                                height: 100,
                                                width: 150,
                                                textIconSpacing: 0,
                                                states: item.states,
                                                // customThemeKey: item.customThemeKey,
                                                customThemeKey: 'simpleButton2',
                                                textStyle: myTheme.textTheme?.bodyMedium,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.5)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 05.0, vertical: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('ZONAL DRYER', style: myTheme.textTheme?.bodyMedium),
                            const SizedBox(height: 50),
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              if (itemObjects['dryer_indicator'] != null)
                                ...[
                                  itemObjects['dryer_indicator'],
                                ].map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                                    child: Selector<CurrentStateProvider, int>(
                                      selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(item!.id.toString()),
                                      builder: (context, currStateValue, child) {
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            GenericSelectionWidget(
                                              id: item!.id,
                                              title: '',
                                              icons: item.icons,
                                              iconSize: item.iconSize,
                                              isMomentary: item.isMomentary,
                                              onStateCallBack: () {},
                                              offStateCallBack: () {},
                                              height: item.height,
                                              width: item.width,
                                              textIconSpacing: item.textIconSpacing + 50,
                                              textStyle: myTheme.textTheme?.headlineSmall,
                                              borderRadius: item.borderRadius,
                                              states: item.states,
                                              // customThemeKey: item.customThemeKey,
                                              customThemeKey: 'indicator2',
                                              color: switch (currStateValue) {
                                                0 => Colors.black54,
                                                1 => Colors.green,
                                                _ => Colors.amber,
                                              },
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              switch (currStateValue) {
                                                0 => 'INACTIVE',
                                                1 => 'ACTIVE',
                                                _ => 'FAULT',
                                              },
                                              style: myTheme.textTheme?.headlineSmall,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ]),
                            const SizedBox(height: 100),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ...[itemObjects['dryer_off'], itemObjects['dryer_on']].map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(left: 3, right: 3, top: 0, bottom: 0),
                                    child: GenericSelectionWidget(
                                      id: item?.id,
                                      title: item?.title,
                                      // icons: item?.icons,
                                      iconSize: item!.iconSize,
                                      isMomentary: item.isMomentary,
                                      onStateCallBack: () {},
                                      offStateCallBack: () {},
                                      height: 100,
                                      width: 200,
                                      textIconSpacing: 5,
                                      states: item.states,
                                      // customThemeKey: item.customThemeKey,
                                      customThemeKey: 'simpleButton2',
                                      textStyle: myTheme.textTheme?.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 80),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ...[itemObjects['dryer_test'], itemObjects['dryer_reset']].map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
                                    child: GenericSelectionWidget(
                                      id: item?.id,
                                      title: item?.title,
                                      // icons: item?.icons,
                                      iconSize: 50,
                                      isMomentary: item!.isMomentary,
                                      onStateCallBack: () {},
                                      offStateCallBack: () {},
                                      height: 180,
                                      width: 165,
                                      textIconSpacing: 0,
                                      states: item.states,
                                      // customThemeKey: item.customThemeKey,
                                      customThemeKey: 'simpleButton2',
                                      textStyle: myTheme.textTheme?.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
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
