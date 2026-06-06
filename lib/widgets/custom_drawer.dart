import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/home_menu_model.dart';
import 'menu_drawer_item.dart';

class CustomDrawer extends StatelessWidget {
  final HomeMenu drawerItems;
  const CustomDrawer({super.key, required this.drawerItems});

  @override
  Widget build(BuildContext context) {
    Color? textColor;

    if (Theme.of(context).brightness == Brightness.light) {
      textColor = Colors.white;
    }

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.3,
      backgroundColor: Colors.grey.shade900,
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: Stack(
        children: [
          Positioned.fill(
            top: 0,
            bottom: MediaQuery.of(context).size.height - 150,
            child: Center(
                child: Text('Select menu', style: TextStyle(color: textColor))),
          ),
          Positioned.fill(
            top: 150,
            child: GridView.builder(
              physics: const ClampingScrollPhysics(),
              // padding: const EdgeInsets.all(10),
              itemCount: drawerItems.navigationItems.length,
              itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                value: drawerItems.navigationItems[i],
                child: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: MenuDrawerItem(),
                ),
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 4 / 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
