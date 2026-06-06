import 'dart:async';
import 'dart:collection';

import '../model/command.dart';
import '../utils/logger.dart';

/// A queue that batches commands and processes them at a regular interval
class CommandQueue {
  final Queue<Map<String, dynamic>> _queue = Queue();
  Timer? _processingTimer;
  final Duration _processingInterval;
  final int _batchSize;
  final Function(Map<String, dynamic>) _processFunction;
  bool _isProcessing = false;

  CommandQueue({
    required Function(Map<String, dynamic>) processFunction,
    Duration? processingInterval,
    int? batchSize,
  }) : 
    _processFunction = processFunction,
    _processingInterval = processingInterval ?? Duration(milliseconds: 16),
    _batchSize = batchSize ?? 10;

  /// Add a command to the queue
  void enqueue(Command command, String type, int msgType, int interfaceNumber) {
    _queue.add({
      'command': command,
      'type': type,
      'msgType': msgType,
      'interfaceNumber': interfaceNumber,
    });
    
    // Start processing if not already running
    if (!_isProcessing) {
      _scheduleBatchProcessing();
    }
  }

  /// Schedule batch processing
  void _scheduleBatchProcessing() {
    if (_processingTimer?.isActive == true) {
      return;
    }
    
    _isProcessing = true;
    _processingTimer = Timer(_processingInterval, () {
      _processBatch();
      
      // Continue processing if more commands are queued
      if (_queue.isNotEmpty) {
        _scheduleBatchProcessing();
      } else {
        _isProcessing = false;
      }
    });
  }

  /// Process a batch of commands
  void _processBatch() {
    // Calculate how many commands to process in this batch
    final commandsToProcess = _queue.length > _batchSize 
        ? _batchSize 
        : _queue.length;
    
    logDebug('CommandQueue', 'Processing batch of $commandsToProcess commands (${_queue.length} remaining)');
    
    // Process commands
    for (int i = 0; i < commandsToProcess; i++) {
      if (_queue.isEmpty) break;
      
      final cmd = _queue.removeFirst();
      _processFunction(cmd);
    }
  }

  /// Get the current queue length
  int get length => _queue.length;

  /// Clear the queue
  void clear() {
    _queue.clear();
  }

  /// Dispose resources
  void dispose() {
    _processingTimer?.cancel();
    _queue.clear();
    _isProcessing = false;
  }
}