import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/generic_selection_widget.dart';

class ShadesOfficeScreen extends StatefulWidget {
  const ShadesOfficeScreen({super.key, title});

  static const routeName = '/app/lights/galley';

  @override
  State<ShadesOfficeScreen> createState() => _ShadesOfficeScreenState();
}

class _ShadesOfficeScreenState extends State<ShadesOfficeScreen> {
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

    final menuItems = configItems['divider'] as List<dynamic>;

    // lets iterate through menu items add the items to the current state provider

    GenericSelection dividerUp = menuItems
        .firstWhere((element) => element.id == 'dividerUp') as GenericSelection;
    GenericSelection dividerDown =
        menuItems.firstWhere((element) => element.id == 'dividerDown')
            as GenericSelection;

    return ActivityDetector(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SafeArea(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    Text(
                      'DIVIDER',
                      style: myTheme.textTheme?.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...[
                          dividerDown,
                          dividerUp,
                        ].map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(
                                left: 0, right: 0, top: 0, bottom: 0),
                            child: Selector<CurrentStateProvider, int>(
                              selector: (context, currentStateNotifier) =>
                                  currentStateNotifier
                                      .getCurrentState(item.id.toString()),
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
                                  side: dividerDown == item
                                      ? GenericSelelectionWidgetButtonSide.left
                                      : dividerUp == item
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
