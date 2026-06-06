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

class EntertainmentGlobalContentScreen extends StatefulWidget {
  const EntertainmentGlobalContentScreen({super.key});

  @override
  State<EntertainmentGlobalContentScreen> createState() => _EntertainmentGlobalContentScreenState();
}

class _EntertainmentGlobalContentScreenState extends State<EntertainmentGlobalContentScreen> with AutomaticKeepAliveClientMixin {
  // ============================================================
  // 3 independent side menus (only one can be open)
  // ============================================================
  static const String _panelMonitor = 'monitor';
  static const String _panelMap = 'map';
  static const String _panelCamera6 = 'camera6';
  static const bool _disableSideMenuAnimation = true;

  String? _openPanel; // null = closed

  // ============================================================
  // Side menu layout knobs
  // ============================================================
  static const double _menuTop = 90; // where the whole menu block starts
  static const double _menuHeightFactor = 0.82; // height as % of screen height

  static const double _tabWidth = 40;
  static const double _tabHeight = 350;
  static const double _tabGap = 10;
  static const double _tabsTopOffset = 10; // start tabs a bit lower inside menu block

  static const double _panelCorner = 10;

  // keep-alive
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _openPanel = null; // default closed
  }

  double _panelWidthFactor(String id) {
    switch (id) {
      case _panelMap:
        return 0.80;
      case _panelCamera6:
        return 0.35;
      case _panelMonitor:
      default:
        return 0.15;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    return ActivityDetector(
      child: Stack(
        children: [
          // ============================================================
          // Main content
          // ============================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 65, 10, 10),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildGroupControls(myTheme),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // ============================================================
          // overlay (tap closes any open panel)
          // ============================================================
          if (_openPanel != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _openPanel = null),
                child: Container(color: Colors.black.withOpacity(0.1)),
              ),
            ),

          // ============================================================
          // 3 independent side menus (tabs always visible)
          // ============================================================
          _buildAllSideMenus(myTheme),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN PANEL (monitor power + sources + EQ)
  // ============================================================
  Widget _buildGroupControls(CustomTheme myTheme) {
    final menuItems = (configItems['global-entertainment'] as List<dynamic>);

    GenericSelection _gs(String id) => menuItems.firstWhere((e) => e.id == id) as GenericSelection;
    BargraphModel _bg(String id) => menuItems.firstWhere((e) => e.id == id) as BargraphModel;

    final globalEntertainmentMonitorPwrOff = _gs('globalEntertainmentMonitorPwrOff');
    final globalEntertainmentMonitorPwrOn = _gs('globalEntertainmentMonitorPwrOn');
    final globalEntertainmentSpeakerPwrOff = _gs('globalEntertainmentSpeakerPwrOff');
    final globalEntertainmentSpeakerPwrOn = _gs('globalEntertainmentSpeakerPwrOn');

    final sources = <GenericSelection>[
      _gs('globalEntertainmentMap'),
      _gs('globalEntertainmentCamera1'),
      _gs('globalEntertainmentCamera2'),
      _gs('globalEntertainmentCamera3'),
      _gs('globalEntertainmentCamera4'),
      _gs('globalEntertainmentCamera5'),
      _gs('globalEntertainmentCamera6'),
      // _gs('globalEntertainmentHDMILounge'),
      _gs('globalEntertainmentHDMIGlobal'),
      _gs('globalEntertainmentHDMIAVOD'),
    ];

    final globalVolume = _bg('globalVolume');
    final globalBass = _bg('globalBass');
    final globalTreble = _bg('globalTreble');

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              children: [
                // ===== left side (power + sources) =====
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // monitor & speaker power
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...[globalEntertainmentMonitorPwrOff, globalEntertainmentMonitorPwrOn].map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Selector<CurrentStateProvider, int>(
                                selector: (context, p) => p.getCurrentState(item.id.toString()),
                                builder: (context, curr, _) {
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
                          const SizedBox(width: 50),
                          ...[globalEntertainmentSpeakerPwrOff, globalEntertainmentSpeakerPwrOn].map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Selector<CurrentStateProvider, int>(
                                selector: (context, p) => p.getCurrentState(item.id.toString()),
                                builder: (context, curr, _) {
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
                                    side: globalEntertainmentSpeakerPwrOff == item
                                        ? GenericSelelectionWidgetButtonSide.left
                                        : globalEntertainmentSpeakerPwrOn == item
                                            ? GenericSelelectionWidgetButtonSide.right
                                            : GenericSelelectionWidgetButtonSide.middle,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 100),

                      // sources
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: sources.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Selector<CurrentStateProvider, int>(
                              selector: (context, p) => p.getCurrentState(item.id.toString()),
                              builder: (context, curr, _) {
                                return GenericSelectionWidget(
                                  id: item.id,
                                  title: item.title,
                                  icons: item.icons,
                                  iconSize: item.iconSize,
                                  isMomentary: true,
                                  onStateCallBack: () {},
                                  offStateCallBack: () {},
                                  states: item.states,
                                  height: item.height,
                                  width: item.width,
                                  textIconSpacing: 10,
                                  textStyle: myTheme.textTheme?.labelMedium,
                                  removeBtnBackgroundStyling: true,
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // ===== right side (EQ bargraphs rotated) =====
                Expanded(
                  flex: 4,
                  child: Transform.rotate(
                    angle: -90 * 3.1415926535 / 180,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildBargraph(
                          item: globalVolume,
                          titleStyle: myTheme.textTheme?.labelMedium,
                          title: makeTextVertical(globalVolume.title ?? ''),
                          titleRotationQuarterTurns: 1,
                          type: BargraphType.volume,
                        ),
                        buildBargraph(
                          item: globalBass,
                          title: makeTextVertical(globalBass.title ?? ''),
                          titleRotationQuarterTurns: 1,
                          titleStyle: myTheme.textTheme?.labelMedium,
                          type: BargraphType.volume,
                        ),
                        buildBargraph(
                          item: globalTreble,
                          title: makeTextVertical(globalTreble.title ?? ''),
                          titleRotationQuarterTurns: 1,
                          titleStyle: myTheme.textTheme?.labelMedium,
                          type: BargraphType.volume,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MULTI SIDE MENUS (3 independent panels)
  // ============================================================
  Widget _buildAllSideMenus(CustomTheme myTheme) {
    final size = MediaQuery.of(context).size;
    final menuHeight = size.height * _menuHeightFactor;
    final top = _menuTop.clamp(0.0, size.height - menuHeight);

    final specs = <_SideMenuSpec>[
      _SideMenuSpec(
        id: _panelMonitor,
        tabText: 'MONITOR',
        tabIcon: Icons.monitor,
        tabTop: _tabsTopOffset + 0 * (_tabHeight + _tabGap),
        widthFactor: _panelWidthFactor(_panelMonitor),
        title: 'MONITOR',
        tabHeight: 200,
        menuTop: 90,
        menuHeightFactor: 0.65,
        contentBuilder: () => _buildMonitorBrightnessControl(myTheme),
      ),
      _SideMenuSpec(
        id: _panelMap,
        tabText: 'MAP CONTROLS',
        tabIcon: Icons.map,
        tabTop: _tabsTopOffset + 1 * (200 + _tabGap),
        widthFactor: _panelWidthFactor(_panelMap),
        tabHeight: 300,
        title: 'MAP CONTROLS',
        menuTop: 90,
        menuHeightFactor: 0.65,
        contentBuilder: () => _buildMapControls(myTheme),
      ),
      _SideMenuSpec(
        id: _panelCamera6,
        tabText: 'CAMERA CONTROLS',
        tabIcon: Icons.videocam,
        tabTop: _tabsTopOffset + 1 * (500 + 2 * _tabGap),
        widthFactor: _panelWidthFactor(_panelCamera6),
        title: 'DOWN CAMERA CONTROLS',
        tabHeight: 300,
        menuTop: 90,
        menuHeightFactor: 0.85,
        contentBuilder: () => _buildCameraControls(myTheme),
      ),
    ];

    return Stack(
      children: [
        for (final spec in specs) ...[
          // NEW: per-menu height + top
          Builder(
            builder: (_) {
              final h = (size.height * spec.menuHeightFactor).clamp(0.0, size.height);
              final t = spec.menuTop.clamp(0.0, size.height - h);

              return _buildSingleSideMenu(
                myTheme: myTheme,
                spec: spec,
                top: t,
                height: h,
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSingleSideMenu({
    required CustomTheme myTheme,
    required _SideMenuSpec spec,
    required double top,
    required double height,
  }) {
    final size = MediaQuery.of(context).size;
    final panelW = size.width * spec.widthFactor;

    final isOpen = _openPanel == spec.id;
    final right = isOpen ? 0.0 : -panelW; // close => only the tab remains visible

    return AnimatedPositioned(
      duration: _disableSideMenuAnimation ? Duration.zero : const Duration(milliseconds: 350),
      curve: _disableSideMenuAnimation ? Curves.linear : Curves.easeInOut,
      top: top,
      right: right,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            _buildFloatingTab(myTheme: myTheme, spec: spec, height: height),
            Container(
              width: panelW,
              height: height,
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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(_panelCorner),
                  bottomLeft: Radius.circular(_panelCorner),
                ),
              ),
              child: _buildPanelContent(myTheme, spec),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingTab({
    required CustomTheme myTheme,
    required _SideMenuSpec spec,
    required double height,
  }) {
    final tabTop = spec.tabTop.clamp(0.0, height - spec.tabHeight);

    return SizedBox(
      width: _tabWidth,
      height: height,
      child: Stack(
        children: [
          Positioned(
            top: tabTop,
            left: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _openPanel = (_openPanel == spec.id) ? null : spec.id;
                });
              },
              child: Container(
                width: _tabWidth,
                height: spec.tabHeight,
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
                    topLeft: Radius.circular(_panelCorner),
                    bottomLeft: Radius.circular(_panelCorner),
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
                        _openPanel == spec.id ? Icons.chevron_right : Icons.chevron_left,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(height: 10),

                      // Ikonka ponechaná, ale teď zakomentovaná:
                      // Icon(spec.tabIcon, color: Colors.white, size: 26),
                      // const SizedBox(height: 8),

                      RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          spec.tabText,
                          style: const TextStyle(
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
          ),
        ],
      ),
    );
  }

  Widget _buildPanelContent(CustomTheme myTheme, _SideMenuSpec spec) {
    return Column(
      children: [
        // header
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
              Text(
                spec.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => setState(() => _openPanel = null),
              ),
            ],
          ),
        ),

        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Align(
                    alignment: Alignment.center, // <- vertikální centrování
                    child: spec.contentBuilder(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SIDE MENU: MONITOR BRIGHTNESS
  // ============================================================
  Widget _buildMonitorBrightnessControl(CustomTheme myTheme) {
    final menuItems = configItems['common'] as List<dynamic>;
    final monitorBrightness = menuItems.firstWhere((e) => e.id == 'monitorBrightness') as BargraphModel;

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

  // ============================================================
  // SIDE MENU: CAMERA CONTROLS
  // ============================================================
  Widget _buildCameraControls(CustomTheme myTheme) {
    final menuItems = configItems['common'] as List<dynamic>;

    final GenericSelection cameraImage = menuItems.firstWhere((e) => e.id == 'cameraImage') as GenericSelection;
    final GenericSelection zoomIn = menuItems.firstWhere((e) => e.id == 'zoomIn') as GenericSelection;
    final GenericSelection zoomOut = menuItems.firstWhere((e) => e.id == 'zoomOut') as GenericSelection;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Selector<CurrentStateProvider, int>(
                selector: (context, p) => p.getCurrentState(zoomOut.id.toString()),
                builder: (context, curr, _) {
                  return GenericSelectionWidget(
                    id: zoomOut.id,
                    title: zoomOut.title,
                    icons: zoomOut.icons,
                    iconSize: zoomOut.iconSize,
                    isMomentary: zoomOut.isMomentary,
                    onStateCallBack: () {},
                    offStateCallBack: () {},
                    height: zoomOut.height,
                    width: zoomOut.width,
                    textIconSpacing: 10,
                    states: zoomOut.states,
                    textStyle: myTheme.textTheme?.labelMedium,
                    removeBtnBackgroundStyling: true,
                  );
                },
              ),
              const SizedBox(width: 50),
              Selector<CurrentStateProvider, int>(
                selector: (context, p) => p.getCurrentState(cameraImage.id.toString()),
                builder: (context, curr, _) {
                  return GenericSelectionWidget(
                    id: cameraImage.id,
                    title: cameraImage.title,
                    icons: cameraImage.icons,
                    iconSize: cameraImage.iconSize,
                    isMomentary: cameraImage.isMomentary,
                    onStateCallBack: () {},
                    offStateCallBack: () {},
                    height: cameraImage.height,
                    width: cameraImage.width,
                    textIconSpacing: 10,
                    states: cameraImage.states,
                    textStyle: myTheme.textTheme?.labelMedium,
                    removeBtnBackgroundStyling: true,
                  );
                },
              ),
              const SizedBox(width: 50),
              Selector<CurrentStateProvider, int>(
                selector: (context, p) => p.getCurrentState(zoomIn.id.toString()),
                builder: (context, curr, _) {
                  return GenericSelectionWidget(
                    id: zoomIn.id,
                    title: zoomIn.title,
                    icons: zoomIn.icons,
                    iconSize: zoomIn.iconSize,
                    isMomentary: zoomIn.isMomentary,
                    onStateCallBack: () {},
                    offStateCallBack: () {},
                    height: zoomIn.height,
                    width: zoomIn.width,
                    textIconSpacing: 10,
                    states: zoomIn.states,
                    textStyle: myTheme.textTheme?.labelMedium,
                    removeBtnBackgroundStyling: true,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIDE MENU: MAP CONTROLS
  // ============================================================
  Widget _buildMapControls(CustomTheme myTheme) {
    final menuItems = configItems['common'] as List<dynamic>;
    GenericSelection _gs(String id) => menuItems.firstWhere((e) => e.id == id) as GenericSelection;

    // Top buttons
    final mapAuto = _gs('mapAuto');
    final mapInfo = _gs('mapInfo');
    final mapLogo = _gs('mapLogo');
    final mapSetup = _gs('mapSetup');

    // Zoom controls
    final zoomIn = _gs('zoomIn');
    final zoomOut = _gs('zoomOut');
    final mapFindAC = _gs('mapFindAC');

    // Zoom presets
    final mapZoom1 = _gs('mapZoom1');
    final mapZoom2 = _gs('mapZoom2');
    final mapZoom3 = _gs('mapZoom3');
    final mapZoom4 = _gs('mapZoom4');
    final mapZoom5 = _gs('mapZoom5');

    // Views
    final mapViews = <GenericSelection>[
      _gs('mapViewSurround'),
      _gs('mapViewOverWorld'),
      _gs('mapViewACSide'),
      _gs('mapViewACTop'),
      _gs('mapViewCockpit'),
      _gs('mapViewLeftWindow'),
      _gs('mapViewRightWindow'),
      _gs('mapViewDeparture'),
      _gs('mapViewRLI'),
      _gs('mapViewPOI'),
      _gs('mapViewPrayerRoom'),
      _gs('mapViewNight'),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============ LEFT: MAP VIEWS ============
          Expanded(
            flex: 6,
            child: _buildMapViewsGrid(mapViews, myTheme),
          ),

          const SizedBox(width: 15),

          // ============ RIGHT: AUTO/INFO/LOGO/SETUP ============
          Column(
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

          // ============ RIGHT: JOYSTICK + ZOOM ============
          Expanded(
            flex: 4,
            child: Column(
              children: [
                _buildJoystick(myTheme),
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
                  children: _buildZoomPresets(
                    [mapZoom1, mapZoom2, mapZoom3, mapZoom4, mapZoom5],
                    myTheme,
                  ),
                ),
              ],
            ),
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
    return zoomPresets.map((preset) => _buildMapButton(preset, myTheme)).toList();
  }

  Widget _buildMapButton(GenericSelection item, CustomTheme myTheme) {
    return Selector<CurrentStateProvider, int>(
      selector: (context, p) => p.getCurrentState(item.id.toString()),
      builder: (context, curr, _) {
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
        );
      },
    );
  }

  Widget _buildJoystick(CustomTheme myTheme) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Joystick(
        mode: JoystickMode.all,
        listener: (details) {
          // TODO: implement map move
        },
        base: JoystickBase(
          decoration: JoystickBaseDecoration(
            color: Colors.white.withOpacity(0.1),
            drawOuterCircle: true,
            boxShadows: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          arrowsDecoration: JoystickArrowsDecoration(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        stick: JoystickStick(
          decoration: JoystickStickDecoration(
            color: myTheme.highlightColor ?? Colors.blue,
            shadowColor: (myTheme.highlightColor ?? Colors.blue).withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MAP VIEW CARD (trimmed)
  // ============================================================
  Widget _buildSceneCard({
    required GenericSelection button,
    required CustomTheme myTheme,
  }) {
    return Selector<CurrentStateProvider, int>(
      selector: (context, p) => p.getCurrentState(button.id.toString()),
      builder: (context, curr, _) {
        final isActive = curr == 1;

        return GestureDetector(
          onTap: () {
            // TODO optional
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Stack(
              children: [
                Positioned.fill(
                  child: (button.backgroundImage != null && button.backgroundImage!.isNotEmpty)
                      ? CfgImage(
                          button.backgroundImage!,
                          fit: BoxFit.cover,
                          // errorBuilder: (context, error, stackTrace) {
                          //   return Container(
                          //     color: Colors.black.withOpacity(0.3),
                          //     child: const Center(
                          //       child: Icon(Icons.image_not_supported, color: Colors.white54, size: 40),
                          //     ),
                          //   );
                          // },
                        )
                      : Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: Icon(
                              button.icons?.isNotEmpty == true ? button.icons!.first : Icons.map,
                              color: Colors.white54,
                              size: 50,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                    child: Text(
                      button.title ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (isActive)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
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
                      child: const Icon(Icons.check, color: Colors.white, size: 18),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// Side menu spec struct
// ============================================================
class _SideMenuSpec {
  final String id;
  final String tabText;
  final IconData tabIcon;
  final double tabTop;
  final double widthFactor;
  final String title;
  final double tabHeight;
  final double menuTop;
  final double menuHeightFactor;

  final Widget Function() contentBuilder;

  _SideMenuSpec({
    required this.id,
    required this.tabText,
    required this.tabIcon,
    required this.tabTop,
    required this.widthFactor,
    required this.title,
    required this.tabHeight,
    required this.contentBuilder,
    required this.menuTop,
    required this.menuHeightFactor,
  });
}
