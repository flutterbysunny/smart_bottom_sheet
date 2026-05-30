import 'package:flutter/material.dart';

class SheetPhysics {
  /// Rubber-band resistance — boundary cross karne par elastic feel
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

  /// Drag delta — fast drag par slow response (natural feel)
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

  /// Sheet dismiss threshold — kitna neeche aane par close ho
  static bool shouldDismiss({
    required double currentHeight,
    required double peekHeight,
    double threshold = 0.6,
  }) {
    return currentHeight < peekHeight * threshold;
  }

  /// Animation curve — drag end ke baad snap animation
  static const Curve snapCurve = Curves.easeOutCubic;
  static const Curve dismissCurve = Curves.easeInCubic;
  static const Duration snapDuration = Duration(milliseconds: 320);
  static const Duration dismissDuration = Duration(milliseconds: 220);
}