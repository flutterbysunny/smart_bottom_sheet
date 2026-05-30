import 'package:flutter/material.dart';
import 'sheet_handle.dart';


/// Snap positions for [SnapSheet].
enum SnapPoint {
  /// Minimal height — just a peek (default 90px).
  peek,

  /// Half screen height (default 45% of screen).
  half,

  /// Nearly full screen height (92% of screen).
  full,
}

/// Semantic color options for sheet icons and buttons.
enum SheetColor {
  /// Primary/brand color.
  primary,

  /// Green — success or positive action.
  success,

  /// Red — destructive or dangerous action.
  danger,

  /// Orange — warning or caution.
  warning,
}

/// Global configuration applied to all sheet types.
///
/// ```dart
/// const config = SheetConfig(
///   peekHeight: 120,
///   isDismissible: false,
///   handleStyle: HandleStyle.pill,
///   handleColor: Colors.blue,
/// );
/// ```
class SheetConfig {
  /// Height in pixels for the [SnapPoint.peek] position.
  final double peekHeight;

  /// Fraction of screen height for the [SnapPoint.half] position.
  final double halfHeight;

  /// Whether the sheet can be dismissed by tapping the backdrop.
  final bool isDismissible;

  /// Whether to show the drag handle bar at the top of the sheet.
  final bool showHandle;

  /// Visual style of the drag handle.
  final HandleStyle handleStyle;

  /// Custom color for the drag handle.
  final Color? handleColor;

  /// Background color of the sheet. Defaults to [ColorScheme.surface].
  final Color? backgroundColor;

  /// Border radius of the sheet. Defaults to 20px top corners.
  final BorderRadius? borderRadius;

  /// Creates a [SheetConfig] with optional customization.
  const SheetConfig({
    this.peekHeight = 90,
    this.halfHeight = 0.45,
    this.isDismissible = true,
    this.showHandle = true,
    this.handleStyle = HandleStyle.defaultHandle,
    this.handleColor,
    this.backgroundColor,
    this.borderRadius,
  });
}

/// Represents a single action item in [ActionMenuSheet].
///
/// ```dart
/// SheetAction(
///   icon: Icons.share_rounded,
///   label: 'Share',
///   onTap: () {},
/// )
/// ```
class SheetAction {
  /// Icon displayed on the left side of the action.
  final IconData icon;

  /// Label text for the action.
  final String label;

  /// Whether this action is destructive (renders in red).
  final bool isDestructive;

  /// Callback when the action is tapped.
  final VoidCallback onTap;

  /// Creates a [SheetAction].
  const SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}