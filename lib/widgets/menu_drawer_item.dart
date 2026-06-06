import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/custom_theme_provider.dart';
import '../model/theme/item_theme.dart';
import '../model/navigation_icon.dart';
import '../utils/pwm_manager.dart';

class MenuDrawerItem extends StatelessWidget {
  final String? id;
  final String? title;
  final IconData? icon;
  final String? route;

  const MenuDrawerItem({Key? key, this.id, this.title, this.icon, this.route})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CustomTheme myTheme =
        Provider.of<CustomThemes>(context, listen: true).getActiveTheme();
    ItemTheme itemTheme = myTheme.menuItemThemeInactive as ItemTheme;
    final item = Provider.of<NavigationIcon>(context, listen: true);

    if (item.isActive) {
      itemTheme = myTheme.menuItemThemeActive as ItemTheme;
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(item.route, arguments: item.title);
        },
        onPanDown: (det) {
          PwmManager.vibrate(150, 1);
          Navigator.of(context).pushNamed(item.route, arguments: item.title);
        },
        child: GridTile(
          child: Container(
            decoration: BoxDecoration(
              border: itemTheme.border,
              color: itemTheme.backroundColor,
              gradient: itemTheme.gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: itemTheme.boxShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Icon(
                    item.icon,
                    size: 75,
                    color: itemTheme.symbolColor,
                    shadows: itemTheme.shadow,
                  ),
                ),
                Text(
                  item.title.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: itemTheme.textColor ?? itemTheme.symbolColor,
                      fontSize: 45,
                      shadows: itemTheme.textShadows),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
