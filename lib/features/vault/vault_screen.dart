import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/routes.dart';
import '../../data/models/service_def.dart';
import '../../data/providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'credential_list.dart';
import 'service_picker_screen.dart';

/// Tab Vault: daftar semua sandi + pencarian, filter kategori, dan sort.
class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  static const _sortLabels = {
    VaultSort.az: 'A–Z',
    VaultSort.newest: 'Terbaru',
    VaultSort.favorites: 'Favorit dulu',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(vaultProvider.select((v) => v.credentials.length));
    final items = ref.watch(filteredCredentialsProvider);
    final category = ref.watch(categoryFilterProvider);
    final sort = ref.watch(sortProvider);
    final query = ref.watch(searchQueryProvider);

    final Widget body;
    if (total == 0) {
      body = EmptyState(
        key: const ValueKey('empty-all'),
        icon: Icons.lock_outline_rounded,
        title: 'Vault masih kosong',
        message: 'Simpan sandi pertama Anda. Pilih layanan, isi akun, '
            'dan semuanya terenkripsi di perangkat ini.',
        actionLabel: 'Tambah sandi',
        onAction: () => Navigator.of(context).push(
          FadeSlideRoute(builder: (_) => const ServicePickerScreen()),
        ),
      );
    } else if (items.isEmpty) {
      body = const EmptyState(
        key: ValueKey('empty-filter'),
        icon: Icons.search_off_rounded,
        title: 'Tidak ditemukan',
        message: 'Coba kata kunci lain atau ubah filter kategori.',
      );
    } else {
      body = CredentialList(key: const ValueKey('list'), items: items);
    }

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vaulte', style: AppText.heading(44)),
                      const SizedBox(height: 4),
                      Text(
                        total == 0 ? 'Brankas Anda' : '$total sandi tersimpan',
                        style: AppText.body(13, color: AppColors.champagneMuted),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<VaultSort>(
                  tooltip: 'Urutkan',
                  color: AppColors.espresso,
                  icon: const Icon(Icons.sort_rounded, color: AppColors.gold),
                  initialValue: sort,
                  onSelected: (v) => ref.read(sortProvider.notifier).state = v,
                  itemBuilder: (_) => [
                    for (final e in _sortLabels.entries)
                      PopupMenuItem(
                        value: e.key,
                        child: Text(
                          e.value,
                          style: AppText.body(14,
                              weight: e.key == sort ? 700 : 400,
                              color: e.key == sort
                                  ? AppColors.gold
                                  : AppColors.champagne),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: TextField(
              onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Cari layanan atau akun',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isEmpty
                    ? null
                    : const Icon(Icons.filter_alt_rounded, size: 18),
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _chip(ref, 'Semua', category == null, null),
                for (final c in kCategories) _chip(ref, c, category == c, c),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: Motion.tab,
              switchInCurve: Motion.smooth,
              switchOutCurve: Motion.smooth,
              child: body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(WidgetRef ref, String label, bool selected, String? value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        labelStyle: AppText.body(13, weight: selected ? 600 : 400),
        onSelected: (_) => ref.read(categoryFilterProvider.notifier).state = value,
      ),
    );
  }
}
