import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../utils/logger.dart';
import '../widgets/activity_detector.dart';
import '../widgets/generic_selection_widget.dart';

class MaintenanceWifiScreen extends StatelessWidget {
  const MaintenanceWifiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // title = ModalRoute.of(context)?.settings.arguments as String;
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    List<String> items = [
      'wifi_on',
      'wifi_off',
      'ped_on',
      'ped_off',
    ];

    Map<String, GenericSelection> itemObjects = {};

    for (var itemId in items) {
      try {
        GenericSelection item = configItems['global-wifi']?.firstWhere((element) => element.id == itemId) as GenericSelection;
        itemObjects[itemId] = item;
        logDebug('WifiScreen', 'Loaded item: ${itemId}');
      } catch (e) {
        logError('WifiScreen', 'Error loading item ${itemId}: $e');
      }
    }

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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Text('WIFI\n ', style: myTheme.textTheme?.bodyMedium),
                                      const SizedBox(height: 50),
                                      const SizedBox(height: 100),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ...[itemObjects['wifi_off'], itemObjects['wifi_on']].map(
                                            (item) => Padding(
                                              padding: const EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 0),
                                              child: GenericSelectionWidget(
                                                id: item?.id,
                                                title: item?.title,
                                                icons: item?.icons,
                                                iconSize: item!.iconSize,
                                                isMomentary: item.isMomentary,
                                                onStateCallBack: () {},
                                                offStateCallBack: () {},
                                                height: 250,
                                                width: 200,
                                                textIconSpacing: 20,
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
                                      Text('PORTABLE ELECTRONIC \n DEVICES', style: myTheme.textTheme?.bodyMedium, textAlign: TextAlign.center),
                                      const SizedBox(height: 50),
                                      const SizedBox(height: 100),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ...[itemObjects['ped_off'], itemObjects['ped_on']].map(
                                            (item) => Padding(
                                              padding: const EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 0),
                                              child: GenericSelectionWidget(
                                                id: item?.id,
                                                title: item?.title,
                                                icons: item?.icons,
                                                iconSize: item!.iconSize,
                                                isMomentary: item.isMomentary,
                                                onStateCallBack: () {},
                                                offStateCallBack: () {},
                                                height: 250,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
