# native_glass

`native_glass` uses real UIKit components on iOS for high-value System Surfaces and Flutter Fallbacks everywhere else.

It is designed as a broader, performance-aware package rather than a native-everything wrapper.

## When To Use Each Renderer

Use the Native Renderer for:

- System Surfaces such as tab bars and navigation bars.
- Promoted leaf controls such as segmented controls and text buttons.
- A small number of native views per Screen.
- UI where UIKit behavior matters.

Use Flutter Fallback for:

- Decorative Surfaces such as containers and cards.
- Repeated/list items.
- Arbitrary Flutter children.
- Non-iOS platforms or unavailable native paths.

## Current Widgets

- `NativeGlassNavigationBar`
- `NativeGlassSegmentedControl`
- `NativeGlassTabBar`
- `NativeGlassButton`
- `NativeGlassContainer`
- `NativeGlassTheme`
- `NativeGlassAvailabilityBuilder`

`NativeGlassNavigationBar`, `NativeGlassSegmentedControl`, `NativeGlassTabBar`, and text-only `NativeGlassButton` instances can use the Native Renderer on supported iOS paths. `NativeGlassSegmentedControl` is the promoted Leaf Control for Phase 3. Text-only `NativeGlassButton` is the promoted Leaf Control for Phase 4. `NativeGlassButton` instances with arbitrary Flutter children and `NativeGlassContainer` stay on Flutter Fallback.

## Basic Usage

```dart
NativeGlassTabBar(
  selectedIndex: index,
  onDestinationSelected: (next) {
    setState(() => index = next);
  },
  destinations: const [
    NativeGlassDestination(
      label: 'Home',
      icon: NativeGlassIcon.sfSymbol('house'),
      selectedIcon: NativeGlassIcon.sfSymbol('house.fill'),
    ),
    NativeGlassDestination(
      label: 'Search',
      icon: NativeGlassIcon.sfSymbol('magnifyingglass'),
    ),
  ],
)
```

As an app bar:

```dart
Scaffold(
  appBar: NativeGlassNavigationBar(
    title: 'Portfolio',
    trailingActions: const [
      NativeGlassNavigationAction(
        id: 'search',
        label: 'Search',
        icon: NativeGlassIcon.sfSymbol('magnifyingglass'),
      ),
    ],
    onActionSelected: (id) {
      // Route or update state from Flutter.
    },
  ),
)
```

As a promoted native leaf control:

```dart
NativeGlassSegmentedControl(
  selectedIndex: index,
  onSegmentSelected: (next) {
    setState(() => index = next);
  },
  segments: const [
    NativeGlassSegment(label: 'Day'),
    NativeGlassSegment(label: 'Week'),
    NativeGlassSegment(label: 'Month'),
  ],
)
```

As a promoted native text button:

```dart
NativeGlassButton(
  renderMode: NativeGlassRenderMode.auto,
  onPressed: () {
    // Route or update state from Flutter.
  },
  child: const Text('Continue'),
)
```

For Flutter Fallback icons:

```dart
NativeGlassDestination(
  label: 'Home',
  icon: NativeGlassIcon.flutterIcon(Icons.home_outlined),
  selectedIcon: NativeGlassIcon.flutterIcon(Icons.home),
)
```

## Availability

```dart
NativeGlassAvailabilityBuilder(
  builder: (context, availability) {
    return Text(
      'Native Renderer: ${availability.supportsNativeRenderer}\n'
      'Liquid Glass: ${availability.supportsLiquidGlass}',
    );
  },
)
```

Liquid Glass means Apple's native iOS 26+ behavior only. Older iOS versions may still use standard native UIKit rendering, but they are not reported as Liquid Glass.

## Diagnostics

Diagnostics are enabled by default in debug builds and can report render decisions, fallback reasons, active and visible Native Renderer counts, prop update counts, and structural rebuild counts.

The PlatformView Budget warning threshold is 6 visible Native Renderer views. This warning is diagnostic only; it does not force Flutter Fallback.

## Known Limitations

- Native Renderer uses PlatformViews and can have composition limitations with Flutter overlays and effects.
- `NativeGlassButton` uses the Native Renderer only for text-only children. Arbitrary Flutter children stay on Flutter Fallback.
- `NativeGlassContainer` is Flutter Fallback.
- Switches and sliders are not promoted to Native Renderer yet.
- Flutter `IconData` is not supported by Native Renderer components. Use `sfSymbol` or `nativeAsset` for native icons.
- PlatformView Budget diagnostics warn; they do not automatically force fallback.
- iOS integration testing currently starts with manual/device or simulator verification.
