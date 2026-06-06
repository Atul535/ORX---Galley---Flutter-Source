import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';

import '../model/generic_selection.dart';

import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/cfg_image.dart';
import '../widgets/generic_selection_widget.dart';

class ShadesMasterLavAreaScreen extends StatefulWidget {
  const ShadesMasterLavAreaScreen({super.key});

  @override
  State<ShadesMasterLavAreaScreen> createState() => _ShadesMasterLavAreaScreenState();
}

class _ShadesMasterLavAreaScreenState extends State<ShadesMasterLavAreaScreen> {
  // image sizing for overlay

  @override
  Widget build(BuildContext context) {
    final myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    List<dynamic> menuItems = configItems['master_lav_shades'] as List<dynamic>;

    GenericSelection shadesLHDown = menuItems?.firstWhere((element) => element.id == 'master_lav_globalShadesLHDown') as GenericSelection;
    GenericSelection shadesLHUp = menuItems?.firstWhere((element) => element.id == 'master_lav_globalShadesLHUp') as GenericSelection;

    return ActivityDetector(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
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
                    'RIGHT',
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
            ),
          ),
        ],
      ),
    );
  }
}
