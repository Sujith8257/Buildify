import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_palette.dart';
import 'home_screen.dart';
import 'model_store_screen.dart';
import 'self_test_screen.dart';
import 'network_screen.dart';

class AiServerShell extends ConsumerStatefulWidget {
  const AiServerShell({super.key});

  @override
  ConsumerState<AiServerShell> createState() => _AiServerShellState();
}

class _AiServerShellState extends ConsumerState<AiServerShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      HomeScreen(),
      ModelStoreScreen(),
      SelfTestScreen(),
      NetworkScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPalette.bg,
        titleSpacing: 16,
        title: const Row(
          children: [
            Icon(Icons.memory, color: AppPalette.primary),
            SizedBox(width: 8),
            Text('Buildify AI'),
          ],
        ),
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (next) => setState(() => index = next),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.storage_outlined),
            selectedIcon: Icon(Icons.storage),
            label: 'Models',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Self test',
          ),
          NavigationDestination(
            icon: Icon(Icons.lan_outlined),
            selectedIcon: Icon(Icons.lan),
            label: 'Network',
          ),
        ],
      ),
    );
  }
}
