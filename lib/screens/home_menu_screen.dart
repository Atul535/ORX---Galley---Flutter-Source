import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/custom_theme_provider.dart';
import '../providers/settings_provider.dart';

import '../widgets/activity_detector.dart';
import '../widgets/cfg_image.dart';
import '../widgets/virtual_keyboard/type.dart';
import '../widgets/wallpaper.dart';

// Pokud máš PasswordProtectedScreen jinde, uprav import:
import 'base/password_protected_screen.dart';

// cílové screeny (routes):
import 'home_screen.dart'; // GLOBAL MENU (původní HomeScreen)
import 'screen_lounge.dart';
import 'screen_maintenance.dart'; // MAINTENANCE (tvůj MaintenanceScreen)

// ⚠️ pullupBody/pullupChild jsou ve tvém projektu nejspíš v nějakém helperu / widgetu
// sem dej správný import, kde máš pullupChild + pullupBody + PullupTab
import '../widgets/pullup_tab.dart'; // uprav dle reality (jen příklad)

class HomeMenuScreen extends StatelessWidget {
  static const routeName = '/app/home-menu';
  const HomeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    // ✅ LOPA image = úplně stejné jako v HomeScreen
    final String lopaImage = _getLopaImageSameAsHomeScreen(context, myTheme);

    return ActivityDetector(
      shouldNavigate: true,
      child: Stack(
        children: [
          Wallpaper(imagePath: myTheme.backgroundImagePath),
          PullupTab(
            body: pullupBody(context),
            child: pullupChild(
              context,
              lopaImage,
              '',
              const [
                HomeMenuContent(),
              ],
              const [], // nepoužije se, když showSideMenu=false
              'home_menu_screen', // nepoužije se, když showSideMenu=false
              myTheme,
              () {}, // nepoužije se, když showSideMenu=false
              showGlobalMenuBtn: false, // na home menu ho typicky nechceš
              showLopa: false,
              showSideMenu: false, // ✅ POINTA
            ),
          ),
        ],
      ),
    );
  }

  /// ⚠️ Sem překopíruj 1:1 logiku z HomeScreen, jak vybíráš lopaPath.
  /// Já nemůžu uhodnout přesný zdroj (Assets.generated vs hardcoded string vs theme property),
  /// ale ty to máš v HomeScreen hotové.
  static String _getLopaImageSameAsHomeScreen(BuildContext context, CustomTheme myTheme) {
    return 'assets/YG039-LOPA_Final.png';
  }
}

/// Obsah Home menu: 2 karty (GLOBAL MENU + MAINTENANCE) s background image z configu.
/// Styl odpovídá mapView kartám (Image + gradient + title).
class HomeMenuContent extends StatefulWidget {
  const HomeMenuContent({super.key});

  @override
  State<HomeMenuContent> createState() => _HomeMenuContentState();
}

class _HomeMenuContentState extends State<HomeMenuContent> {
  final Map<String, bool> _pressed = {};

  GenericSelection _getRequiredButton(String id) {
    final menuItems = configItems['common'] as List<dynamic>;
    return menuItems.firstWhere((e) => e.id == id) as GenericSelection;
  }

  void _openPinThen(BuildContext context, String routeName) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // ⚠️ klíč 'password' si případně uprav podle toho, jak to máte ve Settings
    final pinRaw = (settings.getValue('password') ?? '').toString().trim();
    var effectivePin = pinRaw.isEmpty ? '0000' : pinRaw;
    effectivePin = '1111';

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false, // ✅ Klíčové pro transparentní pozadí
        barrierColor: Colors.black54, // nebo Colors.transparent
        transitionDuration: Duration.zero, // ✅ Vypne animaci
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) {
          return PasswordProtectedScreen(
            alignment: Alignment.center,
            dialogOffset: const Offset(0, -0.3),
            correctPassword: effectivePin,
            protectedRouteName: routeName,
            dialogTitle: ' ENTER PIN ',
            keyboardType: VirtualKeyboardType.Numeric,
            maxLength: 4,
            obscureText: true,
            barrierDismissible: false,
            barrierColor: Colors.black54, // nebo Colors.transparent
          );
        },
      ),
    );
  }

  Widget _buildHomeCard({
    required GenericSelection item,
    required CustomTheme myTheme,
    required VoidCallback onTap,
  }) {
    _pressed[item.id] ??= false;
    final isPressed = _pressed[item.id] ?? false;
    final highlight = myTheme.highlightColor ?? Colors.blue;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed[item.id] = true),
      onTapUp: (_) {
        setState(() => _pressed[item.id] = false);
        onTap();
      },
      onTapCancel: () => setState(() => _pressed[item.id] = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          border: Border.all(
            color: Color.fromARGB(255, 255, 255, 255),
            width: 0.5, // ← tenký, elegantní
          ),
          boxShadow: [
            BoxShadow(
              color: isPressed ? highlight.withOpacity(0.55) : Colors.black.withOpacity(0.35),
              blurRadius: isPressed ? 14 : 8,
              spreadRadius: isPressed ? 1 : 0,
              offset: Offset(0, isPressed ? 2 : 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: (item.backgroundImage != null && item.backgroundImage!.isNotEmpty)
                    ? CfgImage(
                        item.backgroundImage!,
                        fit: BoxFit.cover,
                        // errorBuilder: (context, error, stackTrace) {
                        //   return Container(
                        //     color: Colors.black.withOpacity(0.35),
                        //     child: const Center(
                        //       child: Icon(Icons.image_not_supported, color: Colors.white54, size: 40),
                        //     ),
                        //   );
                        // },
                      )
                    : Container(
                        color: Colors.black.withOpacity(0.35),
                        child: Center(
                          child: Icon(
                            (item.icons != null && item.icons!.isNotEmpty) ? item.icons!.first : Icons.dashboard,
                            color: Colors.white54,
                            size: 60,
                          ),
                        ),
                      ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        tileMode: TileMode.clamp,
                        stops: const [
                          0.0,
                          0.3,
                        ],
                        colors: [
                          Colors.black.withOpacity(0.7), // ⭐ lom světla
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (!isPressed)
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.15)),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(isPressed ? 0.65 : 0.95),
                      ],
                    ),
                  ),
                  child: Text(
                    item.title == 'MAINTENANCE' ? '${item.title}\n ' : item.title ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    final btnCabinControls = _getRequiredButton('homeCabinControlsMenu');
    final btnGlobal = _getRequiredButton('homeGlobalMenu');
    final btnMaint = _getRequiredButton('homeMaintenance');

    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          /// 🔹 TOTO JE KLÍČ
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch, // ⭐ důležité
              children: [
                Expanded(
                  child: _buildHomeCard(
                    item: btnCabinControls,
                    myTheme: myTheme,
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      LoungeScreen.routeName,
                    ),
                  ),
                ),
                const SizedBox(width: 0),
                Expanded(
                  child: _buildHomeCard(
                    item: btnGlobal,
                    myTheme: myTheme,
                    onTap: () => _openPinThen(
                      context,
                      HomeScreen.routeName,
                    ),
                  ),
                ),
                const SizedBox(width: 0),
                Expanded(
                  child: _buildHomeCard(
                    item: btnMaint,
                    myTheme: myTheme,
                    onTap: () => _openPinThen(
                      context,
                      MaintenanceScreen.routeName,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// pokud chceš spodní odsazení / status bar
          // const SizedBox(height: 30),
        ],
      ),
    );
  }
}
