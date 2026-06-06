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
import '../widgets/cfg_image.dart';
import '../widgets/generic_selection_widget.dart';
import '../widgets/water_tank_simple.dart';

class ShadesScreen extends StatefulWidget {
  const ShadesScreen({super.key, title});

  static const routeName = '/app/water';

  @override
  State<ShadesScreen> createState() => _ShadesScreenState();
}

class _ShadesScreenState extends State<ShadesScreen> {
  String title = '';
  Radius iconsBorderRadius = const Radius.circular(15);

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // title = ModalRoute.of(context)?.settings.arguments as String;
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    final menuItems = configItems['shades'] as List<dynamic>;

    GenericSelection shadesLHDown = menuItems?.firstWhere((element) => element.id == 'globalShadesLHDown') as GenericSelection;
    GenericSelection shadesLHUp = menuItems?.firstWhere((element) => element.id == 'globalShadesLHUp') as GenericSelection;

    GenericSelection shadesRHDown = menuItems?.firstWhere((element) => element.id == 'globalShadesRHDown') as GenericSelection;
    GenericSelection shadesRHUp = menuItems?.firstWhere((element) => element.id == 'globalShadesRHUp') as GenericSelection;

    GenericSelection shadesAllDown = menuItems?.firstWhere((element) => element.id == 'globalShadesAllDown') as GenericSelection;
    GenericSelection shadesAllUp = menuItems?.firstWhere((element) => element.id == 'globalShadesAllUp') as GenericSelection;

    return ActivityDetector(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, kToolbarHeight + 10, 10, 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'LEFT',
                      ),
                      const SizedBox(height: 10),
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
                            height: 400,
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
                ),
                const SizedBox(height: 30),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ALL ',
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...[shadesAllDown].map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
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
                            height: 400,
                            fit: BoxFit.contain,
                          ),
                          ...[shadesAllUp].map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
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
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'RIGHT',
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...[shadesRHDown].map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
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
                            height: 400,
                            fit: BoxFit.contain,
                          ),
                          ...[shadesRHUp].map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
