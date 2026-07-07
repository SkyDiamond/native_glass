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
  var _selectedIndex = 0;
  var _renderMode = NativeGlassRenderMode.auto;

  @override
  void initState() {
    super.initState();
    NativeGlassDiagnostics.listener = (_) {
      if (mounted) setState(() {});
    };
  }

  @override
  void dispose() {
    NativeGlassDiagnostics.listener = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NativeGlassTheme(
      data: const NativeGlassThemeData(
        config: NativeGlassConfig(diagnosticsEnabled: true),
      ),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('native_glass')),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const _SectionTitle('Phase 1 Showcase'),
              const SizedBox(height: 12),
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
              _InfoPanel(
                lines: [
                  'Active Native Renderers: '
                      '${NativeGlassDiagnostics.activeNativeRendererCount}',
                  'Visible Native Renderers: '
                      '${NativeGlassDiagnostics.visibleNativeRendererCount}',
                ],
              ),
              const SizedBox(height: 24),
              SegmentedButton<NativeGlassRenderMode>(
                segments: const [
                  ButtonSegment(
                    value: NativeGlassRenderMode.auto,
                    label: Text('Auto'),
                  ),
                  ButtonSegment(
                    value: NativeGlassRenderMode.native,
                    label: Text('Native'),
                  ),
                  ButtonSegment(
                    value: NativeGlassRenderMode.flutter,
                    label: Text('Flutter'),
                  ),
                ],
                selected: {_renderMode},
                onSelectionChanged: (value) {
                  setState(() => _renderMode = value.single);
                },
              ),
              const SizedBox(height: 24),
              NativeGlassContainer(
                padding: const EdgeInsets.all(20),
                child: const Text('Flutter Fallback container'),
              ),
              const SizedBox(height: 16),
              NativeGlassContainer(
                blur: 0,
                padding: const EdgeInsets.all(20),
                child: const Text('Low-cost fallback surface, blur disabled'),
              ),
              const SizedBox(height: 16),
              NativeGlassButton(
                onPressed: () {},
                child: const Text('Fallback button'),
              ),
            ],
          ),
          bottomNavigationBar: NativeGlassTabBar(
            selectedIndex: _selectedIndex,
            renderMode: _renderMode,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: const [
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
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.headlineSmall);
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
