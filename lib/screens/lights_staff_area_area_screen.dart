import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/enum_room_type.dart';
import '../model/generic_selection.dart';
import '../model/tab_generic_selection_icon.dart';
import '../model/tab_spec.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/cfg_image.dart';
import '../widgets/gallery_widget.dart';
import '../widgets/generic_selection_widget.dart';
import 'attendant_staff_panel.dart';
import 'lights_lounge_lounge_ceiling_panel.dart';
import 'lights_master_lav_dnwash_panel.dart';
import 'lights_staff_area_accent_panel.dart';
import 'lights_staff_area_attendant_panel.dart';
import 'lights_staff_area_ceiling_panel.dart';
import 'lights_staff_area_dnwash_panel.dart';
import 'lights_staff_area_upwash_panel.dart';
import 'lights_vip_lav_upwash_panel.dart';

class LightsStaffAreaAreaScreen extends StatefulWidget {
  const LightsStaffAreaAreaScreen({super.key});

  @override
  State<LightsStaffAreaAreaScreen> createState() => _LightsStaffAreaAreaScreenState();
}

class _LightsStaffAreaAreaScreenState extends State<LightsStaffAreaAreaScreen> {
  int _selectedTabIndex = 0;
  String _selectedGroupId = 'ceiling';
  bool isSideMenuOpen = false;
  final Map<String, bool> _cardPressedStates = {};

  // image sizing for overlay
  final GlobalKey _imageKey = GlobalKey();
  Size? _imageSize;

  // ===== vertical group tabs =====
  static const List<TabSpec> _groupTabs = [
    TabSpec(
      id: 'ceiling',
      label: 'CEILING',
      flex: 20,
      iconAsset: 'assets/icons/icon_lightMid.png',
      iconSize: 60,
      iconPosition: Axis.horizontal,
    ),
    TabSpec(
      id: 'upwash',
      label: 'UPWASH',
      flex: 20,
      iconAsset: 'assets/icons/icon_lightMid.png',
      iconSize: 60,
      iconPosition: Axis.horizontal,
    ),
    TabSpec(
      id: 'dnwash',
      label: 'DNWASH',
      flex: 20,
      iconAsset: 'assets/icons/icon_lightMid.png',
      iconSize: 60,
      iconPosition: Axis.horizontal,
    ),

    TabSpec(
      id: 'accent',
      label: 'ACCENT',
      flex: 20,
      iconAsset: 'assets/icons/icon_lightOff.png',
      iconSize: 60,
      // iconWidth: 55,
      iconPosition: Axis.horizontal,
    ),

    TabSpec(
      id: 'attendant',
      label: 'ATTENDANT',
      flex: 20,
      iconAsset: 'assets/icons/icon_lightOff.png',
      iconSize: 60,
      // iconWidth: 0,
      iconPosition: Axis.horizontal,
      fontSize: 22,
    ),

    // TabSpec(id: 'all', label: 'ALL', flex: 14),
  ];

  @override
  void initState() {
    super.initState();
    final idx = _groupTabs.indexWhere((t) => t.id == _selectedGroupId);
    _selectedTabIndex = idx >= 0 ? idx : 0;
    _selectedGroupId = _groupTabs[_selectedTabIndex].id;

    WidgetsBinding.instance.addPostFrameCallback((_) => _getImageSize());
  }

  void _getImageSize() {
    final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final newSize = renderBox.size;
      if (_imageSize == null || _imageSize != newSize) {
        setState(() => _imageSize = newSize);
      }
    }
  }

  String _getImagePath(RoomType roomType) {
    switch (roomType) {
      case RoomType.lounge:
        return 'assets/backgrounds/lounge.png';
      case RoomType.hallway:
        return 'assets/backgrounds/lounge.png';
      case RoomType.loungeAndHallway:
        return 'assets/backgrounds/lounge.png';
    }
  }

  // ===== Right-side panel routing (tady jen přidáš další group widgety) =====
  Widget _buildRightPanel(CustomTheme myTheme) {
    final Map<String, WidgetBuilder> panels = {
      'ceiling': (_) => const LightsStaffAreaCeilingPanel(),
      'upwash': (_) => const LightsStaffAreaUpwashPanel(),
      'dnwash': (_) => const LightsStaffAreaDnwashPanel(),
      'accent': (_) => const LightsStaffAreaAccentPanel(),
      'attendant': (_) => const LightsStaffAreaAttendantPanel(),
    };

    final builder = panels[_selectedGroupId];
    if (builder != null) return builder(context);

    // fallback (dokud nedoděláš ostatní)
    return Center(
      child: Text(
        'TODO panel for ${_selectedGroupId.toUpperCase()}',
        style: myTheme.textTheme?.headlineSmall?.copyWith(color: Colors.white70),
      ),
    );
  }

  // =========================
  // LEFT: image + bulbs overlay (direction-lights-lounge)
  // =========================
  Widget _buildDirLightsPanel(
    CustomTheme myTheme,
    RoomType? roomType, {
    required int selectedTabIndex,
    required ValueChanged<int> onTabSelected,
  }) {
    final lightsDirection = (configItems['lounge-direction-lights'] ?? configItems['direction-lights-lounge']) as List<dynamic>;
    final directionLights = lightsDirection.cast<GenericSelection>();

    Widget buildDirLight(GenericSelection item) {
      final size = _imageSize;
      final position = item.position;

      if (size == null || position == null) {
        return const SizedBox.shrink();
      }

      final lightWidth = (item.width ?? item.iconSize ?? 100).toDouble();
      final lightHeight = (item.height ?? item.iconSize ?? 100).toDouble();
      final iconSize = (item.iconSize ?? lightWidth).toDouble();

      // Position values are relative to the rendered aircraft image.
      // Example: x = 0.32 means 32% of the rendered image width.
      final left = size.width * position.x.toDouble() - (lightWidth / 2);
      final top = size.height * position.y.toDouble() - (lightHeight / 2);

      return Positioned(
        left: left,
        top: top,
        child: SizedBox(
          width: lightWidth,
          height: lightHeight,
          child: GenericSelectionWidget(
            id: item.id,
            title: item.title,
            icons: item.icons,
            iconSize: iconSize,
            height: lightHeight,
            width: lightWidth,
            imageSize: [iconSize, iconSize],
            isMomentary: item.isMomentary,
            onStateCallBack: () {},
            offStateCallBack: () {},
            textIconSpacing: 0,
            textStyle: myTheme.textTheme?.bodyLarge,
            states: item.states,
            side: GenericSelelectionWidgetButtonSide.none,
            isTransparent: true,
            keepContentWhenTransparent: true,
            removeBtnBackgroundStyling: true,
            iconsShadow: const [
              Shadow(
                color: Colors.black,
                offset: Offset(2, 2),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 245, // ⭐ přidáno místo pro tabs (nebo nech jen constraints a Row si to vezme)
      constraints: const BoxConstraints(maxHeight: 700, minHeight: 300),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            // ===== LEFT: image + bulbs overlay =====
            // Expanded(
            //   child: Stack(
            //     children: [
            //       Container(color: Colors.black.withOpacity(0.1)),
            //       Center(
            //         child: CfgImage(
            //           key: _imageKey,
            //           _getImagePath(roomType),
            //           fit: BoxFit.contain,
            //           gaplessPlayback: true,
            //           frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            //             if (wasSynchronouslyLoaded || frame != null) {
            //               WidgetsBinding.instance.addPostFrameCallback((_) => _getImageSize());
            //             }
            //             if (frame == null) {
            //               return Container(
            //                 color: Colors.black.withOpacity(0.1),
            //                 child: Center(
            //                   child: CircularProgressIndicator(color: Colors.white.withOpacity(0.3)),
            //                 ),
            //               );
            //             }
            //             return child;
            //           },
            //         ),
            //       ),
            //       if (_imageSize != null)
            //         ..._dirLightLayoutRel.entries.map((entry) {
            //           final id = entry.key;
            //           final rel = entry.value;
            //           final item = dirLightById[id];
            //           if (item == null) return const SizedBox.shrink();
            //           return buildDirLight(item, rel);
            //         }),
            //     ],
            //   ),
            // ),

            // ===== RIGHT: vertical tabs inside same block =====
            Container(
              width: 240,
              color: myTheme.tabBarTheme?.tabColor,
              child: _buildMultiRowTabBar(
                myTheme,
                selectedTabIndex: selectedTabIndex,
                onTabSelected: onTabSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // MIDDLE: vertical tabs with indicators
  // =========================
  GenericSelection? _findGenericSelection(String listKey, String id) {
    final items = configItems[listKey];
    if (items == null) return null;

    for (final item in items) {
      if (item is GenericSelection && item.id == id) {
        return item;
      }
    }

    return null;
  }

  Map<String, GenericSelection> _buildTabPowerItems() {
    final candidates = <String, GenericSelection?>{
      'ceiling': _findGenericSelection('lights_staff_ceiling', 'staff_ceiling_power'),
      'upwash': _findGenericSelection('lights_staff_upwash', 'staff_upwash_indication_power'),
      'dnwash': _findGenericSelection('lights_staff_dnwash', 'staff_dnwash_indication_power'),
      'accent': _findGenericSelection('lights_staff_accent', 'staff_accent_indication_power'),
      'attendant': _findGenericSelection('lights_staff_attendant', 'staff_attendant_indication_power'),
    };

    return {
      for (final entry in candidates.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
  }

  Widget _buildMultiRowTabBar(
    CustomTheme myTheme, {
    required int selectedTabIndex,
    required ValueChanged<int> onTabSelected,
    Color? activeBackgroundColor,
    Color? inactiveBackgroundColor,
    Color? activeTextColor,
    Color? inactiveTextColor,
    Color? indicatorColor,
    double? indicatorWeight,
    TextStyle? labelStyle,
    double? tabSpacing,
    BorderRadius? borderRadius,
    bool useCustomFlex = true,
  }) {
    final tabPowerItems = _buildTabPowerItems();

    // One item per row keeps the original vertical panel proportions intact,
    // while sharing the same tab-building approach as lights_lounge_main_screen.dart.
    final List<List<TabSpec>> tabRows = _groupTabs.map((tab) => [tab]).toList();

    final effectiveActiveBackground = activeBackgroundColor ?? myTheme.tabBarTheme?.labelColor?.withOpacity(0.0) ?? Colors.transparent;
    final effectiveInactiveBackground = inactiveBackgroundColor ?? Colors.transparent;
    final effectiveActiveText = activeTextColor ?? myTheme.tabBarTheme?.labelColor ?? Colors.white;
    final effectiveInactiveText = inactiveTextColor ?? myTheme.tabBarTheme?.unselectedLabelColor ?? Colors.white70;
    final effectiveIndicatorColor = indicatorColor ?? myTheme.tabBarTheme?.indicatorColor ?? Colors.white;
    final effectiveIndicatorWeight = indicatorWeight ?? myTheme.tabBarTheme?.indicatorWeight?.toDouble() ?? 4.0;
    final effectiveLabelStyle = labelStyle ?? myTheme.tabBarTheme?.labelStyle ?? myTheme.textTheme?.titleMedium;
    final effectiveTabSpacing = tabSpacing ?? 0.0;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(8);

    int getGlobalIndexById(String id) {
      int index = 0;
      for (final row in tabRows) {
        for (final tab in row) {
          if (tab.isSpacer) continue;
          if (tab.id == id) return index;
          index++;
        }
      }
      return 0;
    }

    int resolveFlexForItem({required TabSpec item, required List<TabSpec> row}) {
      if (!useCustomFlex) return 1;
      if (item.flex != null) return item.flex!.clamp(1, 1000000);

      final totalDefined = row.fold<int>(0, (sum, tab) => sum + (tab.flex ?? 0));
      final missingCount = row.where((tab) => tab.flex == null).length;
      if (totalDefined == 0 && missingCount > 0) return 1;
      if (missingCount <= 0) return 1;

      final remaining = 100 - totalDefined;
      final perItem = remaining > 0 ? remaining ~/ missingCount : 1;
      return perItem.clamp(1, 1000000);
    }

    return Container(
      width: 240,
      color: myTheme.tabBarTheme?.tabColor,
      child: Column(
        children: tabRows.asMap().entries.map((rowEntry) {
          final rowItems = rowEntry.value;

          return Expanded(
            flex: resolveFlexForItem(item: rowItems.first, row: rowItems),
            child: Row(
              children: rowItems.map((item) {
                final flex = resolveFlexForItem(item: item, row: rowItems);

                if (item.isSpacer) {
                  return Expanded(flex: flex, child: const SizedBox.expand());
                }

                final globalIndex = getGlobalIndexById(item.id);
                final isSelected = selectedTabIndex == globalIndex;
                final textColor = isSelected ? effectiveActiveText : effectiveInactiveText;
                final tabPowerItem = tabPowerItems[item.id];

                return Expanded(
                  flex: flex,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTabSelected(globalIndex),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8 + effectiveTabSpacing),
                      decoration: BoxDecoration(
                        color: isSelected ? effectiveActiveBackground : effectiveInactiveBackground,
                        borderRadius: effectiveBorderRadius,
                      ),
                      child: ClipRRect(
                        borderRadius: effectiveBorderRadius,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: effectiveIndicatorWeight + 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.label.trimRight(),
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                      textAlign: TextAlign.center,
                                      style: effectiveLabelStyle?.copyWith(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: item.fontSize ?? effectiveLabelStyle?.fontSize,
                                      ),
                                    ),
                                  ),
                                  if (tabPowerItem != null) ...[
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(width: 8),
                                        TabGenericSelectionIcon(
                                          item: tabPowerItem,
                                          myTheme: myTheme,
                                          size: item.iconSize ?? 40,
                                        ),
                                        const SizedBox(width: 5),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 10,
                                bottom: 10,
                                right: 0,
                                child: Container(
                                  width: effectiveIndicatorWeight,
                                  decoration: BoxDecoration(
                                    color: effectiveIndicatorColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGlobalControls(CustomTheme myTheme) {
   final menuItems = configItems['lights_staff_all'] as List<dynamic>;
    String menuPrefix = 'staff_';

    GenericSelection allLightsBrt = menuItems.firstWhere((element) => element.id == '${menuPrefix}allLightsOn') as GenericSelection;
    GenericSelection allLightsOff = menuItems.firstWhere((element) => element.id == '${menuPrefix}allLightsOff') as GenericSelection;
    GenericSelection allLightsDim = menuItems.firstWhere((element) => element.id == '${menuPrefix}allLightsDim') as GenericSelection;
    GenericSelection allLightsMid = menuItems.firstWhere((element) => element.id == '${menuPrefix}allLightsMid') as GenericSelection;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...[allLightsOff, allLightsDim, allLightsMid, allLightsBrt].map(
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
                    textIconSpacing: 10,
                    states: item.states,
                    textStyle: myTheme.textTheme?.labelMedium,
                    removeBtnBackgroundStyling: true,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenu(CustomTheme myTheme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final menuWidth = screenWidth * 0.7;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
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
              width: 35,
              height: 140,
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
                        'SCENES',
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
            child: _buildSideMenuContent(myTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenuContent(CustomTheme myTheme) {
    final menuItems = configItems['lights_staff_area_presets'] as List<dynamic>;
    final presetRows = _getPresetsRowsForGroup(menuItems);

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
                  'LIGHTING SCENES',
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: presetRows.asMap().entries.map((entry) {
                        final rowIndex = entry.key;
                        final rowItems = entry.value;

                        const rowSpacing = 15.0;
                        const rowHeight = 145.0;

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: rowIndex < presetRows.length - 1 ? rowSpacing : 0,
                          ),
                          child: SizedBox(
                            height: rowHeight,
                            child: SelectionGridGallery(
                              items: rowItems,
                              columns: rowItems.length,
                              spacing: 15,
                              runSpacing: 0,
                              fixedCardHeight: rowHeight,
                              cardAspectRatio: 1.30,
                              textAlignment: Alignment.bottomCenter,
                              imageOverlayGradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.0),
                                  Colors.black.withOpacity(0.65),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    final myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    return ActivityDetector(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDirLightsPanel(
                        myTheme,
                        null,
                        selectedTabIndex: _selectedTabIndex,
                        onTabSelected: (idx) {
                          setState(() {
                            _selectedTabIndex = idx;
                            _selectedGroupId = _groupTabs[idx].id;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: _buildRightPanel(myTheme)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buildGlobalControls(myTheme),
              ],
            ),
          ),
          _buildSideMenu(myTheme),
        ],
      ),
    );
  }
}
