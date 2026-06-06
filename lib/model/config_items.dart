// LOPA NAV
// List of LOPA navigation items
import 'dart:io';

import 'package:ORX_Galley/screens/home_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/config_items.dart';
import '../model/time_service.dart';

import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../screens/home_screen.dart';
import '../screens/screen_saver_blank.dart';
import '../screens/screen_saver_logo.dart';
import '../utils/utils.dart';
import '../widgets/bargraph.dart';
import '../widgets/cfg_image.dart';
import '../widgets/generic_selection_widget.dart';
import '../widgets/side_navigation/src/api/side_navigation_bar.dart';
import '../widgets/side_navigation/src/api/side_navigation_bar_item.dart';
import '../widgets/side_navigation/src/api/side_navigation_bar_theme.dart';
import '../utils/logger.dart';
import 'bargraph_model.dart';
import 'generic_selection.dart';
import 'side_menu_item.dart';

final GenericSelection globalMenuJump = GenericSelection(
  id: 'menuGlobal',
  // icon: Icons.lightbulb,
  title: 'Global Menu',
  // titleAlignVertical: TextAlignVertical.top,
  // titleAlignHorizontal: TextAlign.center,
  iconSize: 20,
  height: 50,
  width: 200,
  isMomentary: true,
  route: HomeScreen.routeName,
);

List<SideMenuItem> globaleMenuFooterItems = [
  SideMenuItem(
    title: 'HOME',
    id: 'mi_globalMenu',
    // icon: Icons.home,
    imageStates: [
      //   ImageState(imagePath: 'assets/icons/icon_home.png', imageEffect: ImageEffect.grayscale),
      //   ImageState(imagePath: 'assets/icons/icon_home.png', imageEffect: ImageEffect.none)
    ],
    backgroundImage: 'assets/banners/banner_home.png',
    route: HomeMenuScreen.routeName,
  ),
];

List<Widget> navGenSelections = configItems['lopa-nav-items']!
    .map(
      (item) => GenericSelectionWidget(
          id: item.id,
          height: item.height,
          width: item.width,
          isMomentary: true,
          position: item.position,
          route: item.route,
          title: item.title,
          isTransparent: true,
          // color: Colors.red.withOpacity(0.5),
          states: item.states),
    )
    .toList();

// Bottom Drawer items
final GenericSelection displayOff = GenericSelection(
  id: 'dispOff',
  icons: [Icons.power_settings_new],
  title: 'Screen Off',
  iconSize: 50,
  height: 120,
  width: 120,
  isMomentary: true,
  route: ScreenSaverBlank.routeName,
);
final GenericSelection logoBtn = GenericSelection(
  id: 'logo',
  icons: [Icons.perm_media],
  title: 'Logo',
  iconSize: 50,
  height: 120,
  width: 120,
  isMomentary: true,
  route: ScreenSaverLogo.routeName,
);

final BargraphModel brtBar = BargraphModel(
  id: 'brtBar',
  title: 'Brightness',
  // defaultValue: 31,
  minValue: 0,
  maxValue: 31,
  steps: 32,
  value: 31,
  height: 100,
  width: 500,
  spacing: 50,
);

void setPwmValue(double value) {
  logDebug("ConfigItems", "setPwmValue value: $value");
  if (Platform.isLinux) {
    value = value * (1024 / 14);
    int valueInt = value.round();
    if (valueInt < 50) {
      valueInt = 50;
    } else if (valueInt > 1024) {
      valueInt = 1024;
    }

    logDebug("ConfigItems", "setPwmValue valueInt: $valueInt");
    gpioService?.setHardwarePWM(1, valueInt);
  }
}

Widget pullupBody(BuildContext context) {
  GenericSelection pullupDisplayOff = configItems['pullup']!.firstWhere((element) => element.id == 'pullupDisplayOff') as GenericSelection;

  BargraphModel pullupBrightness = configItems['pullup']!.firstWhere((element) => element.id == 'pullupBrightness') as BargraphModel;

  CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
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
                      TimerService.of(context).screenSaverActive = true;
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
  );
}

// this is how each screen is designed, the screen body
Widget pullupChild(
  BuildContext context,
  String lopaPath,
  String appBarTitle,
  List<Widget> views,
  List<dynamic> menuItems,
  String menuTrackingObjectId,
  CustomTheme myTheme,
  Function onExpanCollapseTapAction, {
  bool showGlobalMenuBtn = true,
  bool showLopa = true,
  showSideMenu = true,
}) {
  return Scaffold(
    body: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: <Widget>[
            if (showLopa) ...[
              Row(
                children: [
                  SizedBox(
                    height: constraints.maxHeight * 0.29,
                    width: constraints.maxWidth,
                    child: Stack(
                      children: <Widget>[
                        !showGlobalMenuBtn ? const Padding(padding: EdgeInsets.all(15.0), child: SizedBox.shrink()) : const SizedBox.shrink(),
                        SizedBox(
                          height: constraints.maxHeight * 0.29,
                          width: constraints.maxWidth,
                          child: Center(
                            child: CfgImage(lopaPath, fit: BoxFit.fill),
                          ),
                        ),
                        ...navGenSelections,
                      ],
                    ),
                  ),
                ],
              ),
              AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                centerTitle: true,
                title: Text(appBarTitle, style: myTheme.textTheme?.bodyMedium),
                toolbarHeight: constraints.maxHeight * 0.05,
                elevation: 20,
                flexibleSpace: Container(
                  height: kToolbarHeight + MediaQuery.of(context).padding.top,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0.0, 1.0],
                      colors: [
                        myTheme.primaryColor ?? Colors.transparent, // modrá zleva
                        Colors.white.withOpacity(0.0),
                        // tmavší modrá zprava
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(color: Colors.white54, indent: 0, endIndent: 0, thickness: 1, height: 0),
            ],
            Row(
              children: [
                SizedBox(
                  // PŮVODNĚ: height: constraints.maxHeight * 0.65,
                  // Když showLopa==false, chceme plnou výšku:
                  height: showLopa ? constraints.maxHeight * 0.65 : constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: showSideMenu
                      ? Selector<CurrentStateProvider, int>(
                          selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(menuTrackingObjectId),
                          builder: (context, state, child) {
                            print(appBarTitle + " - Current State: $state");

                            List<SideNavigationBarItem> dynamicItems = menuItems.map((item) {
                              String label = item.title;

                              return SideNavigationBarItem(
                                // padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                icon: item.icon,
                                imageStates: item.imageStates,
                                isVisible: item.isVisible,
                                holdTimeDuration: item.holdTimeDuration,
                                label: label,
                                flash: item.id == 'mi_FoodOrder',
                                chipColor: myTheme.highlightColor,
                                backgroundImage: item.backgroundImage,

                                height: 87,
                                textAlign: TextAlign.right,
                                inactiveOpacity: 0.8, // 60% průhlednost
                                grayscaleWhenInactive: true,
                                activeTextColor: Color.fromARGB(255, 255, 211, 164),
                                // Overlay pouze pod textem - gradient zdola nahoru
                                // overlay: item.backgroundImage != null
                                //     ? LinearGradient(
                                //         begin: Alignment.centerLeft,
                                //         end: Alignment.bottomRight,
                                //         colors: [
                                //           Colors.transparent, // Průhledné nahoře
                                //           Colors.black.withOpacity(0.7), // Tmavé dole (pro text)
                                //         ],
                                //         stops: [0.2, 0.7], // Gradient začíná až v polovině
                                //       )
                                //     : null,
                                showIcon: false,
                                showPictogram: false,
                                // imageOverlay: LinearGradient(
                                //   begin: Alignment.topCenter,
                                //   end: Alignment.bottomCenter,
                                //   colors: [
                                //     Colors.transparent, // Průhledné nahoře
                                //     Colors.black.withOpacity(0.8), // Tmavé dole (pro text)
                                //   ],
                                //   stops: [0.0, 0.8], // Gra // Gradient začíná až v polovině
                                // ),
                                inactiveTextOverlay: item.backgroundImage != null
                                    ? LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.transparent, // Průhledné nahoře
                                          Colors.black.withOpacity(0.7), // Tmavé dole (pro text)
                                        ],
                                        stops: [0.2, 0.7], // Gradient začíná až v polovině
                                      )
                                    : null,
                                activeTextOverlay: item.backgroundImage != null
                                    ? LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.transparent, // Průhledné nahoře
                                          Colors.black.withOpacity(0.7), // Tmavé dole (pro text)
                                        ],
                                        stops: [0.2, 0.7], // Gradient začíná až v polovině
                                      )
                                    : null,
                                // activeImageOverlay: LinearGradient(
                                //   begin: Alignment.centerLeft,
                                //   end: Alignment.centerRight,
                                //   colors: [
                                //     Colors.transparent, // Průhledné nahoře
                                //     Colors.black.withOpacity(0.8), // Tmavé dole (pro text)
                                //   ],
                                //   stops: [0.0, 0.8], // Gra // Gradient začíná až v polovině
                                // ),
                                inactiveOverlay: item.backgroundImage != null
                                    ? LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.transparent, // Průhledné nahoře
                                          Colors.black.withOpacity(0.7), // Tmavé dole (pro text)
                                        ],
                                        stops: [0.0, 1.0], // Gradient začíná až v polovině
                                      )
                                    : null,
                              );
                            }).toList();

                            return Row(
                              children: [
                                SideNavigationBar(
                                  key: UniqueKey(),
                                  footerItems: showGlobalMenuBtn
                                      ? globaleMenuFooterItems.map((item) {
                                          String label = item.title;

                                          print('item backgroundImage: ${item.backgroundImage}');

                                          return SideNavigationBarItem(
                                            route: item.route,
                                            imageStates: item.imageStates,
                                            // padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                            icon: item.icon,
                                            label: label,
                                            backgroundImage: item.backgroundImage,
                                            height: 80,
                                            textAlign: TextAlign.right,
                                            inactiveOpacity: 1.0, // 60% průhlednost
                                            grayscaleWhenInactive: false,
                                            activeTextColor: Color.fromARGB(255, 255, 211, 164),
                                            // Overlay pouze pod textem - gradient zdola nahoru
                                            inactiveTextOverlay: item.backgroundImage != null
                                                ? LinearGradient(
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Colors.transparent, // Průhledné nahoře
                                                      Colors.black.withOpacity(0.7), // Tmavé dole (pro text)
                                                    ],
                                                    stops: [0.2, 0.7], // Gradient začíná až v polovině
                                                  )
                                                : null,
                                            showIcon: false,
                                            showPictogram: false,
                                            inactiveOverlay: item.backgroundImage != null
                                                ? LinearGradient(
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Colors.transparent, // Průhledné nahoře
                                                      Colors.black.withOpacity(0.7), // Tmavé dole (pro text)
                                                    ],
                                                    stops: [0.2, 0.7], // Gradient začíná až v polovině
                                                  )
                                                : null,
                                          );
                                        }).toList()
                                      : [],
                                  minWidth: 100,
                                  maxWidth: 280,
                                  theme: SideNavigationBarTheme(
                                    // padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 1.0),
                                    backgroundColor: Colors.black45,
                                    togglerTheme: SideNavigationBarTogglerTheme.standard(),
                                    dividerTheme: const SideNavigationBarDividerTheme(
                                      showHeaderDivider: true,
                                      headerDividerColor: Colors.white54,
                                      headerDividerThickness: 1,
                                      showMainDivider: false,
                                      mainDividerColor: Colors.white54,
                                      mainDividerThickness: 1.0,
                                      showFooterDivider: true,
                                      footerDividerColor: Colors.white54,
                                      footerDividerThickness: null,
                                    ),
                                    itemTheme: SideNavigationBarItemTheme(
                                      iconSize: 45,
                                      labelTextStyle: const TextStyle(fontSize: 26),
                                      selectedBackgroundColor: myTheme.primaryColor,
                                      selectedItemColor: myTheme.highlightColor,
                                      unselectedBackgroundColor: Colors.black.withOpacity(0.0),
                                      imageMaxHeight: 70,
                                      imageMaxWidth: 70,
                                      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
                                    ),
                                  ),
                                  selectedIndex: state,
                                  expandable: false,
                                  initiallyExpanded: true,
                                  items: dynamicItems,
                                  onTap: (index) => onExpanCollapseTapAction(index),
                                ),
                                Expanded(
                                  child: views.elementAt(state),
                                )
                              ],
                            );
                          },
                        )
                      : SizedBox.expand(
                          child: views.isNotEmpty ? views.first : const SizedBox.shrink(),
                        ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}
