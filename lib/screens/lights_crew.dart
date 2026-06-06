import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/generic_selection_widget.dart';

class LightsCrewScreen extends StatefulWidget {
  const LightsCrewScreen({super.key, title});

  static const routeName = '/app/lights/galley';

  @override
  State<LightsCrewScreen> createState() => _LightsCrewScreenState();
}

class _LightsCrewScreenState extends State<LightsCrewScreen> {
  String title = '';
  Radius iconsBorderRadius = const Radius.circular(15);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // title = ModalRoute.of(context)?.settings.arguments as String;
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    final menuItems = configItems['crew-lights'] as List<dynamic>;

    // lets iterate through menu items add the items to the current state provider

    GenericSelection crewLightsCeilingOff = menuItems.firstWhere((element) => element.id == 'crewLightsCeilingOff') as GenericSelection;
    GenericSelection crewLightsCeilingDim = menuItems.firstWhere((element) => element.id == 'crewLightsCeilingDim') as GenericSelection;
    GenericSelection crewLightsCeilingOn = menuItems.firstWhere((element) => element.id == 'crewLightsCeilingOn') as GenericSelection;

    return ActivityDetector(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SafeArea(
                child:
                    // Column(
                    //   // mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     // Align(
                    //     //   alignment: Alignment.topCenter,
                    //     //   child: Padding(
                    //     //     padding: const EdgeInsets.only(bottom: 8.0),
                    //     //     child: Text(
                    //     //       'FWD ENTRY',
                    //     //       style: myTheme.textTheme?.bodyMedium,
                    //     //     ),
                    //     //   ),
                    //     // ),
                    //     const SizedBox(height: 100),
                    //     Text(
                    //       'CEILING',
                    //       style: myTheme.textTheme?.bodyMedium,
                    //     ),
                    //     const SizedBox(height: 10),
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         ...[
                    //           crewLightsCeilingOff,
                    //           crewLightsCeilingDim,
                    //           crewLightsCeilingOn
                    //         ].map(
                    //           (item) => Padding(
                    //             padding: const EdgeInsets.only(
                    //                 left: 0, right: 0, top: 0, bottom: 0),
                    //             child: Selector<CurrentStateProvider, int>(
                    //               selector: (context, currentStateNotifier) =>
                    //                   currentStateNotifier
                    //                       .getCurrentState(item.id.toString()),
                    //               builder: (context, currStateValue, child) {
                    //                 return GenericSelectionWidget(
                    //                   id: item.id,
                    //                   title: item.title,
                    //                   icons: item.icons,
                    //                   iconSize: item.iconSize,
                    //                   isMomentary: item.isMomentary,
                    //                   onStateCallBack: () {},
                    //                   offStateCallBack: () {},
                    //                   height: item.height,
                    //                   width: item.width,
                    //                   textIconSpacing: 10,
                    //                   textStyle: myTheme.textTheme?.labelMedium,
                    //                   side: crewLightsCeilingOff == item
                    //                       ? GenericSelelectionWidgetButtonSide.left
                    //                       : crewLightsCeilingOn == item
                    //                           ? GenericSelelectionWidgetButtonSide
                    //                               .right
                    //                           : GenericSelelectionWidgetButtonSide
                    //                               .middle,
                    //                 );
                    //               },
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                    Container(
                  decoration: BoxDecoration(
                    // color: Colors.black54,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.black54, const Color.fromARGB(31, 143, 121, 121)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'LIGHTING CONTROLS',
                      style: myTheme.textTheme?.headlineMedium,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
