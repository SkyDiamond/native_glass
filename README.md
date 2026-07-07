# native_glass

`native_glass` uses real UIKit components on iOS for high-value System Surfaces and Flutter Fallbacks everywhere else.

It is designed as a broader, performance-aware package rather than a native-everything wrapper.

## When To Use Each Renderer

Use the Native Renderer for:

- System Surfaces such as tab bars.
- A small number of native views per Screen.
- UI where UIKit behavior matters.

Use Flutter Fallback for:

- Decorative Surfaces such as containers and cards.
- Repeated/list items.
- Arbitrary Flutter children.
- Non-iOS platforms or unavailable native paths.

## MVP Widgets

- `NativeGlassTabBar`
- `NativeGlassButton`
- `NativeGlassContainer`
- `NativeGlassTheme`
- `NativeGlassAvailabilityBuilder`

`NativeGlassTabBar` can use the Native Renderer on supported iOS paths. `NativeGlassButton` and `NativeGlassContainer` are Flutter Fallback widgets in the MVP.

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

## Known Limitations

- Native Renderer uses PlatformViews and can have composition limitations with Flutter overlays and effects.
- `NativeGlassButton` and `NativeGlassContainer` are Flutter Fallback in the MVP.
- `NativeGlassNavigationBar` is not in the MVP.
- Flutter `IconData` is not supported by the Native Renderer tab bar in the MVP. Use `sfSymbol` or `nativeAsset` for native tab bar icons.
- PlatformView Budget diagnostics warn; they do not automatically force fallback.
- iOS integration testing currently starts with manual/device or simulator verification.
