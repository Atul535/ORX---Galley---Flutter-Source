import 'package:flutter/material.dart';

import '../../../../model/image_state.dart';

/// Interface to provide information about item use in [SideNavigationBar.items]
class SideNavigationBarItem {
  /// The [IconData] you want to display
  final IconData? icon;

  /// A text to display route information
  final String label;

  /// Padding around the item
  /// Defaults to [EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0)]
  final EdgeInsets padding;
  
  final bool flash;
  final Widget? chipContent;
  final Color? chipColor;
  final String? route;
  final Duration holdTimeDuration;
  final bool isVisible;
  final List<ImageState>? imageStates;

  /// Height of the item in pixels
  /// If null, uses default height
  final double? height;

  /// Background image URL or path for the item
  final String? backgroundImage;

  /// Overlay color or gradient to apply over background image
  /// Can be:
  /// - Simple color: Color(0x80000000) or Colors.black.withOpacity(0.5)
  /// - Linear gradient: LinearGradient(...)
  /// - Radial gradient: RadialGradient(...)
  final dynamic activeTextOverlay;

  /// Overlay color or gradient to apply over background image
  /// Can be:
  /// - Simple color: Color(0x80000000) or Colors.black.withOpacity(0.5)
  /// - Linear gradient: LinearGradient(...)
  /// - Radial gradient: RadialGradient(...)
  final dynamic inactiveTextOverlay;

  /// Overlay for inactive/unselected state
  /// If null, uses the same overlay as active state
  /// Useful for darkening inactive items
  final dynamic inactiveOverlay;

  /// Active overlay for text/icon visibility
  /// If null, uses the same overlay as inactive state
  /// Useful for brightening active items
  final dynamic activeImageOverlay;

  /// Active overlay for text/icon visibility
  /// If null, uses the same overlay as inactive state
  /// Useful for brightening active items
  final dynamic inactiveImageOverlay;

  /// Text alignment within the item
  /// Options: TextAlign.left, TextAlign.center, TextAlign.right
  final TextAlign textAlign;

  /// Whether to show the icon (if provided)
  /// Defaults to true
  final bool showIcon;

  /// Whether to show the pictogram/imageStates (if provided)
  /// Defaults to true
  final bool showPictogram;

  /// Opacity for inactive items (0.0 - 1.0)
  /// Defaults to 0.6
  final double inactiveOpacity;

  /// Whether to apply grayscale filter to inactive items
  /// Defaults to true
  final bool grayscaleWhenInactive;

  /// Text color when item is active/selected
  /// If null, uses theme's selectedItemColor
  final Color? activeTextColor;

  /// Text color when item is inactive/unselected
  /// If null, uses theme's unselectedItemColor
  final Color? inactiveTextColor;

  /// Spacing around the item (margin between items)
  /// Defaults to EdgeInsets.zero
  final EdgeInsets itemSpacing;

  /// Item data
  const SideNavigationBarItem({
    this.route = '',
    this.icon,
    required this.label,
    this.padding = const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
    this.chipContent,
    this.chipColor = Colors.red,
    this.flash = false,
    this.holdTimeDuration = Duration.zero,
    this.isVisible = true,
    this.imageStates,
    this.height,
    this.backgroundImage,
    this.activeTextOverlay,
    this.inactiveTextOverlay,
    this.textAlign = TextAlign.left,
    this.showIcon = true,
    this.showPictogram = true,
    this.inactiveOpacity = 0.6,
    this.grayscaleWhenInactive = true,
    this.activeTextColor,
    this.inactiveTextColor,
    this.itemSpacing = EdgeInsets.zero,
    this.inactiveOverlay,
    this.inactiveImageOverlay,
    this.activeImageOverlay,
  });
}