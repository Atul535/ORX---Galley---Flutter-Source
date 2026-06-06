// import 'package:flutter/material.dart';
// import '../model/theme.dart';

// import '../model/navigation_model.dart';
// import '../widgets/collapsing_list_tile.dart';

// class CollapsingNavigationDrawer extends StatefulWidget {
//   const CollapsingNavigationDrawer({super.key});

//   @override
//   State<CollapsingNavigationDrawer> createState() =>
//       _CollapsingNavigationDrawerState();
// }

// class _CollapsingNavigationDrawerState extends State<CollapsingNavigationDrawer>
//     with SingleTickerProviderStateMixin {
//   double maxWidth = 250;
//   double minWidth = 70;
//   bool isCollapsed = false;
//   AnimationController? _animationController;
//   Animation<double>? widthAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//         vsync: this, duration: Duration(milliseconds: 3000));
//     widthAnimation = Tween<double>(begin: maxWidth, end: minWidth)
//         .animate(_animationController);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (cts, widget) => getWidget(context, widget),
//     );
//   }

//   Widget getWidget(context, widget) {
//     Container(
//       width: widthAnimation as double,
//       color: drawerBackgroundColor,
//       child: Column(
//         children: <Widget>[
//           const SizedBox(height: 50.0),
//           const CollapsingListTile(
//             title: 'Radek Macku',
//             icon: Icons.person,
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: navigationItems.length,
//               itemBuilder: (ctx, index) {
//                 return CollapsingListTile(
//                   title: navigationItems[index].title,
//                   icon: navigationItems[index].icon,
//                   animationController: _animationController,
//                 );
//               },
//             ),
//           ),
//           InkWell(
//             onTap: () {
//               setState(() {
//                 isCollapsed = !isCollapsed;
//                 isCollapsed
//                     ? _animationController.reverse()
//                     : _animationController.forward();
//               });
//             },
//             child:
//                 const Icon(Icons.chevron_left, color: Colors.white, size: 50.0),
//           ),
//           const SizedBox(height: 50.0),
//         ],
//       ),
//     );
//   }
// }
