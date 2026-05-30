import 'package:flutter/material.dart';
import '../utils/sheet_config.dart';

class SheetStep {
  final String title;
  final Widget child;
  final bool showBackButton;

  const SheetStep({
    required this.title,
    required this.child,
    this.showBackButton = true,
  });
}

class StepperSheet extends StatefulWidget {
  final String title;
  final List<SheetStep> steps;
  final String nextLabel;
  final String finishLabel;
  final SheetConfig config;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

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

  static Future<void> show(
      BuildContext context, {
        required String title,
        required List<SheetStep> steps,
        String nextLabel = 'Continue',
        String finishLabel = 'Done',
        SheetConfig config = const SheetConfig(),
        VoidCallback? onComplete,
        VoidCallback? onCancel,
      }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: config.isDismissible,
      isScrollControlled: true,
      builder: (_) => StepperSheet(
        title: title,
        steps: steps,
        nextLabel: nextLabel,
        finishLabel: finishLabel,
        config: config,
        onComplete: onComplete,
        onCancel: onCancel,
      ),
    );
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
          // handle
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 4,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
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
                      style: const TextStyle(fontWeight: FontWeight.w500),
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

class _StepIndicator extends StatelessWidget {
  final int index;
  final String label;
  final bool isDone;
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
                : Theme.of(context).colorScheme.surfaceContainerHighest,
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
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
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