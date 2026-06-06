import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/bargraph_model.dart';
import '../widgets/cfg_image.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/bargraph.dart';
import '../widgets/generic_selection_widget.dart';

class LightsGlobalScreen extends StatefulWidget {
  const LightsGlobalScreen({super.key, title});

  static const routeName = '/app/lights/global';

  @override
  State<LightsGlobalScreen> createState() => _LightsGlobalScreenState();
}

class _LightsGlobalScreenState extends State<LightsGlobalScreen> {
  String title = '';
  Radius iconsBorderRadius = const Radius.circular(15);
  final Map<String, bool> _cardPressedStates = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // title = ModalRoute.of(context)?.settings.arguments as String;
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    Widget buildBargraph(
        {required BargraphModel item, BargraphTitlePosition titlePosition = BargraphTitlePosition.bottom, TextStyle? titleStyle, BargraphType type = BargraphType.temperature}) {
      return Bargraph(
        bargraphType: type,
        width: item.width,
        height: item.height,
        id: item.id,
        maxValue: item.maxValue,
        minValue: item.minValue,
        steps: item.steps,
        title: item.title,
        titlePosition: titlePosition,
        titleStyle: titleStyle ?? myTheme.textTheme?.headlineLarge,
        spacing: item.spacing,
      );
    }

    final currentStateProvider = Provider.of<CurrentStateProvider>(
      context,
      listen: false,
    );

    final menuItems = configItems['lights-global'] as List<dynamic>;

    // lets iterate through menu items add the items to the current state provider
    // for (var item in menuItems) {
    //   if (item is GenericSelection) {
    //     currentStateProvider.addItem(
    //       CurrentState(
    //         id: item.id.toString(),
    //         currentState: item.isActive ? 1 : 0,
    //         group: item.group,
    //         maxState: item.states.length - 1,
    //       ),
    //     );
    //   } else if (item is BargraphModel) {
    //     currentStateProvider.addItem(
    //       CurrentState(
    //         id: item.id.toString(),
    //         currentState: item.defaultState,
    //         maxState: item.states.length - 1,
    //       ),
    //     );
    //   }
    // }

    GenericSelection allLightsBrt = menuItems.firstWhere((element) => element.id == 'allLightsOn') as GenericSelection;
    GenericSelection allLightsOff = menuItems.firstWhere((element) => element.id == 'allLightsOff') as GenericSelection;

    final menuItems2 = configItems['lounge-lights'] as List<dynamic>;
    final presetRows = _getPresetsRowsForGroup(menuItems2);
    // presets are Dining, Movies, Sunrise, Day Board, Night Board, Deplaning, Custom 1, Custom 2, Custom 3 Custom 4, Warm, Neutral, Cool

    return ActivityDetector(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 65, 10.0, 10.0),
        child: Align(
          alignment: Alignment.center,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
              ),
              child:
                  // Center(
                  //   child: Text(
                  //     '',
                  //     style: myTheme.textTheme?.headlineMedium,
                  //   ),
                  // ),
                  Padding(
                padding: const EdgeInsets.all(20.0),
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
                            'ALL LIGHTS',
                            style: myTheme.textTheme?.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              ...[allLightsOff, allLightsBrt].map(
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
                                        textIconSpacing: 5,
                                        states: item.states,
                                        textStyle: myTheme.textTheme?.labelMedium,
                                        side: allLightsOff == item
                                            ? GenericSelelectionWidgetButtonSide.left
                                            : allLightsBrt == item
                                                ? GenericSelelectionWidgetButtonSide.right
                                                : GenericSelelectionWidgetButtonSide.middle,
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

                    const VerticalDivider(
                      color: Colors.white54,
                      thickness: 1,
                      width: 1,
                      endIndent: 30,
                      indent: 100,
                    ),

                    //second column of buttons
                    Flexible(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('GLOBAL LIGHTING CABIN SCENARIOS', style: myTheme.textTheme?.bodyMedium),
                          const SizedBox(height: 10),
                          Expanded(
                            child: presetRows.isEmpty
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.touch_app, color: Colors.white54, size: 60),
                                        SizedBox(height: 20),
                                        Text('Select a light group', style: TextStyle(color: Colors.white70, fontSize: 18)),
                                      ],
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(50),
                                    child: Column(
                                      children: presetRows.asMap().entries.map((entry) {
                                        final rowIndex = entry.key;
                                        final rowItems = entry.value;

                                        return Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(bottom: rowIndex < presetRows.length - 1 ? 15 : 0),
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                const spacing = 15.0;
                                                final totalSpacing = spacing * (rowItems.length - 1);
                                                final cardWidth = (constraints.maxWidth - totalSpacing) / rowItems.length;

                                                return Row(
                                                  children: rowItems.asMap().entries.map((e) {
                                                    final i = e.key;
                                                    final button = e.value;

                                                    return Container(
                                                      width: cardWidth,
                                                      margin: EdgeInsets.only(right: i < rowItems.length - 1 ? spacing : 0),
                                                      child: _buildSceneCard(button: button, myTheme: myTheme),
                                                    );
                                                  }).toList(),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<List<GenericSelection>> _getPresetsRowsForGroup(List<dynamic> menuItems) {
    return [
      [
        menuItems.firstWhere((el) => el.id == 'allLightsPresetDining') as GenericSelection,
        menuItems.firstWhere((el) => el.id == 'allLightsPresetMovies') as GenericSelection,
        menuItems.firstWhere((el) => el.id == 'allLightsPresetSunrise') as GenericSelection,
        menuItems.firstWhere((el) => el.id == 'allLightsPresetDayBoard') as GenericSelection,
        menuItems.firstWhere((el) => el.id == 'allLightsPresetNightBoard') as GenericSelection,
        menuItems.firstWhere((el) => el.id == 'allLightsPresetDeplaning') as GenericSelection,
      ],
      [
        menuItems.firstWhere((el) => el.id == 'allLightsPresetCustom1') as GenericSelection,
        menuItems.firstWhere((el) => el.id == 'allLightsPresetCustom2') as GenericSelection,
        menuItems.firstWhere((el) => el.id == 'allLightsPresetCustom3') as GenericSelection,
        menuItems.firstWhere((el) => el.id == 'allLightsPresetCustom4') as GenericSelection,
      ],
      [
        menuItems.firstWhere((el) => el.id == 'allLightsPresetWarm') as GenericSelection,
        menuItems.firstWhere((el) => el.id == 'allLightsPresetNeutral') as GenericSelection,
        menuItems.firstWhere((el) => el.id == 'allLightsPresetCool') as GenericSelection,
      ],
      [
        menuItems.firstWhere((el) => el.id == 'allLightsPresetRed') as GenericSelection,
        menuItems.firstWhere((el) => el.id == 'allLightsPresetYellow') as GenericSelection,
        menuItems.firstWhere((el) => el.id == 'allLightsPresetBlue') as GenericSelection,
        menuItems.firstWhere((el) => el.id == 'allLightsPresetGreen') as GenericSelection,
        menuItems.firstWhere((el) => el.id == 'allLightsPresetPink') as GenericSelection,
        menuItems.firstWhere((el) => el.id == 'allLightsPresetWhite') as GenericSelection,
      ],
    ];
  }

  Widget _buildSceneCard({
    required GenericSelection button,
    required CustomTheme myTheme,
  }) {
    _cardPressedStates[button.id] ??= false;

    return Selector<CurrentStateProvider, int>(
      selector: (context, provider) => provider.getCurrentState(button.id.toString()),
      builder: (context, currStateValue, child) {
        final isActive = currStateValue == 1;
        final isPressed = _cardPressedStates[button.id] ?? false;
        final isHighlighted = isPressed || isActive;

        return GestureDetector(
          onTapDown: (_) {
            _cardPressedStates[button.id] = true;
            (context as Element).markNeedsBuild();
          },
          onTapUp: (_) {
            _cardPressedStates[button.id] = false;
            (context as Element).markNeedsBuild();
            // TODO: tady zavolej scénu (command / setCurrentState / send packet)
          },
          onTapCancel: () {
            _cardPressedStates[button.id] = false;
            (context as Element).markNeedsBuild();
          },
          child: AnimatedContainer(
            duration: Duration.zero,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: isHighlighted ? (myTheme.highlightColor?.withOpacity(0.5) ?? Colors.blue.withOpacity(0.5)) : Colors.black.withOpacity(0.3),
                  blurRadius: isHighlighted ? 10 : 5,
                  spreadRadius: isHighlighted ? 1 : 0,
                  offset: Offset(0, isHighlighted ? 2 : 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: button.backgroundImage != null && button.backgroundImage!.isNotEmpty
                        ? CfgImage(
                            button.backgroundImage!,
                            fit: BoxFit.cover,
                            // errorBuilder: (context, error, stackTrace) {
                            //   return Container(
                            //     decoration: BoxDecoration(
                            //       gradient: LinearGradient(
                            //         begin: Alignment.topLeft,
                            //         end: Alignment.bottomRight,
                            //         colors: [Colors.grey[800]!, Colors.grey[900]!],
                            //       ),
                            //     ),
                            //     child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 40),
                            //   );
                            // },
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.grey[800]!, Colors.grey[900]!],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                button.icons?.first ?? Icons.lightbulb,
                                color: Colors.white54,
                                size: 60,
                              ),
                            ),
                          ),
                  ),
                  if (!isHighlighted)
                    Positioned.fill(
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.matrix(<double>[
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.6),
                              ],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(isHighlighted ? 0.7 : 0.85),
                          ],
                        ),
                      ),
                      child: Text(
                        button.title ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (isActive)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: myTheme.highlightColor ?? Colors.blue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (myTheme.highlightColor ?? Colors.blue).withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 20),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
