import 'package:flutter/material.dart';
import '../utils/sheet_config.dart';

class ActionMenuSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<SheetAction> actions;
  final SheetConfig config;

  const ActionMenuSheet({
    super.key,
    this.title,
    this.subtitle,
    required this.actions,
    this.config = const SheetConfig(),
  });

  static Future<void> show(
      BuildContext context, {
        String? title,
        String? subtitle,
        required List<SheetAction> actions,
        SheetConfig config = const SheetConfig(),
      }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: config.isDismissible,
      builder: (_) => ActionMenuSheet(
        title: title,
        subtitle: subtitle,
        actions: actions,
        config: config,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: config.backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: config.borderRadius ??
            const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (config.showHandle) _Handle(),
          if (title != null || subtitle != null) _Header(title: title, subtitle: subtitle),
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

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor,
          borderRadius: BorderRadius.circular(2),
        ),
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
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
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
        ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3)
        : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4);

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
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w500),
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