import 'package:flutter/material.dart';

import '../widgets/cfg_image.dart';
import '../widgets/lazy_indexed_stack.dart';
import 'ecbu_tab_content.dart';

class MaintenanceEcbScreen extends StatefulWidget {
  const MaintenanceEcbScreen({super.key});

  @override
  State<MaintenanceEcbScreen> createState() => _MaintenanceEcbScreenState();
}

class _MaintenanceEcbScreenState extends State<MaintenanceEcbScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EcbuTabs(
          tabs: _tabs.map((e) => e.id).toList(growable: false),
          selectedIndex: _selected,
          onSelect: (i) => setState(() => _selected = i),
          topSpacing: 50,
          tabsHeight: 140, // výška tabs
          tabsDecoration: const BoxDecoration(
            color: Colors.white54,
            border: Border(
              bottom: BorderSide(color: Colors.white24, width: 1),
            ),
          ),
          activeIconAsset: 'assets/icons/tab_active.png',
          inactiveIconAsset: 'assets/icons/tab_inactive.png',
          iconHeight: 100,
        ),
        const Divider(height: 1, color: Colors.white24),
        Expanded(
          child: LazyIndexedStack(
            index: _selected,
            builders: _tabs.map((t) {
              return (ctx) => EcbuTabContent(
                    ecbuId: t.id,
                    groupKeyPage: t.pageKey,
                    groupKeyActions: t.actionsKey,
                    backgroundAsset: t.backgroundAsset,
                  );
            }).toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class _EcbuTabDef {
  final String id;
  final String pageKey;
  final String actionsKey;
  final String? backgroundAsset;

  const _EcbuTabDef({
    required this.id,
    required this.pageKey,
    required this.actionsKey,
    this.backgroundAsset,
  });
}

final List<_EcbuTabDef> _tabs = const [
  // =========================
  // DC GROUP
  // =========================
  _EcbuTabDef(
    id: 'dc1',
    pageKey: 'ecbu-dc1',
    actionsKey: 'ecbu-dc1-actions',
    // backgroundAsset: 'assets/ecbu/dc1_bg.png',
  ),
  _EcbuTabDef(
    id: 'dc2',
    pageKey: 'ecbu-dc2',
    actionsKey: 'ecbu-dc2-actions',
    // backgroundAsset: 'assets/ecbu/dc2_bg.png',
  ),
  _EcbuTabDef(
    id: 'dc3',
    pageKey: 'ecbu-dc3',
    actionsKey: 'ecbu-dc3-actions',
    // backgroundAsset: 'assets/ecbu/dc3_bg.png',
  ),
  _EcbuTabDef(
    id: 'dc4',
    pageKey: 'ecbu-dc4',
    actionsKey: 'ecbu-dc4-actions',
    // backgroundAsset: 'assets/ecbu/dc4_bg.png',
  ),
  _EcbuTabDef(
    id: 'dc5',
    pageKey: 'ecbu-dc5',
    actionsKey: 'ecbu-dc5-actions',
    // backgroundAsset: 'assets/ecbu/dc5_bg.png',
  ),
  _EcbuTabDef(
    id: 'dc6',
    pageKey: 'ecbu-dc6',
    actionsKey: 'ecbu-dc6-actions',
    // backgroundAsset: 'assets/ecbu/dc6_bg.png',
  ),
  _EcbuTabDef(
    id: 'dc7',
    pageKey: 'ecbu-dc7',
    actionsKey: 'ecbu-dc7-actions',
    // backgroundAsset: 'assets/ecbu/dc7_bg.png',
  ),
  _EcbuTabDef(
    id: 'dc8',
    pageKey: 'ecbu-dc8',
    actionsKey: 'ecbu-dc8-actions',
    // backgroundAsset: 'assets/ecbu/dc8_bg.png',
  ),

  // =========================
  // AC GROUP
  // =========================
  _EcbuTabDef(
    id: 'ac1',
    pageKey: 'ecbu-ac1',
    actionsKey: 'ecbu-ac1-actions',
    // backgroundAsset: 'assets/ecbu/ac1_bg.png',
  ),
  _EcbuTabDef(
    id: 'ac2',
    pageKey: 'ecbu-ac2',
    actionsKey: 'ecbu-ac2-actions',
    // backgroundAsset: 'assets/ecbu/ac2_bg.png',
  ),
  _EcbuTabDef(
    id: 'ac3',
    pageKey: 'ecbu-ac3',
    actionsKey: 'ecbu-ac3-actions',
    // backgroundAsset: 'assets/ecbu/ac3_bg.png',
  ),
  _EcbuTabDef(
    id: 'ac4',
    pageKey: 'ecbu-ac4',
    actionsKey: 'ecbu-ac4-actions',
    // backgroundAsset: 'assets/ecbu/ac4_bg.png',
  ),
];

class _EcbuTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  final double topSpacing;
  final double tabsHeight;
  final String activeIconAsset;
  final String inactiveIconAsset;
  final double iconHeight;

  // 🔥 NEW
  final BoxDecoration? tabsDecoration;

  const _EcbuTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
    required this.activeIconAsset,
    required this.inactiveIconAsset,
    this.topSpacing = 30,
    this.tabsHeight = 150,
    this.iconHeight = 100,
    this.tabsDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topSpacing),
      child: Container(
        height: tabsHeight,
        decoration: tabsDecoration ??
            const BoxDecoration(
              color: Colors.black,
            ),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isActive = index == selectedIndex;
            final icon = isActive ? activeIconAsset : inactiveIconAsset;

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(index),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CfgImage(
                        icon,
                        height: iconHeight,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        tabs[index].toUpperCase(),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black.withOpacity(0.8),
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
