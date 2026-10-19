import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/routes.dart';
import '../../data/models/credential.dart';
import '../../data/providers.dart';
import '../../shared/widgets/copy_helper.dart';
import '../../shared/widgets/dialogs.dart';
import '../../shared/widgets/service_icon.dart';
import '../../shared/widgets/strength_meter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'credential_form_screen.dart';

/// Detail sandi: lihat, salin, edit, hapus.
class CredentialDetailScreen extends ConsumerStatefulWidget {
  const CredentialDetailScreen({super.key, required this.credentialId});

  final String credentialId;

  @override
  ConsumerState<CredentialDetailScreen> createState() =>
      _CredentialDetailScreenState();
}

class _CredentialDetailScreenState
    extends ConsumerState<CredentialDetailScreen> {
  bool _showPassword = false;

  Future<void> _delete(Credential c) async {
    final ok = await confirmDialog(
      context,
      title: 'Hapus sandi?',
      message: 'Sandi "${c.serviceName}" akan dihapus permanen dan tidak '
          'bisa dikembalikan.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!ok || !mounted) return;
    HapticFeedback.heavyImpact();
    await ref.read(vaultProvider.notifier).remove(c.id);
    if (mounted) Navigator.of(context).pop();
    showSnack('Sandi dihapus');
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(credentialByIdProvider(widget.credentialId));
    if (c == null) {
      // Sudah dihapus: tampilkan layar kosong selama transisi keluar.
      return const Scaffold();
    }
    final service = ref.watch(serviceResolverProvider)(c.serviceId, c.serviceName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        actions: [
          IconButton(
            tooltip: c.favorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
            onPressed: () => ref.read(vaultProvider.notifier).toggleFavorite(c),
            icon: AnimatedSwitcher(
              duration: Motion.tab,
              child: Icon(
                c.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                key: ValueKey(c.favorite),
                color: AppColors.gold,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: () => Navigator.of(context).push(
              FadeSlideRoute(builder: (_) => CredentialFormScreen(existing: c)),
            ),
            icon: const Icon(Icons.edit_outlined, color: AppColors.gold),
          ),
          IconButton(
            tooltip: 'Hapus',
            onPressed: () => _delete(c),
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 32),
        children: [
          Center(
            child: ServiceIcon(
              service: service,
              size: 92,
              heroTag: 'cred-${c.id}',
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(c.serviceName,
                textAlign: TextAlign.center, style: AppText.heading(38)),
          ),
          const SizedBox(height: 8),
          Center(
            child: Chip(
              label: Text(c.category),
              avatar: const Icon(Icons.label_outline_rounded,
                  size: 16, color: AppColors.gold),
            ),
          ),
          const SizedBox(height: 22),
          Card(
            child: Column(
              children: [
                _Row(
                  icon: Icons.person_outline_rounded,
                  label: 'Username / Email',
                  value: c.username,
                  onCopy: c.username.isEmpty
                      ? null
                      : () => copyValue(ref, c.username, 'Username'),
                ),
                const Divider(height: 1),
                _Row(
                  icon: Icons.lock_outline_rounded,
                  label: 'Password',
                  value: _showPassword ? c.password : '•' * 12,
                  mono: true,
                  onToggle: () => setState(() => _showPassword = !_showPassword),
                  toggled: _showPassword,
                  onCopy: () => copyValue(ref, c.password, 'Password'),
                ),
                if (c.url.isNotEmpty) ...[
                  const Divider(height: 1),
                  _Row(
                    icon: Icons.link_rounded,
                    label: 'URL',
                    value: c.url,
                    onCopy: () => copyValue(ref, c.url, 'URL'),
                  ),
                ],
                if (c.notes.isNotEmpty) ...[
                  const Divider(height: 1),
                  _Row(
                    icon: Icons.sticky_note_2_outlined,
                    label: 'Catatan',
                    value: c.notes,
                    onCopy: () => copyValue(ref, c.notes, 'Catatan'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kekuatan password',
                      style: AppText.body(13, color: AppColors.champagneMuted)),
                  const SizedBox(height: 10),
                  StrengthMeter(password: c.password),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Dibuat ${_fmt(c.createdAt)} • Diubah ${_fmt(c.updatedAt)}',
              style: AppText.body(12, color: AppColors.champagneMuted),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.onCopy,
    this.onToggle,
    this.toggled = false,
    this.mono = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onCopy;
  final VoidCallback? onToggle;
  final bool toggled;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppText.body(12, color: AppColors.champagneMuted)),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? '—' : value,
                  style: AppText.body(15.5, weight: 500).copyWith(
                    letterSpacing: mono ? 0.6 : null,
                  ),
                ),
              ],
            ),
          ),
          if (onToggle != null)
            IconButton(
              tooltip: toggled ? 'Sembunyikan' : 'Tampilkan',
              onPressed: onToggle,
              icon: Icon(
                toggled
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.gold,
              ),
            ),
          if (onCopy != null)
            IconButton(
              tooltip: 'Salin',
              onPressed: onCopy,
              icon: const Icon(Icons.copy_rounded, color: AppColors.gold),
            ),
        ],
      ),
    );
  }
}
