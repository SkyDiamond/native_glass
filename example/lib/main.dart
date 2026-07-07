import 'package:flutter/material.dart';
import 'package:native_glass/native_glass.dart';

void main() {
  runApp(const NativeGlassExampleApp());
}

class NativeGlassExampleApp extends StatefulWidget {
  const NativeGlassExampleApp({super.key});

  @override
  State<NativeGlassExampleApp> createState() => _NativeGlassExampleAppState();
}

class _NativeGlassExampleAppState extends State<NativeGlassExampleApp> {
  var _pageIndex = 0;
  var _demoSelectedIndex = 0;
  var _renderMode = NativeGlassRenderMode.auto;

  @override
  void initState() {
    super.initState();
    NativeGlassDiagnostics.listener = (_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    };
  }

  @override
  void dispose() {
    NativeGlassDiagnostics.listener = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _ShowcaseDemo(
        renderMode: _renderMode,
        selectedIndex: _demoSelectedIndex,
        onRenderModeChanged: (mode) => setState(() => _renderMode = mode),
        onDestinationSelected: (index) {
          setState(() => _demoSelectedIndex = index);
        },
      ),
      _TabBarDemo(
        renderMode: _renderMode,
        selectedIndex: _demoSelectedIndex,
        onDestinationSelected: (index) {
          setState(() => _demoSelectedIndex = index);
        },
      ),
      const _FallbackSurfacesDemo(),
      _RenderPolicyDemo(
        renderMode: _renderMode,
        onChanged: (mode) => setState(() => _renderMode = mode),
      ),
      const _DiagnosticsDemo(),
    ];

    return NativeGlassTheme(
      data: const NativeGlassThemeData(
        config: NativeGlassConfig(diagnosticsEnabled: true),
      ),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('native_glass')),
          body: pages[_pageIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _pageIndex,
            onDestinationSelected: (index) {
              setState(() => _pageIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Showcase',
              ),
              NavigationDestination(
                icon: Icon(Icons.tab_outlined),
                selectedIcon: Icon(Icons.tab),
                label: 'Tab Bar',
              ),
              NavigationDestination(
                icon: Icon(Icons.layers_outlined),
                selectedIcon: Icon(Icons.layers),
                label: 'Surfaces',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined),
                selectedIcon: Icon(Icons.tune),
                label: 'Policy',
              ),
              NavigationDestination(
                icon: Icon(Icons.monitor_heart_outlined),
                selectedIcon: Icon(Icons.monitor_heart),
                label: 'Diagnostics',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShowcaseDemo extends StatelessWidget {
  const _ShowcaseDemo({
    required this.renderMode,
    required this.selectedIndex,
    required this.onRenderModeChanged,
    required this.onDestinationSelected,
  });

  final NativeGlassRenderMode renderMode;
  final int selectedIndex;
  final ValueChanged<NativeGlassRenderMode> onRenderModeChanged;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: 'Phase 1 Showcase',
      children: [
        NativeGlassAvailabilityBuilder(
          builder: (context, availability) {
            return _InfoPanel(
              lines: [
                'Native Renderer: ${availability.supportsNativeRenderer}',
                'Liquid Glass: ${availability.supportsLiquidGlass}',
                'iOS Version: ${availability.iosVersion ?? '-'}',
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _DiagnosticsSummary(),
        const SizedBox(height: 24),
        _RenderModeControl(value: renderMode, onChanged: onRenderModeChanged),
        const SizedBox(height: 24),
        const NativeGlassContainer(
          padding: EdgeInsets.all(20),
          child: Text('Flutter Fallback container'),
        ),
        const SizedBox(height: 16),
        NativeGlassButton(
          onPressed: () {},
          child: const Text('Fallback button'),
        ),
        const SizedBox(height: 24),
        NativeGlassTabBar(
          selectedIndex: selectedIndex,
          renderMode: renderMode,
          onDestinationSelected: onDestinationSelected,
          destinations: _demoDestinations,
        ),
      ],
    );
  }
}

class _TabBarDemo extends StatelessWidget {
  const _TabBarDemo({
    required this.renderMode,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final NativeGlassRenderMode renderMode;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: 'Tab Bar Demo',
      children: [
        const Text('NativeGlassTabBar uses Native Renderer when available.'),
        const SizedBox(height: 16),
        NativeGlassTabBar(
          selectedIndex: selectedIndex,
          renderMode: renderMode,
          onDestinationSelected: onDestinationSelected,
          destinations: _demoDestinations,
        ),
        const SizedBox(height: 24),
        const Text('Forced Flutter Fallback'),
        const SizedBox(height: 16),
        NativeGlassTabBar(
          selectedIndex: selectedIndex,
          renderMode: NativeGlassRenderMode.flutter,
          onDestinationSelected: onDestinationSelected,
          destinations: _demoDestinations,
        ),
      ],
    );
  }
}

class _FallbackSurfacesDemo extends StatelessWidget {
  const _FallbackSurfacesDemo();

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: 'Fallback Surfaces Demo',
      children: [
        const NativeGlassContainer(
          padding: EdgeInsets.all(20),
          child: Text('Blurred fallback container'),
        ),
        const SizedBox(height: 16),
        const NativeGlassContainer(
          blur: 0,
          padding: EdgeInsets.all(20),
          child: Text('Low-cost fallback surface, blur disabled'),
        ),
        const SizedBox(height: 16),
        NativeGlassButton(
          onPressed: () {},
          child: const Text('Enabled fallback button'),
        ),
        const SizedBox(height: 12),
        const NativeGlassButton(
          onPressed: null,
          child: Text('Disabled fallback button'),
        ),
      ],
    );
  }
}

class _RenderPolicyDemo extends StatelessWidget {
  const _RenderPolicyDemo({required this.renderMode, required this.onChanged});

  final NativeGlassRenderMode renderMode;
  final ValueChanged<NativeGlassRenderMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: 'Render Policy Demo',
      children: [
        const Text('Switch render modes to inspect native/fallback behavior.'),
        const SizedBox(height: 16),
        _RenderModeControl(value: renderMode, onChanged: onChanged),
        const SizedBox(height: 16),
        _InfoPanel(
          lines: [
            'Current mode: ${renderMode.name}',
            'Native failure behavior: fallback',
            'PlatformView Budget warning starts at 6 visible views',
          ],
        ),
      ],
    );
  }
}

class _DiagnosticsDemo extends StatelessWidget {
  const _DiagnosticsDemo();

  @override
  Widget build(BuildContext context) {
    return const _DemoPage(
      title: 'Diagnostics Demo',
      children: [
        _DiagnosticsSummary(),
        SizedBox(height: 16),
        Text(
          'Render decision events are logged through NativeGlassDiagnostics.',
        ),
      ],
    );
  }
}

class _RenderModeControl extends StatelessWidget {
  const _RenderModeControl({required this.value, required this.onChanged});

  final NativeGlassRenderMode value;
  final ValueChanged<NativeGlassRenderMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<NativeGlassRenderMode>(
      segments: const [
        ButtonSegment(value: NativeGlassRenderMode.auto, label: Text('Auto')),
        ButtonSegment(
          value: NativeGlassRenderMode.native,
          label: Text('Native'),
        ),
        ButtonSegment(
          value: NativeGlassRenderMode.flutter,
          label: Text('Flutter'),
        ),
      ],
      selected: {value},
      onSelectionChanged: (value) => onChanged(value.single),
    );
  }
}

class _DiagnosticsSummary extends StatelessWidget {
  const _DiagnosticsSummary();

  @override
  Widget build(BuildContext context) {
    return _InfoPanel(
      lines: [
        'Active Native Renderers: '
            '${NativeGlassDiagnostics.activeNativeRendererCount}',
        'Visible Native Renderers: '
            '${NativeGlassDiagnostics.visibleNativeRendererCount}',
      ],
    );
  }
}

class _DemoPage extends StatelessWidget {
  const _DemoPage({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return NativeGlassContainer(
      blur: 0,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(line),
            ),
        ],
      ),
    );
  }
}

const _demoDestinations = [
  NativeGlassDestination(
    label: 'Home',
    icon: NativeGlassIcon.flutterIcon(Icons.home_outlined),
    selectedIcon: NativeGlassIcon.flutterIcon(Icons.home),
  ),
  NativeGlassDestination(
    label: 'Search',
    icon: NativeGlassIcon.flutterIcon(Icons.search),
    badge: NativeGlassBadge.dot(),
  ),
];
