import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';

import 'lights_master_lav_area_screen.dart';

class LightsMasterLavMainScreen extends StatefulWidget {
  const LightsMasterLavMainScreen({super.key, title});

  @override
  State<LightsMasterLavMainScreen> createState() => _LightsMasterLavMainScreenState();
}

class _LightsMasterLavMainScreenState extends State<LightsMasterLavMainScreen> with TickerProviderStateMixin {
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
    return ActivityDetector(
      child: Padding(
        padding: const EdgeInsets.only(top: kToolbarHeight), // ⭐ Celá stránka odsazená
        child: DefaultTabController(
          animationDuration: Duration.zero,
          length: 3,
          initialIndex: 0,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 0,
            ),
            body: const LightsMasterLavAreaScreen(),
          ),
        ),
      ),
    );
  }
}
