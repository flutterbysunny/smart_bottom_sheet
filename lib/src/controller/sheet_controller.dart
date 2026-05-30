import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/sheet_config.dart';

/// Controls the height and snap state of a [SnapSheet].
///
/// Can be used to programmatically snap the sheet:
/// ```dart
/// final controller = SheetController(
///   onSnap: (snap) => print('Snapped to $snap'),
///   onOpen: () => print('Sheet opened'),
///   onClose: () => print('Sheet closed'),
/// );
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

  /// Called when sheet reaches [SnapPoint.full].
  final VoidCallback? onOpen;

  /// Called when sheet is dismissed or closed.
  final VoidCallback? onClose;

  /// Called whenever sheet snaps to a new [SnapPoint].
  final void Function(SnapPoint snap)? onSnap;

  /// Creates a [SheetController].
  SheetController({
    this.peekHeight = 90,
    this.halfFraction = 0.45,
    SnapPoint initialSnap = SnapPoint.half,
    this.onOpen,
    this.onClose,
    this.onSnap,
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
    _currentHeight =
        _currentHeight.clamp(peekHeight * 0.8, screenHeight * 0.95);
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

  void _applyHaptic(SnapPoint snap) {
    switch (snap) {
      case SnapPoint.peek:
        HapticFeedback.lightImpact();
        break;
      case SnapPoint.half:
        HapticFeedback.mediumImpact();
        break;
      case SnapPoint.full:
        HapticFeedback.heavyImpact();
        break;
    }
  }

  void _updateSnap(SnapPoint snap, double screenHeight) {
    _currentSnap = snap;
    _currentHeight = _heightForSnap(snap, screenHeight);
    _applyHaptic(snap);
    onSnap?.call(snap);
    if (snap == SnapPoint.full) onOpen?.call();
  }

  void _snapUp(double screenHeight) {
    switch (_currentSnap) {
      case SnapPoint.peek:
        _updateSnap(SnapPoint.half, screenHeight);
        break;
      case SnapPoint.half:
        _updateSnap(SnapPoint.full, screenHeight);
        break;
      case SnapPoint.full:
        break;
    }
  }

  void _snapDown(double screenHeight) {
    switch (_currentSnap) {
      case SnapPoint.full:
        _updateSnap(SnapPoint.half, screenHeight);
        break;
      case SnapPoint.half:
        _updateSnap(SnapPoint.peek, screenHeight);
        break;
      case SnapPoint.peek:
        break;
    }
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
    final nearest = distances.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
    _updateSnap(nearest, screenHeight);
  }

  /// Programmatically snap to a specific [SnapPoint].
  void snapTo(SnapPoint snap, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    _updateSnap(snap, screenHeight);
    notifyListeners();
  }

  /// Dismisses the sheet by setting height to 0.
  void dismiss() {
    HapticFeedback.lightImpact();
    _currentHeight = 0;
    onClose?.call();
    notifyListeners();
  }
}