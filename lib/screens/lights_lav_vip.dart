import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/custom_theme_provider.dart';
import '../widgets/activity_detector.dart';
import 'lights_vip_lav_main_screen.dart';

class LightsLavVipScreen extends StatefulWidget {
  const LightsLavVipScreen({super.key, title});

  @override
  State<LightsLavVipScreen> createState() => _LightsLavVipScreenState();
}

class _LightsLavVipScreenState extends State<LightsLavVipScreen> with TickerProviderStateMixin {
  String title = '';
  Radius iconsBorderRadius = const Radius.circular(15);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // title = ModalRoute.of(context)?.settings.arguments as String;
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();
    // lets iterate through menu items add the items to the current state provider

    return ActivityDetector(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SafeArea(
                child: Container(
                  // decoration: BoxDecoration(
                  //   // color: Colors.black54,
                  //   gradient: LinearGradient(
                  //     begin: Alignment.topLeft,
                  //     end: Alignment.bottomRight,
                  //     colors: [Colors.black54, const Color.fromARGB(31, 143, 121, 121)],
                  //   ),
                  // ),
                  child: const LightsVipLavMainScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
