import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/dir_light_layout_rel.dart'; // (už se nepoužívá pro overlay, můžeš smazat import když chceš)
import '../model/enum_room_type.dart';
import '../model/generic_selection.dart';
import '../model/tab_spec.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import '../widgets/cfg_image.dart';
import '../widgets/generic_selection_widget.dart';
import 'shades_bedroom_all_panel.dart';


class ShadesBedroomAreaScreen extends StatefulWidget {
  const ShadesBedroomAreaScreen({super.key});

  @override
  State<ShadesBedroomAreaScreen> createState() => _ShadesBedroomAreaScreenState();
}

class _ShadesBedroomAreaScreenState extends State<ShadesBedroomAreaScreen> {
  int _selectedTabIndex = 0;
  String _selectedGroupId = 'right';
  bool isSideMenuOpen = false;
  final Map<String, bool> _cardPressedStates = {};

  // image sizing (už jen pro případné debug / future use)
  final GlobalKey _imageKey = GlobalKey();
  Size? _imageSize;

  // ===== vertical group tabs =====
  static const List<TabSpec> _groupTabs = [
    TabSpec(
      id: 'all',
      label: 'ALL',
      flex: 20,
      iconAsset: 'assets/icons/icon_shade_open.png',
      iconSize: 60,
      iconPosition: Axis.horizontal,
    ),
  ];

  // (už se nepoužívá – overlay pozice jsme zrušili)
  static const Map<String, DirLightLayoutRel> _dirLightLayoutRel = {
    'shades1': DirLightLayoutRel(x: 0.32, y: 0.20, height: 120, width: 120),
  };

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
        return 'assets/backgrounds/bedroom.png';
      case RoomType.hallway:
        return 'assets/backgrounds/bedroom.png';
      case RoomType.loungeAndHallway:
        return 'assets/backgrounds/bedroom.png';
    }
  }

  // ===== Right-side panel routing =====
  Widget _buildRightPanel(CustomTheme myTheme) {
    final Map<String, WidgetBuilder> panels = {
      'all': (_) => const ShadesBedroomAllPanel(),
    };

    final builder = panels[_selectedGroupId];
    if (builder != null) return builder(context);

    return Center(
      child: Text(
        'TODO panel for ${_selectedGroupId.toUpperCase()}',
        style: myTheme.textTheme?.headlineSmall?.copyWith(color: Colors.white70),
      ),
    );
  }

  // =========================
  // NEW: Split shades dirLights into TOP (8) + BOTTOM (7)
  // =========================
  ({List<GenericSelection> top, List<GenericSelection> bottom}) _splitDirLightsForShades(List<GenericSelection> all) {
    // Varianta A: podle pořadí v configu (prvních 8 nahoře, dalších 7 dole)
    final top = all.take(3).toList();
    final bottom = all.skip(8).take(0).toList();
    return (top: top, bottom: bottom);

    // Varianta B (pokud chceš explicitní ID):
    // final byId = {for (final it in all) it.id.toString(): it};
    // final topIds = ['shades1','shades2','shades3','shades4','shades5','shades6','shades7','shades8'];
    // final bottomIds = ['shades9','shades10','shades11','shades12','shades13','shades14','shades15'];
    // final top = topIds.map((id) => byId[id]).whereType<GenericSelection>().toList();
    // final bottom = bottomIds.map((id) => byId[id]).whereType<GenericSelection>().toList();
    // return (top: top, bottom: bottom);
  }

  // =========================
  // NEW: DirLights strip (row) with semi-transparent underlay
  // =========================
  Widget _buildDirLightsStrip({
    required CustomTheme myTheme,
    required List<GenericSelection> items,
    required int slots, // 8 nebo 7
    double height = 60,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
  }) {
    final filled = List<GenericSelection?>.generate(
      slots,
      (i) => i < items.length ? items[i] : null,
    );

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.15), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: filled.map((item) {
          return Center(
            child: item == null
                ? const SizedBox.shrink()
                : SizedBox(
                    height: height - padding.vertical,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(1, 0, 1, 0),
                          child: IgnorePointer(
                            child: GenericSelectionWidget(
                              id: item.id,
                              title: '',
                              icons: const [],
                              iconSize: 10,
                              height: 60,
                              width: 60,
                              imageSize: const [100, 100],
                              isMomentary: item.isMomentary,
                              onStateCallBack: () {},
                              offStateCallBack: () {},
                              textIconSpacing: 0,
                              states: item.states,
                              side: GenericSelelectionWidgetButtonSide.none,
                              isTransparent: true,
                              keepContentWhenTransparent: true,
                              removeBtnBackgroundStyling: true,
                              iconsShadow: const [
                                Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          );
        }).toList(),
      ),
    );
  }

  // =========================
  // LEFT: Top strip (8) + Image + Bottom strip (7) + right vertical tabs
  // =========================
  Widget _buildDirLightsPanel(
    CustomTheme myTheme,
    RoomType? roomType, {
    required int selectedTabIndex,
    required ValueChanged<int> onTabSelected,
  }) {
    final lightsDirection = configItems['direction-lounge-shades'] as List<dynamic>;
    final items = lightsDirection.cast<GenericSelection>();
    final split = _splitDirLightsForShades(items);

    return Container(
      width: 550 + 250,
      constraints: const BoxConstraints(maxHeight: 700, minHeight: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
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
            // ===== LEFT: strips + image =====
            Expanded(
              child: Column(
                children: [
                  // TOP: 8
                  _buildDirLightsStrip(
                    myTheme: myTheme,
                    items: split.top,
                    slots: 8,
                    height: 60,
                  ),

                  // IMAGE
                  Expanded(
                    child: Stack(
                      children: [
                        Container(color: Colors.black.withOpacity(0.1)),
                        Center(
                          child: CfgImage(
                            key: _imageKey,
                            _getImagePath(roomType ?? RoomType.lounge),
                            fit: BoxFit.contain,
                            // gaplessPlayback: true,
                            // frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            //   if (wasSynchronouslyLoaded || frame != null) {
                            //     WidgetsBinding.instance.addPostFrameCallback((_) => _getImageSize());
                            //   }
                            //   if (frame == null) {
                            //     return Container(
                            //       color: Colors.black.withOpacity(0.1),
                            //       child: Center(
                            //         child: CircularProgressIndicator(color: Colors.white.withOpacity(0.3)),
                            //       ),
                            //     );
                            //   }
                            //   return child;
                            // },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // BOTTOM: 7
                  _buildDirLightsStrip(
                    myTheme: myTheme,
                    items: split.bottom,
                    slots: 7,
                    height: 60,
                  ),
                ],
              ),
            ),

            // ===== RIGHT: vertical tabs =====
            Container(
              width: 200,
              color: myTheme.tabBarTheme?.tabColor,
              child: _buildVerticalGroupTabs(
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
  // vertical tabs
  // =========================
  Widget _buildVerticalGroupTabs(
    CustomTheme myTheme, {
    required int selectedTabIndex,
    required ValueChanged<int> onTabSelected,
  }) {
    final activeBg = myTheme.tabBarTheme?.labelColor?.withOpacity(0.0) ?? Colors.transparent;
    final inactiveBg = Colors.transparent;

    final activeText = myTheme.tabBarTheme?.labelColor ?? Colors.white;
    final inactiveText = myTheme.tabBarTheme?.unselectedLabelColor ?? Colors.white70;

    final indicatorColor = myTheme.tabBarTheme?.indicatorColor ?? Colors.white;
    final indicatorW = (myTheme.tabBarTheme?.indicatorWeight?.toDouble() ?? 4.0);

    final labelStyle = myTheme.tabBarTheme?.labelStyle ?? myTheme.textTheme?.titleMedium;

    return Container(
      width: 240,
      color: myTheme.tabBarTheme?.tabColor,
      child: Column(
        children: _groupTabs.asMap().entries.map((e) {
          final idx = e.key;
          final t = e.value;

          final isSelected = selectedTabIndex == idx;
          final textColor = isSelected ? activeText : inactiveText;
          final flex = (t.flex ?? 1).clamp(1, 1000000);

          final double iconBoxW = (t.iconWidth ?? 60).toDouble();
          final double iconBoxH = (t.iconSize ?? 60).toDouble();

          return Expanded(
            flex: flex,
            child: GestureDetector(
              onTap: () => onTabSelected(idx),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? activeBg : inactiveBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: t.iconAsset != null ? (iconBoxW + 12) : 0,
                        ),
                        child: Text(
                          t.label.trimRight(),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.center,
                          style: labelStyle?.copyWith(
                            color: textColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    if (t.iconAsset != null)
                      Positioned(
                        right: 14,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: SizedBox(
                            width: iconBoxW,
                            height: iconBoxH,
                            child: CfgImage(
                              t.iconAsset!,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ),
                    if (isSelected)
                      Positioned(
                        top: 10,
                        bottom: 10,
                        right: 0,
                        child: Container(
                          width: indicatorW,
                          decoration: BoxDecoration(
                            color: indicatorColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
