import 'dart:ui';
import 'package:flutter/material.dart';

/// Style options for the sheet backdrop.
enum BackdropStyle {
  /// Standard dark overlay backdrop.
  dark,

  /// Light overlay backdrop.
  light,

  /// Frosted glass blur effect.
  frosted,

  /// No backdrop.
  none,
}

/// Configures the backdrop behind a bottom sheet.
///
/// ```dart
/// SheetBackdrop(
///   style: BackdropStyle.frosted,
///   blurStrength: 10,
///   opacity: 0.3,
/// )
/// ```
class SheetBackdrop {
  /// Visual style of the backdrop.
  final BackdropStyle style;

  /// Blur strength for [BackdropStyle.frosted]. Default is 8.
  final double blurStrength;

  /// Opacity of the backdrop overlay. Default is 0.5.
  final double opacity;

  /// Custom backdrop color. Defaults based on [style].
  final Color? color;

  /// Creates a [SheetBackdrop].
  const SheetBackdrop({
    this.style = BackdropStyle.dark,
    this.blurStrength = 8,
    this.opacity = 0.5,
    this.color,
  });

  /// Frosted glass preset.
  const SheetBackdrop.frosted({
    this.blurStrength = 10,
    this.opacity = 0.2,
    this.color,
  }) : style = BackdropStyle.frosted;

  /// No backdrop preset.
  const SheetBackdrop.none()
      : style = BackdropStyle.none,
        blurStrength = 0,
        opacity = 0,
        color = null;
}

/// Widget that renders the backdrop behind a sheet.
class SheetBackdropWidget extends StatelessWidget {
  /// Backdrop configuration.
  final SheetBackdrop backdrop;

  /// Called when backdrop is tapped.
  final VoidCallback? onTap;

  /// Creates a [SheetBackdropWidget].
  const SheetBackdropWidget({
    super.key,
    required this.backdrop,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (backdrop.style == BackdropStyle.none) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: _buildBackdrop(context),
    );
  }

  Widget _buildBackdrop(BuildContext context) {
    switch (backdrop.style) {
      case BackdropStyle.frosted:
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: backdrop.blurStrength,
            sigmaY: backdrop.blurStrength,
          ),
          child: Container(
            color: (backdrop.color ?? Colors.white)
                .withValues(alpha:backdrop.opacity),
          ),
        );

      case BackdropStyle.dark:
        return Container(
          color: (backdrop.color ?? Colors.black)
              .withValues(alpha:backdrop.opacity),
        );

      case BackdropStyle.light:
        return Container(
          color: (backdrop.color ?? Colors.white)
              .withValues(alpha:backdrop.opacity),
        );

      case BackdropStyle.none:
        return const SizedBox.shrink();
    }
  }
}