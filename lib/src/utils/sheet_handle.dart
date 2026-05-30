import 'package:flutter/material.dart';

/// Style options for the sheet drag handle.
enum HandleStyle {
  /// Default gray bar handle.
  defaultHandle,

  /// Pill-shaped colored handle.
  pill,

  /// Animated pulsing handle.
  pulse,

  /// Line handle with arrow indicator.
  arrow,

  /// No handle shown.
  none,
}

/// Customizable drag handle for all sheet types.
///
/// ```dart
/// SheetHandle(
///   style: HandleStyle.pill,
///   color: Colors.blue,
/// )
/// ```
class SheetHandle extends StatefulWidget {
  /// Visual style of the handle.
  final HandleStyle style;

  /// Custom color for the handle. Defaults to [dividerColor].
  final Color? color;

  /// Width of the handle bar.
  final double? width;

  /// Height of the handle bar.
  final double? height;

  /// Creates a [SheetHandle].
  const SheetHandle({
    super.key,
    this.style = HandleStyle.defaultHandle,
    this.color,
    this.width,
    this.height,
  });

  @override
  State<SheetHandle> createState() => _SheetHandleState();
}

class _SheetHandleState extends State<SheetHandle>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.style == HandleStyle.pulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.style == HandleStyle.none) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: _buildHandle(context),
    );
  }

  Widget _buildHandle(BuildContext context) {
    final color = widget.color ?? Theme.of(context).dividerColor;

    switch (widget.style) {
      case HandleStyle.defaultHandle:
        return _DefaultHandle(
          color: color,
          width: widget.width ?? 36,
          height: widget.height ?? 4,
        );

      case HandleStyle.pill:
        return _PillHandle(
          color: color,
          width: widget.width ?? 48,
          height: widget.height ?? 6,
        );

      case HandleStyle.pulse:
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (_, __) => Transform.scale(
            scaleX: _pulseAnimation.value,
            child: _DefaultHandle(
              color: color,
              width: widget.width ?? 36,
              height: widget.height ?? 4,
            ),
          ),
        );

      case HandleStyle.arrow:
        return _ArrowHandle(color: color);

      case HandleStyle.none:
        return const SizedBox.shrink();
    }
  }
}

/// Default thin bar handle.
class _DefaultHandle extends StatelessWidget {
  final Color color;
  final double width;
  final double height;

  const _DefaultHandle({
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

/// Wider pill-shaped handle with rounded ends.
class _PillHandle extends StatelessWidget {
  final Color color;
  final double width;
  final double height;

  const _PillHandle({
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height),
      ),
    );
  }
}

/// Handle with upward arrow indicator.
class _ArrowHandle extends StatelessWidget {
  final Color color;

  const _ArrowHandle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.keyboard_arrow_up_rounded,
          color: color,
          size: 20,
        ),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}