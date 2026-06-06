import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import 'shades_bedroom_area_screen.dart';

class ShadesBedroomScreen extends StatefulWidget {
  const ShadesBedroomScreen({super.key, title});

  @override
  State<ShadesBedroomScreen> createState() => _ShadesBedroomScreenState();
}

class _ShadesBedroomScreenState extends State<ShadesBedroomScreen> with TickerProviderStateMixin {
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
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 0,
          ),
          body: const ShadesBedroomAreaScreen(),
        ),
      ),
    );
  }
}
