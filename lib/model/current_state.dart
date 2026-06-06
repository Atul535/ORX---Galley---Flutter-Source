import 'inhibit_info.dart';

class CurrentState {
  final String id;
  int currentState;
  bool justSent;
  int maxState;
  String group;
  Map<int, List<dynamic>>? popRoutesMap;
  Set<int> inhibits;
  bool isInhibited;
  List<int> data;
  DateTime? lastStateChangeTime;
  InhibitInfo? inhibitInfo;

  CurrentState({
    required this.id,
    this.currentState = 0,
    this.group = "",
    this.justSent = false,
    this.maxState = 0,
    this.popRoutesMap,
    this.inhibits = const {},
    this.isInhibited = false,
    this.data = const [],
    this.lastStateChangeTime,
    this.inhibitInfo,
  });
}
