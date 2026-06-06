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
import '../widgets/cfg_image.dart';
import '../widgets/gallery_widget.dart';
import '../widgets/generic_selection_widget.dart';
import '../widgets/joystick_widget.dart';

class EntertainmentDiningAftLh extends StatefulWidget {
  const EntertainmentDiningAftLh({super.key, title});

  @override
  State<EntertainmentDiningAftLh> createState() => _EntertainmentDiningAftLhState();
}

class _EntertainmentDiningAftLhState extends State<EntertainmentDiningAftLh> with TickerProviderStateMixin {
  String title = '';
  final Map<String, bool> _cardPressedStates = {};

  // State management
  String? selectedLightGroup = 'ceiling'; // Vybraná skupina světel (radio button)
  bool isSideMenuOpen = false;

  // tab visibility
  bool _isTabVisible = true;
  bool _isFirstBuild = true;

  bool isNavigationMode = true;

  // tracking selected source for menu width adjustment
  String? selectedSource;

  // funkce pro získání šířky menu na základě vybraného zdroje
  double getMenuWidth() {
    switch (selectedSource) {
      case 'dining_Camera6Aft':
        return 0.4; // 30% pro kamery (málo tlačítek)
      case 'dining_MapAft':
        return 0.7; // 90% pro MAP (hodně tlačítek  )
      default:
        return 0.12; // 20% výchozí
    }
  }

  bool get hasControls {
    return true;
    // if (selectedSource == null) return false;
    // return selectedSource == 'diningEntertainmentMap' || selectedSource!.contains('Camera6');
  }

  void _checkActiveSource() {
    final currentStateProvider = Provider.of<CurrentStateProvider>(context, listen: false);

    // Seznam všech zdrojů
    final sources = [
      'dining_MapAft',
      'dining_Camera1Aft',
      'dining_Camera2Aft',
      'dining_Camera3Aft',
      'dining_Camera4Aft',
      'dining_Camera5Aft',
      'dining_Camera6Aft',
      'dining_HDMILoungeAft',
      'dining_HDMIGlobalAft',
      'dining_HDMIAVODAft',
    ];

    // Najdi aktivní zdroj (state == 1)
    for (String sourceId in sources) {
      if (currentStateProvider.getCurrentState(sourceId) == 1) {
        setState(() {
          selectedSource = sourceId;
          isSideMenuOpen = false;
        });
        break;
      }
    }
  }

  String getTabText() {
    if (selectedSource == null) return 'CONTROLS';

    if (selectedSource == 'dining_MapAft') {
      return 'MAP CONTROLS';
    }

    if (selectedSource!.contains('Camera6')) {
      return 'CAMERA CONTROLS';
    }

    return 'MONITOR';
  }

  // Pro sledování velikosti obrázku
  final GlobalKey _imageKey = GlobalKey();
  Size? _imageSize;

  @override
  bool get wantKeepAlive => true; // ⭐ PŘIDEJ

  @override
  void initState() {
    super.initState();
    isSideMenuOpen = false; // ⭐ EXPLICITNĚ zavři menu při inicializaci
    selectedSource = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getImageSize();
      // _checkActiveSource();
      if (mounted) {
        setState(() {
          _isFirstBuild = false;
        });
      }
    });
    selectedSource = null;
  }

  @override
  void didUpdateWidget(EntertainmentDiningAftLh oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Zavři menu pokaždé když se widget znovu aktivuje
    if (mounted && isSideMenuOpen) {
      setState(() {
        isSideMenuOpen = false;
      });
    }
  }

  void _getImageSize() {
    final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _imageSize = renderBox.size;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();
    // super.build(context);

    return ActivityDetector(
      child: Stack(
        children: [
          // Hlavní obsah
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // 1. Hlavní oblast s obrázkem (nahoře)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Levá strana - obrázek s radio tlačítky (skupiny světel)
                      // _buildInteractiveImage(myTheme),

                      // SizedBox(width: 10),

                      // Pravá strana - ovládání vybrané skupiny
                      Expanded(
                        flex: 1,
                        child: _buildGroupControls(
                          myTheme,
                        ),
                      ),
                      // if (selectedLightGroup != null)
                      //   Expanded(
                      //     flex: 2,
                      //     child: _buildGroupControls(
                      //       myTheme,
                      //     ),
                      //   ),
                    ],
                  ),
                ),

                SizedBox(height: 10), // ⭐ Mezera mezi obsahem a controls

                // 2. Globální tlačítka DOLE ⭐⭐⭐
                // _buildGlobalControls(myTheme),
              ],
            ),
          ),

          // ⭐ Overlay když je menu otevřené
          if (isSideMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isSideMenuOpen = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.1), // Tmavý overlay
                ),
              ),
            ),

          // 3. Vysouvací side menu zprava (70% šířky)
          _buildSideMenu(myTheme),
        ],
      ),
    );
  }

  // 1. GLOBÁLNÍ OVLÁDÁNÍ nahoře

  // 3. OVLÁDACÍ PANEL vpravo pro vybranou skupinu
  Widget _buildGroupControls(CustomTheme myTheme) {
    List<dynamic> menuItemsVideo = configItems['dining_video_aft'] as List<dynamic>;
    List<dynamic> menuItemsAudio = configItems['dining_audio'] as List<dynamic>;

    GenericSelection globalEntertainmentMonitorPwr = menuItemsVideo.firstWhere((element) => element.id == 'dining_MonitorPwrAft') as GenericSelection;
    GenericSelection globalEntertainmentSpeakerPwr = menuItemsAudio.firstWhere((element) => element.id == 'dining_SpeakerPwr') as GenericSelection;

    GenericSelection globalEntertainmentMap = menuItemsVideo.firstWhere((element) => element.id == 'dining_MapAft') as GenericSelection;
    GenericSelection globalEntertainmentHDMILounge = menuItemsVideo.firstWhere((element) => element.id == 'dining_HDMILoungeAft') as GenericSelection;
    GenericSelection globalEntertainmentHDMIGlobal = menuItemsVideo.firstWhere((element) => element.id == 'dining_HDMIGlobalAft') as GenericSelection;
    GenericSelection globalEntertainmentHDMIAVOD = menuItemsVideo.firstWhere((element) => element.id == 'dining_HDMIAVODAft') as GenericSelection;
    GenericSelection globalEntertainmentCamera1 = menuItemsVideo.firstWhere((element) => element.id == 'dining_Camera1Aft') as GenericSelection;
    GenericSelection globalEntertainmentCamera2 = menuItemsVideo.firstWhere((element) => element.id == 'dining_Camera2Aft') as GenericSelection;
    GenericSelection globalEntertainmentCamera3 = menuItemsVideo.firstWhere((element) => element.id == 'dining_Camera3Aft') as GenericSelection;
    GenericSelection globalEntertainmentCamera4 = menuItemsVideo.firstWhere((element) => element.id == 'dining_Camera4Aft') as GenericSelection;
    GenericSelection globalEntertainmentCamera5 = menuItemsVideo.firstWhere((element) => element.id == 'dining_Camera5Aft') as GenericSelection;
    GenericSelection globalEntertainmentCamera6 = menuItemsVideo.firstWhere((element) => element.id == 'dining_Camera6Aft') as GenericSelection;

    BargraphModel globalVolume = menuItemsAudio.firstWhere((element) => element.id == 'dining_volume') as BargraphModel;
    BargraphModel globalBass = menuItemsAudio.firstWhere((element) => element.id == 'dining_bass') as BargraphModel;
    BargraphModel globalTreble = menuItemsAudio.firstWhere((element) => element.id == 'dining_treble') as BargraphModel;

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...[globalEntertainmentMonitorPwr, globalEntertainmentSpeakerPwr].map(
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
                                  // side: globalEntertainmentMonitorPwrOff == item
                                  //     ? GenericSelelectionWidgetButtonSide.left
                                  //     : globalEntertainmentMonitorPwrOn == item
                                  //         ? GenericSelelectionWidgetButtonSide.right
                                  //         : GenericSelelectionWidgetButtonSide.middle,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: [
                        ...[
                          globalEntertainmentMap,
                          globalEntertainmentCamera1,
                          globalEntertainmentCamera2,
                          globalEntertainmentCamera3,
                          globalEntertainmentCamera4,
                          globalEntertainmentCamera5,
                          globalEntertainmentCamera6,
                          globalEntertainmentHDMILounge,
                          globalEntertainmentHDMIGlobal,
                          globalEntertainmentHDMIAVOD
                        ].map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
                            child: Selector<CurrentStateProvider, int>(
                              selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(item.id.toString()),
                              builder: (context, currStateValue, child) {
                                // ⭐ NOVÁ LOGIKA SE SCHOVÁVACÍM TABEM
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (currStateValue == 1 && selectedSource != item.id) {
                                    // KROK 1: Schovat tab
                                    setState(() {
                                      _isTabVisible = false;
                                      isSideMenuOpen = false;
                                    });

                                    // KROK 2: Po 100ms změnit zdroj (tab je schovaný, nikdo nic nevidí)
                                    Future.delayed(Duration(milliseconds: 100), () {
                                      if (mounted) {
                                        setState(() {
                                          selectedSource = item.id;
                                        });

                                        // KROK 3: Po dalších 50ms ukázat tab (vše je už správně nastavené)
                                        Future.delayed(Duration(milliseconds: 50), () {
                                          if (mounted) {
                                            setState(() {
                                              _isTabVisible = true;
                                            });
                                          }
                                        });
                                      }
                                    });
                                  }
                                });

                                return GenericSelectionWidget(
                                  id: item.id,
                                  title: item.title,
                                  icons: item.icons,
                                  iconSize: item.iconSize,
                                  isMomentary: item.isMomentary,
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
              Flexible(
                flex: 4,
                child: Transform.rotate(
                  angle: -90 * 3.1415926535 / 180,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          buildBargraph(
                            item: globalVolume,
                            titleStyle: myTheme.textTheme?.labelMedium,
                            title: makeTextVertical(globalVolume.title ?? ''),
                            titleRotationQuarterTurns: 1,
                            type: BargraphType.volume,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          buildBargraph(
                            item: globalBass,
                            title: makeTextVertical(globalBass.title ?? ''),
                            titleRotationQuarterTurns: 1,
                            titleStyle: myTheme.textTheme?.labelMedium,
                            type: BargraphType.volume,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          buildBargraph(
                            item: globalTreble,
                            title: makeTextVertical(globalTreble.title ?? ''),
                            titleRotationQuarterTurns: 1,
                            titleStyle: myTheme.textTheme?.labelMedium,
                            type: BargraphType.volume,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15.0),
        ],
      ),
    );
  }

  // ⭐ UPRAVENÝ _buildSideMenu - zobrazí se pouze pokud _isTabVisible == true
  Widget _buildSideMenu(CustomTheme myTheme) {
    // Pokud vybraný zdroj nemá controls NEBO je tab schovaný, nezobrazuj
    if (!hasControls || !_isTabVisible) {
      return SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final menuWidth = screenWidth * getMenuWidth();

    return AnimatedPositioned(
      duration: _isFirstBuild ? Duration(milliseconds: 0) : Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      right: isSideMenuOpen ? 0 : -menuWidth,
      top: 0,
      bottom: 0,
      child: Row(
        children: [
          // Tab ouško
          GestureDetector(
            onTap: () {
              setState(() {
                isSideMenuOpen = !isSideMenuOpen;
              });
            },
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: Offset(-3, 0),
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
                    SizedBox(height: 10),
                    RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        getTabText(),
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

          // Side menu content
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
                  offset: Offset(-10, 0),
                ),
              ],
            ),
            child: _buildSideMenuContent(myTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenuContent(CustomTheme myTheme) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(10),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMenuTitle(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    setState(() {
                      isSideMenuOpen = false;
                    });
                  },
                ),
              ],
            ),
          ),

          // Dynamický obsah
          Expanded(
            child: _buildDynamicContent(myTheme),
          ),
        ],
      ),
    );
  }

  String _getMenuTitle() {
    switch (selectedSource) {
      case 'dining_MapAft':
        return 'MAP CONTROLS';
      case 'dining_Camera6Aft':
        return 'DOWN CAMERA CONTROLS';
      default:
        return 'CONTROLS';
    }
  }

  Widget _buildDynamicContent(CustomTheme myTheme) {
    // Camera 6 ovládání
    if (selectedSource == 'dining_Camera6Aft') {
      return _buildCameraControls(myTheme);
    }

    // MAP ovládání
    if (selectedSource == 'dining_MapAft') {
      return _buildMapControls(myTheme);
    }

    return _buildMonitorBrightnessControl(myTheme);

    // return Center(
    //   child: Text(
    //     'No controls available',
    //     style: TextStyle(color: Colors.white70, fontSize: 18),
    //   ),
    // );
  }

  Widget _buildMonitorBrightnessControl(CustomTheme myTheme) {
    List<dynamic> menuItems = configItems['dining_video_aft'] as List<dynamic>;
    BargraphModel monitorBrightness = menuItems.firstWhere(
      (element) => element.id == 'dining_brightnessAft', // ⭐ ID z config
    ) as BargraphModel;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 800),
      child: Center(
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
      ),
    );
  }

  Widget _buildCameraControls(CustomTheme myTheme) {
    // Načteme položky z 'common' menu
    List<dynamic> menuItems = configItems['common'] as List<dynamic>;

    GenericSelection cameraImage = menuItems.firstWhere((element) => element.id == 'cameraImage') as GenericSelection;
    GenericSelection zoomIn = menuItems.firstWhere((element) => element.id == 'zoomIn') as GenericSelection;
    GenericSelection zoomOut = menuItems.firstWhere((element) => element.id == 'zoomOut') as GenericSelection;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Obrázek kamery

          // SizedBox(height: 30),

          // Tlačítka Zoom In a Zoom Out vedle sebe
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Zoom Out
              Selector<CurrentStateProvider, int>(
                selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(zoomOut.id.toString()),
                builder: (context, currStateValue, child) {
                  return GenericSelectionWidget(
                    id: zoomOut.id,
                    title: zoomOut.title,
                    icons: zoomOut.icons,
                    iconSize: zoomOut.iconSize,
                    isMomentary: zoomOut.isMomentary,
                    onStateCallBack: () {
                      print('Zoom Out on $selectedSource');
                    },
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

              SizedBox(width: 50),
              Selector<CurrentStateProvider, int>(
                selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(cameraImage.id.toString()),
                builder: (context, currStateValue, child) {
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
              SizedBox(width: 50),

              // Zoom In
              Selector<CurrentStateProvider, int>(
                selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(zoomIn.id.toString()),
                builder: (context, currStateValue, child) {
                  return GenericSelectionWidget(
                    id: zoomIn.id,
                    title: zoomIn.title,
                    icons: zoomIn.icons,
                    iconSize: zoomIn.iconSize,
                    isMomentary: zoomIn.isMomentary,
                    onStateCallBack: () {
                      print('Zoom In on $selectedSource');
                    },
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

  Widget _buildSceneCard({
    required GenericSelection button,
    required CustomTheme myTheme,
  }) {
    // Inicializujeme state pro tuto kartu
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
            print('Scene ${button.title} tapped');
            // TODO: Zde aktualizujte CurrentStateProvider
          },
          onTapCancel: () {
            _cardPressedStates[button.id] = false;
            (context as Element).markNeedsBuild();
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: isHighlighted ? myTheme.highlightColor?.withOpacity(0.5) ?? Colors.blue.withOpacity(0.5) : Colors.black.withOpacity(0.3),
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
                  // Background image
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
                            //     child: Icon(Icons.image_not_supported, color: Colors.white54, size: 40),
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

                  // Grayscale + dark overlay když NENÍ highlighted
                  if (!isHighlighted)
                    Positioned.fill(
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(<double>[
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
                              stops: [0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Gradient pod textem (vždy)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                        style: TextStyle(
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

                  // Check badge když je aktivní
                  if (isActive)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: EdgeInsets.all(8),
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
                        child: Icon(Icons.check, color: Colors.white, size: 20),
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

  Widget _buildMapControls(CustomTheme myTheme) {
    // Načteme položky z 'common' menu
    List<dynamic> menuItems = configItems['common'] as List<dynamic>;

    // Horní tlačítka
    GenericSelection mapAuto = menuItems.firstWhere((element) => element.id == 'mapAuto') as GenericSelection;
    GenericSelection mapInfo = menuItems.firstWhere((element) => element.id == 'mapInfo') as GenericSelection;
    GenericSelection mapLogo = menuItems.firstWhere((element) => element.id == 'mapLogo') as GenericSelection;
    GenericSelection mapSetup = menuItems.firstWhere((element) => element.id == 'mapSetup') as GenericSelection;

    // Zoom controls
    GenericSelection zoomIn = menuItems.firstWhere((element) => element.id == 'mapZoomIn') as GenericSelection;
    GenericSelection zoomOut = menuItems.firstWhere((element) => element.id == 'mapZoomOut') as GenericSelection;
    GenericSelection mapFindAC = menuItems.firstWhere((element) => element.id == 'mapFindAC') as GenericSelection;

    // Zoom presets
    GenericSelection mapZoom1 = menuItems.firstWhere((element) => element.id == 'mapZoom1') as GenericSelection;
    GenericSelection mapZoom2 = menuItems.firstWhere((element) => element.id == 'mapZoom2') as GenericSelection;
    GenericSelection mapZoom3 = menuItems.firstWhere((element) => element.id == 'mapZoom3') as GenericSelection;
    GenericSelection mapZoom4 = menuItems.firstWhere((element) => element.id == 'mapZoom4') as GenericSelection;
    GenericSelection mapZoom5 = menuItems.firstWhere((element) => element.id == 'mapZoom5') as GenericSelection;

    // Map Views
    List<GenericSelection> mapViews = [
      menuItems.firstWhere((element) => element.id == 'mapViewSurround') as GenericSelection,
      menuItems.firstWhere((element) => element.id == 'mapViewOverWorld') as GenericSelection,
      menuItems.firstWhere((element) => element.id == 'mapViewACSide') as GenericSelection,
      menuItems.firstWhere((element) => element.id == 'mapViewACTop') as GenericSelection,
      menuItems.firstWhere((element) => element.id == 'mapViewCockpit') as GenericSelection,
      menuItems.firstWhere((element) => element.id == 'mapViewLeftWindow') as GenericSelection,
      menuItems.firstWhere((element) => element.id == 'mapViewRightWindow') as GenericSelection,
      menuItems.firstWhere((element) => element.id == 'mapViewDeparture') as GenericSelection,
      menuItems.firstWhere((element) => element.id == 'mapViewRLI') as GenericSelection,
      menuItems.firstWhere((element) => element.id == 'mapViewPOI') as GenericSelection,
      menuItems.firstWhere((element) => element.id == 'mapViewPrayerRoom') as GenericSelection,
      menuItems.firstWhere((element) => element.id == 'mapViewNight') as GenericSelection,
    ];

    GenericSelection mapJoystick = menuItems.firstWhere((element) => element.id == 'mapJoystick') as GenericSelection;

    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============ LEVÁ STRANA - MAP VIEWS (karty 4x3) ============
          Expanded(
            flex: 6,
            child: _buildMapViewsGrid(mapViews, myTheme),
          ),

          SizedBox(width: 15),

          // ============ AUTO, INFO, LOGO, SETUP (pod sebou) ============
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMapButton(mapAuto, myTheme),
              SizedBox(height: 10),
              _buildMapButton(mapInfo, myTheme),
              SizedBox(height: 10),
              _buildMapButton(mapLogo, myTheme),
              SizedBox(height: 10),
              _buildMapButton(mapSetup, myTheme),
            ],
          ),

          // SizedBox(width: 15),

          // // ============ ZOOM PRESETS (5 tlačítek pod sebou) ============
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     _buildZoomPresets([mapZoom1, mapZoom2, mapZoom3, mapZoom4, mapZoom5], myTheme),
          //   ],
          // ),

          SizedBox(width: 15),

          // ============ JOYSTICK + CONTROLS ============
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // --- Radio tlačítko Navigation/Setup ---
              // _buildNavigationSetupToggle(myTheme),

              SizedBox(height: 15),

              // --- Joystick ---
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

              SizedBox(height: 15),

              // --- Zoom controls (Zoom Out, Find AC, Zoom In) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMapButton(zoomOut, myTheme),
                  SizedBox(width: 10),
                  _buildMapButton(mapFindAC, myTheme),
                  SizedBox(width: 10),
                  _buildMapButton(zoomIn, myTheme),
                ],
              ),
              SizedBox(height: 10),
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

// ============ HELPER METODY ============

// Grid pro Map Views (4x3 karty) - upravený spacing
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

// Zoom presets - 5 tlačítek pod sebou
  List<Widget> _buildZoomPresets(List<GenericSelection> zoomPresets, CustomTheme myTheme) {
    return zoomPresets.map((preset) {
      return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: _buildMapButton(preset, myTheme),
      );
    }).toList();
  }

// Generické tlačítko pro MAP controls
  Widget _buildMapButton(GenericSelection item, CustomTheme myTheme) {
    return Selector<CurrentStateProvider, int>(
      selector: (context, currentStateNotifier) => currentStateNotifier.getCurrentState(item.id.toString()),
      builder: (context, currStateValue, child) {
        return GenericSelectionWidget(
          id: item.id,
          title: item.title,
          icons: item.icons,
          iconSize: item.iconSize,
          isMomentary: item.isMomentary,
          onStateCallBack: () {
            print('${item.title} pressed');
          },
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

// Radio tlačítko pro Navigation/Setup
  Widget _buildNavigationSetupToggle(CustomTheme myTheme) {
    return StatefulBuilder(
      builder: (context, setState) {
        // Použij state proměnnou z hlavní třídy pokud potřebuješ persistenci
        bool isNavigation = isNavigationMode;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Navigation
              GestureDetector(
                onTap: () {
                  this.setState(() {
                    isNavigationMode = true;
                  });
                  setState(() {
                    isNavigation = true;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isNavigation ? myTheme.highlightColor?.withOpacity(0.7) ?? Colors.blue.withOpacity(0.7) : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                  child: Text(
                    'NAVIGATION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: isNavigation ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),

              Container(
                width: 2,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),

              // Setup
              GestureDetector(
                onTap: () {
                  this.setState(() {
                    isNavigationMode = false;
                  });
                  setState(() {
                    isNavigation = false;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: !isNavigation ? myTheme.highlightColor?.withOpacity(0.7) ?? Colors.blue.withOpacity(0.7) : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                  child: Text(
                    'SETUP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: !isNavigation ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
