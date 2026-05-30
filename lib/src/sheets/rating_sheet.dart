import 'package:flutter/material.dart';
import '../utils/sheet_config.dart';

class RatingSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final int maxStars;
  final bool showComment;
  final String commentHint;
  final String submitLabel;
  final SheetConfig config;
  final void Function(int stars, String? comment) onSubmit;

  const RatingSheet({
    super.key,
    required this.title,
    required this.onSubmit,
    this.subtitle,
    this.maxStars = 5,
    this.showComment = true,
    this.commentHint = 'Add a comment (optional)',
    this.submitLabel = 'Submit Rating',
    this.config = const SheetConfig(),
  });

  static Future<void> show(
      BuildContext context, {
        required String title,
        String? subtitle,
        required void Function(int stars, String? comment) onSubmit,
        int maxStars = 5,
        bool showComment = true,
        String commentHint = 'Add a comment (optional)',
        String submitLabel = 'Submit Rating',
        SheetConfig config = const SheetConfig(),
      }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: config.isDismissible,
      isScrollControlled: true,
      builder: (_) => RatingSheet(
        title: title,
        subtitle: subtitle,
        onSubmit: onSubmit,
        maxStars: maxStars,
        showComment: showComment,
        commentHint: commentHint,
        submitLabel: submitLabel,
        config: config,
      ),
    );
  }

  @override
  State<RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<RatingSheet> {
  int _selectedStars = 0;
  int _hoveredStar = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _ratingLabel() {
    switch (_selectedStars) {
      case 1:
        return 'Poor 😞';
      case 2:
        return 'Fair 😐';
      case 3:
        return 'Good 🙂';
      case 4:
        return 'Great 😊';
      case 5:
        return 'Excellent 🤩';
      default:
        return 'Tap to rate';
    }
  }

  Color _starColor(int index) {
    final active = _hoveredStar > 0 ? _hoveredStar : _selectedStars;
    return index <= active ? const Color(0xFFEF9F27) : Colors.grey.shade300;
  }

  void _submit() async {
    if (_selectedStars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
      widget.onSubmit(
        _selectedStars,
        _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );
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
        bottomInset + MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // handle
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

          // title
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),

          // stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.maxStars, (i) {
              final index = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _selectedStars = index),
                onTapDown: (_) => setState(() => _hoveredStar = index),
                onTapUp: (_) => setState(() => _hoveredStar = 0),
                onTapCancel: () => setState(() => _hoveredStar = 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedScale(
                    scale: _selectedStars >= index ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      _selectedStars >= index
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 40,
                      color: _starColor(index),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // rating label
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _ratingLabel(),
              key: ValueKey(_selectedStars),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _selectedStars > 0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // comment field
          if (widget.showComment)
            TextFormField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: widget.commentHint,
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.4),
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
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          const SizedBox(height: 16),

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
    );
  }
}