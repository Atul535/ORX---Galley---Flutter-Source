import 'command.dart';

class CommandLocation {
  final String objectId;
  final int stateId;
  final Command command;

  CommandLocation(this.objectId, this.stateId, this.command);

  @override
  String toString() {
    return 'CommandLocation{objectId: $objectId, stateId: $stateId, command: $command}';
  }
}
