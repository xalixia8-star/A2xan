import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/password_tools.dart';
import '../../data/providers.dart';
import '../../shared/widgets/dialogs.dart';
import '../../shared/widgets/password_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/strength_meter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../splash/splash_screen.dart';

/// Membuat master password saat pertama kali.
class CreateMasterScreen extends ConsumerStatefulWidget {
  const CreateMasterScreen({super.key});

  @override
  ConsumerState<CreateMasterScreen> createState() => _CreateMasterScreenState();
}

class _CreateMasterScreenState extends ConsumerState<CreateMasterScreen> {
  static const int minLength = 10;

  final _formKey = GlobalKey<FormState>();
  final _pw = TextEditingController();
  final _confirm = TextEditingController();
  bool _useBiometric = false;
  bool _bioAvailable = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    ref.read(biometricProvider).isAvailable().then((v) {
      if (mounted) setState(() => _bioAvailable = v);
    });
  }

  @override
  void dispose() {
    _pw.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      var bio = _useBiometric && _bioAvailable;
      if (bio) {
        bio = await ref
            .read(biometricProvider)
            .authenticate('Aktifkan buka kunci biometrik');
      }
      await ref
          .read(authProvider.notifier)
          .createVault(_pw.text, enableBiometric: bio);
    } catch (_) {
      showSnack('Gagal membuat vault. Coba lagi.');
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: VaulteLogo(size: 76)),
                const SizedBox(height: 24),
                Text('Buat master password', style: AppText.heading(38)),
                const SizedBox(height: 10),
                Text(
                  'Satu password untuk membuka seluruh brankas Anda. '
                  'Pilih yang kuat dan mudah Anda ingat.',
                  style: AppText.body(14,
                      color: AppColors.champagneMuted, height: 1.55),
                ),
                const SizedBox(height: 28),
                PasswordField(
                  controller: _pw,
                  label: 'Master password',
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if ((v ?? '').length < minLength) {
                      return 'Minimal $minLength karakter';
                    }
                    if (PasswordStrength.evaluate(v!).level ==
                        StrengthLevel.weak) {
                      return 'Password terlalu lemah';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                StrengthMeter(password: _pw.text),
                const SizedBox(height: 18),
                PasswordField(
                  controller: _confirm,
                  label: 'Ulangi master password',
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: (v) =>
                      v == _pw.text ? null : 'Password tidak sama',
                ),
                if (_bioAvailable) ...[
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _useBiometric,
                    onChanged: (v) => setState(() => _useBiometric = v),
                    title: Text('Buka dengan biometrik',
                        style: AppText.body(15, weight: 500)),
                    subtitle: Text('Face ID / sidik jari',
                        style: AppText.body(12, color: AppColors.champagneMuted)),
                  ),
                ],
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.espresso,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.goldBorder(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 20, color: AppColors.gold),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Master password tidak disimpan di mana pun dan '
                          'tidak dapat dipulihkan. Jika lupa, data tidak bisa '
                          'dibuka kembali.',
                          style: AppText.body(12.5,
                              color: AppColors.champagneMuted, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                PrimaryButton(
                  label: 'Buat Vault',
                  icon: Icons.lock_rounded,
                  loading: _busy,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
