import 'package:flutter/material.dart';

import '../model/system_metrics.dart';

class SystemInfo extends StatefulWidget {
  final bool isRow;
  final Color backgroundColor;

  const SystemInfo(
      {super.key,
      this.isRow = true,
      this.backgroundColor = Colors.transparent});

  @override
  State<SystemInfo> createState() => _SystemInfoState();
}

class _SystemInfoState extends State<SystemInfo> {
  final SystemMetrics _systemMetrics = SystemMetrics();
  Map<String, double> _metrics = {
    'cpu_temp': 0,
    'gpu_temp': 0,
    'cpu_performance': 0
  };
  bool? _isException;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _isException = false;
    _updateMetrics();
  }

  void _updateMetrics() async {
    if (mounted) {
      try {
        final metrics = await _systemMetrics.getMetrics();
        setState(() {
          _metrics = metrics;
        });
      } catch (e) {
        // Handle exceptions, e.g. show an error message
        _isException = true;
      }
      Future.delayed(const Duration(seconds: 1), _updateMetrics);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isException == null) {
      _showResults = false;
    } else {
      _showResults = true;
    }

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (widget.isRow) {
            // Show widgets in a row if the screen has enough space
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                    'CPU Temp: ${_showResults ? _metrics['cpu_temp']?.toStringAsFixed(1) ?? '--' : '--'}°C',
                    style: TextStyle(backgroundColor: widget.backgroundColor)),
                Text(
                    'GPU Temp: ${_showResults ? _metrics['gpu_temp']?.toStringAsFixed(1) ?? '--' : '--'}°C',
                    style: TextStyle(backgroundColor: widget.backgroundColor)),
                Text(
                    'CPU Load: ${_showResults ? _metrics['cpu_performance']?.toStringAsFixed(1) ?? '--' : '--'}%',
                    style: TextStyle(backgroundColor: widget.backgroundColor)),
              ],
            );
          } else {
            // Show widgets in a column if there is less space
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    'CPU Temp: ${_showResults ? _metrics['cpu_temp']?.toStringAsFixed(1) ?? '--' : '--'}°C',
                    style: TextStyle(backgroundColor: widget.backgroundColor)),
                const SizedBox(height: 20),
                Text(
                    'GPU Temp: ${_showResults ? _metrics['gpu_temp']?.toStringAsFixed(1) ?? '--' : '--'}°C',
                    style: TextStyle(backgroundColor: widget.backgroundColor)),
                const SizedBox(height: 20),
                Text(
                    'CPU Load: ${_showResults ? _metrics['cpu_performance']?.toStringAsFixed(1) ?? '--' : '--'}%',
                    style: TextStyle(backgroundColor: widget.backgroundColor)),
              ],
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
