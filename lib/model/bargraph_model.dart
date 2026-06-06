import 'component.dart';

class BargraphModel extends Component {
  final String? title;
  final double minValue;
  final double maxValue;
  final int steps;
  final double? height;
  final double? width;
  final double spacing;
  double value;

  BargraphModel({
    required super.id,
    super.inhibits = const {},
    super.inhibitInfo,
    this.title,
    super.defaultState = 0,
    this.minValue = 0,
    this.maxValue = 100,
    this.steps = 10,
    this.height,
    this.width,
    this.spacing = 10,
    this.value = 0,
    super.states,
  });

  set setValue(double newValue) {
    value = newValue;
  }

  get getValue {
    return value;
  }
}
