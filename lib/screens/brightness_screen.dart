import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../helpers/utility.dart';
import '../model/bargraph_model.dart';
import '../model/generic_selection.dart';
import '../model/time_service.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../utils/utils.dart';
import '../widgets/activity_detector.dart';
import '../widgets/bargraph.dart';
import '../widgets/generic_selection_widget.dart';

class BrightnessScreen extends StatefulWidget {
  static const routeName = '/app/brtscreen';
  const BrightnessScreen({super.key, title});

  @override
  State<BrightnessScreen> createState() => _BrightnessScreenState();
}

class _BrightnessScreenState extends State<BrightnessScreen> {
  String title = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    GenericSelection pullupDisplayOff = configItems['pullup']!.firstWhere((element) => element.id == 'pullupDisplayOff') as GenericSelection;

    BargraphModel pullupBrightness = configItems['pullup']!.firstWhere((element) => element.id == 'pullupBrightness') as BargraphModel;

    TimerService timerService = Provider.of<TimerService>(context, listen: false);

    return ActivityDetector(
      child: Stack(
        children: [
          Container(color: myTheme.primaryColor),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ...[
                      pullupDisplayOff,
                    ].map(
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
                              onStateCallBack: () {
                                timerService.screenSaverActive = true;
                                if (item.route != null) {
                                  Navigator.of(context).pushNamed(
                                    item.route.toString(),
                                    arguments: "",
                                  );
                                }
                              },
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
                    const SizedBox(width: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        buildBargraph(
                          item: pullupBrightness,
                          titleStyle: myTheme.textTheme?.labelMedium,
                          type: BargraphType.volume,
                          onValueChangeCallback: (double value) {
                            setPwmValue(value);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ),
        ],
      ),
    );
  }
}
