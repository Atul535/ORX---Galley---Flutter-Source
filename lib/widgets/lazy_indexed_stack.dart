import 'package:flutter/material.dart';

/// Lazy alternative to IndexedStack:
/// - Builds only the active child initially.
/// - Builds other children only after they were visited.
/// - Keeps already built children alive (no re-build on tab switch).
class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<WidgetBuilder> builders;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.builders,
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late final List<bool> _built;

  @override
  void initState() {
    super.initState();
    _built = List<bool>.filled(widget.builders.length, false);
    _built[widget.index] = true;
  }

  @override
  void didUpdateWidget(covariant LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Mark current index as built when user switches tabs.
    final i = widget.index;
    if (i >= 0 && i < _built.length && !_built[i]) {
      _built[i] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.builders.length, (i) {
        if (!_built[i]) {
          // Not built yet → keep it out of the tree.
          return const SizedBox.shrink();
        }

        final active = i == widget.index;

        return Offstage(
          offstage: !active,
          child: TickerMode(
            enabled: active,
            child: widget.builders[i](context),
          ),
        );
      }),
    );
  }
}