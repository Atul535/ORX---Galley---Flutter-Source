import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/generic_selection_widget.dart';

class LightsHallwayScreen extends StatefulWidget {
  const LightsHallwayScreen({super.key, title});

  @override
  State<LightsHallwayScreen> createState() => _LightsHallwayScreenState();
}

class _LightsHallwayScreenState extends State<LightsHallwayScreen>
    with TickerProviderStateMixin {
  String title = '';
  Radius iconsBorderRadius = const Radius.circular(15);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // title = ModalRoute.of(context)?.settings.arguments as String;
    CustomTheme myTheme =
        Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    final menuItems = configItems['hallway-lights'] as List<dynamic>;

    // lets iterate through menu items add the items to the current state provider

    GenericSelection hallwayLightsCeilingOff = menuItems
            .firstWhere((element) => element.id == 'hallwayLightsCeilingOff')
        as GenericSelection;
    GenericSelection hallwayLightsCeilingDim = menuItems
            .firstWhere((element) => element.id == 'hallwayLightsCeilingDim')
        as GenericSelection;
    GenericSelection hallwayLightsCeilingOn =
        menuItems.firstWhere((element) => element.id == 'hallwayLightsCeilingOn')
            as GenericSelection;

    GenericSelection hallwayLightsUpwashOff =
        menuItems.firstWhere((element) => element.id == 'hallwayLightsUpwashOff')
            as GenericSelection;
    GenericSelection hallwayLightsUpwashDim =
        menuItems.firstWhere((element) => element.id == 'hallwayLightsUpwashDim')
            as GenericSelection;
    GenericSelection hallwayLightsUpwashOn =
        menuItems.firstWhere((element) => element.id == 'hallwayLightsUpwashOn')
            as GenericSelection;

    return ActivityDetector(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SafeArea(
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //first column of buttons
                    Flexible(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'CEILING',
                            style: myTheme.textTheme?.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ...[
                                    hallwayLightsCeilingOff,
                                    hallwayLightsCeilingDim,
                                    hallwayLightsCeilingOn
                                  ].map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, right: 0, top: 0, bottom: 0),
                                      child:
                                          Selector<CurrentStateProvider, int>(
                                        selector: (context,
                                                currentStateNotifier) =>
                                            currentStateNotifier
                                                .getCurrentState(
                                                    item.id.toString()),
                                        builder:
                                            (context, currStateValue, child) {
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
                                            textStyle:
                                                myTheme.textTheme?.labelMedium,
                                            side: hallwayLightsCeilingOff == item
                                                ? GenericSelelectionWidgetButtonSide
                                                    .left
                                                : hallwayLightsCeilingOn == item
                                                    ? GenericSelelectionWidgetButtonSide
                                                        .right
                                                    : GenericSelelectionWidgetButtonSide
                                                        .middle,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    ),

                    //second column of buttons
                    Flexible(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'UPWASH',
                            style: myTheme.textTheme?.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ...[
                                  hallwayLightsUpwashOff,
                                  hallwayLightsUpwashDim,
                                  hallwayLightsUpwashOn
                                ].map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 0, right: 0, top: 0, bottom: 0),
                                    child: Selector<CurrentStateProvider, int>(
                                      selector: (context,
                                              currentStateNotifier) =>
                                          currentStateNotifier.getCurrentState(
                                              item.id.toString()),
                                      builder:
                                          (context, currStateValue, child) {
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
                                          textStyle:
                                              myTheme.textTheme?.labelMedium,
                                          side: hallwayLightsUpwashOff == item
                                              ? GenericSelelectionWidgetButtonSide
                                                  .left
                                              : hallwayLightsUpwashOn == item
                                                  ? GenericSelelectionWidgetButtonSide
                                                      .right
                                                  : GenericSelelectionWidgetButtonSide
                                                      .middle,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
