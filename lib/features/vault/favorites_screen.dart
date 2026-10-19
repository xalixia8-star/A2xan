import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'credential_list.dart';

/// Tab Favorit.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(favoriteCredentialsProvider);
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Favorit', style: AppText.heading(42)),
                const SizedBox(height: 4),
                Text(
                  items.isEmpty ? 'Akses cepat akun penting' : '${items.length} akun favorit',
                  style: AppText.body(13, color: AppColors.champagneMuted),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    icon: Icons.star_outline_rounded,
                    title: 'Belum ada favorit',
                    message: 'Tandai bintang pada sandi penting agar '
                        'selalu mudah ditemukan di sini.',
                  )
                : CredentialList(items: items, bottomPadding: 24),
          ),
        ],
      ),
    );
  }
}
