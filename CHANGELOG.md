## 1.0.2

### New Features
* `SheetBackdrop` — dark, light, frosted, none backdrop styles
* `SheetTheme` — app-wide default config via `InheritedWidget`
* `SideSheet` — slides in from left or right side of screen
* `SheetHandle` integrated in all sheet types
* `SheetTheme.configOf()` — all sheets auto-pick theme config
* `barrierColor` — all sheets respect backdrop config
* Event callbacks demo in example app

### Improvements
* All sheets now use `SheetTheme` automatically
* `_resolveBarrierColor` consistent across all sheets
* 33 unit + widget tests passing
* Full dartdoc on all new public APIs


## 1.0.1

### New Features
* Haptic feedback on snap — light, medium, heavy impact based on snap position
* `onOpen` / `onClose` / `onSnap` callbacks in `SheetController`
* Nested scroll support in `SnapSheet` — inner list scrolls when sheet is full
* `SheetStackManager` — push/pop sheets on top of each other like Apple Maps
* Custom handle styles — `defaultHandle`, `pill`, `pulse`, `arrow`, `none`
* `handleStyle` and `handleColor` added to `SheetConfig`

### Improvements
* `SheetController` refactored with `_updateSnap` — cleaner snap logic
* `_applyHaptic` helper extracted for reuse
* All public API documented with dartdoc comments


## 1.0.0

* Initial release
* Action Menu Sheet with destructive action support
* Snap Sheet with 3 snap points and rubber-band physics
* Form Sheet with keyboard avoidance and validation
* Confirm Sheet as AlertDialog replacement
* Stepper Sheet with animated step transitions
* Rating Sheet with animated star picker
* SheetConfig for global customization
* Dark mode support