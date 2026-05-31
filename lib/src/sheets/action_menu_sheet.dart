import 'package:flutter/material.dart';
import '../utils/sheet_config.dart';
import '../utils/sheet_handle.dart';
import '../utils/sheet_backdrop.dart';
import '../utils/sheet_theme.dart';

/// A bottom sheet that displays a list of actions with icons.
///
/// Supports destructive actions, custom icons, and optional title/subtitle.
/// Automatically uses [SheetTheme] config if available in widget tree.
///
/// ```dart
/// ActionMenuSheet.show(
///   context,
///   title: 'File Options',
///   actions: [
///     SheetAction(
///       icon: Icons.share_rounded,
///       label: 'Share',
///       onTap: () {},
///     ),
///     SheetAction(
///       icon: Icons.delete_rounded,
///       label: 'Delete',
///       isDestructive: true,
///       onTap: () {},
///     ),
///   ],
/// );
/// ```
class ActionMenuSheet extends StatelessWidget {
  /// Optional title displayed at the top of the sheet.
  final String? title;

  /// Optional subtitle displayed below the title.
  final String? subtitle;

  /// List of actions to display.
  final List<SheetAction> actions;

  /// Sheet configuration — falls back to [SheetTheme] if not provided.
  final SheetConfig config;

  /// Creates an [ActionMenuSheet].
  const ActionMenuSheet({
    super.key,
    this.title,
    this.subtitle,
    required this.actions,
    this.config = const SheetConfig(),
  });

  /// Shows an [ActionMenuSheet] as a modal bottom sheet.
  static Future<void> show(
      BuildContext context, {
        String? title,
        String? subtitle,
        required List<SheetAction> actions,
        SheetConfig? config,
      }) {
    final resolvedConfig = config ?? SheetTheme.configOf(context);
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: resolvedConfig.isDismissible,
      barrierColor: _resolveBarrierColor(resolvedConfig),
      builder: (_) => ActionMenuSheet(
        title: title,
        subtitle: subtitle,
        actions: actions,
        config: resolvedConfig,
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: config.backgroundColor ??
            Theme.of(context).colorScheme.surface,
        borderRadius: config.borderRadius ??
            const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // custom handle
          if (config.showHandle)
            SheetHandle(
              style: config.handleStyle,
              color: config.handleColor,
            ),

          if (title != null || subtitle != null)
            _Header(title: title, subtitle: subtitle),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            itemBuilder: (_, i) => _ActionTile(action: actions[i]),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const _Header({this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Divider(height: 1, color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final SheetAction action;

  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final color = action.isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;

    final bgColor = action.isDestructive
        ? Theme.of(context).colorScheme.errorContainer.withValues(alpha:0.3)
        : Theme.of(context)
        .colorScheme
        .surfaceContainerHighest
        .withValues(alpha:0.4);

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        action.onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(action.icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                action.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.outline,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}