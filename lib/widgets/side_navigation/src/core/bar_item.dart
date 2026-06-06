import 'package:flutter/material.dart';
import 'dart:async';

import '../../../cfg_image.dart';
import '../api/side_navigation_bar.dart';
import '../api/side_navigation_bar_item.dart';
import '../api/side_navigation_bar_theme.dart';

/// This widget uses information obtained from [SideNavigationBarItem]
/// to generate the widget which provides an [onTap] callback while
/// it also holds the [index] of its position defined in the [SideNavigationBar]'s
/// [SideNavigationBar.items] field.
class SideNavigationBarItemWidget extends StatefulWidget {
  final SideNavigationBarItem itemData;
  final ValueChanged<int> onTap;
  final int index;
  final SideNavigationBarItemTheme itemTheme;
  final bool expanded;

  const SideNavigationBarItemWidget({
    Key? key,
    required this.itemData,
    required this.onTap,
    required this.index,
    required this.itemTheme,
    required this.expanded,
  }) : super(key: key);

  @override
  State<SideNavigationBarItemWidget> createState() => _SideNavigationBarItemWidgetState();
}

class _SideNavigationBarItemWidgetState extends State<SideNavigationBarItemWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;
  bool _isHeld = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });

    if (widget.itemData.flash) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant SideNavigationBarItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemData.flash != oldWidget.itemData.flash) {
      if (widget.itemData.flash) {
        _controller.forward();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _isHeld = true;
    _timer = Timer(widget.itemData.holdTimeDuration, () {
      if (_isHeld) {
        _action();
      }
    });
  }

  void _action() {
    if (widget.itemData.route != '') {
      Navigator.pushNamed(context, widget.itemData.route!);
    } else {
      widget.onTap(widget.index);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _cancelTimer();
  }

  void _handleTapCancel() {
    _cancelTimer();
  }

  void _cancelTimer() {
    _isHeld = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    final barItems = SideNavigationBar.of(context).widget.items;
    final selectedIndex = SideNavigationBar.of(context).widget.selectedIndex;
    final isSelected = _isTileSelected(barItems, selectedIndex);
    final currentColor = _evaluateColor(context, isSelected);

    // Debug výpis
    print('Item: ${widget.itemData.label}, isSelected: $isSelected, '
        'opacity: ${isSelected ? 1.0 : widget.itemData.inactiveOpacity}, '
        'grayscale: ${widget.itemData.grayscaleWhenInactive}');

    return widget.expanded ? _buildExpandedItem(isSelected, currentColor) : _buildCollapsedItem(isSelected, currentColor);
  }

  /// Build expanded item with full text and optional background image
  Widget _buildExpandedItem(bool isSelected, Color? currentColor) {
    final itemHeight = widget.itemData.height ?? 56.0;
    final hasBackgroundImage = widget.itemData.backgroundImage != null;

    return Container(
      // itemSpacing vytváří mezeru MEZI položkami
      margin: widget.itemData.itemSpacing,
      padding: widget.itemTheme.padding,
      child: GestureDetector(
        onTap: () {
          widget.itemData.holdTimeDuration == Duration.zero ? _action() : null;
        },
        onTapDown: widget.itemData.holdTimeDuration != Duration.zero ? _handleTapDown : null,
        onTapUp: widget.itemData.holdTimeDuration != Duration.zero ? _handleTapUp : null,
        onTapCancel: widget.itemData.holdTimeDuration != Duration.zero ? _handleTapCancel : null,
        child: Container(
          height: itemHeight,
          child: Stack(
            children: [
              // Background layer s opacity a grayscale
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isSelected ? 1.0 : widget.itemData.inactiveOpacity,
                  child: ColorFiltered(
                    colorFilter: isSelected || !widget.itemData.grayscaleWhenInactive
                        ? const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.dst,
                          )
                        : const ColorFilter.matrix(<double>[
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ]),
                    child: hasBackgroundImage
                        ? CfgImage(
                            widget.itemData.backgroundImage!,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: _evaluateBackgroundColor(isSelected),
                            ),
                          ),
                  ),
                ),
              ),

              // lets put the active overlay layer here
              isSelected && widget.itemData.activeImageOverlay != null
                  ? Positioned.fill(
                      child: widget.itemData.activeImageOverlay is Color
                          ? Container(
                              color: widget.itemData.activeImageOverlay as Color,
                            )
                          : widget.itemData.activeImageOverlay is Gradient
                              ? Container(
                                  decoration: BoxDecoration(
                                    gradient: widget.itemData.activeImageOverlay as Gradient,
                                  ),
                                )
                              : const SizedBox.shrink(),
                    )
                  : !isSelected && widget.itemData.inactiveImageOverlay != null
                      ? Positioned.fill(
                          child: widget.itemData.inactiveImageOverlay is Color
                              ? Container(
                                  color: widget.itemData.inactiveImageOverlay as Color,
                                )
                              : widget.itemData.inactiveImageOverlay is Gradient
                                  ? Container(
                                      decoration: BoxDecoration(
                                        gradient: widget.itemData.inactiveImageOverlay as Gradient,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                        )
                      : const SizedBox.shrink(),

              // Text overlay layer - vždy plně viditelný
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: _buildTextWithOverlay(isSelected, currentColor, hasBackgroundImage),
              ),

              // Inactive overlay layer
              // if inactiveOverlay is color we just use color, if gradient we use gradient

              !isSelected && widget.itemData.inactiveOverlay != null
                  ? Positioned.fill(
                      child: widget.itemData.inactiveOverlay is Color
                          ? Container(
                              color: widget.itemData.inactiveOverlay as Color,
                            )
                          : widget.itemData.inactiveOverlay is Gradient
                              ? Container(
                                  decoration: BoxDecoration(
                                    gradient: widget.itemData.inactiveOverlay as Gradient,
                                  ),
                                )
                              : const SizedBox.shrink(),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build text content with localized overlay
  Widget _buildTextWithOverlay(bool isSelected, Color? currentColor, bool hasBackgroundImage) {
    final alignment = _getMainAxisAlignment(widget.itemData.textAlign);
    final useImageStates = widget.itemData.imageStates != null && widget.itemData.imageStates!.isNotEmpty;

    return Container(
      // Overlay pouze v této oblasti
      decoration: hasBackgroundImage && isSelected && widget.itemData.activeTextOverlay != null
          ? BoxDecoration(
              gradient: _getOverlayGradient(widget.itemData.activeTextOverlay),
            )
          : hasBackgroundImage && !isSelected && widget.itemData.inactiveTextOverlay != null
              ? BoxDecoration(
                  gradient: _getOverlayGradient(widget.itemData.inactiveTextOverlay),
                )
              : null,
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
      child: Row(
        mainAxisAlignment: alignment,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Leading icon/image - zobrazí se POUZE pokud showIcon = true
          if (widget.itemData.showIcon && widget.itemData.isVisible) ...[
            if (useImageStates)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: _buildImageState(isSelected),
              )
            else if (widget.itemData.icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Icon(
                  widget.itemData.icon,
                  color: currentColor,
                  size: widget.itemTheme.iconSize,
                ),
              ),
          ],

          // Label
          if (widget.itemData.isVisible)
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: _evaluateTextStyle(currentColor)!,
                child: Text(
                  widget.itemData.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

          // Chip
          if (widget.itemData.chipContent != null && widget.itemData.isVisible)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: FadeTransition(
                opacity: _animation,
                child: Chip(
                  label: widget.itemData.chipContent!,
                  backgroundColor: widget.itemData.chipColor ?? Colors.red,
                ),
              ),
            ),

          // Trailing pictogram
          if (widget.itemData.showPictogram && !widget.itemData.showIcon && useImageStates && widget.itemData.isVisible)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: _buildImageState(isSelected),
            ),
        ],
      ),
    );
  }

  /// Get overlay gradient based on text alignment
  Gradient? _getOverlayGradient(dynamic overlay) {
    // final overlay = widget.itemData.activeTextOverlay;

    // Pokud už má uživatel definovaný overlay, použijeme ho
    if (overlay is LinearGradient) {
      return overlay;
    } else if (overlay is RadialGradient) {
      return overlay;
    } else if (overlay is Gradient) {
      return overlay;
    } else if (overlay is Color) {
      // Pokud je to barva, vytvoříme gradient podle zarovnání textu
      return _createGradientFromColor(overlay);
    }

    return null;
  }

  /// Create gradient from solid color based on text alignment
  Gradient _createGradientFromColor(Color color) {
    switch (widget.itemData.textAlign) {
      case TextAlign.left:
      case TextAlign.start:
        return LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Colors.transparent, color],
        );
      case TextAlign.right:
      case TextAlign.end:
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.transparent, color],
        );
      case TextAlign.center:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, color, Colors.transparent],
        );
      default:
        return LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Colors.transparent, color],
        );
    }
  }

  /// Build collapsed item (icon only) - BEZ background image
  Widget _buildCollapsedItem(bool isSelected, Color? currentColor) {
    final bool useImageStates = widget.itemData.imageStates != null && widget.itemData.imageStates!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: isSelected ? widget.itemTheme.selectedBackgroundColor : widget.itemTheme.unselectedBackgroundColor,
        ),
        child: Padding(
          padding: widget.itemData.padding,
          child: GestureDetector(
            onTap: () {
              widget.itemData.holdTimeDuration == Duration.zero ? _action() : null;
            },
            onTapDown: widget.itemData.holdTimeDuration != Duration.zero ? _handleTapDown : null,
            onTapUp: widget.itemData.holdTimeDuration != Duration.zero ? _handleTapUp : null,
            onTapCancel: widget.itemData.holdTimeDuration != Duration.zero ? _handleTapCancel : null,
            child: Center(
              child: widget.itemData.isVisible
                  ? useImageStates
                      ? _buildImageState(isSelected)
                      : widget.itemData.icon != null
                          ? Icon(
                              widget.itemData.icon,
                              color: currentColor,
                              size: widget.itemTheme.iconSize,
                            )
                          : null
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  /// Build image state widget with color filter
  Widget _buildImageState(bool isSelected) {
    if (widget.itemData.imageStates == null || widget.itemData.imageStates!.isEmpty) {
      return const SizedBox.shrink();
    }

    return ColorFiltered(
      colorFilter: isSelected
          ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
          : const ColorFilter.matrix(<double>[
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
      child: CfgImage(
        widget.itemData.imageStates![isSelected ? 1 : 0].imagePath,
        width: widget.itemTheme.imageMaxWidth ?? 40,
        height: widget.itemTheme.imageMaxHeight ?? 40,
        fit: BoxFit.contain,
        // errorBuilder: (context, error, stackTrace) {
        //   print('Error loading image: ${widget.itemData.imageStates![isSelected ? 1 : 0].imagePath}');
        //   return Icon(
        //     Icons.image_not_supported,
        //     size: widget.itemTheme.imageMaxWidth ?? 40,
        //     color: Colors.grey,
        //   );
        // },
      ),
    );
  }

  /// Get MainAxisAlignment based on TextAlign
  MainAxisAlignment _getMainAxisAlignment(TextAlign align) {
    switch (align) {
      case TextAlign.left:
      case TextAlign.start:
        return MainAxisAlignment.start;
      case TextAlign.center:
        return MainAxisAlignment.center;
      case TextAlign.right:
      case TextAlign.end:
        return MainAxisAlignment.end;
      default:
        return MainAxisAlignment.start;
    }
  }

  bool _isTileSelected(List<SideNavigationBarItem> items, int index) {
    for (final item in items) {
      if (item.label == widget.itemData.label && index == widget.index) {
        return true;
      }
    }
    return false;
  }

  Color? _evaluateColor(BuildContext context, bool isSelected) {
    // Priorita: 1. item vlastní barvy, 2. theme barvy, 3. default barvy
    if (isSelected) {
      return widget.itemData.activeTextColor ?? widget.itemTheme.selectedItemColor ?? SideNavigationBarItemTheme.defaultSelectedItemColor;
    } else {
      final brightness = Theme.of(context).brightness;
      return widget.itemData.inactiveTextColor ?? widget.itemTheme.unselectedItemColor ?? (brightness == Brightness.light ? Colors.grey : Colors.white);
    }
  }

  Color? _evaluateBackgroundColor(bool isSelected) {
    return isSelected ? widget.itemTheme.selectedBackgroundColor : widget.itemTheme.unselectedBackgroundColor;
  }

  TextStyle? _evaluateTextStyle(Color? evaluatedColor) {
    if (widget.itemTheme.labelTextStyle == null) {
      return TextStyle(color: evaluatedColor);
    }
    return widget.itemTheme.labelTextStyle!.apply(color: evaluatedColor);
  }
}
