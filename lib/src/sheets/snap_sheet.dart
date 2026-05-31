import 'package:flutter/material.dart';
import '../../smart_bottom_sheet.dart';
import '../controller/sheet_controller.dart';
import '../physics/sheet_physics.dart';
import '../utils/sheet_config.dart';

/// A bottom sheet with 3 snap points and physics-based dragging.
///
/// Supports nested scrollable content — inner list scrolls when
/// sheet is fully expanded, drag collapses when list is at top.
///
/// ```dart
/// SnapSheet.show(
///   context,
///   initialSnap: SnapPoint.half,
///   onSnap: (snap) => print('Snapped to $snap'),
///   child: YourScrollableWidget(),
/// );
/// ```
class SnapSheet extends StatefulWidget {
  /// Content displayed inside the sheet.
  final Widget child;

  /// Global sheet configuration.
  final SheetConfig config;

  /// Optional external controller for programmatic control.
  final SheetController? controller;

  /// Initial snap position when sheet opens.
  final SnapPoint initialSnap;

  /// Called when sheet is dismissed.
  final VoidCallback? onDismiss;

  /// Called when sheet snaps to a new position.
  final void Function(SnapPoint snap)? onSnap;

  /// Called when sheet reaches full snap.
  final VoidCallback? onOpen;

  /// Called when sheet is closed.
  final VoidCallback? onClose;

  /// Creates a [SnapSheet].
  const SnapSheet({
    super.key,
    required this.child,
    this.config = const SheetConfig(),
    this.controller,
    this.initialSnap = SnapPoint.half,
    this.onDismiss,
    this.onSnap,
    this.onOpen,
    this.onClose,
  });

  /// Shows a [SnapSheet] as a modal bottom sheet.
  /// Shows a [SnapSheet] as a modal bottom sheet.
  static Future<void> show(
      BuildContext context, {
        required Widget child,
        SheetConfig? config,
        SnapPoint initialSnap = SnapPoint.half,
        SheetController? controller,
        VoidCallback? onDismiss,
        void Function(SnapPoint snap)? onSnap,
        VoidCallback? onOpen,
        VoidCallback? onClose,
      }) {
    final resolvedConfig = config ?? SheetTheme.configOf(context);
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: resolvedConfig.isDismissible,
      isScrollControlled: true,
      barrierColor: _resolveBarrierColor(resolvedConfig),
      builder: (_) => SnapSheet(
        config: resolvedConfig,
        initialSnap: initialSnap,
        controller: controller,
        onDismiss: onDismiss,
        onSnap: onSnap,
        onOpen: onOpen,
        onClose: onClose,
        child: child,
      ),
    );
  }

  static Color _resolveBarrierColor(SheetConfig config) {
    switch (config.backdrop.style) {
      case BackdropStyle.dark:
        return (config.backdrop.color ?? Colors.black)
            .withValues(alpha: config.backdrop.opacity);
      case BackdropStyle.light:
        return (config.backdrop.color ?? Colors.white)
            .withValues(alpha:config.backdrop.opacity);
      case BackdropStyle.frosted:
        return (config.backdrop.color ?? Colors.black)
            .withValues(alpha:config.backdrop.opacity * 0.5);
      case BackdropStyle.none:
        return Colors.transparent;
    }
  }

  @override
  State<SnapSheet> createState() => _SnapSheetState();
}

class _SnapSheetState extends State<SnapSheet>
    with SingleTickerProviderStateMixin {
  late SheetController _controller;
  late AnimationController _animController;
  late Animation<double> _heightAnimation;

  // nested scroll support
  final ScrollController _scrollController = ScrollController();
  bool _isScrollingContent = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        SheetController(
          peekHeight: widget.config.peekHeight,
          halfFraction: widget.config.halfHeight,
          initialSnap: widget.initialSnap,
          onSnap: widget.onSnap,
          onOpen: widget.onOpen,
          onClose: widget.onClose,
        );

    _animController = AnimationController(
      vsync: this,
      duration: SheetPhysics.snapDuration,
    );

    _heightAnimation = const AlwaysStoppedAnimation(0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init(context);
      _animateToHeight(_controller.currentHeight);
    });

    _controller.addListener(_onControllerUpdate);

    _scrollController.addListener(_onScrollUpdate);
  }

  void _onScrollUpdate() {
    // content scroll top par hai — sheet drag allow karo
    _isScrollingContent = _scrollController.offset > 0;
  }

  void _onControllerUpdate() {
    if (!_controller.isDragging) {
      _animateToHeight(_controller.currentHeight);
    } else {
      setState(() {});
    }
  }

  void _animateToHeight(double target) {
    final begin = _heightAnimation.value;
    _heightAnimation = Tween<double>(begin: begin, end: target).animate(
      CurvedAnimation(
        parent: _animController,
        curve: SheetPhysics.snapCurve,
      ),
    );
    _animController.forward(from: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenHeight = MediaQuery.of(context).size.height;
    _heightAnimation = Tween<double>(
      begin: widget.config.peekHeight,
      end: screenHeight * widget.config.halfHeight,
    ).animate(_animController);
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _shouldDragSheet(double delta) {
    // full snap par aur content upar scroll hai — sheet drag mat karo
    if (_controller.currentSnap == SnapPoint.full &&
        _isScrollingContent &&
        delta < 0) {
      return false;
    }
    // full snap par aur swipe down hai aur content top par hai — sheet drag karo
    if (_controller.currentSnap == SnapPoint.full &&
        !_isScrollingContent &&
        delta > 0) {
      return true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (!_shouldDragSheet(details.delta.dy)) return;

        final newHeight = _controller.currentHeight - details.delta.dy;
        final withResistance = SheetPhysics.applyResistance(
          currentHeight: newHeight,
          minHeight: widget.config.peekHeight,
          maxHeight: screenHeight * 0.92,
        );
        setState(() {
          _heightAnimation = AlwaysStoppedAnimation(withResistance);
        });
        _controller.onDragUpdate(
          DragUpdateDetails(
            globalPosition: details.globalPosition,
            delta: Offset(0, details.delta.dy),
            primaryDelta: details.delta.dy,
          ),
          context,
        );
      },
      onVerticalDragEnd: (details) {
        if (SheetPhysics.shouldDismiss(
          currentHeight: _controller.currentHeight,
          peekHeight: widget.config.peekHeight,
        )) {
          Navigator.pop(context);
          widget.onDismiss?.call();
          widget.onClose?.call();
          return;
        }
        _controller.onDragEnd(details, context);
      },
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: _heightAnimation.value,
              decoration: BoxDecoration(
                color: widget.config.backgroundColor ??
                    Theme.of(context).colorScheme.surface,
                borderRadius: widget.config.borderRadius ??
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: child,
            ),
          );
        },
        child: Column(
          children: [
            if (widget.config.showHandle)
              _SnapHandle(controller: _controller),
            _SnapIndicator(currentSnap: _controller.currentSnap),
            Expanded(
              // nested scroll — PrimaryScrollController se connect karo
              child: PrimaryScrollController(
                controller: _scrollController,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated drag handle that changes style at full snap.
class _SnapHandle extends StatelessWidget {
  /// The sheet controller to observe snap state.
  final SheetController controller;

  const _SnapHandle({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isExpanded = controller.currentSnap == SnapPoint.full;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isExpanded ? 48 : 36,
        height: 4,
        decoration: BoxDecoration(
          color: isExpanded
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Animated dots indicating current snap position.
class _SnapIndicator extends StatelessWidget {
  /// The current active snap point.
  final SnapPoint currentSnap;

  const _SnapIndicator({required this.currentSnap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: SnapPoint.values.map((snap) {
        final isActive = snap == currentSnap;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          width: isActive ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }).toList(),
    );
  }
}