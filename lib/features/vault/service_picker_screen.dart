import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/routes.dart';
import '../../data/models/credential.dart';
import '../../data/models/service_def.dart';
import '../../data/providers.dart';
import '../../shared/widgets/dialogs.dart';
import '../../shared/widgets/service_icon.dart';
import '../../shared/widgets/staggered_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'credential_form_screen.dart';
import 'custom_service_sheet.dart';

/// Langkah 1 tambah sandi: pilih layanan dari grid ikon bergaya iOS.
class ServicePickerScreen extends ConsumerStatefulWidget {
  const ServicePickerScreen({super.key});

  @override
  ConsumerState<ServicePickerScreen> createState() => _ServicePickerScreenState();
}

class _ServicePickerScreenState extends ConsumerState<ServicePickerScreen> {
  String _group = kGroupAll;
  String _query = '';

  void _open(ServiceDef s) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      FadeSlideRoute(builder: (_) => CredentialFormScreen(service: s)),
    );
  }

  Future<void> _custom() async {
    final created = await showAppSheet<CustomService>(
      context,
      builder: (_) => const CustomServiceSheet(),
    );
    if (created == null || !mounted) return;
    await ref.read(vaultProvider.notifier).addCustomService(created);
    if (mounted) _open(created.toDef());
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(allServicesProvider);
    final q = _query.trim().toLowerCase();
    final filtered = all.where((s) {
      if (_group != kGroupAll && s.group != _group) return false;
      return q.isEmpty || s.name.toLowerCase().contains(q);
    }).toList();

    // Tombol "Lainnya / Custom" tampil di grup Semua & Lainnya (atau saat tak mencari).
    final showCustom =
        q.isEmpty && (_group == kGroupAll || _group == 'Lainnya');
    final count = filtered.length + (showCustom ? 1 : 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih layanan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Cari layanan',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final g in [kGroupAll, ...kServiceGroups])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(g),
                      selected: _group == g,
                      showCheckmark: false,
                      labelStyle: AppText.body(13, weight: _group == g ? 600 : 400),
                      onSelected: (_) => setState(() => _group = g),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: AnimatedSwitcher(
              duration: Motion.tab, // cross-fade antar tab
              switchInCurve: Motion.smooth,
              switchOutCurve: Motion.smooth,
              child: count == 0
                  ? Center(
                      key: const ValueKey('none'),
                      child: Text('Layanan tidak ditemukan',
                          style: AppText.body(14, color: AppColors.champagneMuted)),
                    )
                  : LayoutBuilder(
                      key: ValueKey('$_group|$q'),
                      builder: (context, box) {
                        // Ukuran ikon seragam, menyesuaikan lebar layar (4 kolom).
                        final cell = (box.maxWidth - 40) / 4;
                        final iconSize = (cell * 0.78).clamp(52.0, 72.0).toDouble();
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 18,
                            crossAxisSpacing: 4,
                            childAspectRatio: cell / (iconSize + 40),
                          ),
                          itemCount: count,
                          itemBuilder: (context, i) {
                            if (showCustom && i == filtered.length) {
                              return StaggeredItem(
                                index: i % 12,
                                child: _Tile(
                                  label: 'Lainnya / Custom',
                                  size: iconSize,
                                  onTap: _custom,
                                  leading: _CustomTileIcon(size: iconSize),
                                ),
                              );
                            }
                            final s = filtered[i];
                            return StaggeredItem(
                              index: i % 12,
                              child: _Tile(
                                label: s.name,
                                size: iconSize,
                                onTap: () => _open(s),
                                leading: ServiceIcon(
                                  service: s,
                                  size: iconSize,
                                  heroTag: 'svc-${s.id}',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.size,
    required this.onTap,
    required this.leading,
  });

  final String label;
  final double size;
  final VoidCallback onTap;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: size * 0.8,
      child: Column(
        children: [
          leading,
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(11.5, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _CustomTileIcon extends StatelessWidget {
  const _CustomTileIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: AppColors.espresso,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(size * 0.44),
          side: const BorderSide(color: AppColors.gold, width: 1.2),
        ),
      ),
      child: Icon(Icons.add_rounded, color: AppColors.gold, size: size * 0.5),
    );
  }
}
