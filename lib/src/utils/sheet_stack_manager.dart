import 'package:flutter/material.dart';
import '../utils/sheet_config.dart';

/// Manages a stack of bottom sheets layered on top of each other.
///
/// Similar to Apple Maps — tapping a result opens a detail sheet
/// on top of the list sheet, each maintaining its own state.
///
/// ```dart
/// SheetStackManager.push(
///   context,
///   title: 'Blue Tokai Coffee',
///   child: CoffeeDetailWidget(),
/// );
///
/// SheetStackManager.pop(context);
/// ```
class SheetStackManager {
  SheetStackManager._();

  /// Pushes a new sheet on top of the current sheet stack.
  static Future<void> push(
      BuildContext context, {
        required Widget child,
        String? title,
        String? subtitle,
        SheetConfig config = const SheetConfig(),
        VoidCallback? onClose,
      }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: config.isDismissible,
      isScrollControlled: true,
      builder: (_) => _StackedSheet(
        title: title,
        subtitle: subtitle,
        config: config,
        onClose: onClose,
        child: child,
      ),
    );
  }

  /// Pops the top sheet from the stack.
  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// A single sheet in the stack with header and close button.
class _StackedSheet extends StatelessWidget {
  /// Optional title displayed at the top of the sheet.
  final String? title;

  /// Optional subtitle displayed below the title.
  final String? subtitle;

  /// Content of the sheet.
  final Widget child;

  /// Sheet configuration.
  final SheetConfig config;

  /// Called when the sheet is closed.
  final VoidCallback? onClose;

  const _StackedSheet({
    required this.child,
    this.title,
    this.subtitle,
    this.config = const SheetConfig(),
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: config.backgroundColor ??
            Theme.of(context).colorScheme.surface,
        borderRadius: config.borderRadius ??
            const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // handle
          if (config.showHandle)
            Padding(
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

          // header row
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              color:
                              Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // close button
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onClose?.call();
                    },
                    icon: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Divider(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 8),

          // content
          Flexible(child: child),
        ],
      ),
    );
  }
}