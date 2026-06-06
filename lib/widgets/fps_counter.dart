import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FpsCounter extends StatefulWidget {
  const FpsCounter({Key? key}) : super(key: key);

  @override
  _FpsCounterState createState() => _FpsCounterState();
}

class _FpsCounterState extends State<FpsCounter> {
  double _fps = 0;
  late Timer _timer;
  int _frameCount = 0;
  late DateTime _lastTime;

  // Track rendering time
  int _maxRenderTime = 0;
  int _lastRenderTime = 0;
  int _avgRenderTime = 0;
  int _totalRenderTime = 0;
  int _renderSamples = 0;

  @override
  void initState() {
    super.initState();
    _lastTime = DateTime.now();

    // Count frames and measure render times
    WidgetsBinding.instance.addPostFrameCallback(_countFrame);

    // Update FPS display every second
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastTime).inMilliseconds;
      if (mounted) {
        setState(() {
          if (elapsed > 0) {
            _fps = _frameCount * 1000 / elapsed;
          }
          _frameCount = 0;
          _lastTime = now;

          // Reset max render time every few seconds
          if (_timer.tick % 6 == 0) {
            _maxRenderTime = 0;
            _totalRenderTime = 0;
            _renderSamples = 0;
            _avgRenderTime = 0;
          }
        });
      }
    });
  }

  void _countFrame(Duration timeStamp) {
    _frameCount++;

    // Measure render time for this frame
    final stopwatch = Stopwatch()..start();

    // Schedule to be called after the next frame
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      stopwatch.stop();
      _lastRenderTime = stopwatch.elapsedMicroseconds;

      if (_lastRenderTime > _maxRenderTime) {
        _maxRenderTime = _lastRenderTime;
      }

      _totalRenderTime += _lastRenderTime;
      _renderSamples++;

      if (_renderSamples > 0) {
        _avgRenderTime = _totalRenderTime ~/ _renderSamples;
      }

      // Continue counting frames
      WidgetsBinding.instance.addPostFrameCallback(_countFrame);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPerformant = _fps >= 50;
    final bool hasJank = _maxRenderTime > 16667; // Over 16.7ms (below 60fps)

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'FPS: ${_fps.toStringAsFixed(1)}',
            style: TextStyle(
              color: isPerformant ? Colors.green : Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Frame time: ${(_lastRenderTime / 1000).toStringAsFixed(1)}ms',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            'Max: ${(_maxRenderTime / 1000).toStringAsFixed(1)}ms',
            style: TextStyle(
              color: hasJank ? Colors.red : Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            'Avg: ${(_avgRenderTime / 1000).toStringAsFixed(1)}ms',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
