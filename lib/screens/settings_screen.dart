import 'package:flutter/material.dart';
import '../model/time_service.dart';
import '../providers/settings_provider.dart';
import '../providers/socket_provider.dart';
import '../providers/wallpapers_provider.dart';
import 'package:provider/provider.dart';
import '../providers/screensavers_provider.dart';
import '../widgets/activity_detector.dart';

import '../providers/custom_theme_provider.dart';
import 'base/edit_settings_screen.dart';
import 'base/password_protected_screen.dart';

class WallPaperDropDown extends StatelessWidget {
  const WallPaperDropDown({super.key});

  @override
  Widget build(BuildContext context) {
    CustomThemes myThemes = Provider.of<CustomThemes>(context, listen: true);
    CustomTheme myTheme = myThemes.getActiveTheme();

    Wallpapers wallpapers = Provider.of<Wallpapers>(context, listen: true);
    String dropdownValue = wallpapers.getActive();

    if (myTheme.backgroundImagePath == null) {
      dropdownValue = "disabled";
    }

    return DropdownButton<String>(
      value: dropdownValue,
      itemHeight: 50,
      icon: const Icon(Icons.arrow_downward, size: 20),
      elevation: 10,
      style: const TextStyle(color: Colors.white38, fontSize: 25),
      underline: Container(
        height: 2,
        color: Colors.white38,
      ),
      dropdownColor: Colors.grey.shade800,
      // selectedItemBuilder: ,
      onChanged: myTheme.backgroundImagePath == null
          ? null
          : (String? value) {
              // This is called when the user selects an item.
              wallpapers.setActiveWallpaper(value.toString());
              myThemes.changeWallpaper(myTheme.id, wallpapers.getWallpaperFilePathByName(value));
            },
      items: myTheme.backgroundImagePath == null
          ? <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                value: dropdownValue,
                child: Text(
                  dropdownValue,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 25),
                ),
              )
            ]
          : wallpapers.getWallpaperNames.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 25),
                ),
              );
            }).toList(),
    );
  }
}

class ThemeDropDown extends StatelessWidget {
  const ThemeDropDown({super.key});

  @override
  Widget build(BuildContext context) {
    CustomThemes myThemes = Provider.of<CustomThemes>(context, listen: true);
    String dropdownValue = myThemes.getActiveThemeName();

    return DropdownButton<String>(
      value: dropdownValue,
      itemHeight: 50,
      icon: const Icon(Icons.arrow_downward, size: 30),
      elevation: 10,
      style: const TextStyle(color: Colors.white38, fontSize: 25),
      underline: Container(
        height: 2,
        color: Colors.white38,
      ),
      dropdownColor: Colors.grey.shade800,
      // selectedItemBuilder: ,
      onChanged: (String? value) {
        // This is called when the user selects an item.
        myThemes.setActiveThemeByName(value.toString());
      },
      items: myThemes.customThemes.map<DropdownMenuItem<String>>((CustomTheme theme) {
        return DropdownMenuItem<String>(
          value: theme.name,
          child: Text(
            theme.name.toString(),
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 25),
          ),
        );
      }).toList(),
    );
  }
}

class ScreenSaverDropDown extends StatelessWidget {
  const ScreenSaverDropDown({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenSaversProvider screensavers = Provider.of<ScreenSaversProvider>(context, listen: true);
    String dropdownValue = screensavers.getActive();

    return DropdownButton<String>(
      value: dropdownValue,
      itemHeight: 50,
      icon: const Icon(Icons.arrow_downward, size: 30),
      elevation: 10,
      style: const TextStyle(color: Colors.white38, fontSize: 25),
      underline: Container(
        height: 2,
        color: Colors.white38,
      ),
      dropdownColor: Colors.grey.shade800,
      // selectedItemBuilder: ,
      onChanged: (String? value) {
        // This is called when the user selects an item.
        // if screensaver is disabled,

        screensavers.setActiveScreensaver(value.toString());
        if (value?.toUpperCase() == 'DISABLED') {
          TimerService.of(context).disable();
        } else {
          TimerService.of(context).enable();
          TimerService.of(context).screenSaverRoute = screensavers.getScreensaverRouteByName(value.toString());
        }
      },
      items: screensavers.getScreensaverNames.map<DropdownMenuItem<String>>((String screensaverName) {
        return DropdownMenuItem<String>(
          value: screensaverName,
          child: Text(
            screensaverName.toString(),
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 25),
          ),
        );
      }).toList(),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  static const routeName = '/app/settings';
  const SettingsScreen({super.key, title});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    CustomTheme myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.loadSettings();

    SocketProvider socketProvider = Provider.of<SocketProvider>(context, listen: false);

    return ActivityDetector(
      child: Stack(
        children: [
          // Wallpaper(imagePath: myTheme.backgroundImagePath),

          Container(
            color: myTheme.primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                // mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: myTheme.overlayColor,
                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'TURN SCREEN AFTER 120s',
                                  style: TextStyle(fontSize: 30),
                                ),
                              ),
                            ),
                            ScreenSaverDropDown(
                              key: UniqueKey(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            // width: double.infinity,
                            // height: double.infinity,
                            decoration: BoxDecoration(
                              color: myTheme.overlayColor,
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text('CHANGE THEME', style: TextStyle(fontSize: 30)),
                                  // SizedBox(height: 30),
                                  ThemeDropDown(
                                    key: UniqueKey(),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            // width: double.infinity,
                            // height: double.infinity,
                            decoration: BoxDecoration(
                              color: myTheme.overlayColor,
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text('CHANGE BACKGROUND', style: TextStyle(fontSize: 30)),
                                  // SizedBox(height: 30),
                                  WallPaperDropDown(
                                    key: UniqueKey(),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: myTheme.overlayColor,
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('CHANGE SETTINGS', style: TextStyle(fontSize: 30)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: myTheme.highlightColor),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PasswordProtectedScreen(
                                                alignment: Alignment.topCenter,
                                                insetPadding: const EdgeInsets.only(top: 100),
                                                correctPassword: settingsProvider.getValue("password"),
                                                protectedRouteName: EditSettingsScreen.routeName,
                                                titleStyle:
                                                    // myTheme.textTheme?.bodyLarge,
                                                    myTheme.textTheme?.titleSmall,
                                                textStyle: myTheme.textTheme?.titleSmall,
                                                // myTheme.textTheme?.bodyMedium,
                                                contentStyle: myTheme.textTheme?.titleSmall,
                                                // myTheme.textTheme?.bodyMedium,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text('SETTINGS', style: myTheme.textTheme?.displaySmall),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: myTheme.highlightColor),
                                        onPressed: () {
                                          socketProvider.sendMessageWithFraming([2]);
                                        },
                                        child: Text('RESET APP', style: myTheme.textTheme?.displaySmall),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ),
        ],
      ),
    );
  }
}
