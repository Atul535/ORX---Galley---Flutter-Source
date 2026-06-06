// config/ecbu/ecbu_config.dart
import 'package:flutter/material.dart';

import '../../model/generic_selection.dart';
import '../../model/image_state.dart';
import '../../model/command.dart';
import '../../model/component_state.dart';

/// Public entrypoint used by registerAdditionalConfigs()
void registerEcbuConfig(Map<String, List<dynamic>> target) {
  // Common legend (bottom row)
  target.putIfAbsent('ecbu-common', () => <dynamic>[]).addAll(_buildEcbuCommonLegend());

  // DC1..DC8 (24 CB)
  for (final id in ['dc1', 'dc2', 'dc3', 'dc4', 'dc5', 'dc6', 'dc7', 'dc8']) {
    target['ecbu-$id'] = <dynamic>[
      ..._buildEcbuPageItems(ecbuId: id, cbCount: 24),
      ..._buildEcbuFaults(ecbuId: id),
    ];
    target['ecbu-$id-actions'] = <dynamic>[
      ..._buildEcbuActionsForPage(ecbuId: id, cbCount: 24),
    ];
  }

  // AC1..AC4 (9 CB)
  for (final id in ['ac1', 'ac2', 'ac3', 'ac4']) {
    target['ecbu-$id'] = <dynamic>[
      ..._buildEcbuPageItems(ecbuId: id, cbCount: 9),
      ..._buildEcbuFaults(ecbuId: id),
    ];
    target['ecbu-$id-actions'] = <dynamic>[
      ..._buildEcbuActionsForPage(ecbuId: id, cbCount: 9),
    ];
  }
}

/// ------------------------------
/// TAB SPECS (data only)
/// ------------------------------

class EcbuTabSpec {
  final String id; // "dc1"
  final String pageKey; // "ecbu-dc1"
  final String actionsKey; // "ecbu-dc1-actions"
  final int cbCount; // 24 or 9
  final bool isDc; // layout
  final List<EcbuCbSpec> cbs;

  const EcbuTabSpec({
    required this.id,
    required this.pageKey,
    required this.actionsKey,
    required this.cbCount,
    required this.isDc,
    required this.cbs,
  });
}

class EcbuCbSpec {
  final int cbNumber; // 1..24 or 1..9
  final String? insideText; // number inside ring, can be null/empty
  final String label; // text under CB (can be empty)
  final bool enabled; // if false => no trigger, no popup actions

  const EcbuCbSpec({
    required this.cbNumber,
    required this.label,
    required this.enabled,
    this.insideText,
  });
}

// Center text inside CB ring = AMP rating (from column E).
// Rows: 3,7,11,... (step 4). If empty => not present in the map.
const Map<String, Map<int, String>> _ecbuAmps = {
  'ac1': {
    4: '5',
    5: '5',
    6: '5',
    7: '5',
    8: '5',
    9: '5',
  },
  'ac2': {
    1: '12',
    2: '12',
    3: '12',
    7: '5',
    8: '5',
  },
  'ac3': {
    5: '5',
    6: '5',
    7: '5',
    8: '2',
    9: '5',
  },
  'ac4': {
    4: '6',
    5: '6',
    6: '6',
    7: '5',
    8: '5',
    9: '5',
  },
  'dc1': {
    6: '6',
    7: '5',
    8: '3',
    9: '2',
    10: '8',
    11: '4',
    12: '2',
    13: '5',
    14: '2',
    15: '3',
    16: '3',
    17: '2',
    19: '5',
    20: '9',
  },
  'dc2': {
    1: '8',
    2: '8',
    5: '4',
    6: '5',
    7: '2',
    8: '6',
    9: '2',
    10: '2',
    11: '2',
    12: '2',
    13: '3',
    14: '4',
    15: '3',
    16: '6',
    17: '7',
    18: '3',
    19: '2',
  },
  'dc3': {
    1: '4',
    6: '5',
    7: '5',
    8: '6',
    9: '2',
    10: '5',
    11: '2',
    12: '8',
    13: '3',
    14: '2',
    15: '3',
    16: '4',
    17: '5',
    18: '2',
    19: '2',
    21: '15',
  },
  'dc4': {
    6: '2',
    7: '2',
    8: '6',
    9: '4',
    10: '3',
    12: '2',
    13: '3',
    14: '8',
    15: '8',
    16: '8',
    17: '8',
  },
  'dc5': {
    3: '4',
    4: '4',
    6: '2',
    9: '4',
    11: '2',
    12: '2',
    13: '6',
    14: '6',
    15: '6',
    16: '6',
    21: '15',
    22: '15',
  },
  'dc6': {
    1: '4',
    6: '7',
    7: '4',
    8: '4',
    9: '2',
    10: '6',
    11: '6',
    12: '6',
    13: '6',
    16: '3',
    21: '15',
  },
  'dc7': {
    2: '4',
    3: '4',
    7: '3',
    8: '6',
    9: '6',
    11: '3',
    12: '3',
    13: '6',
    14: '6',
    16: '3',
    22: '15',
    23: '15',
  },
  'dc8': {
    1: '4',
    2: '4',
    3: '4',
    6: '2',
    8: '7',
    21: '15',
    22: '15',
    23: '15',
    24: '15',
  },
};

// Description labels for each CB (from column I, rows 3,4,5,6 for CB1, 7,8,9,10 for CB2, etc.)
// Multiple lines joined with \n
const Map<String, Map<int, String>> _ecbuLabels = {
  'ac1': {
    5: 'AUX HEATERS\nFWD ENTRY\n(CE9096)',
    7: 'IFE/CMS\nFWD LOUNGE\nAUDIO AMP\n(CE9001)',
    8: 'IFE/CMS\nFWD LOUNGE\nFWD MON\n(CE9076)',
    9: 'WATER HEATER\nVIP LAV\nFWD\n(CE9005)',
  },
  'ac2': {
    2: 'AUX HEATER\nMSTR LAV\n(CE9091)',
    7: 'IFE/CMS\nMSTR BDRM\nAUDIO AMP\n(CE9002)',
    8: 'IFE/CMS\nFWD LOUNGE\nAFT MON\n(CE9064)',
  },
  'ac3': {
    5: 'ELECTRIC SEATS\nBUSINESS\nLH\n(CE9094)',
    6: 'ELECTRIC SEATS\nBUSINESS\nRH\n(CE9095)',
    7: 'IFE/CMS\nMSTR LAV\nAUDIO AMP\n(CE9003)',
    8: 'IFE/CMS\nSTREAMING\nCNSU/CWAP\n(CE9115)',
    9: 'IFE/CMS\nDNG/CONF\nFWD MON\n(CE9086)',
  },
  'ac4': {
    5: 'AUX HEATERS\nAFT GALLEY\n(CE9106)',
    7: 'IFE/CMS\nDNG/CONF\nAUDIO AMP\n(CE9004)',
    8: 'WATER HEATER\nAFT LAV\nLH\n(CE9012)',
    9: 'WATER HEATER\nAFT LAV\nRH\n(CE9013)',
  },
  'dc1': {
    6: 'IFE/CMS\nAVDS\nP9200\n(CE9015)',
    7: 'IFE/CMS\nFWD LOUNGE\nSW PANELS\n(CE9068)',
    8: 'CEILING LIGHTS\nFWD LOUNGE\nLH\n(CE9118)',
    9: 'ZOOM CAMERA\n(CE9063)',
    10: 'CABIN\nLAN\n(CE9047)',
    11: 'CLOSET LIGHTS\nFWD LOUNGE\n(CE9070)',
    12: 'TOEKICK/ACCENT LTS\nENTRY\n(CE9069)',
    13: 'WINDOW SHADES\nFWD LOUNGE\n(CE9055)',
    14: 'IFE/CMS\nBF MODULES\nP9100\n(CE9113)',
    15: 'READING LIGHTS\nFWD LOUNGE\n(CE9042)',
    16: 'CEILING LIGHTS\nFWD ENTRY\n(CE9117)',
    17: 'TABLE LIGHTS\nFWD LOUNGE\n(CE9083)',
    19: 'WIRELESS PHONE\nCHARGERS\nFWD LOUNGE\n(CE9088)',
    20: 'TOEKICK/ACCENT LTS\nFWD LOUNGE\nVIP LAV\n(CE9071)',
  },
  'dc2': {
    1: 'USB OUTLETS\nDNG/CONF\nLH\n(CE9051)',
    2: 'USB OUTLETS\nDNG/CONF\nRH\n(CE9033)',
    5: 'ELECTRIC HI/LO\nTABLE\nDNG/CONF\n(CE9092)',
    6: 'WINDOW SHADES\nMSTR BDRM\nHALLWAY\n(CE9056)',
    7: 'CLOSET LIGHTS\nHALLWAY\nFWD\n(CE9072)',
    8: 'IFE/CMS\nAVDS\nP9300\n(CE9016)',
    9: 'IFE/CMS\nBF MODULES\nP9300\n(CE9102)',
    10: 'SCONCE LIGHTS\nVIP LAV\n(CE9036)',
    11: 'READING LIGHTS\nMSTR BDRM\n(CE9046)',
    12: 'TABLE LAMPS\nFWD LOUNGE\n(CE9066)',
    13: 'CEILING LIGHTS\nMSTR BDRM\nMSTR LAV\n(CE9121)',
    14: 'TOEKICK/ACCENT LTS\nHALLWAY\n(CE9116)',
    15: 'IFE/CMS\nMSTR BDRM\nSWPS/ADPTS\n(CE9077)',
    16: 'USB OUTLETS\nMSTR BDRM\n(CE9032)',
    17: 'TOEKICK/ACCENT LTS\nMSTR BDRM\nMSTR LAV\n(CE9097)',
    18: 'CEILING LIGHTS\nHALLWAY\n(CE9120)',
    19: 'SHOWER LIGHTS\nMSTR LAV\n(CE9108)',
  },
  'dc3': {
    1: 'SEATS TRK/SWVL\nDNG/CONF\nLH FWD\n(CE9020)',
    6: 'WINDOW SHADES\nDNG/CONF\nLH\n(CE9058)',
    7: 'WINDOW SHADES\nDNG/CONF\nRH\n(CE9057)',
    8: 'IFE/CMS\nAVDS\nP9400\n(CE9017)',
    9: 'READING LIGHTS\nDNG/CONF\n(CE9043)',
    10: 'IFE/CMS\nDNG/CONF\nSW PANELS\n(CE9079)',
    11: 'IFE/CMS\nBF MODULES\nP9400\n(CE9103)',
    12: 'TOEKICK/ACCENT LTS\nDNG/CONF\n(CE9098)',
    13: 'CEILING LIGHTS\nDNG/CONF\n(CE9090)',
    14: 'IFE/CMS\nDNG/CONF\nADAPTERS\n(CE9123)',
    15: 'CLOSET LIGHTS\nHALLWAY\nAFT\n(CE9073)',
    16: 'CLOSET LIGHTS\nMSTR LAV\n(CE9084)',
    17: 'WIRELESS PHONE\nCHARGERS\nDNG/CONF\n(CE9089)',
    18: 'TABLE LIGHTS\nDNG/CONF\n(CE9087)',
    19: 'SCONCE LIGHTS\nMSTR BDRM\nMSTR LAV\n(CE9060)',
    21: 'SEATS LUMBAR\nDNG/CONF\nLH FWD\n(CE9019)',
  },
  'dc4': {
    6: 'READING LIGHTS\nBUSINESS\n(CE9048)',
    7: 'READING LIGHTS\nAFT ATTEND\n(CE9059)',
    8: 'IFE/CMS\nAVDS\nP9500\n(CE9018)',
    9: 'IFE/CMS\nAFT LAVS\nSWPS/ADPTS\n(CE9082)',
    10: 'CLOSET LIGHTS\nAFT LAVS\n(CE9085)',
    12: 'IFE/CMS\nBF MODULES\nP9500\n(CE9112)',
    13: 'CEILING LIGHTS\nAFT LAVS\n(CE9093)',
    14: 'USB OUTLETS\nSTAFF SEAT\nRH FWD\n(CE9035)',
    15: 'USB OUTLETS\nSTAFF SEAT\nRH AFT\n(CE9053)',
    16: 'USB OUTLETS\nSTAFF SEAT\nLH FWD\n(CE9037)',
    17: 'USB OUTLETS\nSTAFF SEAT\nLH AFT\n(CE9054)',
  },
  'dc5': {
    3: 'SEATS TRK/SWVL\nFWD LOUNGE\nLH FWD\n(CE9007)',
    4: 'SEATS TRK/SWVL\nFWD LOUNGE\nLH AFT\n(CE9009)',
    6: 'AUX HEATERS\nCONTROL\nFWD\n(CE9105)',
    9: 'CEILING LIGHTS\nFWD LOUNGE\nRH\n(CE9119)',
    11: 'IFE/CMS\nBF MODULES\nP9200\n(CE9114)',
    12: 'IFE/CMS\nFWD LOUNGE\nADAPTERS\n(CE9122)',
    13: 'USB OUTLETS\nFWD LOUNGE\nLH FWD\n(CE99061)',
    14: 'USB OUTLETS\nFWD LOUNGE\nLH AFT\n(CE99062)',
    15: 'USB OUTLETS\nFWD LOUNGE\nRH FWD\n(CE9031)',
    16: 'USB OUTLETS\nFWD LOUNGE\nRH AFT\n(CE9050)',
    21: 'SEATS LUMBAR\nFWD LOUNGE\nLH FWD\n(CE9006)',
    22: 'SEATS LUMBAR\nFWD LOUNGE\nLH AFT\n(CE9008)',
  },
  'dc6': {
    1: 'SEATS TRK/SWVL\nFWD LOUNGE\nRH AFT\n(CE9011)',
    6: 'ELECTRIC DIVAN\nFWD LOUNGE\n(CE9104)',
    7: 'ELECTRIC HI/LO\nTABLE, FWD\nFWD LOUNGE\n(CE9109)',
    8: 'ELECTRIC HI/LO\nTABLE, AFT\nFWD LOUNGE\n(CE9110)',
    9: 'AUX HEATERS\nCONTROL\nMSTR LAV\n(CE9111)',
    10: 'USB OUTLETS\nDNG/CONF\nLH FWD\n(CE9044)',
    11: 'USB OUTLETS\nDNG/CONF\nLH AFT\n(CE9074)',
    12: 'USB OUTLETS\nDNG/CONF\nRH FWD\n(CE9033)',
    13: 'USB OUTLETS\nDNG/CONF\nRH AFT\n(CE9051)',
    16: 'IFE/CMS\nMSTR BDRM\nAFT MON\n(CE9065)',
    21: 'SEATS LUMBAR\nFWD LOUNGE\nRH AFT\n(CE9010)',
  },
  'dc7': {
    2: 'SEATS TRK/SWVL\nDNG/CONF\nRH FWD INB\n(CE9022)',
    3: 'SEATS TRK/SWVL\nDNG/CONF\nRH FWD OTB\n(CE9024)',
    7: 'IFE/CMS\nBUSINESS\nLH MON\n(CE9101)',
    8: 'USB OUTLETS\nBUSINESS\nLH OUTBD\n(CE9045)',
    9: 'USB OUTLETS\nBUSINESS\nLH INBD\n(CE9075)',
    11: 'IFE/CMS\nDNG/CONF\nAFT RH MON\n(CE9078)',
    12: 'IFE/CMS\nBUSINESS\nLH MON\n(CE9100)',
    13: 'USB OUTLETS\nBUSINESS\nRH OUTBD\n(CE9034)',
    14: 'USB OUTLETS\nBUSINESS\nRH INBD\n(CE9052)',
    16: 'IFE/CMS\nDNG/CONF\nAFT LH MON\n(CE9067)',
    22: 'SEATS LUMBAR\nDNG/CONF\nRH FWD INB\n(CE9021)',
    23: 'SEATS LUMBAR\nDNG/CONF\nRH FWD OTB\n(CE9023)',
  },
  'dc8': {
    1: 'SEATS TRK/SWVL\nDNG/CONF\nLH AFT\n(CE9026)',
    2: 'SEATS TRK/SWVL\nDNG/CONF\nRH AFT INB\n(CE9028)',
    3: 'SEATS TRK/SWVL\nDNG/CONF\nRH AFT OTB\n(CE9030)',
    6: 'AUX HEATERS\nCONTROL\nAFT\n(CE9107)',
    8: 'TOEKICK/ACCENT LTS\nAFT LAVS\n(CE9099)',
    21: 'SEATS LUMBAR\nDNG/CONF\nLH AFT\n(CE9025)',
    22: 'SEATS LUMBAR\nDNG/CONF\nRH AFT INB\n(CE9027)',
    23: 'SEATS LUMBAR\nDNG/CONF\nRH AFT OTB\n(CE9029)',
    24: 'IFE/CMS\nMOVING MAP\n(CE9014)',
  },
};

/// ------------------------------
/// COMMON LEGEND (rendered in UI too)
/// ------------------------------

List<GenericSelection> _buildEcbuCommonLegend() {
  return [
    _legendItem(id: 'ecbu_legend_open', title: 'OPEN', image: 'assets/icons/legend_open.png'),
    _legendItem(id: 'ecbu_legend_close', title: 'CLOSE', image: 'assets/icons/legend_close.png'),
    _legendItem(id: 'ecbu_legend_collar', title: 'COLLAR', image: 'assets/icons/legend_collar.png'),
    _legendItem(id: 'ecbu_legend_unc', title: 'UN-COLLAR', image: 'assets/icons/legend_uncollar.png'),
    _legendItem(id: 'ecbu_legend_reset', title: 'RESET', image: 'assets/icons/legend_reset.png'),
  ];
}

GenericSelection _legendItem({
  required String id,
  required String title,
  required String image,
}) {
  return GenericSelection(
    id: id,
    title: title,
    height: 100,
    width: 200,
    isMomentary: false,
    isActive: false,
    customThemeKey: 'ecbuLegend',
    states: {
      0: GenericSelectionState(
        stateId: 0,
        title: title,
        touchDisabled: true,
        imageState: [ImageState(imagePath: image, imageEffect: ImageEffect.none)],
        commands: const [],
      ),
    },
  );
}

GenericSelection _buildCbIndicator({required String ecbuId, required int cbNumber}) {
  final cb = cbNumber.toString().padLeft(2, '0');
  final id = 'ecbu_${ecbuId}_cb${cb}_indicator';

  const stateAssets = <int, String>{
    0: 'assets/icons/ecbu_state_open.png',
    1: 'assets/icons/ecbu_state_close.png',
    2: 'assets/icons/ecbu_state_collar.png',
    3: 'assets/icons/ecbu_state_uncollar.png',
    4: 'assets/icons/ecbu_state_reset.png',
  };

  GenericSelectionState s(int stateId) => GenericSelectionState(
        stateId: stateId,
        title: '',
        touchDisabled: true,
        imageState: [ImageState(imagePath: stateAssets[stateId]!, imageEffect: ImageEffect.none)],
        commands: const [],
      );

  return GenericSelection(
    id: id,
    title: '',
    height: 95,
    width: 105,
    isMomentary: false,
    isActive: false,
    customThemeKey: 'ecbuIndicator',
    borderRadius: BorderRadius.circular(43),
    states: {0: s(0), 1: s(1), 2: s(2), 3: s(3), 4: s(4)},
  );
}

GenericSelection _buildCbTrigger({required String ecbuId, required int cbNumber}) {
  final cb = cbNumber.toString().padLeft(2, '0');
  final id = 'ecbu_${ecbuId}_cb${cb}_trigger';

  return GenericSelection(
    id: id,
    title: '',
    height: 86,
    width: 86,
    isMomentary: false,
    isActive: false,
    customThemeKey: 'transparentTap',
    states: {
      0: GenericSelectionState(stateId: 0, title: '', commands: const []),
    },
  );
}

/// ------------------------------
/// FAULTS (same IDs, layout handled in UI)
/// ------------------------------

GenericSelection _faultItem({required String id, required String title, required String image}) {
  return GenericSelection(
    id: id,
    title: '',
    height: 160,
    width: 100,
    isMomentary: false,
    isActive: true,
    // customThemeKey: 'faultIndicator',
    states: {
      0: GenericSelectionState(stateId: 0, title: '', touchDisabled: true, commands: const []),
      1: GenericSelectionState(
        stateId: 1,
        title: title,
        touchDisabled: true,
        imageState: [ImageState(imagePath: image, imageEffect: ImageEffect.none)],
        commands: const [],
      ),
    },
  );
}

GenericSelection _actionButton({
  required String ecbuId,
  required String cb,
  required String action,
  required String title,
}) {
  final id = 'ecbu_${ecbuId}_cb${cb}_action_$action';

  const iconByAction = <String, String>{
    'open': 'assets/icons/legend_open.png',
    'close': 'assets/icons/legend_close.png',
    'collar': 'assets/icons/legend_collar.png',
    'uncollar': 'assets/icons/legend_uncollar.png',
    'reset': 'assets/icons/legend_reset.png',
  };

  final iconPath = iconByAction[action];

  return GenericSelection(
    id: id,
    title: title,
    height: 120, // ✅ popup button vyšší, aby se vešel text pod ikonou
    width: 140,
    isMomentary: true,
    isActive: false,

    // ✅ použijeme separátní theme pro popup, který má text POD ikonou
    // customThemeKey: 'ecbuLegendPopup',

    states: {
      0: GenericSelectionState(
        stateId: 0,
        title: title,
        imageState: iconPath != null ? [ImageState(imagePath: iconPath, imageEffect: ImageEffect.none)] : const [],
        commands: const [],
      ),
      1: GenericSelectionState(
        stateId: 1,
        title: title,
        imageState: iconPath != null ? [ImageState(imagePath: iconPath, imageEffect: ImageEffect.none)] : const [],
        commands: const [
          // TODO: doplnit správné Command
        ],
      ),
    },
  );
}

List<dynamic> _buildEcbuPageItems({
  required String ecbuId,
  required int cbCount,
}) {
  final List<dynamic> out = [];

  final labels = _ecbuLabels[ecbuId] ?? const <int, String>{};
  final amps = _ecbuAmps[ecbuId] ?? const <int, String>{};

  for (int cb = 1; cb <= cbCount; cb++) {
    final label = labels[cb] ?? '';
    final connected = label.trim().isNotEmpty;

    // Meta entry (UI uses it for layout + label + popup enable)
    final insideText = connected ? cb.toString() : ''; // <- fallback; později dáš přesně dle screenshotů

    out.add(<String, dynamic>{
      'type': 'cb_meta',
      'ecbuId': ecbuId,
      'cb': cb,
      'label': label,
      'insideText': (amps[cb] ?? '').trim(), // <-- AMP rating shown in the center
      'popupEnabled': connected,
    });

    // Always add indicator (it will show state; still okay even if empty label)
    out.add(_buildCbIndicator(ecbuId: ecbuId, cbNumber: cb));

    // Add trigger only if popup should exist
    if (connected) {
      out.add(_buildCbTrigger(ecbuId: ecbuId, cbNumber: cb));
    }
  }

  return out;
}

List<GenericSelection> _buildEcbuFaults({required String ecbuId}) {
  return [
    // _faultItem(
    //   id: 'ecbu_${ecbuId}_fault_cec',
    //   title: 'CEC\nFAULT',
    //   image: 'assets/icons/warning.png',
    // ),
    _faultItem(
      id: 'ecbu_${ecbuId}_fault_com',
      title: 'COM\nFAULT',
      image: 'assets/icons/warning.png',
    ),
    _faultItem(
      id: 'ecbu_${ecbuId}_fault_ecbu',
      title: 'ECBU\nFAULT',
      image: 'assets/icons/warning.png',
    ),
  ];
}

List<GenericSelection> _buildEcbuActionsForPage({required String ecbuId, required int cbCount}) {
  final List<GenericSelection> out = [];
  final labels = _ecbuLabels[ecbuId] ?? const <int, String>{};

  for (int cb = 1; cb <= cbCount; cb++) {
    final label = (labels[cb] ?? '').trim();
    if (label.isEmpty) continue; // not wired => no actions => no popup

    final cbStr = cb.toString().padLeft(2, '0');
    out.add(_actionButton(ecbuId: ecbuId, cb: cbStr, action: 'open', title: 'OPEN'));
    out.add(_actionButton(ecbuId: ecbuId, cb: cbStr, action: 'close', title: 'CLOSE'));
    out.add(_actionButton(ecbuId: ecbuId, cb: cbStr, action: 'collar', title: 'COLLAR'));
    out.add(_actionButton(ecbuId: ecbuId, cb: cbStr, action: 'uncollar', title: 'UN-COLLAR'));
    out.add(_actionButton(ecbuId: ecbuId, cb: cbStr, action: 'reset', title: 'RESET'));
  }

  return out;
}
