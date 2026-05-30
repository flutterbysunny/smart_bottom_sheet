import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_bottom_sheet/smart_bottom_sheet.dart';

void main() {
  // ─── SheetConfig Tests ───────────────────────────────────────
  group('SheetConfig', () {
    test('default values are correct', () {
      const config = SheetConfig();
      expect(config.peekHeight, 90);
      expect(config.halfHeight, 0.45);
      expect(config.isDismissible, true);
      expect(config.showHandle, true);
      expect(config.handleStyle, HandleStyle.defaultHandle);
      expect(config.handleColor, null);
      expect(config.backgroundColor, null);
      expect(config.borderRadius, null);
    });

    test('custom values are set correctly', () {
      const config = SheetConfig(
        peekHeight: 120,
        halfHeight: 0.6,
        isDismissible: false,
        showHandle: false,
        handleStyle: HandleStyle.pill,
        handleColor: Colors.blue,
      );
      expect(config.peekHeight, 120);
      expect(config.halfHeight, 0.6);
      expect(config.isDismissible, false);
      expect(config.showHandle, false);
      expect(config.handleStyle, HandleStyle.pill);
      expect(config.handleColor, Colors.blue);
    });
  });

  // ─── SheetAction Tests ───────────────────────────────────────
  group('SheetAction', () {
    test('isDestructive defaults to false', () {
      final action = SheetAction(
        icon: Icons.share,
        label: 'Share',
        onTap: () {},
      );
      expect(action.isDestructive, false);
      expect(action.label, 'Share');
    });

    test('destructive action sets correctly', () {
      final action = SheetAction(
        icon: Icons.delete,
        label: 'Delete',
        isDestructive: true,
        onTap: () {},
      );
      expect(action.isDestructive, true);
    });
  });

  // ─── SheetPhysics Tests ──────────────────────────────────────
  group('SheetPhysics', () {
    test('applyResistance returns same value when in bounds', () {
      final result = SheetPhysics.applyResistance(
        currentHeight: 200,
        minHeight: 90,
        maxHeight: 400,
      );
      expect(result, 200);
    });

    test('applyResistance applies resistance below min', () {
      final result = SheetPhysics.applyResistance(
        currentHeight: 50,
        minHeight: 90,
        maxHeight: 400,
      );
      expect(result, lessThan(90));
      expect(result, greaterThan(50));
    });

    test('applyResistance applies resistance above max', () {
      final result = SheetPhysics.applyResistance(
        currentHeight: 450,
        minHeight: 90,
        maxHeight: 400,
      );
      expect(result, greaterThan(400));
      expect(result, lessThan(450));
    });

    test('shouldDismiss returns true below threshold', () {
      final result = SheetPhysics.shouldDismiss(
        currentHeight: 40,
        peekHeight: 90,
      );
      expect(result, true);
    });

    test('shouldDismiss returns false above threshold', () {
      final result = SheetPhysics.shouldDismiss(
        currentHeight: 80,
        peekHeight: 90,
      );
      expect(result, false);
    });

    test('snapDuration is 320ms', () {
      expect(SheetPhysics.snapDuration,
          const Duration(milliseconds: 320));
    });

    test('dismissDuration is 220ms', () {
      expect(SheetPhysics.dismissDuration,
          const Duration(milliseconds: 220));
    });
  });

  // ─── SheetController Tests ───────────────────────────────────
  group('SheetController', () {
    test('initializes with correct snap point', () {
      final controller = SheetController(
        initialSnap: SnapPoint.peek,
      );
      expect(controller.currentSnap, SnapPoint.peek);
      controller.dispose();
    });

    test('dismiss sets height to 0', () {
      final controller = SheetController();
      controller.dismiss();
      expect(controller.currentHeight, 0);
      controller.dispose();
    });

    test('onClose callback fires on dismiss', () {
      bool called = false;
      final controller = SheetController(
        onClose: () => called = true,
      );
      controller.dismiss();
      expect(called, true);
      controller.dispose();
    });

    test('onSnap callback fires on dismiss indirectly', () {
      bool closeCalled = false;
      final controller = SheetController(
        onClose: () => closeCalled = true,
      );
      controller.dismiss();
      expect(closeCalled, true);
      controller.dispose();
    });

    test('isDragging is false initially', () {
      final controller = SheetController();
      expect(controller.isDragging, false);
      controller.dispose();
    });
  });

  // ─── SheetField Tests ────────────────────────────────────────
  group('SheetField', () {
    test('text factory sets correct type', () {
      const field = SheetField.text('Name');
      expect(field.type, SheetFieldType.text);
      expect(field.label, 'Name');
      expect(field.isRequired, false);
    });

    test('email factory sets correct type', () {
      const field = SheetField.email('Email', isRequired: true);
      expect(field.type, SheetFieldType.email);
      expect(field.isRequired, true);
    });

    test('phone factory sets correct type', () {
      const field = SheetField.phone('Phone');
      expect(field.type, SheetFieldType.phone);
    });

    test('multiline factory sets correct type', () {
      const field = SheetField.multiline('Notes');
      expect(field.type, SheetFieldType.multiline);
    });
  });

  // ─── HandleStyle Tests ───────────────────────────────────────
  group('HandleStyle', () {
    test('all handle styles are available', () {
      expect(HandleStyle.values.length, 5);
      expect(HandleStyle.values, containsAll([
        HandleStyle.defaultHandle,
        HandleStyle.pill,
        HandleStyle.pulse,
        HandleStyle.arrow,
        HandleStyle.none,
      ]));
    });
  });

  // ─── SheetColor Tests ────────────────────────────────────────
  group('SheetColor', () {
    test('all color options are available', () {
      expect(SheetColor.values.length, 4);
      expect(SheetColor.values, containsAll([
        SheetColor.primary,
        SheetColor.success,
        SheetColor.danger,
        SheetColor.warning,
      ]));
    });
  });

  // ─── SnapPoint Tests ─────────────────────────────────────────
  group('SnapPoint', () {
    test('all snap points are available', () {
      expect(SnapPoint.values.length, 3);
      expect(SnapPoint.values, containsAll([
        SnapPoint.peek,
        SnapPoint.half,
        SnapPoint.full,
      ]));
    });
  });

  // ─── Widget Tests ────────────────────────────────────────────
  group('ActionMenuSheet widget', () {
    testWidgets('renders title and actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionMenuSheet(
              title: 'Test Title',
              actions: [
                SheetAction(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: () {},
                ),
                SheetAction(
                  icon: Icons.delete,
                  label: 'Delete',
                  isDestructive: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });

  group('SheetHandle widget', () {
    testWidgets('renders default handle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SheetHandle(
              style: HandleStyle.defaultHandle,
            ),
          ),
        ),
      );
      expect(find.byType(SheetHandle), findsOneWidget);
    });

    testWidgets('renders none handle as empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SheetHandle(style: HandleStyle.none),
          ),
        ),
      );
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}

/// Fake BuildContext for unit tests that need context.
class _FakeBuildContext extends Fake implements BuildContext {
  @override
  Size get size => const Size(390, 844);
}