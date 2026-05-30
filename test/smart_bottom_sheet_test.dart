import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_bottom_sheet/smart_bottom_sheet.dart';

void main() {
  group('SheetConfig', () {
    test('default values are correct', () {
      const config = SheetConfig();
      expect(config.peekHeight, 90);
      expect(config.halfHeight, 0.45);
      expect(config.isDismissible, true);
      expect(config.showHandle, true);
    });

    test('custom values are set correctly', () {
      const config = SheetConfig(
        peekHeight: 120,
        halfHeight: 0.6,
        isDismissible: false,
        showHandle: false,
      );
      expect(config.peekHeight, 120);
      expect(config.halfHeight, 0.6);
      expect(config.isDismissible, false);
      expect(config.showHandle, false);
    });
  });

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
  });

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
  });
}