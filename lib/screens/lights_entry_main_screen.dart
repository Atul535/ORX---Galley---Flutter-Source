import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import 'lights_entry_area_screen.dart';

class LightsEntryScreen extends StatefulWidget {
  const LightsEntryScreen({super.key, title});

  @override
  State<LightsEntryScreen> createState() => _LightsEntryScreenState();
}

class _LightsEntryScreenState extends State<LightsEntryScreen> with TickerProviderStateMixin {
  String title = '';
  Radius iconsBorderRadius = const Radius.circular(15);

  CustomThemes myThemes = CustomThemes();
  late CustomTheme myTheme = myThemes.getActiveTheme();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final CustomThemes myThemes = Provider.of<CustomThemes>(context, listen: true);
    myTheme = myThemes.getActiveTheme();
  }

  @override
  Widget build(BuildContext context) {
    return const ActivityDetector(
      child: Padding(
        padding: EdgeInsets.only(top: kToolbarHeight), // ⭐ Celá stránka odsazená
        child: LightsEntryAreaScreen(),
      ),
    );
  }
}
