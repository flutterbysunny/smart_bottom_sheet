import 'package:flutter/material.dart';
import 'sheet_config.dart';
import 'sheet_handle.dart';
import 'sheet_backdrop.dart';

/// App-wide default configuration for all sheet types.
///
/// Wrap your app with [SheetTheme] to set global defaults:
/// ```dart
/// SheetTheme(
///   config: SheetConfig(
///     handleStyle: HandleStyle.pill,
///     backdrop: SheetBackdrop(style: BackdropStyle.frosted),
///   ),
///   child: MaterialApp(...),
/// )
/// ```
class SheetTheme extends InheritedWidget {
  /// Default config applied to all sheets.
  final SheetConfig config;

  /// Creates a [SheetTheme].
  const SheetTheme({
    super.key,
    required this.config,
    required super.child,
  });

  /// Returns the nearest [SheetTheme] in the widget tree.
  ///
  /// Returns null if no [SheetTheme] is found.
  static SheetTheme? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SheetTheme>();
  }

  /// Returns the nearest [SheetTheme] config or default [SheetConfig].
  static SheetConfig configOf(BuildContext context) {
    return maybeOf(context)?.config ?? const SheetConfig();
  }

  @override
  bool updateShouldNotify(SheetTheme oldWidget) {
    return config != oldWidget.config;
  }
}