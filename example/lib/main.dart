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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('native_glass')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<NativeGlassAvailability>(
                future: NativeGlassAvailability.check(),
                builder: (context, snapshot) {
                  final availability = snapshot.data;
                  return Text(
                    availability == null
                        ? 'Checking availability...'
                        : 'Native Renderer: ${availability.supportsNativeRenderer}\n'
                              'Liquid Glass: ${availability.supportsLiquidGlass}',
                  );
                },
              ),
              const SizedBox(height: 24),
              NativeGlassContainer(
                padding: const EdgeInsets.all(20),
                child: const Text('Flutter Fallback container'),
              ),
              const SizedBox(height: 16),
              NativeGlassButton(
                onPressed: () {},
                child: const Text('Fallback button'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NativeGlassTabBar(
          selectedIndex: _selectedIndex,
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
            ),
          ],
        ),
      ),
    );
  }
}
