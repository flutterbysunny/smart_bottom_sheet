import 'package:flutter/material.dart';
import '../utils/sheet_config.dart';
import '../utils/sheet_handle.dart';
import '../utils/sheet_backdrop.dart';
import '../utils/sheet_theme.dart';

/// A single step in [StepperSheet].
///
/// ```dart
/// SheetStep(
///   title: 'Address',
///   child: AddressWidget(),
/// )
/// ```
class SheetStep {
  /// Title of this step shown in the indicator.
  final String title;

  /// Content widget for this step.
  final Widget child;

  /// Whether to show the back button on this step.
  final bool showBackButton;

  /// Creates a [SheetStep].
  const SheetStep({
    required this.title,
    required this.child,
    this.showBackButton = true,
  });
}

/// A bottom sheet with a multi-step flow and progress indicator.
///
/// Each step slides in with animation. No full-screen navigation needed.
/// Automatically uses [SheetTheme] config if available in widget tree.
///
/// ```dart
/// StepperSheet.show(
///   context,
///   title: 'Place Order',
///   steps: [
///     SheetStep(title: 'Bag', child: BagWidget()),
///     SheetStep(title: 'Address', child: AddressWidget()),
///     SheetStep(title: 'Payment', child: PaymentWidget()),
///   ],
///   onComplete: () => placeOrder(),
/// );
/// ```
class StepperSheet extends StatefulWidget {
  /// Title displayed at the top of the sheet.
  final String title;

  /// List of steps to display.
  final List<SheetStep> steps;

  /// Label for the next button.
  final String nextLabel;

  /// Label for the finish button on the last step.
  final String finishLabel;

  /// Sheet configuration — falls back to [SheetTheme] if not provided.
  final SheetConfig config;

  /// Called when all steps are completed.
  final VoidCallback? onComplete;

  /// Called when the sheet is cancelled.
  final VoidCallback? onCancel;

  /// Creates a [StepperSheet].
  const StepperSheet({
    super.key,
    required this.title,
    required this.steps,
    this.nextLabel = 'Continue',
    this.finishLabel = 'Done',
    this.config = const SheetConfig(),
    this.onComplete,
    this.onCancel,
  });

  /// Shows a [StepperSheet] as a modal bottom sheet.
  static Future<void> show(
      BuildContext context, {
        required String title,
        required List<SheetStep> steps,
        String nextLabel = 'Continue',
        String finishLabel = 'Done',
        SheetConfig? config,
        VoidCallback? onComplete,
        VoidCallback? onCancel,
      }) {
    final resolvedConfig = config ?? SheetTheme.configOf(context);
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: resolvedConfig.isDismissible,
      isScrollControlled: true,
      barrierColor: _resolveBarrierColor(resolvedConfig),
      builder: (_) => StepperSheet(
        title: title,
        steps: steps,
        nextLabel: nextLabel,
        finishLabel: finishLabel,
        config: resolvedConfig,
        onComplete: onComplete,
        onCancel: onCancel,
      ),
    );
  }

  static Color _resolveBarrierColor(SheetConfig config) {
    switch (config.backdrop.style) {
      case BackdropStyle.dark:
        return (config.backdrop.color ?? Colors.black)
            .withValues(alpha:config.backdrop.opacity);
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
  State<StepperSheet> createState() => _StepperSheetState();
}

class _StepperSheetState extends State<StepperSheet>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  bool _isForward = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _updateSlideAnimation();
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _updateSlideAnimation() {
    _slideAnimation = Tween<Offset>(
      begin: Offset(_isForward ? 1.0 : -1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _goNext() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _isForward = true;
        _currentStep++;
        _updateSlideAnimation();
      });
      _animController.forward(from: 0);
    } else {
      Navigator.pop(context);
      widget.onComplete?.call();
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() {
        _isForward = false;
        _currentStep--;
        _updateSlideAnimation();
      });
      _animController.forward(from: 0);
    } else {
      Navigator.pop(context);
      widget.onCancel?.call();
    }
  }

  double get _progress => (_currentStep + 1) / widget.steps.length;
  bool get _isLastStep => _currentStep == widget.steps.length - 1;

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStep];
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: widget.config.backgroundColor ??
            Theme.of(context).colorScheme.surface,
        borderRadius: widget.config.borderRadius ??
            const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20, 0, 20,
        bottomInset + MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // custom handle
          Center(
            child: SheetHandle(
              style: widget.config.handleStyle,
              color: widget.config.handleColor,
            ),
          ),

          // progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 4,
              backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // step counter
          Text(
            'Step ${_currentStep + 1} of ${widget.steps.length}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),

          // step indicators
          Row(
            children: List.generate(widget.steps.length, (i) {
              final isDone = i < _currentStep;
              final isActive = i == _currentStep;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _StepIndicator(
                    index: i + 1,
                    label: widget.steps[i].title,
                    isDone: isDone,
                    isActive: isActive,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // step title
          Text(
            step.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 12),

          // animated step content
          ClipRect(
            child: SlideTransition(
              position: _slideAnimation,
              child: step.child,
            ),
          ),
          const SizedBox(height: 16),

          // buttons
          Row(
            children: [
              if (step.showBackButton)
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _goBack,
                    child: Text(
                      _currentStep == 0 ? 'Cancel' : 'Back',
                      style:
                      const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              if (step.showBackButton) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _goNext,
                  child: Text(
                    _isLastStep ? widget.finishLabel : widget.nextLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Animated step indicator circle with label.
class _StepIndicator extends StatelessWidget {
  /// Step number displayed inside the circle.
  final int index;

  /// Label below the circle.
  final String label;

  /// Whether this step is completed.
  final bool isDone;

  /// Whether this step is currently active.
  final bool isActive;

  const _StepIndicator({
    required this.index,
    required this.label,
    required this.isDone,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone || isActive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? Theme.of(context).colorScheme.primary
                : isActive
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
          ),
          child: Center(
            child: isDone
                ? Icon(
              Icons.check,
              size: 14,
              color: Theme.of(context).colorScheme.onPrimary,
            )
                : Text(
              '$index',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight:
            isActive ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}