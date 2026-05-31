import 'package:flutter/material.dart';
import '../utils/sheet_config.dart';
import '../utils/sheet_handle.dart';
import '../utils/sheet_backdrop.dart';
import '../utils/sheet_theme.dart';

/// A bottom sheet for confirming destructive or important actions.
///
/// Replaces [AlertDialog] with a more thumb-friendly sheet.
/// Automatically uses [SheetTheme] config if available in widget tree.
///
/// ```dart
/// ConfirmSheet.show(
///   context,
///   icon: Icons.delete_rounded,
///   iconColor: SheetColor.danger,
///   title: 'Delete item?',
///   message: 'This cannot be undone.',
///   confirmLabel: 'Yes, delete',
///   isDangerous: true,
///   onConfirm: () => deleteItem(),
/// );
/// ```
class ConfirmSheet extends StatelessWidget {
  /// Icon displayed in the circle at the top.
  final IconData icon;

  /// Semantic color of the icon circle.
  final SheetColor iconColor;

  /// Title text of the confirmation.
  final String title;

  /// Message text below the title.
  final String message;

  /// Label for the confirm button.
  final String confirmLabel;

  /// Label for the cancel button.
  final String cancelLabel;

  /// Whether the confirm action is dangerous (renders in red).
  final bool isDangerous;

  /// Called when confirm button is tapped.
  final VoidCallback onConfirm;

  /// Called when cancel button is tapped.
  final VoidCallback? onCancel;

  /// Sheet configuration — falls back to [SheetTheme] if not provided.
  final SheetConfig config;

  /// Creates a [ConfirmSheet].
  const ConfirmSheet({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.iconColor = SheetColor.danger,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDangerous = false,
    this.onCancel,
    this.config = const SheetConfig(),
  });

  /// Shows a [ConfirmSheet] as a modal bottom sheet.
  static Future<bool?> show(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String message,
        required VoidCallback onConfirm,
        SheetColor iconColor = SheetColor.danger,
        String confirmLabel = 'Confirm',
        String cancelLabel = 'Cancel',
        bool isDangerous = false,
        VoidCallback? onCancel,
        SheetConfig? config,
      }) {
    final resolvedConfig = config ?? SheetTheme.configOf(context);
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: resolvedConfig.isDismissible,
      barrierColor: _resolveBarrierColor(resolvedConfig),
      builder: (_) => ConfirmSheet(
        icon: icon,
        iconColor: iconColor,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDangerous: isDangerous,
        onConfirm: onConfirm,
        onCancel: onCancel,
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

  Color _resolveIconBg(BuildContext context) {
    switch (iconColor) {
      case SheetColor.danger:
        return Theme.of(context).colorScheme.errorContainer;
      case SheetColor.success:
        return Colors.green.shade50;
      case SheetColor.warning:
        return Colors.orange.shade50;
      case SheetColor.primary:
        return Theme.of(context).colorScheme.primaryContainer;
    }
  }

  Color _resolveIconFg(BuildContext context) {
    switch (iconColor) {
      case SheetColor.danger:
        return Theme.of(context).colorScheme.error;
      case SheetColor.success:
        return Colors.green.shade700;
      case SheetColor.warning:
        return Colors.orange.shade700;
      case SheetColor.primary:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _resolveConfirmColor(BuildContext context) {
    if (isDangerous) return Theme.of(context).colorScheme.error;
    return Theme.of(context).colorScheme.primary;
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
      padding: EdgeInsets.fromLTRB(
        20, 0, 20,
        MediaQuery.of(context).padding.bottom + 16,
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
          const SizedBox(height: 8),

          // icon circle
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _resolveIconBg(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: _resolveIconFg(context),
              size: 26,
            ),
          ),
          const SizedBox(height: 16),

          // title
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // message
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // confirm button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _resolveConfirmColor(context),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, true);
                onConfirm();
              },
              child: Text(
                confirmLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, false);
                onCancel?.call();
              },
              child: Text(
                cancelLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}