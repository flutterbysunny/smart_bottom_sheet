import 'package:flutter/material.dart';
import '../controller/sheet_controller.dart';
import '../physics/sheet_physics.dart';
import '../utils/sheet_config.dart';

class SnapSheet extends StatefulWidget {
  final Widget child;
  final SheetConfig config;
  final SheetController? controller;
  final SnapPoint initialSnap;
  final VoidCallback? onDismiss;

  const SnapSheet({
    super.key,
    required this.child,
    this.config = const SheetConfig(),
    this.controller,
    this.initialSnap = SnapPoint.half,
    this.onDismiss,
  });

  static Future<void> show(
      BuildContext context, {
        required Widget child,
        SheetConfig config = const SheetConfig(),
        SnapPoint initialSnap = SnapPoint.half,
        SheetController? controller,
        VoidCallback? onDismiss,
      }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: config.isDismissible,
      isScrollControlled: true,
      builder: (_) => SnapSheet(
        config: config,
        initialSnap: initialSnap,
        controller: controller,
        onDismiss: onDismiss,
        child: child,
      ),
    );
  }

  @override
  State<SnapSheet> createState() => _SnapSheetState();
}

class _SnapSheetState extends State<SnapSheet>
    with SingleTickerProviderStateMixin {
  late SheetController _controller;
  late AnimationController _animController;
  late Animation<double> _heightAnimation;
  double dragStartHeight = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        SheetController(
          peekHeight: widget.config.peekHeight,
          halfFraction: widget.config.halfHeight,
          initialSnap: widget.initialSnap,
        );

    _animController = AnimationController(
      vsync: this,
      duration: SheetPhysics.snapDuration,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init(context);
      _animateToHeight(_controller.currentHeight);
    });

    _controller.addListener(_onControllerUpdate);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onVerticalDragStart: (details) {
        dragStartHeight = _controller.currentHeight;
      },
      onVerticalDragUpdate: (details) {
        final newHeight = _controller.currentHeight - details.delta.dy;
        final dampened = SheetPhysics.applyDampening(
          delta: details.delta.dy,
          currentHeight: _controller.currentHeight,
          minHeight: widget.config.peekHeight,
          maxHeight: screenHeight * 0.92,
        );
        _controller.onDragUpdate(
          DragUpdateDetails(
            globalPosition: details.globalPosition,
            delta: Offset(0, dampened),
            primaryDelta: dampened,
          ),
          context,
        );

        // rubber-band apply karo
        final withResistance = SheetPhysics.applyResistance(
          currentHeight: newHeight,
          minHeight: widget.config.peekHeight,
          maxHeight: screenHeight * 0.92,
        );
        setState(() {
          _heightAnimation = AlwaysStoppedAnimation(withResistance);
        });
      },
      onVerticalDragEnd: (details) {
        // dismiss check
        if (SheetPhysics.shouldDismiss(
          currentHeight: _controller.currentHeight,
          peekHeight: widget.config.peekHeight,
        )) {
          Navigator.pop(context);
          widget.onDismiss?.call();
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
            if (widget.config.showHandle) _SnapHandle(controller: _controller),
            _SnapIndicator(currentSnap: _controller.currentSnap),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}

class _SnapHandle extends StatelessWidget {
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

class _SnapIndicator extends StatelessWidget {
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