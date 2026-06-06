import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

import '/providers/settings_provider.dart';
import '/services/gpio_service.dart';
import '../can-helpers/can_manager.dart';
import '../config/config_items.dart';
import '../helpers/command_processor_isolate.dart';
import '../helpers/command_queue..dart';
import '../helpers/utility.dart';
import '../model/bargraph_model.dart';
import '../model/command.dart';
import '../model/command_processor_message.dart';
import '../model/component.dart';
import '../model/current_state.dart';
import '../model/generic_selection.dart';
import '../utils/logger.dart';

/// Provider responsible for tracking and managing state changes
/// Works with both CAN and Ethernet devices
class CurrentStateProvider extends ChangeNotifier {
  // Initialization state
  bool _isInitialized = false;
  Completer<void> _initCompleter = Completer<void>();

  // Dependencies
  final SettingsProvider settingsProvider;
  final canManager = CanManager();
  final GpioService gpioService = GpioService();

  // Current states tracking
  final List<CurrentState> _currentStates = [];

  // Communication subscriptions
  final Map<String, StreamSubscription<String>?> _canSubscriptions = {};
  StreamSubscription<Command>? _ethernetSubscription;

  // Inhibits tracking
  final Set<int> activeInhibits = {};

  // Optimized data structures
  final Map<String, CurrentState> _stateById = {};
  final Map<String, List<CurrentState>> _statesByGroup = {};

  // Command processing isolate
  Isolate? _commandProcessorIsolate;
  ReceivePort? _receivePort;
  SendPort? _isolateSendPort;
  bool _isolateInitialized = false;

  // Command queue for batching
  late CommandQueue _commandQueue;

  // Device type determination
  final bool _useEthernet;
  final bool _useCan;
  final bool _useGpio;

  // Supported message types
  final Map<String, int> messageTypes = {
    'StartSystem': 0x04,
    'DO': 0x10,
    'Rly': 0x11,
    'AVDSTransports': 0x50,
    'AVDSMonTransports': 0x51,
    'VarPot': 0x13,
    'PWM': 0x14,
    'ADC': 0x15,
    'Calls': 0x33,
    'Inhibits': 0x30,
    'Status': 0x31,
    'Macro': 0x32,
    'QIILights': 0x40,
  };

  /// Wait for the provider to be fully initialized
  Future<void> waitForInitialization() => _initCompleter.future;

  /// Constructor - determines the device type based on constructor parameters
  CurrentStateProvider({
    required this.settingsProvider,
    bool useEthernet = false,
    bool useCan = true,
    bool useGpio = true,
  })  : _useEthernet = useEthernet,
        _useCan = useCan,
        _useGpio = useGpio {
    _initializeCommandQueue();
  }

  /// Initialize the provider with configuration items
  Future<void> initialize(Map<String, List<dynamic>> configItems) async {
    if (_isInitialized) return;
    logDebug("CurrentStateProvider", "Initializing...");

    // Initialize states and optimized data structures
    _initializeCurrentStates(configItems);
    _buildOptimizedDataStructures();

    // Setup command processor isolate
    await _setupCommandProcessorIsolate();

    // Initialize communication interfaces
    _initializeSubscriptions();

    _isInitialized = true;
    _initCompleter.complete(); // Mark initialization as complete

    logDebug("CurrentStateProvider", "✅ CurrentStateProvider initialized.");
  }

  // Initialize the command queue for batching
  void _initializeCommandQueue() {
    _commandQueue = CommandQueue(
      processFunction: _processCommand,
      processingInterval: Duration(milliseconds: 16), // ~60fps
      batchSize: 10,
    );
  }

  // Setup command processor isolate
  Future<void> _setupCommandProcessorIsolate() async {
    logDebug("CurrentStateProvider", "Setting up command processor isolate");

    _receivePort = ReceivePort();

    try {
      _commandProcessorIsolate = await Isolate.spawn(commandProcessorIsolate, _receivePort!.sendPort);

      // Get the send port from the isolate
      _isolateSendPort = await _receivePort!.first;

      // Initialize the isolate with lookup tables
      _isolateSendPort!.send(InitializeMessage(
        reverseLookup: reverseLookup,
        matchRulesByMsgType: matchRulesByMsgType,
      ).toMap());

      // Listen for match results
      _receivePort!.listen(_handleIsolateMessage);

      _isolateInitialized = true;
      logDebug("CurrentStateProvider", "Command processor isolate initialized");
    } catch (e) {
      logDebug("CurrentStateProvider", "Failed to initialize command processor isolate: $e");
      // Fall back to processing on main thread
      _isolateInitialized = false;
    }
  }

  // Handle messages from the isolate
  void _handleIsolateMessage(dynamic message) {
    if (message is Map<String, dynamic>) {
      try {
        final messageType = MessageType.values[message['type'] as int];

        switch (messageType) {
          case MessageType.matchFound:
            final matchMessage = MatchFoundMessage.fromMap(message);

            // Update state on main thread
            setCurrentState(matchMessage.objectId, matchMessage.stateId,
                triggersSendCmd: false, data: matchMessage.data);
            break;

          default:
            // Ignore other message types
            break;
        }
      } catch (e) {
        logDebug("CurrentStateProvider", "Error handling isolate message: $e");
      }
    }
  }

  // Initialize all CurrentState objects from provided configItems
  void _initializeCurrentStates(Map<String, List<dynamic>> configItems) {
    for (var entry in configItems.entries) {
      for (var item in entry.value) {
        if (item is GenericSelection) {
          CurrentState newState = CurrentState(
            id: item.id.toString(),
            currentState: item.isActive ? 1 : 0,
            group: item.group,
            maxState: item.states.length - 1,
            inhibits: item.inhibits,
            inhibitInfo: item.inhibitInfo,
          );

          // Only add to popRoutesMap if BOTH route and popRoute are not null & not empty
          newState.popRoutesMap = {
            for (var key in item.states.keys)
              if (item.states[key]?.route.isNotEmpty == true &&
                  item.states[key]?.popRoute != null &&
                  item.states[key]!.popRoute!.isNotEmpty) // Ensure popRoute is not empty
                key: [
                  item.states[key]!.route, // ✅ Route as first element
                  item.states[key]!.popRoute!.keys.first, // ✅ First key from popRoute map
                  item.states[key]!.popRoute!.values.first // ✅ Corresponding value
                ]
          };

          _currentStates.add(newState);
        } else if (item is BargraphModel) {
          _currentStates.add(
            CurrentState(
              id: item.id.toString(),
              currentState: item.defaultState,
              maxState: item.states.length - 1,
              inhibits: item.inhibits,
              inhibitInfo: item.inhibitInfo,
            ),
          );
        }
      }
    }
    logDebug("CurrentStateProvider", "Initialized ${_currentStates.length} states.");
  }

  // Build optimized data structures for lookups
  void _buildOptimizedDataStructures() {
    // Map states by ID for quick lookup
    for (var state in _currentStates) {
      _stateById[state.id] = state;

      // Group states by group
      if (state.group.isNotEmpty) {
        _statesByGroup.putIfAbsent(state.group, () => []).add(state);
      }
    }
  }

  // Initialize subscriptions for either CAN or Ethernet
  void _initializeSubscriptions() {
    // Initialize CAN subscriptions if using CAN
    if (_useCan) {
      for (var entry in messageTypes.entries) {
        _canSubscriptions['${entry.value}:0'] = canManager.can0.getCommandStream(entry.value).listen(
              (command) => _handleCanCommand(command, entry.key, entry.value, 0),
            );
      }
      for (var entry in messageTypes.entries) {
        _canSubscriptions['${entry.value}:1'] = canManager.can1.getCommandStream(entry.value).listen(
              (command) => _handleCanCommand(command, entry.key, entry.value, 1),
            );
      }
    }

    // Initialize Ethernet subscription if using Ethernet
    if (_useEthernet) {
      return;
      // _ethernetSubscription = ethernetManager.commandStreamController.stream.listen((command) {
      //   logDebug("[CurrentStateProvider]", "Received Command via Ethernet: ${command.msgType} - ${command.toString()}");

      //   int msgType = command.msgType;
      //   String type = messageTypes.keys.firstWhere(
      //     (key) => messageTypes[key] == msgType,
      //     orElse: () => "Unknown",
      //   );

      //   _handleEthernetCommand(command, type, msgType);
      // }, onError: (error) {
      //   logDebug("[CurrentStateProvider]", "ERROR in Ethernet Stream Subscription: $error");
      // });
    }
  }

  // Handle command from CAN interface
  void _handleCanCommand(String command, String type, int msgType, int interfaceNumber) {
    logDebug("CurrentStateProvider", "Received $type command on can$interfaceNumber: $command");

    // Parse the command
    final canCommand = Command.parse(command);

    // Process relays locally if needed
    if (_useGpio &&
        msgType == messageTypes['Rly'] &&
        canCommand.canIdBF.toString() == settingsProvider.getValue("id")) {
      _handleLocalRelayCommand(canCommand);
    }

    // Process inhibits
    if (msgType == messageTypes['Inhibits']) {
      _updateInhibitsFromCommand(canCommand);
      // Note: We still queue the command for further processing for any controls
      // that need to track the inhibit state
    }

    // Add command to the queue for processing
    _commandQueue.enqueue(canCommand, type, msgType, interfaceNumber);
  }

  // Handle command from Ethernet interface
  void _handleEthernetCommand(Command ethernetCommand, String type, int msgType) {
    logInfo("CurrentStateProvider",
        "Received $type command from ${ethernetCommand.originId} via Ethernet: $ethernetCommand");

    // Process inhibits
    if (msgType == messageTypes['Inhibits']) {
      _updateInhibitsFromCommand(ethernetCommand);
      // Note: We still queue the command for further processing for any controls
      // that need to track the inhibit state
    }

    // Add command to the queue for processing (using 0 as the interface number for Ethernet)
    _commandQueue.enqueue(ethernetCommand, type, msgType, 0);
  }

  // Process a command (called from the command queue)
  void _processCommand(Map<String, dynamic> commandData) {
    final command = commandData['command'] as Command;
    final type = commandData['type'] as String;
    final msgType = commandData['msgType'] as int;
    final interfaceNumber = commandData['interfaceNumber'] as int;

    if (_isolateInitialized && _isolateSendPort != null) {
      // Process in isolate
      _isolateSendPort!.send(ProcessCommandMessage(
        command: command,
        commandType: type,
        msgType: msgType,
        interfaceNumber: interfaceNumber,
      ).toMap());
    } else {
      // Fallback: process on main thread
      _processCommandOnMainThread(command, type, msgType, interfaceNumber);
    }
  }

  // Fallback method to process commands on the main thread
  void _processCommandOnMainThread(Command command, String type, int msgType, int interfaceNumber) {
    // Check if the command is a match for any of the objects
    final matchOps = matchRulesByMsgType[msgType] ?? [];
    final possibleMatches = reverseLookup[msgType] ?? [];

    // Skip if no match operations or possible matches
    if (matchOps.isEmpty || possibleMatches.isEmpty) {
      return;
    }

    // Check for matches
    for (final location in possibleMatches) {
      final configCmd = location.command;

      // Check if the CAN ID matches
      if (!canIdMatches(command.canIdBF, configCmd.canIdBF)) {
        continue;
      }

      // Ignore commands from the same UI element
      if (command.originId != null && location.objectId == command.originId) {
        continue;
      }

      // Check if the command matches
      final matchResult = commandMatches(command.data, configCmd.data, matchOps);
      if (matchResult.isMatch) {
        setCurrentState(location.objectId, location.stateId, triggersSendCmd: false, data: matchResult.storedBytes);
        // Do NOT break here - continue checking for other potential matches
      }
    }
  }

  // Get the current state of an object
  int getCurrentState(String id) {
    return _stateById[id]?.currentState ?? 0;
  }

  // Get the current state object
  CurrentState getCurrentStateObject(String id) {
    return _stateById[id] ?? _currentStates.firstWhere((item) => (item.id == id));
  }

  void addState(CurrentState state) {
    _currentStates.add(state);
    _stateById[state.id] = state;
    notifyListeners();
  }

  // Set the current state of an object
  void setCurrentState(
    String id,
    int value, {
    bool triggersSendCmd = true,
    List<int> data = const [],
    bool silently = false,
    // --- NEW options ---
    bool force = false, // allows bypassing guards (e.g., force 0 in a group)
    bool suppressNavigation = false, // skip navigation handling if true
    bool suppressNotify = false, // skip notifyListeners() if true (useful for batching)
  }) {
    if (silently) {
      logDebug("CurrentStateProvider", 'Silently setting state for objectId: $id, value: $value');
      // when silently is true, do not send commands
      triggersSendCmd = false;
    }

    logDebug("CurrentStateProvider", 'Going to set state for objectId: $id, value: $value');

    final element = _stateById[id];
    if (element == null) {
      logDebug("CurrentStateProvider", 'No state found with id: $id');
      return;
    }

    // Bounds / No-op guard – prevent invalid values
    if (value > element.maxState) {
      logDebug("CurrentStateProvider", 'Value $value is out of range for $id (max ${element.maxState})');
      return;
    }
    final isStateChange = element.currentState != value;
    final shouldUpdateData = data.isNotEmpty && element.data != data;

    // ----- GROUP LOGIC (radio button style) -----
    if (element.group.isNotEmpty) {
      // Default behavior: if active (1) and user tries to deactivate (0) → block
      // New: if force==true → allow deactivation (used e.g. by inhibit logic)
      if (!force && element.currentState == 1 && value == 0) {
        logDebug("CurrentStateProvider", 'Element is active, cannot deactivate it (group guard)');
        if (triggersSendCmd) {
          // keep original state 1 – possibly send command again
          sendCommand(element.id, 1);
        }
        return;
      }

      // Deactivate all other members of the group (UI state only, no commands)
      final groupMembers = _statesByGroup[element.group] ?? [];
      for (final groupMember in groupMembers) {
        if (groupMember.id != id && groupMember.currentState != 0) {
          logDebug("CurrentStateProvider", 'Deactivating element in group: ${groupMember.id}');
          groupMember.currentState = 0;
          groupMember.lastStateChangeTime = DateTime.now();
        }
      }

      // Activate this element
      if (isStateChange) {
        logDebug("CurrentStateProvider", 'Activating element in group: ${element.id} to value $value');
        element.currentState = value;
        element.lastStateChangeTime = DateTime.now();
        if (triggersSendCmd) {
          sendCommand(element.id, value);
        }
      }

      if (shouldUpdateData) {
        element.data = data;
      }
    }
    // ----- NON-GROUP ELEMENT -----
    else {
      if (isStateChange) {
        element.currentState = value;
        element.lastStateChangeTime = DateTime.now();
        if (triggersSendCmd) {
          sendCommand(element.id, value);
        }
      }
      if (shouldUpdateData) {
        element.data = data;
      }
    }

    // Handle navigation if needed (unless suppressed)
    if (!suppressNavigation) {
      _handleNavigationIfNeeded(element, value);
    }

    // Notify listeners unless suppressed
    if (!silently && !suppressNotify) {
      notifyListeners();
    }
  }

  void _handleNavigationIfNeeded(CurrentState element, int value) {
    // Skip if not applicable
    if (element.popRoutesMap == null ||
        !element.popRoutesMap!.containsKey(value) ||
        element.popRoutesMap![value] == null ||
        element.popRoutesMap![value]!.isEmpty) {
      return;
    }

    final navigationRoute = element.popRoutesMap?[value]?[0] ?? "";
    final navigationStateId = element.popRoutesMap?[value]?[1] ?? 0;
    final navigationMenuId = element.popRoutesMap?[value]?[2] ?? "";

    if (navigationRoute.isNotEmpty) {
      // Use the smart navigation function
      smartNavigate(navigationRoute, selectedStateId: navigationStateId, navigationMenuId: navigationMenuId);
    }
  }

  void smartNavigate(String routeName, {int? selectedStateId, String? navigationMenuId}) {
    // Get the current Navigator state
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator == null) {
      logInfo("CurrentStateProvider", 'Navigator state is null, cannot navigate');
      return;
    }

    // Check if NavigatorState is ready and has routes
    bool hasRoutes = false;
    try {
      // This is a safe way to check if history exists
      hasRoutes = navigator.canPop();
    } catch (e) {
      logInfo("CurrentStateProvider", 'Error checking if navigator can pop: $e');
      hasRoutes = false;
    }

    // Update menu state if needed (before navigation)
    if (navigationMenuId != null && selectedStateId != null) {
      final item = _stateById[navigationMenuId];
      if (item != null && item.currentState != selectedStateId) {
        item.currentState = selectedStateId;
        _pendingNotification = true;
      }
    }

    // Safely navigate
    try {
      if (!hasRoutes) {
        // No routes in history, just push a new one
        logInfo("CurrentStateProvider", 'No routes in history, pushing initial route: $routeName');
        navigator.pushNamed(routeName);
      } else {
        // Get current route information
        String? currentRouteName;
        try {
          currentRouteName = ModalRoute.of(navigatorKey.currentContext!)?.settings.name;
        } catch (e) {
          logInfo("CurrentStateProvider", 'Error getting current route: $e');
        }

        if (currentRouteName == routeName) {
          // Already on this route
          logInfo("CurrentStateProvider", 'Already on route: $routeName - no navigation needed');
        } else {
          // Not on the target route, use replacement to avoid stack growth
          logInfo("CurrentStateProvider", 'Navigating to route: $routeName using replacement');
          navigator.pushReplacementNamed(routeName);
        }
      }
    } catch (e) {
      // Last resort - if everything else fails, try direct navigation
      logInfo("CurrentStateProvider", 'Error during navigation: $e');
      try {
        navigator.pushNamed(routeName);
      } catch (e2) {
        logInfo("CurrentStateProvider", 'Fatal navigation error: $e2');
      }
    }

    // Flush any pending notifications
    if (_pendingNotification) {
      _pendingNotification = false;
      notifyListeners();
    }
  }

  // Add this flag to batch notifications
  bool _pendingNotification = false;

// Add this method to flush notifications when changes are complete
  void _flushNotifications() {
    if (_pendingNotification) {
      _pendingNotification = false;
      notifyListeners();
    }
  }

  // Add a new current state object
  void addItem(CurrentState state) {
    // Only add if it doesn't already exist
    if (!_stateById.containsKey(state.id)) {
      _currentStates.add(state);
      _stateById[state.id] = state;

      // Add to group map if needed
      if (state.group.isNotEmpty) {
        _statesByGroup.putIfAbsent(state.group, () => []).add(state);
      }
    }
  }

  // Send command based on object ID and state ID
  void sendCommand(String objectId, int stateId) {
    logDebug("CurrentStateProvider", 'Sending command for objectId: $objectId, stateId: $stateId');

    // Find the component and get its commands
    for (var key in configItems.keys) {
      for (var element in configItems[key]!) {
        if (element is Component && element.id == objectId) {
          List<Command> commands = element.states[stateId]?.commands ?? [];

          logDebug("CurrentStateProvider", 'Command to send: $commands');

          // Send via appropriate interface
          if (_useEthernet) {
            return;
            // ethernetManager.sendCommand(commands: commands, originId: objectId);
          } else if (_useCan) {
            canManager.sendCommand(commands: commands, originId: objectId);
          }

          return;
        }
      }
    }
  }

  // Handle local relay commands (only for CAN + GPIO devices)
  void _handleLocalRelayCommand(Command command) {
    if (!_useGpio) return;

    logDebug("CurrentStateProvider", "Handling local relay command: ${command.data}");

    // Check for valid command data
    if (command.data.length < 10) {
      logDebug("CurrentStateProvider", "Invalid relay command data: ${command.data}");
      return;
    }

    // Extract relay on/off bits
    int relayOn = command.data[4];
    int relayOff = command.data[9];

    // Map relays to GPIO pins
    List<int> listRelaysToPins = [24, 28, 29, 3];

    // Update GPIO pins based on relay commands
    for (var i = 0; i < 4; i++) {
      if (relayOn & (1 << i) != 0) {
        logDebug("CurrentStateProvider", "Relay $i is ON");
        gpioService.setPinHigh(listRelaysToPins[i]);
      } else if (relayOff & (1 << i) != 0) {
        logDebug("CurrentStateProvider", "Relay $i is OFF");
        gpioService.setPinLow(listRelaysToPins[i]);
      }
    }
  }

  // Update inhibits from a command
  void _updateInhibitsFromCommand(Command canCommand) {
    // (doporučeno přidat i guard na délku rámce)
    if (canCommand.data.length < 16) {
      logDebug("CurrentStateProvider", "Invalid inhibits packet (len=${canCommand.data.length})");
      return;
    }

    final bool isAddingInhibits = canCommand.data[4] == 1; // 1=Add, 2=Remove
    final Set<int> newInhibits = {};

    for (var i = 6; i < 16; i++) {
      final byte = canCommand.data[i];
      for (var bit = 0; bit < 8; bit++) {
        if ((byte & (1 << bit)) != 0) {
          newInhibits.add(((i - 6) * 8) + bit + 1);
        }
      }
    }

    final before = Set<int>.from(activeInhibits);
    if (isAddingInhibits) {
      activeInhibits.addAll(newInhibits);
    } else {
      activeInhibits.removeAll(newInhibits);
    }

    // Only recompute and notify if the set actually changed
    final bool changed = !(before.length == activeInhibits.length && before.containsAll(activeInhibits));
    if (changed) {
      _updateObjectsInhibitedState(); // this method will do a single notify at the end
    }
  }

  // Update inhibited state for all objects
  void _updateObjectsInhibitedState() {
    bool anyChanged = false;

    for (final obj in _currentStates) {
      if (obj.inhibits.isEmpty) continue;

      final info = obj.inhibitInfo; // may be null – that's fine
      final wasInhibited = obj.isInhibited;

      // recompute inhibition
      obj.isInhibited = obj.inhibits.any(activeInhibits.contains);

      // Transition: normal -> inhibited
      if (!wasInhibited && obj.isInhibited && info != null) {
        info.setLastState = obj.currentState;
        if (info.inhibitState != null && obj.currentState != info.inhibitState) {
          setCurrentState(
            obj.id,
            info.inhibitState!,
            force: true,
            triggersSendCmd: info.shouldSendInhibitStateCommand,
            silently: !info.shouldSendInhibitStateCommand,
            suppressNavigation: true,
            suppressNotify: true,
          );
          anyChanged = true;
        }
      }

      // Transition: inhibited -> normal
      if (wasInhibited && !obj.isInhibited && info?.shouldReturnToLastState == true) {
        final target = info!.getLastState as int;
        if (obj.currentState != target) {
          setCurrentState(
            obj.id,
            target,
            force: true,
            triggersSendCmd: info.shouldSendLastStateCommand,
            silently: !info.shouldSendLastStateCommand,
            suppressNavigation: true,
            suppressNotify: true,
          );
          anyChanged = true;
        }
      }

      // If the flag itself changed, we must notify
      if (wasInhibited != obj.isInhibited) {
        anyChanged = true;
        logDebug("CurrentStateProvider", "${obj.id} changed isInhibited: ${obj.isInhibited}");
      }
    }

    if (anyChanged) {
      notifyListeners(); // single, final notify after all updates
    }
  }

  @override
  void dispose() {
    // Clean up CAN subscriptions
    _canSubscriptions.forEach((_, sub) => sub?.cancel());

    // Clean up Ethernet subscription
    _ethernetSubscription?.cancel();

    // Clean up command queue
    _commandQueue.dispose();

    // Shutdown isolate
    if (_isolateInitialized && _isolateSendPort != null) {
      _isolateSendPort!.send(ShutdownMessage().toMap());
      _commandProcessorIsolate?.kill();
    }

    _receivePort?.close();

    super.dispose();
  }
}
