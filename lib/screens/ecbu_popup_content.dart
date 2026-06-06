import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config_items.dart';
import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import '../widgets/generic_selection_widget.dart';
import '../utils/logger.dart';

/// Popup content: renders 5 momentary action buttons for a given ECBU+CB.
/// Expects config IDs in this format (as generated):
///   ecbu_<ecbuId>_cb<cb>_action_open
///   ecbu_<ecbuId>_cb<cb>_action_close
///   ecbu_<ecbuId>_cb<cb>_action_collar
///   ecbu_<ecbuId>_cb<cb>_action_uncollar
///   ecbu_<ecbuId>_cb<cb>_action_reset
///
/// Example:
///   ecbu_dc1_cb07_action_open
class EcbuCbPopupContent extends StatelessWidget {
  final String ecbuId; // "dc1"
  final String cb; // "07"
  final String actionsGroupKey; // "ecbu-dc1-actions"
  final String titleText; // "CB 07"

  const EcbuCbPopupContent({
    super.key,
    required this.ecbuId,
    required this.cb,
    required this.actionsGroupKey,
    required this.titleText,
  });

  static const List<String> _order = ['open', 'close', 'collar', 'uncollar', 'reset'];

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    final raw = configItems[actionsGroupKey] ?? const [];
    final actions = raw.whereType<GenericSelection>().toList(growable: false);

    final prefix = 'ecbu_${ecbuId}_cb${cb}_action_';

    // Map: actionKey -> config item
    final Map<String, GenericSelection> byAction = {};
    for (final it in actions) {
      final id = it.id ?? '';
      if (!id.startsWith(prefix)) continue;
      final actionKey = id.substring(prefix.length); // open/close/...
      byAction[actionKey] = it;
    }

    // Optional sanity log (helps during bring-up)
    for (final k in _order) {
      if (!byAction.containsKey(k)) {
        logDebug('EcbuCbPopupContent', 'Missing action item for $prefix$k in group=$actionsGroupKey');
      }
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            titleText,
            textAlign: TextAlign.center,
            style: theme.textTheme?.titleLarge?.copyWith(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // Buttons
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _order.map((actionKey) {
                  final item = byAction[actionKey];
                  if (item == null) {
                    // Keep layout stable even if config missing
                    return const SizedBox(width: 150, height: 110);
                  }

                  // We want: momentary press -> send command -> on release -> state goes back to 0 -> close popup.
                  // Your GenericSelectionWidget already calls offStateCallBack when it returns to 0.
                  return Selector<CurrentStateProvider, int>(
                    selector: (ctx, p) => p.getCurrentState(item.id ?? ''),
                    builder: (ctx, state, _) {
                      return GenericSelectionWidget.fromSelection(
                        item: item,
                        // Not needed here; command is sent by CurrentStateProvider on state changes
                        onStateCallBack: () {},
                        removeBtnBackgroundStyling: true,

                        textStyle: theme.textTheme?.bodyMedium?.copyWith(fontSize: 20),
                        // Close popup when the button returns to 0 (release)
                        offStateCallBack: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
