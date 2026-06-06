import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/generic_selection_widget.dart';
import 'generic_selection.dart';

class TabGenericSelectionIcon extends StatelessWidget {
  final GenericSelection item;
  final CustomTheme myTheme;
  final double size;

  const TabGenericSelectionIcon({
    super.key,
    required this.item,
    required this.myTheme,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // This prevents the icon widget from stealing the tab click.
      child: SizedBox(
        width: size,
        height: size,
        child: Selector<CurrentStateProvider, int>(
          selector: (context, currentStateNotifier) {
            return currentStateNotifier.getCurrentState(item.id.toString());
          },
          builder: (context, currStateValue, child) {
            return GenericSelectionWidget(
              id: item.id,
              title: '',
              // icons: item.icons,
              iconSize: item.iconSize,
              isMomentary: item.isMomentary,
              onStateCallBack: () {},
              offStateCallBack: () {},
              height: size,
              width: size,
              textIconSpacing: 0,
              textStyle: myTheme.textTheme?.bodyLarge,
              side: GenericSelelectionWidgetButtonSide.none,
              states: item.states,
              isTransparent: false,
              removeBtnBackgroundStyling: true,
              iconsShadow: const [
                Shadow(
                  color: Colors.black,
                  offset: Offset(4, 4),
                  blurRadius: 20,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
