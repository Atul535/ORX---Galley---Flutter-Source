import 'dart:collection';

import 'package:flutter/material.dart';

import '../model/theme/item_theme.dart';
import '../model/theme/my_tabbar_theme.dart';

typedef StateThemeMap = SplayTreeMap<int, ItemTheme>;

class CustomTheme extends ChangeNotifier {
  String? id;
  String name;
  Brightness? brightness;
  Color? canvasColor;
  Color? primaryColor;
  Color? highlightColor;
  AppBarTheme? appBarTheme;
  MyTabBarTheme? tabBarTheme;
  ElevatedButtonThemeData? elevatedButtonThemeData;
  TextTheme? textTheme;
  String? backgroundImagePath;
  ItemTheme? menuItemThemeActive;
  ItemTheme? menuItemThemeInactive;
  ItemTheme? selectionItemThemeActive;
  ItemTheme? selectionItemThemeInactive;
  ItemTheme? baseThemeActive;
  ItemTheme? baseThemeInactive;
  Map<String, StateThemeMap>? customItemThemes;
  SliderThemeData? bargraphTheme;
  bool? isActive;
  Color? overlayColor;
  Color? selectionTextOverlayColor;
  Color? pullupTabColor;
  List<BoxShadow> pullupTabShadow;
  Color? pullupBackgroundColor;
  List<BoxShadow> pullupBackgroundShadow;
  BorderRadius pullupTabBorderRadius;
  Color? pullupTabTextColor;
  double pullupTabHeight;
  double pullupTabElevation;
  String? fontFamily;

  CustomTheme({
    this.id,
    required this.name,
    this.brightness,
    this.canvasColor,
    this.primaryColor,
    this.highlightColor,
    this.appBarTheme,
    this.tabBarTheme,
    this.elevatedButtonThemeData,
    this.fontFamily,
    this.textTheme,
    this.backgroundImagePath,
    this.menuItemThemeActive,
    this.menuItemThemeInactive,
    this.selectionItemThemeActive,
    this.selectionItemThemeInactive,
    this.baseThemeActive,
    this.baseThemeInactive,
    this.bargraphTheme,
    this.overlayColor,
    this.selectionTextOverlayColor = Colors.transparent,
    this.isActive = false,
    this.pullupTabColor,
    this.pullupBackgroundColor,
    this.pullupTabBorderRadius = BorderRadius.zero,
    this.pullupTabTextColor = Colors.white30,
    this.pullupTabHeight = 100,
    this.pullupTabElevation = 0,
    this.pullupTabShadow = const [BoxShadow(color: Colors.black26, blurRadius: 3, spreadRadius: 1, offset: Offset(0, -1))],
    this.pullupBackgroundShadow = const [BoxShadow(color: Colors.black26, blurRadius: 3, spreadRadius: 1, offset: Offset(0, -1))],
    this.customItemThemes,
  }) {
    id ??= UniqueKey().toString();
  }

  void setBackgroundImagePath(String value) {
    backgroundImagePath = value;
    notifyListeners();
  }

  ItemTheme resolveSelectionTheme({
    required int state,
    String? themeKey,
    StateThemeMap? override, // když widget pošle vlastní mapu
  }) {
    // 0) override z widgetu má nejvyšší prioritu
    final StateThemeMap? map = override ?? (themeKey == null ? null : customItemThemes?[themeKey]);

    if (map == null || map.isEmpty) {
      // fallback na původní chování
      final isActive = state == 1;
      return (isActive ? selectionItemThemeActive : selectionItemThemeInactive) ??
          (isActive ? baseThemeActive : baseThemeInactive) ??
          ItemTheme(id: id ?? ''); // poslední fallback, ať to nikdy nespadne
    }

    // 1) exact match
    final exact = map[state];
    if (exact != null) return exact;

    // 2) floor match (nejvyšší key <= state)
    ItemTheme? floorTheme;
    for (final k in map.keys) {
      if (k <= state) {
        floorTheme = map[k];
      } else {
        break;
      }
    }
    if (floorTheme != null) return floorTheme;

    // 3) state je menší než nejnižší -> použij nejnižší
    return map[map.firstKey()]!;
  }
}

class CustomThemes with ChangeNotifier {
  CustomThemes() {
    setActiveTheme('0');
  }
  final List<CustomTheme> _customThemes = [
    CustomTheme(
        id: '0',
        name: 'beige light',
        isActive: true,
        fontFamily: 'Montserrat', //'PoiretOne'
        selectionTextOverlayColor: Colors.transparent,
        overlayColor: Colors.black.withOpacity(0.3),
        backgroundImagePath: "assets/wallpaper0_3.png",
        brightness: Brightness.dark,
        canvasColor: const Color(0xff262626).withOpacity(0.0),
        primaryColor: Color.fromARGB(255, 255, 211, 164).withOpacity(0.0),
        highlightColor: Colors.brown.shade100,
        appBarTheme: const AppBarTheme(
          elevation: 30,
          backgroundColor: Color(0xAAbfb8af),
          toolbarHeight: 50,
          titleSpacing: 30,
          iconTheme: IconThemeData(
            size: 30,
            color: Colors.black,
          ),
          titleTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonThemeData: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            visualDensity: VisualDensity.comfortable,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 50.0, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 2, color: Colors.black, offset: Offset(0, 1))]),
          bodyMedium: TextStyle(
              // standard text on body
              fontSize: 40.0,
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                // Shadow(
                //   blurRadius: 1,
                //   color: Colors.black87,
                //   offset: Offset(0, 0),
                // )
              ]), // Regular Text eve// for large text on appBar
          bodySmall: TextStyle(
            fontSize: 30.0,
            fontFamily: 'Montserrat',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          labelLarge: TextStyle(
            fontSize: 35.0,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            // shadows: [
            //   Shadow(blurRadius: 1, color: Colors.black87, offset: Offset(0, 1)),
            // ],
          ),
          labelMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          labelSmall: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ), // for button text
          displayLarge: TextStyle(fontFamily: 'Montserrat', fontSize: 50.0, fontWeight: FontWeight.bold, color: Color(0xff666666)),
          displayMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          displaySmall: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 75.0,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 55.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleSmall: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 45.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 55.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontSize: 45.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: Colors.white,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 35.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        baseThemeActive: ItemTheme(
          id: '0',
          backroundColor: const Color(0xff171515),
          shadow: const <Shadow>[
            Shadow(
              // color: Color(0xffd35400),
              color: Color.fromARGB(255, 68, 34, 12),
              blurRadius: 10.0,
              // offset: Offset.fromDirection(0),
            ),
          ],
          symbolColor: Color.fromARGB(237, 247, 215, 167),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0xffd35400),
              spreadRadius: 2,
              blurRadius: 25,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        baseThemeInactive: ItemTheme(
          id: '0',
          // backroundColor: const Color(0xff171515),
          backroundColor: Colors.white,
          shadow: const <Shadow>[
            Shadow(
              // color: Color(0xffd35400),
              blurRadius: 30.0,
              // offset: Offset.fromDirection(0),
            ),
          ],
          symbolColor: Color.fromARGB(255, 131, 101, 66),
          // symbolColor: const Color(0xff666666),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        menuItemThemeActive: ItemTheme(
          id: '0',
          backroundColor: const Color.fromARGB(255, 36, 17, 2).withOpacity(0.3),
          border: Border.all(width: 1, color: const Color(0xffd35400)),
          shadow: const <Shadow>[
            Shadow(
              color: Color.fromARGB(255, 114, 63, 30),
              blurRadius: 60.0,
              offset: Offset(0, 1),
            ),
          ],
          symbolColor: Color.fromARGB(237, 247, 215, 167),
          boxShadow: const <BoxShadow>[
            // BoxShadow(
            //     color: Colors.black26,
            //     blurRadius: 5,
            //     spreadRadius: 2,
            //     offset: Offset(0, 1)),
          ],
        ),
        menuItemThemeInactive: ItemTheme(
          id: '0',
          border: Border.all(width: 1, color: Colors.white12),
          // backroundColor: Color.fromARGB(255, 128, 128, 128).withOpacity(0.2),
          // backroundColor: Color.fromARGB(255, 0, 113, 96).withOpacity(0.4),
          shadow: const <Shadow>[
            Shadow(
              color: Color.fromARGB(255, 45, 45, 45),
              blurRadius: 20.0,
              // offset: Offset.fromDirection(0),
            ),
          ],
          symbolColor: const Color.fromARGB(255, 197, 197, 197),
          boxShadow: <BoxShadow>[
            // const BoxShadow(
            //     color: Colors.black12,
            //     blurRadius: 5,
            //     spreadRadius: 2,
            //     offset: Offset(0, 1)),
          ],
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEBEBF4).withAlpha(20),
              const Color(0xFFF4F4F4).withAlpha(80),
              const Color(0xFFEBEBF4).withAlpha(20),
            ],
            stops: const [
              0.1,
              0.5,
              0.51,
            ],
            begin: const Alignment(0.0, -0.8),
            end: const Alignment(0.0, 1.0),
            // begin: Alignment(1.2, -1.2),
            // end: Alignment(1.6, 0.7),
            tileMode: TileMode.clamp,
          ),
        ),
        selectionItemThemeActive: ItemTheme(
          id: '0',
          // borderRadius: BorderRadius.circular(12),
          textShadows: <Shadow>[const Shadow(blurRadius: 2, color: Color.fromARGB(255, 125, 90, 53), offset: Offset(0, 1))],
          // backroundColor: Color.fromARGB(255, 255, 227, 190).withOpacity(0.3),
          border: Border.all(width: 2, color: const Color.fromARGB(255, 255, 231, 209)),
          // border: Border.all(width: 1, color: Color.fromARGB(255, 255, 231, 209)),
          // shadow: const <Shadow>[
          //   Shadow(
          //     color: Color.fromARGB(255, 129, 88, 49),
          //     blurRadius: 60.0,
          //     offset: Offset(0, 1),
          //   ),
          // ],
          symbolColor: Color.fromARGB(255, 255, 211, 164),
          // symbolColor: Color.fromARGB(255, 255, 205, 159),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color.fromARGB(100, 255, 211, 164),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 0), // changes position of shadow
            ),
            // BoxShadow(color: Color.fromARGB(64, 255, 205, 158), blurRadius: 5, spreadRadius: 2, offset: Offset(0, 1)),
          ],
          // lets add gradient radial from the center simulating a glow effect
          // gradient: RadialGradient(
          //   center: Alignment.center,
          //   radius: 0.8,
          //   colors: [
          //     Color.fromARGB(255, 255, 220, 184).withOpacity(0.8),
          //     Color.fromARGB(255, 255, 220, 184).withOpacity(0.15),
          //     Color.fromARGB(255, 255, 255, 255).withOpacity(0.0),
          //   ],
          //   stops: [0.0, 0.3,0.5],
          // ),
        ),
        selectionItemThemeInactive: ItemTheme(
          id: '0',
          // borderRadius: BorderRadius.circular(12),
          textShadows: <Shadow>[const Shadow(blurRadius: 1, color: Colors.black, offset: Offset(0, 1))],
          // border: Border.all(width: 1, color: Colors.white54),
          // backroundColor: Color.fromARGB(255, 128, 128, 128).withOpacity(0.2),
          // backroundColor: Color.fromARGB(255, 0, 113, 96).withOpacity(0.4),
          shadow: const <Shadow>[
            // Shadow(
            //   color: Color.fromARGB(255, 45, 45, 45),
            //   blurRadius: 20.0,
            //   // offset: Offset.fromDirection(0),
            // ),
          ],
          symbolColor: Color.fromARGB(255, 255, 255, 255),
          boxShadow: <BoxShadow>[
            // BoxShadow(
            //   color: Colors.grey.shade700,
            //   spreadRadius: 1,
            //   blurRadius: 1,
            //   offset: Offset(0, 0), // changes position of shadow
            // ),
            // const BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 2, offset: Offset(0, 1)),
          ],
          // gradient: LinearGradient(
          //   colors: [
          //     const Color(0xFFEBEBF4).withAlpha(20),
          //     const Color(0xFFF4F4F4).withAlpha(80),
          //     const Color(0xFFEBEBF4).withAlpha(20),
          //   ],
          //   stops: const [
          //     0.1,
          //     0.5,
          //     0.51,
          //   ],
          //   begin: const Alignment(0.5, -0.8),
          //   end: const Alignment(0.5, 1.0),
          //   // begin: Alignment(1.2, -1.2),
          //   // end: Alignment(1.6, 0.7),
          //   tileMode: TileMode.clamp,
          // ),
        ),
        customItemThemes: {
          'simpleButton': SplayTreeMap<int, ItemTheme>.from({
            1: ItemTheme(
              id: '0',
              // borderRadius: BorderRadius.circular(12),
              textShadows: <Shadow>[const Shadow(blurRadius: 4, color: Color.fromARGB(255, 72, 43, 12), offset: Offset(0, 0))],
              backroundColor: Color.fromARGB(255, 255, 214, 159).withOpacity(0.5),
              border: Border.all(width: 1, color: const Color.fromARGB(255, 255, 231, 209)),
              // border: Border.all(width: 1, color: Color.fromARGB(255, 255, 231, 209)),
              shadow: const <Shadow>[
                Shadow(
                  color: Color.fromARGB(255, 10, 5, 1),
                  blurRadius: 20.0,
                  offset: Offset(0, 2),
                ),
              ],
              symbolColor: Color.fromARGB(255, 255, 248, 240),
              // symbolColor: Color.fromARGB(255, 255, 205, 159),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color.fromARGB(100, 255, 211, 164),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 0), // changes position of shadow
                ),
                // BoxShadow(color: Color.fromARGB(64, 255, 205, 158), blurRadius: 5, spreadRadius: 2, offset: Offset(0, 1)),
              ],
              // lets add gradient radial from the center simulating a glow effect
              // gradient: RadialGradient(
              //   center: Alignment.center,
              //   radius: 0.8,
              //   colors: [
              //     Color.fromARGB(255, 255, 220, 184).withOpacity(0.8),
              //     Color.fromARGB(255, 255, 220, 184).withOpacity(0.15),
              //     Color.fromARGB(255, 255, 255, 255).withOpacity(0.0),
              //   ],
              //   stops: [0.0, 0.3,0.5],
              // ),
            ),
            0: ItemTheme(
              id: '0',
              // borderRadius: BorderRadius.circular(12),
              textShadows: <Shadow>[const Shadow(blurRadius: 3, color: Colors.black, offset: Offset(0, 0))],
              border: Border.all(width: 1, color: Colors.white54),
              backroundColor: Color.fromARGB(255, 128, 128, 128).withOpacity(0.8),
              // backroundColor: Color.fromARGB(255, 0, 113, 96).withOpacity(0.4),
              shadow: const <Shadow>[
                Shadow(
                  color: Color.fromARGB(255, 45, 45, 45),
                  blurRadius: 10.0,
                  // offset: Offset.fromDirection(0),
                ),
              ],
              symbolColor: Color.fromARGB(255, 255, 255, 255),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color.fromARGB(255, 0, 0, 0),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2), // changes position of shadow
                ),
              ],
              // gradient: LinearGradient(
              //   colors: [
              //     const Color(0xFFEBEBF4).withAlpha(20),
              //     const Color(0xFFF4F4F4).withAlpha(80),
              //     const Color(0xFFEBEBF4).withAlpha(20),
              //   ],
              //   stops: const [
              //     0.1,
              //     0.5,
              //     0.51,
              //   ],
              //   begin: const Alignment(0.5, -0.8),
              //   end: const Alignment(0.5, 1.0),
              //   // begin: Alignment(1.2, -1.2),
              //   // end: Alignment(1.6, 0.7),
              //   tileMode: TileMode.clamp,
              // ),
            ),
          }),
          'simpleButton2': SplayTreeMap<int, ItemTheme>.from({
            1: ItemTheme(
              id: '0',
              borderRadius: BorderRadius.circular(12),
              textShadows: <Shadow>[const Shadow(blurRadius: 4, color: Color.fromARGB(255, 72, 43, 12), offset: Offset(0, 0))],
              backroundColor: Color.fromARGB(255, 255, 214, 159).withOpacity(0.8),
              gradient: LinearGradient(
                begin: const Alignment(-0.6, -0.8),
                end: const Alignment(0.7, 0.9),
                colors: _getColorsForGradident(Color.fromARGB(169, 255, 213, 159), true),
                stops: const [0.0, 0.55, 1.0],
              ),

              border: Border.all(width: 1, color: const Color.fromARGB(255, 255, 231, 209)),
              // border: Border.all(width: 1, color: Color.fromARGB(255, 255, 231, 209)),
              shadow: const <Shadow>[
                Shadow(
                  color: Color.fromARGB(255, 79, 39, 7),
                  blurRadius: 5.0,
                  offset: Offset(0, 0),
                ),
              ],

              symbolColor: Color.fromARGB(255, 255, 248, 240),
              // symbolColor: Color.fromARGB(255, 255, 205, 159),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color.fromARGB(152, 138, 77, 11),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1), // changes position of shadow
                ),
                // BoxShadow(color: Color.fromARGB(64, 255, 205, 158), blurRadius: 5, spreadRadius: 2, offset: Offset(0, 1)),
              ],
              // lets add gradient radial from the center simulating a glow effect
              // gradient: RadialGradient(
              //   center: Alignment.center,
              //   radius: 0.8,
              //   colors: [
              //     Color.fromARGB(255, 255, 220, 184).withOpacity(0.8),
              //     Color.fromARGB(255, 255, 220, 184).withOpacity(0.15),
              //     Color.fromARGB(255, 255, 255, 255).withOpacity(0.0),
              //   ],
              //   stops: [0.0, 0.3,0.5],
              // ),
            ),
            0: ItemTheme(
              id: '0',
              borderRadius: BorderRadius.circular(12),
              textShadows: <Shadow>[const Shadow(blurRadius: 3, color: Colors.black, offset: Offset(0, 0))],
              border: Border.all(width: 1, color: Colors.white54),
              backroundColor: Color.fromARGB(255, 128, 128, 128).withOpacity(0.8),
              gradient: LinearGradient(
                begin: const Alignment(-0.6, -0.8),
                end: const Alignment(0.7, 0.9),
                colors: _getColorsForGradident(Color.fromARGB(171, 255, 255, 255), false),
                stops: const [0.0, 0.55, 1.0],
              ),
              shadow: const <Shadow>[
                Shadow(
                  color: Color.fromARGB(255, 45, 45, 45),
                  blurRadius: 5.0,
                  // offset: Offset.fromDirection(0),
                ),
              ],
              symbolColor: Color.fromARGB(255, 255, 255, 255),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color.fromARGB(153, 0, 0, 0),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              // gradient: LinearGradient(
              //   colors: [
              //     const Color(0xFFEBEBF4).withAlpha(20),
              //     const Color(0xFFF4F4F4).withAlpha(80),
              //     const Color(0xFFEBEBF4).withAlpha(20),
              //   ],
              //   stops: const [
              //     0.1,
              //     0.5,
              //     0.51,
              //   ],
              //   begin: const Alignment(0.5, -0.8),
              //   end: const Alignment(0.5, 1.0),
              //   // begin: Alignment(1.2, -1.2),
              //   // end: Alignment(1.6, 0.7),
              //   tileMode: TileMode.clamp,
              // ),
            ),
          }),
          'indicator': SplayTreeMap<int, ItemTheme>.from({
            1: ItemTheme(
              id: '0',
              textShadows: <Shadow>[const Shadow(blurRadius: 2, color: Color.fromARGB(255, 125, 90, 53), offset: Offset(0, 1))],
              border: Border.all(width: 2, color: Color.fromARGB(255, 222, 222, 222)),
              symbolColor: Color.fromARGB(255, 255, 211, 164),
              // symbolColor: Color.fromARGB(255, 255, 205, 159),
              // gradient: RadialGradient(
              //   center: const Alignment(-0.25, -0.35), // lehce k horní levé
              //   radius: 0.95,
              //   colors: [
              //     Colors.white.withOpacity(0.55), // "hot spot"
              //     Colors.green.withOpacity(0.95),
              //     Colors.green.withOpacity(0.85),
              //   ],
              //   stops: const [0.0, 0.45, 1.0],
              // ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color.fromARGB(99, 255, 250, 245),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 0), // changes position of shadow
                ),
              ],
            ),
            0: ItemTheme(
              id: '0',
              textShadows: <Shadow>[const Shadow(blurRadius: 2, color: Color.fromARGB(255, 125, 90, 53), offset: Offset(0, 1))],
              border: Border.all(width: 2, color: Color.fromARGB(255, 222, 222, 222)),
              symbolColor: Color.fromARGB(255, 255, 211, 164),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color.fromARGB(99, 255, 250, 245),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 0), // changes position of shadow
                ),
              ],
            ),
          }),
          'indicator2': SplayTreeMap<int, ItemTheme>.from({
            1: ItemTheme(
              id: '0',
              textShadows: <Shadow>[const Shadow(blurRadius: 2, color: Color.fromARGB(255, 125, 90, 53), offset: Offset(0, 1))],
              border: Border.all(width: 2, color: Color.fromARGB(255, 222, 222, 222)),
              symbolColor: Color.fromARGB(255, 255, 211, 164),
              gradient: LinearGradient(
                begin: const Alignment(-0.6, -0.8),
                end: const Alignment(0.7, 0.9),
                colors: _getColorsForGradident(Color.fromARGB(255, 30, 255, 0), true),
                stops: const [0.0, 0.55, 1.0],
              ),
              // symbolColor: Color.fromARGB(255, 255, 205, 159),
              // gradient: RadialGradient(
              //   center: const Alignment(-0.25, -0.35), // lehce k horní levé
              //   radius: 0.95,
              //   colors: [
              //     Colors.white.withOpacity(0.55), // "hot spot"
              //     Colors.green.withOpacity(0.95),
              //     Colors.green.withOpacity(0.85),
              //   ],
              //   stops: const [0.0, 0.45, 1.0],
              // ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color.fromARGB(99, 255, 250, 245),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 0), // changes position of shadow
                ),
              ],
            ),
            0: ItemTheme(
              id: '0',
              textShadows: <Shadow>[const Shadow(blurRadius: 2, color: Color.fromARGB(255, 125, 90, 53), offset: Offset(0, 1))],
              border: Border.all(width: 2, color: Color.fromARGB(255, 137, 137, 137)),
              symbolColor: Color.fromARGB(255, 255, 211, 164),
              gradient: LinearGradient(
                begin: const Alignment(-0.6, -0.8),
                end: const Alignment(0.7, 0.9),
                colors: _getColorsForGradident(Color.fromARGB(255, 81, 81, 81), true),
                stops: const [0.0, 0.55, 1.0],
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color.fromARGB(255, 0, 0, 0),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 0), // changes position of shadow
                ),
              ],
            ),
            2: ItemTheme(
              id: '0',
              textShadows: <Shadow>[const Shadow(blurRadius: 2, color: Color.fromARGB(255, 125, 90, 53), offset: Offset(0, 1))],
              border: Border.all(width: 2, color: Color.fromARGB(255, 222, 222, 222)),
              symbolColor: Color.fromARGB(255, 255, 211, 164),
              gradient: LinearGradient(
                begin: const Alignment(-0.6, -0.8),
                end: const Alignment(0.7, 0.9),
                colors: _getColorsForGradident(Color.fromARGB(255, 255, 213, 74), true),
                stops: const [0.0, 0.55, 1.0],
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color.fromARGB(99, 255, 250, 245),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 0), // changes position of shadow
                ),
              ],
            ),
          }),
          'indicator3': SplayTreeMap<int, ItemTheme>.from({
            1: ItemTheme(
              id: '0',
              textShadows: <Shadow>[const Shadow(blurRadius: 2, color: Color.fromARGB(255, 125, 90, 53), offset: Offset(0, 1))],
              border: Border.all(width: 2, color: Color.fromARGB(255, 222, 222, 222)),
              symbolColor: Color.fromARGB(255, 255, 211, 164),
              gradient: LinearGradient(
                begin: const Alignment(-0.6, -0.8),
                end: const Alignment(0.7, 0.9),
                colors: _getColorsForGradident(Color.fromARGB(255, 255, 0, 55), true),
                stops: const [0.0, 0.55, 1.0],
              ),
              // symbolColor: Color.fromARGB(255, 255, 205, 159),
              // gradient: RadialGradient(
              //   center: const Alignment(-0.25, -0.35), // lehce k horní levé
              //   radius: 0.95,
              //   colors: [
              //     Colors.white.withOpacity(0.55), // "hot spot"
              //     Colors.green.withOpacity(0.95),
              //     Colors.green.withOpacity(0.85),
              //   ],
              //   stops: const [0.0, 0.45, 1.0],
              // ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color.fromARGB(99, 255, 250, 245),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 0), // changes position of shadow
                ),
              ],
            ),
            0: ItemTheme(
              id: '0',
              textShadows: <Shadow>[const Shadow(blurRadius: 2, color: Color.fromARGB(255, 125, 90, 53), offset: Offset(0, 1))],
              border: Border.all(width: 2, color: Color.fromARGB(255, 137, 137, 137)),
              symbolColor: Color.fromARGB(255, 255, 211, 164),
              gradient: LinearGradient(
                begin: const Alignment(-0.6, -0.8),
                end: const Alignment(0.7, 0.9),
                colors: _getColorsForGradident(Color.fromARGB(255, 81, 81, 81), true),
                stops: const [0.0, 0.55, 1.0],
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color.fromARGB(255, 0, 0, 0),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 0), // changes position of shadow
                ),
              ],
            ),
            2: ItemTheme(
              id: '0',
              textShadows: <Shadow>[const Shadow(blurRadius: 2, color: Color.fromARGB(255, 125, 90, 53), offset: Offset(0, 1))],
              border: Border.all(width: 2, color: Color.fromARGB(255, 222, 222, 222)),
              symbolColor: Color.fromARGB(255, 255, 211, 164),
              gradient: LinearGradient(
                begin: const Alignment(-0.6, -0.8),
                end: const Alignment(0.7, 0.9),
                colors: _getColorsForGradident(Color.fromARGB(255, 255, 213, 74), true),
                stops: const [0.0, 0.55, 1.0],
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color.fromARGB(99, 255, 250, 245),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 0), // changes position of shadow
                ),
              ],
            ),
          }),
        },
        tabBarTheme: MyTabBarTheme(
          indicatorColor: Color.fromARGB(255, 255, 211, 164),
          unselectedLabelColor: Color.fromARGB(255, 228, 228, 228),
          labelColor: Color.fromARGB(255, 255, 211, 164),
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontSize: 27),
          indicatorWeight: 3,
          // tabColor: Colors.grey.shade700.withOpacity(0.2),
          tabColor: Colors.black26.withOpacity(0.3),
        ),
        bargraphTheme: SliderThemeData(
          showValueIndicator: ShowValueIndicator.never,
          trackHeight: 10.0,
          // trackShape: const RoundedRectSliderTrackShape(),
          trackShape: const RoundedRectSliderTrackShape(),
          activeTrackColor: Color.fromARGB(255, 255, 211, 164),
          inactiveTrackColor: Colors.white54,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 20.0, pressedElevation: 8.0, elevation: 5.0),
          thumbColor: Color.fromARGB(255, 225, 179, 129),
          overlayColor: Color.fromARGB(255, 255, 211, 164).withOpacity(0.4),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 40.0),
          tickMarkShape: const RoundSliderTickMarkShape(),
          activeTickMarkColor: Colors.transparent,
          inactiveTickMarkColor: Colors.transparent,
          valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
          valueIndicatorColor: Colors.black,
          valueIndicatorTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
        pullupTabColor: Colors.grey.shade800.withOpacity(0.9),
        pullupBackgroundColor: Colors.grey.shade800,
        pullupTabBorderRadius: const BorderRadius.vertical(
          top: Radius.circular(5),
        ),
        pullupTabTextColor: Colors.grey.shade400,
        pullupTabHeight: 105,
        pullupTabElevation: 20),
    CustomTheme(
        id: '',
        name: 'dark',
        isActive: true,
        fontFamily: 'Montserrat', //'PoiretOne'
        selectionTextOverlayColor: Colors.transparent,
        overlayColor: Colors.black.withOpacity(0.3),
        backgroundImagePath: "assets/wallpaper0_1.png",
        brightness: Brightness.dark,
        canvasColor: const Color(0xff262626).withOpacity(0.0),
        primaryColor: const Color(0xDDbfb8af),
        highlightColor: Colors.brown.shade100,
        appBarTheme: const AppBarTheme(
          elevation: 30,
          backgroundColor: Color(0xAAbfb8af),
          toolbarHeight: 50,
          titleSpacing: 30,
          iconTheme: IconThemeData(
            size: 30,
            color: Colors.black,
          ),
          titleTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevatedButtonThemeData: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            visualDensity: VisualDensity.comfortable,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 50.0, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 2, color: Colors.black, offset: Offset(0, 1))]),
          bodyMedium: TextStyle(
              // standard text on body
              fontSize: 40.0,
              fontFamily: 'Montserrat',
              color: Colors.black,
              fontWeight: FontWeight.bold,
              shadows: [
                // Shadow(
                //   blurRadius: 1,
                //   color: Colors.black87,
                //   offset: Offset(0, 0),
                // )
              ]), // Regular Text eve// for large text on appBar
          bodySmall: TextStyle(
            fontSize: 30.0,
            fontFamily: 'Montserrat',
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          labelLarge: TextStyle(
            fontSize: 35.0,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.black,
            // shadows: [
            //   Shadow(blurRadius: 1, color: Colors.black87, offset: Offset(0, 1)),
            // ],
          ),
          labelMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          labelSmall: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ), // for button text
          displayLarge: TextStyle(fontFamily: 'Montserrat', fontSize: 50.0, fontWeight: FontWeight.bold, color: Color(0xff666666)),
          displayMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          displaySmall: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 75.0,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 55.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          titleSmall: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 45.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 55.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          headlineMedium: TextStyle(
            fontSize: 45.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: Colors.black,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 35.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        baseThemeActive: ItemTheme(
          id: '0',
          backroundColor: const Color(0xff171515),
          shadow: const <Shadow>[
            Shadow(
              // color: Color(0xffd35400),
              color: Color.fromARGB(255, 68, 34, 12),
              blurRadius: 10.0,
              // offset: Offset.fromDirection(0),
            ),
          ],
          symbolColor: Color.fromARGB(237, 247, 215, 167),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0xffd35400),
              spreadRadius: 2,
              blurRadius: 25,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        baseThemeInactive: ItemTheme(
          id: '0',
          // backroundColor: const Color(0xff171515),
          backroundColor: Colors.white,
          shadow: const <Shadow>[
            Shadow(
              // color: Color(0xffd35400),
              blurRadius: 30.0,
              // offset: Offset.fromDirection(0),
            ),
          ],
          symbolColor: Color.fromARGB(255, 131, 101, 66),
          // symbolColor: const Color(0xff666666),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        menuItemThemeActive: ItemTheme(
          id: '0',
          backroundColor: const Color.fromARGB(255, 36, 17, 2).withOpacity(0.3),
          border: Border.all(width: 1, color: const Color(0xffd35400)),
          shadow: const <Shadow>[
            Shadow(
              color: Color.fromARGB(255, 114, 63, 30),
              blurRadius: 60.0,
              offset: Offset(0, 1),
            ),
          ],
          symbolColor: Color.fromARGB(237, 247, 215, 167),
          boxShadow: const <BoxShadow>[
            // BoxShadow(
            //     color: Colors.black26,
            //     blurRadius: 5,
            //     spreadRadius: 2,
            //     offset: Offset(0, 1)),
          ],
        ),
        menuItemThemeInactive: ItemTheme(
          id: '0',
          border: Border.all(width: 1, color: Colors.white12),
          // backroundColor: Color.fromARGB(255, 128, 128, 128).withOpacity(0.2),
          // backroundColor: Color.fromARGB(255, 0, 113, 96).withOpacity(0.4),
          shadow: const <Shadow>[
            Shadow(
              color: Color.fromARGB(255, 45, 45, 45),
              blurRadius: 20.0,
              // offset: Offset.fromDirection(0),
            ),
          ],
          symbolColor: const Color.fromARGB(255, 197, 197, 197),
          boxShadow: <BoxShadow>[
            // const BoxShadow(
            //     color: Colors.black12,
            //     blurRadius: 5,
            //     spreadRadius: 2,
            //     offset: Offset(0, 1)),
          ],
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEBEBF4).withAlpha(20),
              const Color(0xFFF4F4F4).withAlpha(80),
              const Color(0xFFEBEBF4).withAlpha(20),
            ],
            stops: const [
              0.1,
              0.5,
              0.51,
            ],
            begin: const Alignment(0.0, -0.8),
            end: const Alignment(0.0, 1.0),
            // begin: Alignment(1.2, -1.2),
            // end: Alignment(1.6, 0.7),
            tileMode: TileMode.clamp,
          ),
        ),
        selectionItemThemeActive: ItemTheme(
          id: '0',
          // textShadows: <Shadow>[const Shadow(blurRadius: 2, color: Colors.black, offset: Offset(0, 0))],
          backroundColor: Color.fromARGB(255, 255, 227, 190).withOpacity(0.3),
          border: Border.all(width: 1, color: Color.fromARGB(255, 255, 231, 209)),
          shadow: const <Shadow>[
            Shadow(
              color: Color.fromARGB(255, 255, 220, 187),
              blurRadius: 60.0,
              offset: Offset(0, 1),
            ),
          ],
          symbolColor: Color.fromARGB(255, 76, 76, 76),
          // symbolColor: Color.fromARGB(255, 255, 205, 159),
          boxShadow: const <BoxShadow>[
            // BoxShadow(
            //   color: Color(0xffd35400),
            //   spreadRadius: 1,
            //   blurRadius: 2,
            //   offset: Offset(0, 1), // changes position of shadow
            // ),
            BoxShadow(color: Color.fromARGB(255, 243, 187, 135), blurRadius: 5, spreadRadius: 2, offset: Offset(0, 1)),
          ],
        ),
        selectionItemThemeInactive: ItemTheme(
          id: '0',
          // textShadows: <Shadow>[const Shadow(blurRadius: 1, color: Colors.black, offset: Offset(0, 1))],
          border: Border.all(width: 1, color: Colors.white54),
          // backroundColor: Color.fromARGB(255, 128, 128, 128).withOpacity(0.2),
          // backroundColor: Color.fromARGB(255, 0, 113, 96).withOpacity(0.4),
          shadow: const <Shadow>[
            // Shadow(
            //   color: Color.fromARGB(255, 45, 45, 45),
            //   blurRadius: 20.0,
            //   // offset: Offset.fromDirection(0),
            // ),
          ],
          symbolColor: Color.fromARGB(255, 76, 76, 76),
          boxShadow: <BoxShadow>[
            // BoxShadow(
            //   color: Colors.grey.shade700,
            //   spreadRadius: 1,
            //   blurRadius: 1,
            //   offset: Offset(0, 0), // changes position of shadow
            // ),
            // const BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 2, offset: Offset(0, 1)),
          ],
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEBEBF4).withAlpha(20),
              const Color(0xFFF4F4F4).withAlpha(80),
              const Color(0xFFEBEBF4).withAlpha(20),
            ],
            stops: const [
              0.1,
              0.5,
              0.51,
            ],
            begin: const Alignment(0.5, -0.8),
            end: const Alignment(0.5, 1.0),
            // begin: Alignment(1.2, -1.2),
            // end: Alignment(1.6, 0.7),
            tileMode: TileMode.clamp,
          ),
        ),
        tabBarTheme: MyTabBarTheme(
          indicatorColor: const Color.fromARGB(255, 237, 109, 24),
          unselectedLabelColor: Colors.grey,
          labelColor: const Color.fromARGB(255, 254, 177, 22),
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontSize: 27, fontWeight: FontWeight.w500),
          indicatorWeight: 3,
          // tabColor: Colors.grey.shade700.withOpacity(0.2),
          tabColor: Colors.black26.withOpacity(0.1),
        ),
        bargraphTheme: SliderThemeData(
          showValueIndicator: ShowValueIndicator.never,
          trackHeight: 25.0,
          // trackShape: const RoundedRectSliderTrackShape(),
          trackShape: const RoundedRectSliderTrackShape(),
          activeTrackColor: Color.fromARGB(255, 255, 211, 164),
          inactiveTrackColor: Colors.white54,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 30.0, pressedElevation: 8.0, elevation: 5.0),
          thumbColor: Color.fromARGB(255, 225, 179, 129),
          overlayColor: Color.fromARGB(255, 255, 211, 164),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 70.0),
          tickMarkShape: const RoundSliderTickMarkShape(),
          activeTickMarkColor: Color.fromARGB(255, 255, 211, 164),
          inactiveTickMarkColor: Colors.white,
          valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
          valueIndicatorColor: Colors.black,
          valueIndicatorTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
        pullupTabColor: Colors.grey.shade800.withOpacity(0.9),
        pullupBackgroundColor: Colors.grey.shade800,
        pullupTabBorderRadius: const BorderRadius.vertical(
          top: Radius.circular(5),
        ),
        pullupTabTextColor: Colors.grey.shade400,
        pullupTabHeight: 105,
        pullupTabElevation: 20),
    // CustomTheme(
    //     id: '1',
    //     name: 'mavs',
    //     fontFamily: 'Montserrat',
    //     isActive: true,
    //     selectionTextOverlayColor: Colors.transparent,
    //     overlayColor: Colors.black.withOpacity(0.3),
    //     backgroundImagePath: "assets/mavs.png",
    //     brightness: Brightness.dark,
    //     canvasColor: const Color(0xff262626).withOpacity(0.0),
    //     primaryColor: Colors.white24,
    //     highlightColor: Color.fromARGB(255, 20, 49, 89),
    //     appBarTheme: const AppBarTheme(
    //       elevation: 10,
    //       backgroundColor: Color.fromARGB(200, 20, 48, 89),
    //       toolbarHeight: 50,
    //       titleSpacing: 30,
    //       iconTheme: IconThemeData(
    //         size: 30,
    //         color: Colors.white,
    //       ),
    //     ),
    //     elevatedButtonThemeData: ElevatedButtonThemeData(
    //       style: ElevatedButton.styleFrom(
    //         visualDensity: VisualDensity.comfortable,
    //         padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    //       ),
    //     ),
    //     textTheme: const TextTheme(
    //       bodyLarge: TextStyle(
    //           fontSize: 50.0,
    //           fontWeight: FontWeight.bold,
    //           shadows: [
    //             Shadow(blurRadius: 2, color: Colors.black, offset: Offset(0, 1))
    //           ]),
    //       bodyMedium: TextStyle(
    //           // standard text on body
    //           fontSize: 40.0,
    //           fontFamily: 'Montserrat',
    //           color: Color.fromARGB(255, 232, 232, 232),
    //           fontWeight: FontWeight.bold,
    //           shadows: [
    //             Shadow(
    //               blurRadius: 1,
    //               color: Colors.black87,
    //               offset: Offset(0, 0),
    //             )
    //           ]), // Regular Text eve// for large text on appBar
    //       bodySmall: TextStyle(
    //         fontSize: 30.0,
    //         fontFamily: 'Montserrat',
    //         fontWeight: FontWeight.bold,
    //       ),
    //       labelLarge: TextStyle(
    //           fontSize: 25.0,
    //           fontFamily: 'Montserrat',
    //           fontWeight: FontWeight.bold,
    //           shadows: [
    //             Shadow(
    //                 blurRadius: 1, color: Colors.black87, offset: Offset(0, 1))
    //           ]),
    //       labelMedium: TextStyle(
    //         fontSize: 20.0,
    //         fontWeight: FontWeight.bold,
    //       ),
    //       labelSmall: TextStyle(
    //         fontSize: 15.0,
    //         fontWeight: FontWeight.bold,
    //       ), // for button text
    //       displayLarge: TextStyle(
    //           fontSize: 50.0,
    //           fontWeight: FontWeight.bold,
    //           color: Color(0xff666666)),
    //       displayMedium: TextStyle(
    //         fontSize: 40.0,
    //         fontWeight: FontWeight.bold,
    //       ),
    //       displaySmall: TextStyle(
    //         fontSize: 30.0,
    //         fontWeight: FontWeight.bold,
    //       ),
    //       titleLarge: TextStyle(
    //           fontSize: 75.0,
    //           fontStyle: FontStyle.normal,
    //           fontWeight: FontWeight.bold,
    //           color: Color.fromARGB(255, 221, 221, 221)),
    //       titleMedium: TextStyle(
    //         fontSize: 55.0,
    //         fontWeight: FontWeight.bold,
    //       ),
    //       titleSmall: TextStyle(
    //         fontSize: 45.0,
    //         fontWeight: FontWeight.bold,
    //       ),
    //       headlineLarge: TextStyle(
    //         fontSize: 55.0,
    //         fontWeight: FontWeight.bold,
    //       ),
    //       headlineMedium:
    //           TextStyle(fontSize: 45.0, fontWeight: FontWeight.bold),
    //       headlineSmall: TextStyle(
    //         fontSize: 35.0,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     baseThemeActive: ItemTheme(
    //       id: '0',
    //       backroundColor: const Color(0xff171515),
    //       shadow: const <Shadow>[
    //         Shadow(
    //           // color: Color(0xffd35400),
    //           color: Color.fromARGB(255, 65, 26, 0),
    //           blurRadius: 10.0,
    //           // offset: Offset.fromDirection(0),
    //         ),
    //       ],
    //       symbolColor: const Color(0xffffa502),
    //       boxShadow: const <BoxShadow>[
    //         BoxShadow(
    //           color: Color(0xffd35400),
    //           spreadRadius: 2,
    //           blurRadius: 25,
    //           offset: Offset(0, 3), // changes position of shadow
    //         ),
    //       ],
    //     ),
    //     baseThemeInactive: ItemTheme(
    //       id: '0',
    //       // backroundColor: const Color(0xff171515),
    //       backroundColor: Colors.white,
    //       shadow: const <Shadow>[
    //         Shadow(
    //           // color: Color(0xffd35400),
    //           blurRadius: 30.0,
    //           // offset: Offset.fromDirection(0),
    //         ),
    //       ],
    //       symbolColor: Colors.white,
    //       // symbolColor: const Color(0xff666666),
    //       boxShadow: const <BoxShadow>[
    //         BoxShadow(
    //           color: Colors.black26,
    //           spreadRadius: 2,
    //           blurRadius: 4,
    //           offset: Offset(0, 0), // changes position of shadow
    //         ),
    //       ],
    //     ),
    //     menuItemThemeActive: ItemTheme(
    //       id: '0',
    //       backroundColor: Colors.white.withOpacity(0.4),
    //       border: Border.all(width: 10, color: Colors.white),
    //       shadow: const <Shadow>[],
    //       symbolColor: Color.fromARGB(255, 20, 49, 89),
    //       boxShadow: const <BoxShadow>[
    //         // BoxShadow(
    //         //     color: Colors.black26,
    //         //     blurRadius: 5,
    //         //     spreadRadius: 2,
    //         //     offset: Offset(0, 1)),
    //       ],
    //     ),
    //     menuItemThemeInactive: ItemTheme(
    //       id: '0',
    //       border: Border.all(width: 10, color: Color.fromARGB(255, 20, 49, 89)),
    //       // backroundColor: Color.fromARGB(255, 128, 128, 128).withOpacity(0.2),
    //       // backroundColor: Color.fromARGB(255, 0, 113, 96).withOpacity(0.4),
    //       shadow: const <Shadow>[
    //         Shadow(
    //           color: Color.fromARGB(255, 45, 45, 45),
    //           blurRadius: 15.0,
    //           // offset: Offset.fromDirection(0),
    //         ),
    //       ],
    //       symbolColor: Colors.white.withOpacity(0.8),
    //       boxShadow: <BoxShadow>[
    //         const BoxShadow(
    //             color: Colors.black26,
    //             blurRadius: 5,
    //             spreadRadius: 2,
    //             offset: Offset(0, 1)),
    //       ],
    //     ),
    //     selectionItemThemeActive: ItemTheme(
    //       id: '0',
    //       backroundColor: Colors.white.withOpacity(0.4),
    //       borderRadius: BorderRadius.circular(15),
    //       border: Border.all(width: 4, color: Colors.white),
    //       shadow: const <Shadow>[],
    //       symbolColor: Color.fromARGB(255, 20, 49, 89),
    //       boxShadow: const <BoxShadow>[],
    //     ),
    //     selectionItemThemeInactive: ItemTheme(
    //       id: '0',
    //       border: Border.all(width: 4, color: Color.fromARGB(255, 20, 49, 89)),
    //       borderRadius: BorderRadius.circular(10),
    //       backroundColor: Color.fromARGB(255, 20, 49, 89).withOpacity(0.1),
    //       shadow: const <Shadow>[
    //         Shadow(
    //           color: Color.fromARGB(255, 45, 45, 45),
    //           blurRadius: 15.0,
    //           // offset: Offset.fromDirection(0),
    //         ),
    //       ],
    //       symbolColor: Colors.white.withOpacity(0.8),
    //       boxShadow: <BoxShadow>[
    //         const BoxShadow(
    //             color: Colors.black26,
    //             blurRadius: 5,
    //             spreadRadius: 2,
    //             offset: Offset(0, 1)),
    //       ],
    //     ),
    //     tabBarTheme: MyTabBarTheme(
    //       indicatorColor: const Color.fromARGB(255, 237, 109, 24),
    //       unselectedLabelColor: Colors.grey,
    //       labelColor: const Color.fromARGB(255, 254, 177, 22),
    //       indicatorSize: TabBarIndicatorSize.tab,
    //       labelStyle:
    //           const TextStyle(fontSize: 27, fontWeight: FontWeight.w500),
    //       indicatorWeight: 3,
    //       // tabColor: Colors.grey.shade700.withOpacity(0.2),
    //       tabColor: Colors.black26.withOpacity(0.1),
    //     ),
    //     bargraphTheme: SliderThemeData(
    //       showValueIndicator: ShowValueIndicator.never,
    //       trackHeight: 12.0,
    //       // trackShape: const RoundedRectSliderTrackShape(),
    //       trackShape: const RoundedRectSliderTrackShape(),
    //       activeTrackColor: Colors.white,
    //       inactiveTrackColor: Color.fromARGB(255, 106, 126, 148),
    //       thumbShape: const RoundSliderThumbShape(
    //           enabledThumbRadius: 17.0, pressedElevation: 8.0, elevation: 5.0),
    //       thumbColor: Colors.grey.shade300,
    //       overlayColor: Colors.black54,
    //       overlayShape: const RoundSliderOverlayShape(overlayRadius: 32.0),
    //       tickMarkShape: const RoundSliderTickMarkShape(),
    //       activeTickMarkColor: Colors.transparent,
    //       inactiveTickMarkColor: Colors.transparent,
    //       valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
    //       valueIndicatorColor: Colors.black,
    //       valueIndicatorTextStyle: const TextStyle(
    //         color: Colors.white,
    //         fontSize: 20.0,
    //       ),
    //     ),
    //     pullupTabColor: Colors.grey.shade800.withOpacity(0.9),
    //     pullupBackgroundColor: Colors.grey.shade800,
    //     pullupTabBorderRadius: const BorderRadius.vertical(
    //       top: Radius.circular(5),
    //     ),
    //     pullupTabTextColor: Colors.grey.shade400,
    //     pullupTabHeight: 105,
    //     pullupTabElevation: 20),
  ];

// getter
  List<CustomTheme> get customThemes {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._customThemes];
  }

  void changeWallpaper(id, wallpaperPath) {
    for (var item in _customThemes) {
      if (item.id == id) item.setBackgroundImagePath(wallpaperPath);
    }
    notifyListeners();
  }

  void setActiveTheme(String id) {
    _clearActive();
    _customThemes.firstWhere((obj) => obj.id == id).isActive = true;
    notifyListeners();
  }

  void setActiveThemeByName(String name) {
    _clearActive();
    _customThemes.firstWhere((obj) => obj.name == name).isActive = true;
    notifyListeners();
  }

  void _clearActive() {
    _customThemes.firstWhere((obj) => obj.isActive == true).isActive = false;
  }

  CustomTheme getActiveTheme() {
    return _customThemes.firstWhere((obj) => obj.isActive == true);
  }

  String getActiveThemeName() {
    return _customThemes.firstWhere((obj) => obj.isActive == true).name.toString();
  }

  void addTheme(CustomTheme theme) {
    _customThemes.add(theme);
  }

  String addThemeGetId(CustomTheme theme) {
    _customThemes.add(theme);
    return theme.id.toString();
  }
}

Color _mix(Color a, Color b, double t) {
  return Color.lerp(a, b, t)!;
}

List<Color> _getColorsForGradident(Color base, bool isActive) {
  return [
    _mix(base, Colors.white, isActive ? 0.18 : 0.12),
    base,
    _mix(base, Colors.black, isActive ? 0.22 : 0.28),
  ];
}
