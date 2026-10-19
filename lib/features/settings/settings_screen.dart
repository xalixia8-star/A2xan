import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/security/lock_guard.dart';
import '../../data/models/app_settings.dart';
import '../../data/providers.dart';
import '../../data/repositories/vault_repository.dart';
import '../../shared/widgets/dialogs.dart';
import '../../shared/widgets/password_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/strength_meter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Tab Pengaturan.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 18),
            child: Text('Pengaturan', style: AppText.heading(42)),
          ),
          _Section(title: 'Keamanan', children: [
            _Tile(
              icon: Icons.key_rounded,
              title: 'Ubah master password',
              subtitle: 'Ganti password untuk membuka vault',
              onTap: () => _changePassword(context, ref),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.gold),
              title: Text('Buka dengan biometrik', style: AppText.body(15, weight: 500)),
              subtitle: Text('Face ID / sidik jari',
                  style: AppText.body(12.5, color: AppColors.champagneMuted)),
              value: s.biometricEnabled,
              onChanged: (v) => _toggleBiometric(context, ref, v),
            ),
            _Tile(
              icon: Icons.timer_outlined,
              title: 'Auto-lock',
              subtitle: 'Kunci setelah ${AppSettings.durationLabel(s.autoLockSeconds)} tidak aktif',
              onTap: () => _pickDuration(
                context,
                title: 'Auto-lock',
                options: AppSettings.autoLockOptions,
                current: s.autoLockSeconds,
                onSelected: (v) => ref
                    .read(settingsProvider.notifier)
                    .update((x) => x.copyWith(autoLockSeconds: v)),
              ),
            ),
            _Tile(
              icon: Icons.content_paste_off_rounded,
              title: 'Bersihkan clipboard',
              subtitle: 'Otomatis setelah ${AppSettings.durationLabel(s.clipboardSeconds)}',
              onTap: () => _pickDuration(
                context,
                title: 'Bersihkan clipboard',
                options: AppSettings.clipboardOptions,
                current: s.clipboardSeconds,
                onSelected: (v) => ref
                    .read(settingsProvider.notifier)
                    .update((x) => x.copyWith(clipboardSeconds: v)),
              ),
            ),
          ]),
          _Section(title: 'Data', children: [
            _Tile(
              icon: Icons.upload_file_rounded,
              title: 'Backup terenkripsi',
              subtitle: 'Ekspor vault ke berkas .vaulte',
              onTap: () => _backup(context, ref),
            ),
            _Tile(
              icon: Icons.download_rounded,
              title: 'Restore backup',
              subtitle: 'Impor dari berkas .vaulte',
              onTap: () => _restore(context, ref),
            ),
          ]),
          _Section(title: 'Lainnya', children: [
            _Tile(
              icon: Icons.lock_rounded,
              title: 'Kunci sekarang',
              onTap: () => ref.read(authProvider.notifier).lock(),
            ),
            _Tile(
              icon: Icons.info_outline_rounded,
              title: 'Tentang Vaulte',
              onTap: () => _about(context),
            ),
          ]),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- aksi

  Future<void> _toggleBiometric(BuildContext context, WidgetRef ref, bool on) async {
    final repo = ref.read(vaultRepoProvider);
    final settings = ref.read(settingsProvider.notifier);
    if (on) {
      final bio = ref.read(biometricProvider);
      if (!await bio.isAvailable()) {
        showSnack('Biometrik tidak tersedia / belum diatur di perangkat ini');
        return;
      }
      if (!await bio.authenticate('Aktifkan buka kunci biometrik')) return;
      await repo.storeBiometricKey();
      await settings.update((x) => x.copyWith(biometricEnabled: true));
      showSnack('Biometrik diaktifkan');
    } else {
      await repo.removeBiometricKey();
      await settings.update((x) => x.copyWith(biometricEnabled: false));
      showSnack('Biometrik dinonaktifkan');
    }
  }

  Future<void> _pickDuration(
    BuildContext context, {
    required String title,
    required List<int> options,
    required int current,
    required ValueChanged<int> onSelected,
  }) {
    return showAppSheet<void>(
      context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppText.heading(32)),
            const SizedBox(height: 8),
            for (final o in options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppSettings.durationLabel(o), style: AppText.body(16)),
                trailing: o == current
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.gold)
                    : const Icon(Icons.circle_outlined, color: AppColors.champagneMuted),
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(o);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref) {
    return showAppSheet<void>(
      context,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  Future<String?> _askPassword(
    BuildContext context, {
    required String title,
    required String hint,
    bool confirm = false,
    required String action,
  }) {
    return showAppSheet<String>(
      context,
      builder: (_) => _PasswordPromptSheet(
        title: title,
        hint: hint,
        confirm: confirm,
        action: action,
      ),
    );
  }

  Future<void> _backup(BuildContext context, WidgetRef ref) async {
    final pw = await _askPassword(
      context,
      title: 'Backup terenkripsi',
      hint: 'Buat password khusus untuk berkas backup ini. Anda akan '
          'membutuhkannya saat restore.',
      confirm: true,
      action: 'Buat backup',
    );
    if (pw == null) return;
    try {
      final bytes = await ref.read(vaultRepoProvider).exportBackup(pw);
      final dir = await getTemporaryDirectory();
      final t = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      final name = 'vaulte-backup-${t.year}${two(t.month)}${two(t.day)}-'
          '${two(t.hour)}${two(t.minute)}.vaulte';
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(bytes, flush: true);
      await LockGuard.run(() => Share.shareXFiles(
            [XFile(file.path, mimeType: 'application/octet-stream')],
            subject: 'Backup Vaulte',
          ));
      // Hapus salinan sementara.
      if (await file.exists()) await file.delete();
    } catch (_) {
      showSnack('Backup gagal dibuat');
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final result = await LockGuard.run(
      () => FilePicker.platform.pickFiles(type: FileType.any, withData: true),
    );
    final bytes = result?.files.single.bytes;
    if (bytes == null) return;
    if (!context.mounted) return;
    final pw = await _askPassword(
      context,
      title: 'Restore backup',
      hint: 'Masukkan password yang dipakai saat membuat backup.',
      action: 'Restore',
    );
    if (pw == null) return;
    try {
      final n = await ref.read(vaultProvider.notifier).importBackup(bytes, pw);
      HapticFeedback.mediumImpact();
      showSnack('Restore berhasil: $n sandi ditambahkan/diperbarui');
    } on WrongPasswordException {
      showSnack('Password backup salah atau berkas rusak');
    } on InvalidBackupException catch (e) {
      showSnack(e.message);
    } catch (_) {
      showSnack('Restore gagal');
    }
  }

  void _about(BuildContext context) {
    showAppDialog<void>(
      context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vaulte'),
        content: Text(
          'Versi 1.0.0\n\n'
          'Password manager offline. Data dienkripsi AES-256-GCM dengan kunci '
          'dari master password (PBKDF2-HMAC-SHA256 + salt acak) dan tidak '
          'pernah meninggalkan perangkat. Tanpa analytics, tanpa pelacak.',
          style: AppText.body(14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ widget

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: AppText.body(12, weight: 600, color: AppColors.gold)
                  .copyWith(letterSpacing: 1.4),
            ),
          ),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 60),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.gold),
      title: Text(title, style: AppText.body(15, weight: 500)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!,
              style: AppText.body(12.5, color: AppColors.champagneMuted)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.gold),
      onTap: onTap,
    );
  }
}

/// Sheet ubah master password.
class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _form = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _oldError;

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _oldError = null);
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(vaultRepoProvider)
          .changeMasterPassword(_old.text, _new.text);
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      Navigator.pop(context);
      showSnack('Master password diubah');
    } on WrongPasswordException {
      setState(() {
        _busy = false;
        _oldError = 'Password lama salah';
      });
      _form.currentState!.validate();
    } catch (_) {
      setState(() => _busy = false);
      showSnack('Gagal mengubah password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          22, 4, 22, 22 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Ubah master password', style: AppText.heading(32)),
              const SizedBox(height: 18),
              PasswordField(
                controller: _old,
                label: 'Password saat ini',
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if ((v ?? '').isEmpty) return 'Wajib diisi';
                  return _oldError;
                },
              ),
              const SizedBox(height: 14),
              PasswordField(
                controller: _new,
                label: 'Password baru',
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                validator: (v) =>
                    (v ?? '').length < 10 ? 'Minimal 10 karakter' : null,
              ),
              const SizedBox(height: 10),
              StrengthMeter(password: _new.text),
              const SizedBox(height: 14),
              PasswordField(
                controller: _confirm,
                label: 'Ulangi password baru',
                textInputAction: TextInputAction.done,
                validator: (v) => v == _new.text ? null : 'Password tidak sama',
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'Simpan',
                icon: Icons.check_rounded,
                loading: _busy,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sheet generik untuk meminta satu password (backup / restore).
class _PasswordPromptSheet extends StatefulWidget {
  const _PasswordPromptSheet({
    required this.title,
    required this.hint,
    required this.confirm,
    required this.action,
  });

  final String title;
  final String hint;
  final bool confirm;
  final String action;

  @override
  State<_PasswordPromptSheet> createState() => _PasswordPromptSheetState();
}

class _PasswordPromptSheetState extends State<_PasswordPromptSheet> {
  final _form = GlobalKey<FormState>();
  final _pw = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _pw.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          22, 4, 22, 22 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title, style: AppText.heading(32)),
              const SizedBox(height: 8),
              Text(widget.hint,
                  style: AppText.body(13.5,
                      color: AppColors.champagneMuted, height: 1.5)),
              const SizedBox(height: 18),
              PasswordField(
                controller: _pw,
                label: 'Password backup',
                autofocus: true,
                onChanged: (_) => setState(() {}),
                textInputAction:
                    widget.confirm ? TextInputAction.next : TextInputAction.done,
                validator: (v) {
                  if ((v ?? '').isEmpty) return 'Wajib diisi';
                  if (widget.confirm && v!.length < 8) return 'Minimal 8 karakter';
                  return null;
                },
              ),
              if (widget.confirm) ...[
                const SizedBox(height: 10),
                StrengthMeter(password: _pw.text),
                const SizedBox(height: 14),
                PasswordField(
                  controller: _confirm,
                  label: 'Ulangi password backup',
                  validator: (v) => v == _pw.text ? null : 'Password tidak sama',
                ),
              ],
              const SizedBox(height: 22),
              PrimaryButton(
                label: widget.action,
                icon: Icons.check_rounded,
                onPressed: () {
                  if (_form.currentState!.validate()) {
                    Navigator.pop(context, _pw.text);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
