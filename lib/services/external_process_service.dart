import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../utils/logger.dart';

class ExternalProcessService {
  Process? _process;

  Future<bool> isProgramInPath(String programName) async {
    try {
      final result = await Process.run('which', [programName]);
      return result.exitCode == 0;
    } catch (e) {
      logError('ExternalProcessService', 'Error checking program in PATH: $e');
      return false;
    }
  }

  Future<bool> fileExists(programName) async {
    try {
      final file = File(programName);
      return await file.exists();
    } catch (e) {
      logError('ExternalProcessService', 'Error checking program file: $e');
      return false;
    }
  }

  Future<void> startProcess(String programName, List<String> arguments,
      {int timeoutMilliseconds = 500}) async {
    if (!Platform.isLinux) {
      logDebug('ExternalProcessService', 'Platform not supported');
      return;
    }

    logDebug('ExternalProcessService', 'programName $programName, $arguments');

    // Check if program is in PATH
    try {
      final result = await Process.run('which', [programName]);
      if (result.exitCode != 0) {
        logError('ExternalProcessService',
            "Error: Program not in PATH - $programName");
        // check if program file exists, if exists then continue, else return, use fileExists function
        if (await fileExists(programName) == false) {
          logError('ExternalProcessService',
              "Error: Program file does not exist - $programName");
          return;
        }
      }
    } catch (e) {
      logError('ExternalProcessService', "Error checking on program: $e");
      return;
    }

    try {
      var processFuture = Process.start(programName, arguments);
      _process = await processFuture
          .timeout(Duration(milliseconds: timeoutMilliseconds), onTimeout: () {
        if (_process != null) {
          _process!.kill();
          logDebug('ExternalProcessService', "Process killed due to timeout.");
        }
        throw TimeoutException(
            "Process did not finish within the allotted time");
      });

      logDebug('ExternalProcessService', 'process id: ${_process?.pid}');

      _process?.stderr.listen((event) {
        logDebug('ExternalProcessService',
            "Process Err listen: ${String.fromCharCodes(event)}");
      });

      // Handle process exit
      _process?.exitCode.then((exitCode) {
        logDebug(
            'ExternalProcessService', 'Process exited with code $exitCode');
        _process = null;
      });
    } catch (e) {
      logError(
          'ExternalProcessService', 'Error starting or timing out process: $e');
      _process = null;
      rethrow;
    }
  }

  Future<String> startProcessStdOut(String programName, List<String> arguments,
      {int timeoutMilliseconds = 500}) async {
    if (!Platform.isLinux) {
      logDebug('ExternalProcessService', 'Platform not supported');
      return '';
    }

    logDebug('ExternalProcessService', 'programName $programName, $arguments');

    // Check if program is in PATH
    try {
      final result = await Process.run('which', [programName]);
      if (result.exitCode != 0) {
        logError('ExternalProcessService',
            "Error: Program not in PATH - $programName");
        // check if program file exists, if exists then continue, else return, use fileExists function
        if (await fileExists(programName) == false) {
          logError('ExternalProcessService',
              "Error: Program file does not exist - $programName");
          return '';
        }
      }
    } catch (e) {
      logError('ExternalProcessService', "Error checking on program: $e");
      return '';
    }

    try {
      var processFuture = Process.start(programName, arguments);
      _process = await processFuture
          .timeout(Duration(milliseconds: timeoutMilliseconds), onTimeout: () {
        if (_process != null) {
          stopProcess();
          logDebug('ExternalProcessService', "Process killed due to timeout.");
        }
        throw TimeoutException(
            "Process did not finish within the allotted time");
      });

      logDebug('ExternalProcessService', 'process id: ${_process?.pid}');

      final StringBuffer outputBuffer = StringBuffer();
      final StringBuffer errorBuffer = StringBuffer();

      await for (var event in _process!.stdout) {
        outputBuffer.write(String.fromCharCodes(event));
      }

      await for (var event in _process!.stderr) {
        errorBuffer.write(String.fromCharCodes(event));
      }

      var exitCode = await _process!.exitCode;
      logDebug('ExternalProcessService', 'Process exited with code $exitCode');

      if (exitCode != 0) {
        logError('ExternalProcessService', 'Error: ${errorBuffer.toString()}');
        // return Future.error('Process exited with error');
      }

      return outputBuffer.toString();
    } catch (e) {
      logError('ExternalProcessService', 'Error: $e');
      return Future.error('Error starting process: $e');
    }
  }

  Future<String> startProcessWithPipes(
      String programName, List<String> arguments,
      {int timeoutMilliseconds = 500}) async {
    if (!Platform.isLinux) {
      return 'Platform not supported';
    }

    bool isTimeout = false; // Flag to indicate if a timeout occurred

    try {
      _process = await Process.start(programName, arguments);

      Timer(Duration(milliseconds: timeoutMilliseconds), () {
        if (!isTimeout) {
          logDebug('ExternalProcessService - startProcessWithPipes',
              'Timer callback invoked - Process timeout - for process $programName $arguments');
          _process?.kill();
          isTimeout = true;
        }
      });

      var output = await _process?.stdout.transform(utf8.decoder).join();
      int exitCode = await _process!.exitCode;

      if (isTimeout) {
        return 'TIMEOUT'; // If the timeout occurred, return 'TIMEOUT'
      }

      if (exitCode != 0) {
        throw Exception(
            'Process exited with code $exitCode for $programName $arguments and output: $output');
      }

      return output.toString(); // Return process output if successful
    } catch (e) {
      logError('ExternalProcessService - startProcessWithPipes',
          'Error running process for process $programName $arguments: $e');
      if (isTimeout) {
        return 'TIMEOUT'; // If an error occurs and it's due to timeout, return 'TIMEOUT'
      } else {
        return 'Error: $e'; // Otherwise, return the error
      }
    }

    return 'Unexpected error'; // Default return statement
  }

  Future<void> stopProcess({String name = ""}) async {
    int? pid = _process?.pid;
    bool processStillRunning = false;
    logDebug("ExternalProcessService - stopProcess - pid: $pid",
        'stopping process: $name, pid: $pid, is process null: ${_process == null}');
    try {
      if (_process != null) {
        var exitCode;

        try {
          exitCode = await _process!.exitCode
              .timeout(const Duration(milliseconds: 200));
        } on TimeoutException catch (_) {
          logDebug("ExternalProcessService - stopProcess - pid: $pid",
              'process likely still running, we are ok to kill it');
          processStillRunning = true;
        }
        logDebug("ExternalProcessService - stopProcess - pid: $pid",
            'process exit code: $exitCode, isnull:${exitCode == null}');

        if (exitCode == null || processStillRunning) {
          _process!.kill();
          var result = await Process.run(
              'sudo', ['kill', '-9', _process!.pid.toString()]);
          logDebug("ExternalProcessService - stopProcess - pid: $pid",
              'pkill pid result: ${result.exitCode}');
          _process = null;
        } else {
          logDebugFine("ExternalProcessService - stopProcess - pid: $pid",
              'process pid: ${_process?.pid} already exited');
        }
      }

      if (name.isNotEmpty) {
        var result = await Process.run('sudo', ['pkill', '-9', name]);
        logDebug("ExternalProcessService - stopProcess - pid: $pid",
            'pkill named result: ${result.exitCode}');
      }
    } catch (e) {
      logError("ExternalProcessService - stopProcess - pid: $pid",
          'Error stopping process: $e');
    }
  }

  Future<bool> isProcessRunning() async {
    int? pid = _process?.pid;
    if (_process == null) {
      logDebug("ExternalProcessService - isProcessRunning - pid: $pid",
          'Process is null, not running');
      return false;
    }

    try {
      await _process!.exitCode.timeout(const Duration(milliseconds: 200));
      // If the above line does not throw a TimeoutException,
      // it means the process has exited.
      logDebug("ExternalProcessService - isProcessRunning - pid: $pid",
          'Process has exited');
      return false;
    } on TimeoutException catch (_) {
      // If a TimeoutException is caught, it means the process is likely still running.
      logDebug("ExternalProcessService - isProcessRunning - pid: $pid",
          'Process is likely still running');
      return true;
    } catch (e) {
      logError("ExternalProcessService - isProcessRunning - pid: $pid",
          'Error checking process: $e');
      return false;
    }
  }
}
