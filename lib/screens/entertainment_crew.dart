import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/generic_selection_widget.dart';

class EntertainmentCrewScreen extends StatefulWidget {
  const EntertainmentCrewScreen({super.key, title});

  static const routeName = '/app/entetainment/crew';

  @override
  State<EntertainmentCrewScreen> createState() => _EntertainmentCrewScreenState();
}

class _EntertainmentCrewScreenState extends State<EntertainmentCrewScreen> {
  String title = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = configItems['crew-entertainment'] as List<dynamic>;

    // lets iterate through menu items add the items to the current state provider

    GenericSelection crewEntertainmentMonitorPwr = menuItems.firstWhere((element) => element.id == 'crewEntertainmentMonitorPwr') as GenericSelection;
    GenericSelection crewEntertainmentSpeakerPwr = menuItems.firstWhere((element) => element.id == 'crewEntertainmentSpeakerPwr') as GenericSelection;
    GenericSelection crewEntertainmentSpeakerPwrInhibit = menuItems.firstWhere((element) => element.id == 'crewEntertainmentSpeakerPwrInhibit') as GenericSelection;

    GenericSelection crewEntertainmentMap = menuItems.firstWhere((element) => element.id == 'crewEntertainmentMap') as GenericSelection;
    GenericSelection crewEntertainmentHDMILounge = menuItems.firstWhere((element) => element.id == 'crewEntertainmentHDMILounge') as GenericSelection;
    GenericSelection crewEntertainmentHDMIDining = menuItems.firstWhere((element) => element.id == 'crewEntertainmentHDMIDining') as GenericSelection;
    GenericSelection crewEntertainmentHDMIOffice = menuItems.firstWhere((element) => element.id == 'crewEntertainmentHDMIOffice') as GenericSelection;

    // title = ModalRoute.of(context)?.settings.arguments as String;
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    return ActivityDetector(
        child: Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //this is for inhibit only
                  ...[crewEntertainmentSpeakerPwrInhibit].map(
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

                  // Main content
                  Text('A/V CONTROLS', style: myTheme.textTheme?.bodyMedium),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      ...[crewEntertainmentMonitorPwr, crewEntertainmentSpeakerPwr].map(
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
                  // const Divider(
                  //     indent: 50,
                  //     endIndent: 50,
                  //     thickness: 2,
                  //     color: Colors.white70),
                  const SizedBox(height: 20.0),
                  Text('A/V SOURCES', style: myTheme.textTheme?.bodyMedium),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      ...[crewEntertainmentMap, crewEntertainmentHDMILounge, crewEntertainmentHDMIDining, crewEntertainmentHDMIOffice].map(
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
                                textStyle: myTheme.textTheme?.labelMedium,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                ],
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
