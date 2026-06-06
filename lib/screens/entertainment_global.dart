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
import 'entertainment_global_content.dart';

class EntertainmentGlobalScreen extends StatefulWidget {
  const EntertainmentGlobalScreen({super.key, title});

  static const routeName = '/app/lights/galley';

  @override
  State<EntertainmentGlobalScreen> createState() => _EntertainmentGlobalScreenState();
}

class _EntertainmentGlobalScreenState extends State<EntertainmentGlobalScreen> {
  String title = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = configItems['global-entertainment'] as List<dynamic>;

    // lets iterate through menu items add the items to the current state provider

    // GenericSelection globalEntertainmentMonitorPwrOff = menuItems.firstWhere((element) => element.id == 'globalEntertainmentMonitorPwrOff') as GenericSelection;
    // GenericSelection globalEntertainmentMonitorPwrOn = menuItems.firstWhere((element) => element.id == 'globalEntertainmentMonitorPwrOn') as GenericSelection;
    // GenericSelection globalEntertainmentSpeakerPwrOff = menuItems.firstWhere((element) => element.id == 'globalEntertainmentSpeakerPwrOff') as GenericSelection;
    // GenericSelection globalEntertainmentSpeakerPwrOn = menuItems.firstWhere((element) => element.id == 'globalEntertainmentSpeakerPwrOn') as GenericSelection;

    // GenericSelection globalEntertainmentMap = menuItems.firstWhere((element) => element.id == 'globalEntertainmentMap') as GenericSelection;
    // GenericSelection globalEntertainmentHDMILounge = menuItems.firstWhere((element) => element.id == 'globalEntertainmentHDMILounge') as GenericSelection;
    // GenericSelection globalEntertainmentHDMIDining = menuItems.firstWhere((element) => element.id == 'globalEntertainmentHDMIDining') as GenericSelection;
    // GenericSelection globalEntertainmentHDMIOffice = menuItems.firstWhere((element) => element.id == 'globalEntertainmentHDMIOffice') as GenericSelection;

    // BargraphModel globalVolume = menuItems.firstWhere((element) => element.id == 'globalVolume') as BargraphModel;
    // BargraphModel globalBass = menuItems.firstWhere((element) => element.id == 'globalBass') as BargraphModel;
    // BargraphModel globalTreble = menuItems.firstWhere((element) => element.id == 'globalTreble') as BargraphModel;

    // title = ModalRoute.of(context)?.settings.arguments as String;
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    return ActivityDetector(
        child: Stack(
      children: [
        // Container(color: myTheme.primaryColor),
        Align(
          alignment: Alignment.center,
          child: SafeArea(
            child: Container(
              // decoration: BoxDecoration(
              //   // color: Colors.black54,
              //   gradient: LinearGradient(
              //     begin: Alignment.topLeft,
              //     end: Alignment.bottomRight,
              //     colors: [Colors.black54, const Color.fromARGB(31, 143, 121, 121)],
              //   ),
                // image: DecorationImage(
                //   // image: AssetImage('assets/backgrounds/generic_background.png'),
                //   // fit: BoxFit.cover,
                //   opacity: 0.3,
                // ),
              // ),
              child: const EntertainmentGlobalContentScreen(),
            ),
          ),
          // child: Flex(
          //   direction: Axis.horizontal,
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     Flexible(
          //       flex: 5,
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           Text('A/V CONTROLS', style: myTheme.textTheme?.bodyMedium),
          //           const SizedBox(height: 10.0),
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               ...[globalEntertainmentMonitorPwrOff, globalEntertainmentMonitorPwrOn].map(
          //                 (item) => Padding(
          //                   padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
          //                   child: Selector<CurrentStateProvider, int>(
          //                     selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(item.id.toString()),
          //                     builder: (context, currStateValue, child) {
          //                       return GenericSelectionWidget(
          //                         id: item.id,
          //                         title: item.title,
          //                         icons: item.icons,
          //                         iconSize: item.iconSize,
          //                         isMomentary: item.isMomentary,
          //                         onStateCallBack: () {},
          //                         offStateCallBack: () {},
          //                         height: item.height,
          //                         width: item.width,
          //                         textIconSpacing: 10,
          //                         states: item.states,
          //                         textStyle: myTheme.textTheme?.labelMedium,
          //                         side: globalEntertainmentMonitorPwrOff == item
          //                             ? GenericSelelectionWidgetButtonSide.left
          //                             : globalEntertainmentMonitorPwrOn == item
          //                                 ? GenericSelelectionWidgetButtonSide.right
          //                                 : GenericSelelectionWidgetButtonSide.middle,
          //                       );
          //                     },
          //                   ),
          //                 ),
          //               ),
          //               const SizedBox(width: 20),
          //               ...[globalEntertainmentSpeakerPwrOff, globalEntertainmentSpeakerPwrOn].map(
          //                 (item) => Padding(
          //                   padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
          //                   child: Selector<CurrentStateProvider, int>(
          //                     selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(item.id.toString()),
          //                     builder: (context, currStateValue, child) {
          //                       return GenericSelectionWidget(
          //                         id: item.id,
          //                         title: item.title,
          //                         icons: item.icons,
          //                         iconSize: item.iconSize,
          //                         isMomentary: item.isMomentary,
          //                         onStateCallBack: () {},
          //                         offStateCallBack: () {},
          //                         height: item.height,
          //                         width: item.width,
          //                         textIconSpacing: 10,
          //                         states: item.states,
          //                         textStyle: myTheme.textTheme?.labelMedium,
          //                         side: globalEntertainmentSpeakerPwrOff == item
          //                             ? GenericSelelectionWidgetButtonSide.left
          //                             : globalEntertainmentSpeakerPwrOn == item
          //                                 ? GenericSelelectionWidgetButtonSide.right
          //                                 : GenericSelelectionWidgetButtonSide.middle,
          //                       );
          //                     },
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //           const SizedBox(height: 20.0),
          //           Text('A/V SOURCES', style: myTheme.textTheme?.bodyMedium),
          //           const SizedBox(height: 10.0),
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               ...[globalEntertainmentMap, globalEntertainmentHDMILounge, globalEntertainmentHDMIDining, globalEntertainmentHDMIOffice].map(
          //                 (item) => Padding(
          //                   padding: const EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
          //                   child: Selector<CurrentStateProvider, int>(
          //                     selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(item.id.toString()),
          //                     builder: (context, currStateValue, child) {
          //                       return GenericSelectionWidget(
          //                         id: item.id,
          //                         title: item.title,
          //                         icons: item.icons,
          //                         iconSize: item.iconSize,
          //                         isMomentary: item.isMomentary,
          //                         onStateCallBack: () {},
          //                         offStateCallBack: () {},
          //                         height: item.height,
          //                         width: item.width,
          //                         textIconSpacing: 10,
          //                         textStyle: myTheme.textTheme?.labelMedium,
          //                       );
          //                     },
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //           const SizedBox(height: 10.0),
          //         ],
          //       ),
          //     ),
          //     Flexible(
          //       flex: 4,
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             crossAxisAlignment: CrossAxisAlignment.center,
          //             mainAxisSize: MainAxisSize.max,
          //             children: [
          //               buildBargraph(
          //                 item: globalVolume,
          //                 titleStyle: myTheme.textTheme?.labelMedium,
          //                 type: BargraphType.volume,
          //               ),
          //             ],
          //           ),
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             crossAxisAlignment: CrossAxisAlignment.center,
          //             mainAxisSize: MainAxisSize.max,
          //             children: [
          //               buildBargraph(
          //                 item: globalBass,
          //                 titleStyle: myTheme.textTheme?.labelMedium,
          //                 type: BargraphType.volume,
          //               ),
          //             ],
          //           ),
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             crossAxisAlignment: CrossAxisAlignment.center,
          //             mainAxisSize: MainAxisSize.max,
          //             children: [
          //               buildBargraph(
          //                 item: globalTreble,
          //                 titleStyle: myTheme.textTheme?.labelMedium,
          //                 type: BargraphType.volume,
          //               ),
          //             ],
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ),
      ],
    ));
  }
}
