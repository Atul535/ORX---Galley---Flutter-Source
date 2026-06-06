import 'dart:async';
import 'dart:io';

class SystemMetrics {
  static final SystemMetrics _instance = SystemMetrics._internal();

  factory SystemMetrics() {
    return _instance;
  }

  SystemMetrics._internal();

  // Function to read CPU temperature
  // Future<double> _readCpuTemp() async {
  //   try {
  //     final contents = await File(_cpuTempPath).readAsString();
  //     return int.parse(contents.trim()) / 1000;
  //   } catch (e) {
  //     return -1.0;
  //   }
  // }

  // // Function to read GPU temperature
  // Future<double> _readGpuTemp() async {
  //   try {
  //     final process = await Process.run(_gpuTempPath, []);
  //     final output = process.stdout.toString();
  //     final match = RegExp(r'temp=(\d+\.\d+)').firstMatch(output);
  //     return double.parse(match!.group(1).toString());
  //   } catch (e) {
  //     return -1.0;
  //   }
  // }

  // // Function to get both CPU and GPU temperatures
  // Future<Map<String, double>> getTemperatures() async {
  //   final cpuTemp = await _readCpuTemp();
  //   final gpuTemp = await _readGpuTemp();
  //   return {'cpu': cpuTemp, 'gpu': gpuTemp};
  // }

  // // Function to get CPU and GPU performance (in percent)
  // // Note: The Raspberry Pi 4 does not provide real-time CPU and GPU performance values. You can use CPU load as an alternative.
  // Future<Map<String, double>> getPerformance() async {
  //   final cpuLoad = await Process.run('uptime', []);
  //   final cpuLoadOutput = cpuLoad.stdout.toString();
  //   final match = RegExp(r'load average: (\d+\.\d+)').firstMatch(cpuLoadOutput);
  //   final cpuPerformance = double.parse(match!.group(1).toString());
  //   return {'cpu': cpuPerformance, 'gpu': -1.0}; // GPU performance is not available
  // }

  Future<Map<String, double>> getMetrics() async {
    final cpuTemp = await _getCPUTemperature();
    final gpuTemp = await _getGPUTemperature();
    final cpuPerformance = await _getCPUPerformance();
    // final gpuPerformance = await _getGPUPerformance();

    return {
      'cpu_temp': cpuTemp,
      'gpu_temp': gpuTemp,
      'cpu_performance': cpuPerformance,
      // 'gpu_performance': gpuPerformance,
    };
  }

  Future<double> _getCPUTemperature() async {
    final result = await Process.run('cat', ['/sys/class/thermal/thermal_zone0/temp']);
    return double.parse(result.stdout.trim()) / 1000;
  }

  Future<double> _getGPUTemperature() async {
    final result = await Process.run('vcgencmd', ['measure_temp']);
    return double.parse(result.stdout.trim().split('=')[1].split('\'')[0]);
  }
// top -n 1 | grep "%Cpu" | sed -nr 's/.*ni,(.*)\id.*/\1/p' | sed 's/ //g'
  Future<double> _getCPUPerformance() async {
    final result = await Process.run('/bin/bash', ['-c', 'top -b -n 1 | grep "%Cpu" | sed -nr "s/.*ni,(.*)id.*/\\1/p" | tr -d " "'],);
    return (100.0 - double.parse(result.stdout.trim()));
  }

  // Future<double> _getGPUPerformance() async {
  //   // Replace this method with the appropriate command to get GPU performance
  // }
}
