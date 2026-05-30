import 'package:flutter/material.dart';
import '../utils/sheet_config.dart';

/// Controls the height and snap state of a [SnapSheet].
///
/// Can be used to programmatically snap the sheet:
/// ```dart
/// final controller = SheetController();
/// controller.snapTo(SnapPoint.full, context);
/// ```
class SheetController extends ChangeNotifier {
  double _currentHeight;
  SnapPoint _currentSnap;
  bool _isDragging = false;

  /// Height in pixels for the peek snap position.
  final double peekHeight;

  /// Fraction of screen height for the half snap position.
  final double halfFraction;

  /// Creates a [SheetController].
  SheetController({
    this.peekHeight = 90,
    this.halfFraction = 0.45,
    SnapPoint initialSnap = SnapPoint.half,
  })  : _currentSnap = initialSnap,
        _currentHeight = 0;

  /// Current height of the sheet in pixels.
  double get currentHeight => _currentHeight;

  /// Current active snap position.
  SnapPoint get currentSnap => _currentSnap;

  /// Whether the user is currently dragging the sheet.
  bool get isDragging => _isDragging;

  /// Initializes the sheet height based on screen size.
  void init(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    _currentHeight = _heightForSnap(_currentSnap, screenHeight);
    notifyListeners();
  }

  double _heightForSnap(SnapPoint snap, double screenHeight) {
    switch (snap) {
      case SnapPoint.peek:
        return peekHeight;
      case SnapPoint.half:
        return screenHeight * halfFraction;
      case SnapPoint.full:
        return screenHeight * 0.92;
    }
  }

  /// Updates height during a drag gesture.
  void onDragUpdate(DragUpdateDetails details, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    _isDragging = true;
    _currentHeight -= details.delta.dy;
    _currentHeight = _currentHeight.clamp(peekHeight * 0.8, screenHeight * 0.95);
    notifyListeners();
  }

  /// Snaps to nearest position when drag ends.
  void onDragEnd(DragEndDetails details, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    _isDragging = false;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -500) {
      _snapUp(screenHeight);
    } else if (velocity > 500) {
      _snapDown(screenHeight);
    } else {
      _snapToNearest(screenHeight);
    }
    notifyListeners();
  }

  void _snapUp(double screenHeight) {
    switch (_currentSnap) {
      case SnapPoint.peek:
        _currentSnap = SnapPoint.half;
        break;
      case SnapPoint.half:
        _currentSnap = SnapPoint.full;
        break;
      case SnapPoint.full:
        break;
    }
    _currentHeight = _heightForSnap(_currentSnap, screenHeight);
  }

  void _snapDown(double screenHeight) {
    switch (_currentSnap) {
      case SnapPoint.full:
        _currentSnap = SnapPoint.half;
        break;
      case SnapPoint.half:
        _currentSnap = SnapPoint.peek;
        break;
      case SnapPoint.peek:
        break;
    }
    _currentHeight = _heightForSnap(_currentSnap, screenHeight);
  }

  void _snapToNearest(double screenHeight) {
    final peek = peekHeight;
    final half = screenHeight * halfFraction;
    final full = screenHeight * 0.92;
    final distances = {
      SnapPoint.peek: (_currentHeight - peek).abs(),
      SnapPoint.half: (_currentHeight - half).abs(),
      SnapPoint.full: (_currentHeight - full).abs(),
    };
    _currentSnap = distances.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
    _currentHeight = _heightForSnap(_currentSnap, screenHeight);
  }

  /// Programmatically snap to a specific [SnapPoint].
  void snapTo(SnapPoint snap, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    _currentSnap = snap;
    _currentHeight = _heightForSnap(snap, screenHeight);
    notifyListeners();
  }

  /// Dismisses the sheet by setting height to 0.
  void dismiss() {
    _currentHeight = 0;
    notifyListeners();
  }
}