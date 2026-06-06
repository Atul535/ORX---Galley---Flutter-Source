import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/bargraph_model.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../utils/utils.dart';
import '../widgets/activity_detector.dart';
import '../widgets/bargraph.dart';
import '../widgets/cfg_image.dart';
import '../widgets/gallery_widget.dart';
import '../widgets/generic_selection_widget.dart';
import '../widgets/joystick_widget.dart';

class EntertainmentBusinessClassAll extends StatefulWidget {
  const EntertainmentBusinessClassAll({super.key, title});

  @override
  State<EntertainmentBusinessClassAll> createState() => _EntertainmentBusinessClassAllState();
}

class _EntertainmentBusinessClassAllState extends State<EntertainmentBusinessClassAll> with TickerProviderStateMixin {
  bool isSideMenuOpen = false;

  // Side menu šířka (fixně)
  double getMenuWidth(BuildContext context) => MediaQuery.of(context).size.width * 0.12;

  @override
  Widget build(BuildContext context) {
    final myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    return ActivityDetector(
      child: Stack(
        children: [
          // ===== MAIN CONTENT =====
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // // ÚPLNĚ VLEVO: Monitor ON/OFF
                // _buildMonitorPowerOnly(myTheme),

                // const SizedBox(width: 10),

                // Vedle: MAP controls (vždy viditelné)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: _buildMapControls(myTheme),
                  ),
                ),
              ],
            ),
          ),

          // Overlay při otevřeném menu
          if (isSideMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => isSideMenuOpen = false),
                child: Container(color: Colors.black.withOpacity(0.1)),
              ),
            ),

          // ===== SIDE MENU (jen MONITOR) =====
          _buildSideMenu(myTheme),
        ],
      ),
    );
  }

  // =========================
  // SIDE MENU (MONITOR only)
  // =========================
  Widget _buildSideMenu(CustomTheme myTheme) {
    final menuWidth = getMenuWidth(context);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      right: isSideMenuOpen ? 0 : -menuWidth,
      top: 0,
      bottom: 0,
      child: Row(
        children: [
          // Tab ouško
          GestureDetector(
            onTap: () => setState(() => isSideMenuOpen = !isSideMenuOpen),
            child: Container(
              width: 40,
              height: 350,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    myTheme.pullupTabColor?.withOpacity(0.7) ?? Colors.blue.withOpacity(0.7),
                    myTheme.pullupTabColor?.withOpacity(0.95) ?? Colors.blue.withOpacity(0.95),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(-3, 0),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSideMenuOpen ? Icons.chevron_right : Icons.chevron_left,
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(height: 10),
                    const RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'MONITOR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Container(
            width: menuWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  myTheme.pullupBackgroundColor?.withOpacity(0.95) ?? Colors.blue.withOpacity(0.95),
                  myTheme.pullupBackgroundColor?.withOpacity(0.98) ?? Colors.blue.withOpacity(0.98),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 30,
                  offset: const Offset(-10, 0),
                ),
              ],
            ),
            child: _buildMonitorMenuContent(myTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitorMenuContent(CustomTheme myTheme) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MONITOR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => setState(() => isSideMenuOpen = false),
                ),
              ],
            ),
          ),

          Expanded(
            child: _buildMonitorBrightnessControl(myTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitorBrightnessControl(CustomTheme myTheme) {
    final menuItems = configItems['business_video_all'] as List<dynamic>;
    final BargraphModel monitorBrightness = menuItems.firstWhere((e) => e.id == 'business_brightnessAll') as BargraphModel;

    return Center(
      child: RotatedBox(
        quarterTurns: 3,
        child: Bargraph(
          width: monitorBrightness.width,
          height: monitorBrightness.height,
          id: monitorBrightness.id,
          maxValue: monitorBrightness.maxValue,
          minValue: monitorBrightness.minValue,
          spacing: monitorBrightness.spacing,
          steps: monitorBrightness.steps,
          title: makeTextVertical(monitorBrightness.title ?? ''),
          titleRotationQuarterTurns: 1,
          titlePosition: BargraphTitlePosition.bottom,
          titleStyle: myTheme.textTheme?.labelMedium,
        ),
      ),
    );
  }

  // =========================
  // MAP CONTROLS (beze změn)
  // =========================

  Widget _buildMapControls(CustomTheme myTheme) {
    final menuItems = configItems['common'] as List<dynamic>;

    final mapAuto = menuItems.firstWhere((e) => e.id == 'mapAuto') as GenericSelection;
    final mapInfo = menuItems.firstWhere((e) => e.id == 'mapInfo') as GenericSelection;
    final mapLogo = menuItems.firstWhere((e) => e.id == 'mapLogo') as GenericSelection;
    final mapSetup = menuItems.firstWhere((e) => e.id == 'mapSetup') as GenericSelection;

    final zoomIn = menuItems.firstWhere((e) => e.id == 'zoomIn') as GenericSelection;
    final zoomOut = menuItems.firstWhere((e) => e.id == 'zoomOut') as GenericSelection;
    final mapFindAC = menuItems.firstWhere((e) => e.id == 'mapFindAC') as GenericSelection;

    final mapZoom1 = menuItems.firstWhere((e) => e.id == 'mapZoom1') as GenericSelection;
    final mapZoom2 = menuItems.firstWhere((e) => e.id == 'mapZoom2') as GenericSelection;
    final mapZoom3 = menuItems.firstWhere((e) => e.id == 'mapZoom3') as GenericSelection;
    final mapZoom4 = menuItems.firstWhere((e) => e.id == 'mapZoom4') as GenericSelection;
    final mapZoom5 = menuItems.firstWhere((e) => e.id == 'mapZoom5') as GenericSelection;

    final List<GenericSelection> mapViews = [
      menuItems.firstWhere((e) => e.id == 'mapViewSurround') as GenericSelection,
      menuItems.firstWhere((e) => e.id == 'mapViewOverWorld') as GenericSelection,
      menuItems.firstWhere((e) => e.id == 'mapViewACSide') as GenericSelection,
      menuItems.firstWhere((e) => e.id == 'mapViewACTop') as GenericSelection,
      menuItems.firstWhere((e) => e.id == 'mapViewCockpit') as GenericSelection,
      menuItems.firstWhere((e) => e.id == 'mapViewLeftWindow') as GenericSelection,
      menuItems.firstWhere((e) => e.id == 'mapViewRightWindow') as GenericSelection,
      menuItems.firstWhere((e) => e.id == 'mapViewDeparture') as GenericSelection,
      menuItems.firstWhere((e) => e.id == 'mapViewRLI') as GenericSelection,
      menuItems.firstWhere((e) => e.id == 'mapViewPOI') as GenericSelection,
      menuItems.firstWhere((e) => e.id == 'mapViewPrayerRoom') as GenericSelection,
      menuItems.firstWhere((e) => e.id == 'mapViewNight') as GenericSelection,
    ];

    GenericSelection globalEntertainmentMonitorPwrOff = configItems['business_video_all']?.firstWhere((element) => element.id == 'business_MonitorPwrAllOff') as GenericSelection;
    GenericSelection globalEntertainmentMonitorPwrOn = configItems['business_video_all']?.firstWhere((element) => element.id == 'business_MonitorPwrAllOn') as GenericSelection;

    GenericSelection mapJoystick = menuItems.firstWhere((element) => element.id == 'mapJoystick') as GenericSelection;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...[globalEntertainmentMonitorPwrOn, globalEntertainmentMonitorPwrOff].map(
                (item) => Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
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
                        removeBtnBackgroundStyling: true,
                        side: globalEntertainmentMonitorPwrOff == item
                            ? GenericSelelectionWidgetButtonSide.left
                            : globalEntertainmentMonitorPwrOn == item
                                ? GenericSelelectionWidgetButtonSide.right
                                : GenericSelelectionWidgetButtonSide.middle,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const VerticalDivider(
            color: Colors.white54,
            thickness: 1,
            width: 40,
          ),
          Expanded(flex: 6, child: _buildMapViewsGrid(mapViews, myTheme)),
          const SizedBox(width: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMapButton(mapAuto, myTheme),
              const SizedBox(height: 10),
              _buildMapButton(mapInfo, myTheme),
              const SizedBox(height: 10),
              _buildMapButton(mapLogo, myTheme),
              const SizedBox(height: 10),
              _buildMapButton(mapSetup, myTheme),
            ],
          ),
          const SizedBox(width: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(height: 15),
              JoystickWidget(item: mapJoystick, json: const {
                'size': 200,
                'knob_size': 65,
              }
                  //   'knob_size': 84,
                  //   'dead_zone': 12,
                  //   'slow_max': 55,
                  //   'spring_back': true,
                  //   'show_crosshair': true,
                  //   'show_knob_highlight': true,
                  //   'outer_color': '0xFF313136',
                  //   'knob_color': '0xFF898989',
                  //   'knob_highlight_color': '0x665F5F5F',
                  // },
                  ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMapButton(zoomOut, myTheme),
                  const SizedBox(width: 10),
                  _buildMapButton(mapFindAC, myTheme),
                  const SizedBox(width: 10),
                  _buildMapButton(zoomIn, myTheme),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildZoomPresets([mapZoom1, mapZoom2, mapZoom3, mapZoom4, mapZoom5], myTheme),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapViewsGrid(List<GenericSelection> mapViews, CustomTheme myTheme) {
    return SelectionGridGallery(
      items: mapViews,
      columns: 4,
      spacing: 8.0,
      textAlignment: Alignment.bottomCenter,
      imageOverlayGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.7),
        ],
      ),
    );
  }

  List<Widget> _buildZoomPresets(List<GenericSelection> zoomPresets, CustomTheme myTheme) {
    return zoomPresets
        .map((preset) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildMapButton(preset, myTheme),
            ))
        .toList();
  }

  Widget _buildMapButton(GenericSelection item, CustomTheme myTheme) {
    return Selector<CurrentStateProvider, int>(
      selector: (context, p) => p.getCurrentState(item.id.toString()),
      builder: (context, currStateValue, child) {
        return GenericSelectionWidget(
          id: item.id,
          title: item.title,
          icons: item.icons,
          iconSize: item.iconSize,
          isMomentary: item.isMomentary,
          onStateCallBack: () => print('${item.title} pressed'),
          offStateCallBack: () {},
          height: item.height,
          width: item.width,
          textIconSpacing: 10,
          states: item.states,
          textStyle: myTheme.textTheme?.labelMedium,
          removeBtnBackgroundStyling: true,
        );
      },
    );
  }

  // Scene card (ponecháno – jen jsem ho sem přesunul beze změn)
  Widget _buildSceneCard({
    required GenericSelection button,
    required CustomTheme myTheme,
  }) {
    // Pokud chceš ještě víc zrychlit rebuildy, řekni — tady to teď nechávám jak máš.
    return Selector<CurrentStateProvider, int>(
      selector: (context, provider) => provider.getCurrentState(button.id.toString()),
      builder: (context, currStateValue, child) {
        final isActive = currStateValue == 1;

        return GestureDetector(
          onTap: () => print('Scene ${button.title} tapped'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: (isActive ? (myTheme.highlightColor ?? Colors.blue).withOpacity(0.5) : Colors.black.withOpacity(0.3)),
                  blurRadius: isActive ? 10 : 5,
                  spreadRadius: isActive ? 1 : 0,
                  offset: Offset(0, isActive ? 2 : 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: button.backgroundImage != null && button.backgroundImage!.isNotEmpty
                        ? CfgImage(button.backgroundImage!, fit: BoxFit.cover)
                        : Container(color: Colors.black.withOpacity(0.3)),
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
                            Colors.black.withOpacity(isActive ? 0.7 : 0.85),
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
