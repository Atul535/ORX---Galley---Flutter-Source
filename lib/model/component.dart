// lets have class Control
// with string id
// and default_state as integer
// and List of States

import 'component_state.dart';
import 'inhibit_info.dart';

abstract class Component {
  final String id;
  final int defaultState;
  final Map<int, ComponentState> states;
  final Set<int> inhibits;
  final InhibitInfo? inhibitInfo;

  Component({
    required this.id,
    this.defaultState = 0,
    this.states = const {},
    this.inhibits = const {},
    this.inhibitInfo,
  });
}

class ButtonComponent extends Component {
  double? width;
  double? height;
  double? iconSize;
  double textIconSpacing;

  ButtonComponent({
    required super.id,
    super.defaultState = 0,
    super.states = const {},
    this.width,
    this.height,
    this.iconSize,
    this.textIconSpacing = 10,
  });
}
