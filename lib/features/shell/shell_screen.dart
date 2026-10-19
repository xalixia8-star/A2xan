import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/routes.dart';
import '../../theme/app_colors.dart';
import '../generator/generator_screen.dart';
import '../settings/settings_screen.dart';
import '../vault/favorites_screen.dart';
import '../vault/service_picker_screen.dart';
import '../vault/vault_screen.dart';

/// Kerangka utama: bottom navigation Vault / Generator / Favorit / Pengaturan.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  static const _tabs = <Widget>[
    VaultScreen(key: ValueKey('tab-vault')),
    GeneratorScreen(key: ValueKey('tab-generator')),
    FavoritesScreen(key: ValueKey('tab-favorites')),
    SettingsScreen(key: ValueKey('tab-settings')),
  ];

  void _select(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cross-fade antar tab 400 ms.
      body: AnimatedSwitcher(
        duration: Motion.tab,
        switchInCurve: Motion.smooth,
        switchOutCurve: Motion.smooth,
        child: _tabs[_index],
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: Motion.tab,
        transitionBuilder: (child, a) =>
            FadeTransition(opacity: a, child: ScaleTransition(scale: a, child: child)),
        child: _index == 0 ? _AddButton(key: const ValueKey('fab')) : const SizedBox.shrink(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.goldBorder(0.3))),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.lock_outline_rounded),
              selectedIcon: Icon(Icons.lock_rounded),
              label: 'Vault',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_fix_high_outlined),
              selectedIcon: Icon(Icons.auto_fix_high_rounded),
              label: 'Generator',
            ),
            NavigationDestination(
              icon: Icon(Icons.star_outline_rounded),
              selectedIcon: Icon(Icons.star_rounded),
              label: 'Favorit',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldBorder(0.6)),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              FadeSlideRoute(builder: (_) => const ServicePickerScreen()),
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Icon(Icons.add_rounded, color: AppColors.champagne, size: 28),
          ),
        ),
      ),
    );
  }
}
