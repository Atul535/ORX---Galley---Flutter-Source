import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/custom_theme_provider.dart';

class CollapsingListTile extends StatefulWidget {
  final String? title;
  final IconData? icon;
  final AnimationController? animationController;

  const CollapsingListTile(
      {super.key, this.title, this.icon, this.animationController});

  @override
  State<CollapsingListTile> createState() => _CollapsingListTileState();
}

class _CollapsingListTileState extends State<CollapsingListTile> {
  @override
  Widget build(BuildContext context) {
    CustomTheme myTheme =
        Provider.of<CustomThemes>(context, listen: true).getActiveTheme();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(children: <Widget>[
        Icon(widget.icon, color: Colors.white30, size: 38.0),
        const SizedBox(width: 10),
        Text(
          widget.title.toString(),
          // style: listTitleDefaultTextStyle,
        ),
      ]),
    );
  }
}
