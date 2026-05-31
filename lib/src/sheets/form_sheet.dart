import 'package:flutter/material.dart';
import '../utils/sheet_config.dart';
import '../utils/sheet_handle.dart';
import '../utils/sheet_backdrop.dart';
import '../utils/sheet_theme.dart';

/// Field types supported by [FormSheet].
enum SheetFieldType {
  /// Single line text input.
  text,

  /// Email address input with email keyboard.
  email,

  /// Phone number input with numeric keyboard.
  phone,

  /// Password input with obscured text.
  password,

  /// Multi-line text input.
  multiline,
}

/// A single input field for use in [FormSheet].
///
/// ```dart
/// SheetField.text('Full Name', isRequired: true)
/// SheetField.email('Email Address')
/// SheetField.multiline('Notes', hint: 'Any instructions?')
/// ```
class SheetField {
  /// Label displayed above the input.
  final String label;

  /// Hint text inside the input.
  final String? hint;

  /// Input type — affects keyboard and validation.
  final SheetFieldType type;

  /// Whether this field is required for form submission.
  final bool isRequired;

  /// Optional external controller for this field.
  final TextEditingController? controller;

  /// Creates a [SheetField].
  const SheetField({
    required this.label,
    this.hint,
    this.type = SheetFieldType.text,
    this.isRequired = false,
    this.controller,
  });

  /// Creates a text [SheetField].
  const SheetField.text(
      String label, {
        String? hint,
        bool isRequired = false,
        TextEditingController? controller,
      }) : this(
    label: label,
    hint: hint,
    type: SheetFieldType.text,
    isRequired: isRequired,
    controller: controller,
  );

  /// Creates an email [SheetField].
  const SheetField.email(
      String label, {
        String? hint,
        bool isRequired = false,
        TextEditingController? controller,
      }) : this(
    label: label,
    hint: hint,
    type: SheetFieldType.email,
    isRequired: isRequired,
    controller: controller,
  );

  /// Creates a phone [SheetField].
  const SheetField.phone(
      String label, {
        String? hint,
        bool isRequired = false,
        TextEditingController? controller,
      }) : this(
    label: label,
    hint: hint,
    type: SheetFieldType.phone,
    isRequired: isRequired,
    controller: controller,
  );

  /// Creates a multiline [SheetField].
  const SheetField.multiline(
      String label, {
        String? hint,
        bool isRequired = false,
        TextEditingController? controller,
      }) : this(
    label: label,
    hint: hint,
    type: SheetFieldType.multiline,
    isRequired: isRequired,
    controller: controller,
  );
}

/// A bottom sheet with an inline form and keyboard avoidance.
///
/// Automatically uses [SheetTheme] config if available in widget tree.
///
/// ```dart
/// FormSheet.show(
///   context,
///   title: 'Add Address',
///   fields: [
///     SheetField.text('Full Name', isRequired: true),
///     SheetField.phone('Phone', isRequired: true),
///     SheetField.multiline('Notes'),
///   ],
///   onSubmit: (data) => print(data['Full Name']),
/// );
/// ```
class FormSheet extends StatefulWidget {
  /// Title displayed at the top of the sheet.
  final String title;

  /// Optional subtitle below the title.
  final String? subtitle;

  /// List of input fields to display.
  final List<SheetField> fields;

  /// Label for the submit button.
  final String submitLabel;

  /// Whether to adjust sheet height when keyboard appears.
  final bool keyboardAware;

  /// Sheet configuration — falls back to [SheetTheme] if not provided.
  final SheetConfig config;

  /// Called when form is submitted with field values.
  final void Function(Map<String, String> data) onSubmit;

  /// Creates a [FormSheet].
  const FormSheet({
    super.key,
    required this.title,
    required this.fields,
    required this.onSubmit,
    this.subtitle,
    this.submitLabel = 'Submit',
    this.keyboardAware = true,
    this.config = const SheetConfig(),
  });

  /// Shows a [FormSheet] as a modal bottom sheet.
  static Future<void> show(
      BuildContext context, {
        required String title,
        String? subtitle,
        required List<SheetField> fields,
        required void Function(Map<String, String> data) onSubmit,
        String submitLabel = 'Submit',
        bool keyboardAware = true,
        SheetConfig? config,
      }) {
    final resolvedConfig = config ?? SheetTheme.configOf(context);
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: resolvedConfig.isDismissible,
      isScrollControlled: true,
      barrierColor: _resolveBarrierColor(resolvedConfig),
      builder: (_) => FormSheet(
        title: title,
        subtitle: subtitle,
        fields: fields,
        onSubmit: onSubmit,
        submitLabel: submitLabel,
        keyboardAware: keyboardAware,
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
  State<FormSheet> createState() => _FormSheetState();
}

class _FormSheetState extends State<FormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _controllers;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controllers = widget.fields.map((f) {
      return f.controller ?? TextEditingController();
    }).toList();
  }

  @override
  void dispose() {
    for (int i = 0; i < widget.fields.length; i++) {
      if (widget.fields[i].controller == null) {
        _controllers[i].dispose();
      }
    }
    super.dispose();
  }

  TextInputType _keyboardType(SheetFieldType type) {
    switch (type) {
      case SheetFieldType.email:
        return TextInputType.emailAddress;
      case SheetFieldType.phone:
        return TextInputType.phone;
      case SheetFieldType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final data = <String, String>{};
    for (int i = 0; i < widget.fields.length; i++) {
      data[widget.fields[i].label] = _controllers[i].text.trim();
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
      widget.onSubmit(data);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        (widget.keyboardAware ? bottomInset : 0) +
            MediaQuery.of(context).padding.bottom +
            16,
      ),
      child: Form(
        key: _formKey,
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

            // title
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
            const SizedBox(height: 16),

            // fields
            ...List.generate(widget.fields.length, (i) {
              final field = widget.fields[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _controllers[i],
                  keyboardType: _keyboardType(field.type),
                  obscureText: field.type == SheetFieldType.password,
                  maxLines:
                  field.type == SheetFieldType.multiline ? 3 : 1,
                  decoration: InputDecoration(
                    labelText:
                    field.label + (field.isRequired ? ' *' : ''),
                    hintText: field.hint,
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha:0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  validator: field.isRequired
                      ? (val) =>
                  (val == null || val.trim().isEmpty)
                      ? '${field.label} is required'
                      : null
                      : null,
                ),
              );
            }),

            const SizedBox(height: 8),

            // submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  widget.submitLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}