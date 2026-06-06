class InhibitInfo {
  int? inhibitState;
  int? _lastState;
  bool shouldReturnToLastState;
  bool shouldSendInhibitStateCommand;
  bool shouldSendLastStateCommand;

  InhibitInfo({
    this.inhibitState,
    this.shouldSendInhibitStateCommand = false,
    this.shouldSendLastStateCommand = false,
    this.shouldReturnToLastState = false,
  });

  int? get getLastState => _lastState;

  set setLastState(int? value) {
    _lastState = value;
  }
}
