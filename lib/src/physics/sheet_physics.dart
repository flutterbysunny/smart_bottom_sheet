import 'package:flutter/material.dart';

/// Physics utilities for sheet drag behavior.
///
/// Provides rubber-band resistance, dampening,
/// dismiss threshold, and animation constants.
class SheetPhysics {
  /// Applies elastic resistance when dragging beyond boundaries.
  ///
  /// Returns a value that resists going past [minHeight] or [maxHeight].
  static double applyResistance({
    required double currentHeight,
    required double minHeight,
    required double maxHeight,
    double resistanceFactor = 0.3,
  }) {
    if (currentHeight < minHeight) {
      final overflow = minHeight - currentHeight;
      return minHeight - (overflow * resistanceFactor);
    }
    if (currentHeight > maxHeight) {
      final overflow = currentHeight - maxHeight;
      return maxHeight + (overflow * resistanceFactor);
    }
    return currentHeight;
  }

  /// Slows down drag delta when sheet is out of bounds.
  static double applyDampening({
    required double delta,
    required double currentHeight,
    required double minHeight,
    required double maxHeight,
    double dampeningFactor = 0.6,
  }) {
    final bool isOutOfBounds =
        currentHeight < minHeight || currentHeight > maxHeight;
    return isOutOfBounds ? delta * dampeningFactor : delta;
  }

  /// Returns true if sheet should be dismissed based on current height.
  static bool shouldDismiss({
    required double currentHeight,
    required double peekHeight,
    double threshold = 0.6,
  }) {
    return currentHeight < peekHeight * threshold;
  }

  /// Curve used for snap animations.
  static const Curve snapCurve = Curves.easeOutCubic;

  /// Curve used for dismiss animations.
  static const Curve dismissCurve = Curves.easeInCubic;

  /// Duration for snap animations.
  static const Duration snapDuration = Duration(milliseconds: 320);

  /// Duration for dismiss animations.
  static const Duration dismissDuration = Duration(milliseconds: 220);
}