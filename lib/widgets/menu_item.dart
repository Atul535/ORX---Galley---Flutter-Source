import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/custom_theme_provider.dart';
import '../model/home_menu_model.dart';
import '../model/theme/item_theme.dart';
import '../model/navigation_icon.dart';
import '../utils/pwm_manager.dart';

class MenuItem extends StatelessWidget {
  final String? id;
  final String? title;
  final IconData? icon;
  final String? route;

  const MenuItem({Key? key, this.id, this.title, this.icon, this.route})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CustomTheme myTheme =
        Provider.of<CustomThemes>(context, listen: true).getActiveTheme();
    ItemTheme itemTheme = myTheme.menuItemThemeInactive as ItemTheme;
    final item = Provider.of<NavigationIcon>(context, listen: true);
    final group = Provider.of<HomeMenu>(context, listen: false);

    if (item.isActive) {
      itemTheme = myTheme.menuItemThemeActive as ItemTheme;
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () {
          item.route != null
              ? Navigator.of(context)
                  .pushNamed(item.route, arguments: item.title)
              : null;
          // group.toggleNavActive(item.id);
        },
        onPanDown: (det) {
          PwmManager.vibrate(150, 1);
          item.route != null
              ? Navigator.of(context)
                  .pushNamed(item.route, arguments: item.title)
              : null;
          // group.toggleNavActive(item.id);
        },
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: myTheme.selectionTextOverlayColor,
            title: Text(
              item.title.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: itemTheme.textColor ?? itemTheme.symbolColor,
                  fontSize: 36,
                  shadows: itemTheme.textShadows),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: itemTheme.border,
              color: itemTheme.backroundColor,
              gradient: itemTheme.gradient,
              borderRadius: itemTheme.borderRadius ?? BorderRadius.circular(20),
              boxShadow: itemTheme.boxShadow,
            ),
            child: Icon(
              item.icon,
              size: item.iconSize,
              color: itemTheme.symbolColor,
              shadows: itemTheme.shadow,
            ),
          ),
        ),
      ),
    );
  }
}
