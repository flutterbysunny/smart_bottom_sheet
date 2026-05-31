import 'package:flutter/material.dart';
import '../../smart_bottom_sheet.dart';
import '../utils/sheet_config.dart';

/// Direction from which the side sheet appears.
enum SideSheetDirection {
  /// Sheet slides in from the right.
  right,

  /// Sheet slides in from the left.
  left,
}

/// A sheet that slides in from the left or right side of the screen.
///
/// Useful for navigation drawers, filter panels, detail views.
///
/// ```dart
/// SideSheet.show(
///   context,
///   title: 'Filters',
///   direction: SideSheetDirection.right,
///   child: FilterWidget(),
/// );
/// ```
class SideSheet extends StatefulWidget {
  /// Content displayed inside the side sheet.
  final Widget child;

  /// Optional title displayed in the header.
  final String? title;

  /// Optional subtitle displayed below the title.
  final String? subtitle;

  /// Direction from which the sheet slides in.
  final SideSheetDirection direction;

  /// Width of the side sheet as fraction of screen width.
  final double widthFraction;

  /// Global sheet configuration.
  final SheetConfig config;

  /// Called when the sheet is closed.
  final VoidCallback? onClose;

  /// Creates a [SideSheet].
  const SideSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.direction = SideSheetDirection.right,
    this.widthFraction = 0.82,
    this.config = const SheetConfig(),
    this.onClose,
  });

  /// Shows a [SideSheet] as a modal sheet from left or right.
  /// Shows a [SideSheet] as a modal sheet from left or right.
  static Future<void> show(
      BuildContext context, {
        required Widget child,
        String? title,
        String? subtitle,
        SideSheetDirection direction = SideSheetDirection.right,
        double widthFraction = 0.82,
        SheetConfig? config,
        VoidCallback? onClose,
      }) {
    final resolvedConfig = config ?? SheetTheme.configOf(context);
    return showGeneralDialog(
      context: context,
      barrierDismissible: resolvedConfig.isDismissible,
      barrierLabel: 'SideSheet',
      barrierColor: _resolveBarrierColor(resolvedConfig),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => SideSheet(
        title: title,
        subtitle: subtitle,
        direction: direction,
        widthFraction: widthFraction,
        config: resolvedConfig,
        onClose: onClose,
        child: child,
      ),
      transitionBuilder: (context, animation, _, child) {
        final isRight = direction == SideSheetDirection.right;
        final offsetTween = Tween<Offset>(
          begin: Offset(isRight ? 1.0 : -1.0, 0),
          end: Offset.zero,
        );
        return SlideTransition(
          position: offsetTween.animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        );
      },
    );
  }

  static Color _resolveBarrierColor(SheetConfig config) {
    switch (config.backdrop.style) {
      case BackdropStyle.dark:
        return (config.backdrop.color ?? Colors.black)
            .withOpacity(config.backdrop.opacity);
      case BackdropStyle.light:
        return (config.backdrop.color ?? Colors.white)
            .withOpacity(config.backdrop.opacity);
      case BackdropStyle.frosted:
        return (config.backdrop.color ?? Colors.black)
            .withOpacity(config.backdrop.opacity * 0.5);
      case BackdropStyle.none:
        return Colors.transparent;
    }
  }
  @override
  State<SideSheet> createState() => _SideSheetState();
}

class _SideSheetState extends State<SideSheet> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sheetWidth = screenWidth * widget.widthFraction;
    final isRight = widget.direction == SideSheetDirection.right;

    return Align(
      alignment:
      isRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: sheetWidth,
          height: double.infinity,
          decoration: BoxDecoration(
            color: widget.config.backgroundColor ??
                Theme.of(context).colorScheme.surface,
            borderRadius: isRight
                ? const BorderRadius.horizontal(
                left: Radius.circular(20))
                : const BorderRadius.horizontal(
                right: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.15),
                blurRadius: 20,
                offset: isRight
                    ? const Offset(-4, 0)
                    : const Offset(4, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header
                _SideSheetHeader(
                  title: widget.title,
                  subtitle: widget.subtitle,
                  isRight: isRight,
                  onClose: () {
                    Navigator.pop(context);
                    widget.onClose?.call();
                  },
                ),

                Divider(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                ),

                // content
                Expanded(child: widget.child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header bar for the side sheet with title and close button.
class _SideSheetHeader extends StatelessWidget {
  /// Optional title text.
  final String? title;

  /// Optional subtitle text.
  final String? subtitle;

  /// Whether sheet is on the right side.
  final bool isRight;

  /// Called when close button is tapped.
  final VoidCallback onClose;

  const _SideSheetHeader({
    this.title,
    this.subtitle,
    required this.isRight,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final closeBtn = IconButton(
      onPressed: onClose,
      icon: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );

    final titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: isRight
            ? [
          Expanded(child: titleWidget),
          closeBtn,
        ]
            : [
          closeBtn,
          const SizedBox(width: 8),
          Expanded(child: titleWidget),
        ],
      ),
    );
  }
}