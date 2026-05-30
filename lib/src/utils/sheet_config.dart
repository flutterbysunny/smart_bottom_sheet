import 'package:flutter/material.dart';

enum SnapPoint { peek, half, full }

enum SheetColor { primary, success, danger, warning }

class SheetConfig {
  final double peekHeight;
  final double halfHeight;
  final bool isDismissible;
  final bool showHandle;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const SheetConfig({
    this.peekHeight = 90,
    this.halfHeight = 0.45,
    this.isDismissible = true,
    this.showHandle = true,
    this.backgroundColor,
    this.borderRadius,
  });
}

class SheetAction {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}