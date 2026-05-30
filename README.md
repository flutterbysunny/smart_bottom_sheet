# Smart Bottom Sheet

A smart, feature-rich Flutter bottom sheet package with snap points, physics-based dragging, stacking, form, stepper, confirmation, and rating sheets.

## Features

- 🎯 **Action Menu Sheet** — quick actions list with icons and destructive styling
- ⚓ **Snap Sheet** — 3 snap points (peek, half, full) with velocity-based snapping and rubber-band physics
- 📝 **Form Sheet** — keyboard-aware inline forms with validation
- ⚠️ **Confirm Sheet** — thumb-friendly replacement for AlertDialog
- 🪜 **Stepper Sheet** — multi-step flow inside a single sheet with progress indicator
- ⭐ **Rating Sheet** — animated star picker with optional comment field
- 🎨 **Fully customizable** — colors, border radius, handle, backdrop
- 🌙 **Dark mode** support out of the box

## Getting Started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  smart_bottom_sheet: ^1.0.0
```

Then run:

```bash
flutter pub get
```

Import in your Dart file:

```dart
import 'package:smart_bottom_sheet/smart_bottom_sheet.dart';
```

## Usage

### Action Menu Sheet

```dart
ActionMenuSheet.show(
  context,
  title: 'File Options',
  subtitle: 'document.pdf',
  actions: [
    SheetAction(
      icon: Icons.share_rounded,
      label: 'Share',
      onTap: () {},
    ),
    SheetAction(
      icon: Icons.delete_rounded,
      label: 'Delete',
      isDestructive: true,
      onTap: () {},
    ),
  ],
);
```

### Snap Sheet

```dart
SnapSheet.show(
  context,
  initialSnap: SnapPoint.half,
  child: YourScrollableWidget(),
);
```

### Form Sheet

```dart
FormSheet.show(
  context,
  title: 'Add Address',
  fields: [
    SheetField.text('Full Name', isRequired: true),
    SheetField.phone('Phone Number', isRequired: true),
    SheetField.multiline('Notes', hint: 'Any instructions?'),
  ],
  onSubmit: (data) {
    print(data['Full Name']);
  },
);
```

### Confirm Sheet

```dart
ConfirmSheet.show(
  context,
  icon: Icons.delete_rounded,
  iconColor: SheetColor.danger,
  title: 'Delete this item?',
  message: 'This action cannot be undone.',
  confirmLabel: 'Yes, Delete',
  isDangerous: true,
  onConfirm: () {
    // handle delete
  },
);
```

### Stepper Sheet

```dart
StepperSheet.show(
  context,
  title: 'Place Order',
  steps: [
    SheetStep(
      title: 'Bag',
      child: YourBagWidget(),
    ),
    SheetStep(
      title: 'Address',
      child: YourAddressWidget(),
    ),
    SheetStep(
      title: 'Payment',
      child: YourPaymentWidget(),
    ),
  ],
  onComplete: () {
    // order placed
  },
);
```

### Rating Sheet

```dart
RatingSheet.show(
  context,
  title: 'How was your order?',
  subtitle: 'Burger King · Zomato Gold',
  showComment: true,
  onSubmit: (stars, comment) {
    print('Rated $stars stars');
  },
);
```

## Customization

Every sheet accepts a `SheetConfig` for global customization:

```dart
SheetConfig(
  peekHeight: 90,        // peek snap height in pixels
  halfHeight: 0.45,      // half snap as screen fraction
  isDismissible: true,   // swipe down to dismiss
  showHandle: true,      // show drag handle bar
  backgroundColor: Colors.white,
  borderRadius: BorderRadius.vertical(
    top: Radius.circular(24),
  ),
)
```

## Additional Information

- 📦 [pub.dev](https://pub.dev/packages/smart_bottom_sheet)
- 🐛 [File an issue](https://github.com/flutterbysunny/smart_bottom_sheet/issues)
- 🤝 Contributions welcome — open a PR!

## License

MIT License — see [LICENSE](LICENSE) file for details.