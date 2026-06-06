import 'dart:math';

class Command {
  final int id;
  final int len;
  final int flags;
  List<int> data;
  int _canProtocol;
  int _canId;
  final int canBusIndex;
  final int delayMs;
  int _canIdBF;
  String? originId;

  Command({
    required this.id,
    this.len = 0,
    this.flags = 5,
    this.data = const [],
    this.canBusIndex = 0,
    int canProtocol = 0x06,
    int canId = 2,
    int? canIdBF,
    this.delayMs = 0,
    this.originId,
  })  : _canProtocol = canProtocol,
        _canIdBF = canIdBF ?? (canId & 0xFF),
        _canId = canIdBF != null ? (canProtocol << 8) | canIdBF : canId {
    _canProtocol = (_canId & 0xFF00) >> 8;

    if (data.length < 4) {
      data = List<int>.filled(4, 0);
    }
  }

  int get canIdBF => _canIdBF;

  set canIdBF(int value) {
    _canIdBF = value;
    _canId = (_canProtocol << 8) | value;
  }

  int get canProtocol => _canProtocol;
  set canProtocol(int value) {
    _canProtocol = value;
    _canId = (_canId & 0x00FF) | (_canProtocol << 8);
  }

  int get canId => _canId;
  set canId(int value) {
    _canId = value;
    _canProtocol = (_canId & 0xFF00) >> 8;
    _canIdBF = _canId & 0xFF;
  }

  // int get canIdBF => _canId & 0xFF;

  // Protocol Descriptor Getters and Setters
  int get srcId => data[0];
  set srcId(int value) {
    data[0] = value;
  }

  int get msgType => data[1];
  set msgType(int value) {
    data[1] = value;
  }

  int get cmdType => data[2];
  set cmdType(int value) {
    data[2] = value;
  }

  int get dataLen => data[3];
  set dataLen(int value) {
    data[3] = value;
    // Ensure that data has enough room for msgData
    if (data.length < 4 + value) {
      data = List<int>.from(data)..addAll(List<int>.filled(value, 0));
    } else if (data.length > 4 + value) {
      data = data.sublist(0, 4 + value);
    }
  }

  List<int> get msgData => data.sublist(4, 4 + dataLen);
  set msgData(List<int> value) {
    dataLen = value.length;
    data.setRange(4, 4 + value.length, value);
  }

  // Update the data field directly
  set setData(List<int> newData) {
    data = newData;

    // Automatically update dataLen based on the new data
    if (data.length >= 4) {
      dataLen = data.length - 4;
    } else {
      dataLen = 0;
    }
  }

  /// Convert byte list to Command object
  static Command fromBytes(List<int> bytes) {
    if (bytes.length < 4) {
      throw const FormatException("Invalid byte length for Command");
    }

    int canBus = bytes[0]; // CAN Bus Index
    int canId = (bytes[1] << 8) | bytes[2]; // Combine two bytes for CAN ID / includes protocol
    int flags = bytes[3];

    List<int> data = bytes.sublist(4); // Remaining bytes are data

    return Command(id: 0, canBusIndex: canBus, canId: canId, flags: flags, data: data);
  }

  /// Convert Command to bytes for TCP transmission
  List<int> toBytes() {
    return [
      canBusIndex, // ✅ CAN Bus Index (1 byte)
      (canId >> 8) & 0xFF, // ✅ CAN ID High byte
      canId & 0xFF, // ✅ CAN ID Low byte
      flags, // ✅ Flags (1 byte)
      ...data // ✅ Data bytes
    ];
  }

  // Static method to parse a command from a string
  static Command parseHex(String commandStr) {
    var parts = commandStr.split('::');
    if (parts.isEmpty) {
      throw FormatException("Invalid command string: $commandStr");
    }

    int canIdBF = int.parse(parts[0], radix: 16);
    List<int> data = parts.skip(1).map((s) => int.parse(s, radix: 16)).toList();

    // Assume the CAN protocol is 0x06 and reconstruct the CAN ID
    int canProtocol = 0x06;
    int canId = (canProtocol << 8) | canIdBF;

    return Command(
      id: Random().nextInt(0xFFFF),
      len: data.length,
      data: data,
      canProtocol: canProtocol,
      canId: canId,
    );
  }

  // Static method to parse a command from a string
  static Command parse(String commandStr) {
    var parts = commandStr.split('::');
    if (parts.isEmpty) {
      throw FormatException("Invalid command string: $commandStr");
    }

    String originId = parts[0];
    int canIdBF = int.parse(parts[1]);
    List<int> data = parts.skip(2).map((s) => int.parse(s)).toList();

    // Assume the CAN protocol is 0x06 and reconstruct the CAN ID
    int canProtocol = 0x06;
    int canId = (canProtocol << 8) | canIdBF;

    return Command(
      id: canId,
      originId: originId,
      len: data.length,
      data: data,
      canProtocol: canProtocol,
      canId: canId,
    );
  }

  @override
  String toString() {
    return '${canIdBF.toString().padLeft(2, '0')}-${data.join('-')}';
  }

  String commandForStream() {
    return '$originId::${canId.toString().padLeft(4, '0')}::${data.join('::')}';
  }
}
