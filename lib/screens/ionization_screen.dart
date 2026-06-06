import 'package:ORX_Galley/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/current_state.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/generic_selection_widget.dart';

class IonizationScreen extends StatefulWidget {
  const IonizationScreen({super.key});

  static const routeName = '/app/ionization';

  @override
  State<IonizationScreen> createState() => _IonizationScreenState();
}

class _IonizationScreenState extends State<IonizationScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final Map<String, GenericSelection> itemObjects = {};

  @override
  void initState() {
    super.initState();

    final items = configItems['global-ionization'] ?? [];

    for (var item in items) {
      if (item is GenericSelection) {
        itemObjects[item.id] = item;
      }
    }

    /// ✅ Register states
    Future.microtask(() {
      final provider = context.read<CurrentStateProvider>();

      for (var item in itemObjects.values) {
        try {
          provider.getCurrentStateObject(item.id);
        } catch (e) {
          provider.addState(
            CurrentState(
              id: item.id,
              currentState: 0,
              isInhibited: false,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    List<String> items = [
      'ionization_on',
      'ionization_off',
      'ionization_indicator',
    ];

    Map<String, GenericSelection> itemObjects = {};

    for (var itemId in items) {
      try {
        GenericSelection item = configItems['global-ionization']?.firstWhere((element) => element.id == itemId) as GenericSelection;
        itemObjects[itemId] = item;
        logDebug('IonizationScreen', 'Loaded item: ${itemId}');
      } catch (e) {
        logError('IonizationScreen', 'Error loading item ${itemId}: $e');
      }
    }

    return ActivityDetector(
      child: SafeArea(
        child: Padding(
          // padding: const EdgeInsets.fromLTRB(10, kToolbarHeight + 10, 10, 10),
          padding: const EdgeInsets.fromLTRB(10, kToolbarHeight + 10, 10, 10), // ⭐ Celá stránka odsazená
          child: Center(
            child: Container(
              // decoration: BoxDecoration(
              //   color: Colors.white.withOpacity(0.2),
              //   borderRadius: BorderRadius.circular(12),
              //   border: Border.all(color: Colors.white.withOpacity(0.5)),
              // ),
              // color: myTheme.primaryColor,
              // height: double.infinity,
              // width: double.infinity,
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 2,
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
                                      Text('IONIZATION', style: myTheme.textTheme?.bodyMedium),
                                      const SizedBox(height: 50),
                                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        if (itemObjects['ionization_indicator'] != null)
                                          ...[
                                            itemObjects['ionization_indicator'],
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
                                                        states: {
                                                          if (item.states.containsKey(0)) 0: item.states[0]!,
                                                          if (item.states.containsKey(1)) 1: item.states[1]!,
                                                          if (item.states.containsKey(2)) 2: item.states[2]!,
                                                        },
                                                        // customThemeKey: item.customThemeKey,
                                                        customThemeKey: 'indicator3',
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Text(
                                                        switch (currStateValue) {
                                                          0 => '',
                                                          _ => 'FAULT',
                                                          // _ => 'FAULT',
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
                                          ...[itemObjects['ionization_off'], itemObjects['ionization_on']].map(
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
                  SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
