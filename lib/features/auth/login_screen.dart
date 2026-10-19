import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../shared/widgets/password_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../splash/splash_screen.dart';

/// Login: master password + biometrik, dengan pembatasan percobaan salah.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _pw = TextEditingController();
  bool _busy = false;
  bool _bioAvailable = false;
  String? _error;
  Duration _lockLeft = Duration.zero;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final remaining = await ref.read(attemptLimiterProvider).remaining();
    if (remaining > Duration.zero) _startCountdown(remaining);

    final enabled = ref.read(settingsProvider).biometricEnabled;
    final available = enabled && await ref.read(biometricProvider).isAvailable();
    if (!mounted) return;
    setState(() => _bioAvailable = available);
    if (available && remaining == Duration.zero) {
      // Tawarkan biometrik otomatis setelah layar tampil.
      WidgetsBinding.instance.addPostFrameCallback((_) => _biometric());
    }
  }

  void _startCountdown(Duration d) {
    _ticker?.cancel();
    setState(() => _lockLeft = d);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      final left = _lockLeft - const Duration(seconds: 1);
      if (left <= Duration.zero) {
        t.cancel();
        if (mounted) {
          setState(() {
            _lockLeft = Duration.zero;
            _error = null;
          });
        }
      } else if (mounted) {
        setState(() => _lockLeft = left);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || _lockLeft > Duration.zero || _pw.text.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref.read(authProvider.notifier).login(_pw.text);
    if (!mounted) return;
    switch (r.outcome) {
      case LoginOutcome.success:
        return; // AppRoot berpindah ke halaman utama.
      case LoginOutcome.wrong:
        setState(() {
          _busy = false;
          _error = 'Password salah. Sisa ${r.attemptsLeft} percobaan '
              'sebelum penundaan.';
        });
        _pw.clear();
      case LoginOutcome.locked:
        setState(() {
          _busy = false;
          _error = 'Terlalu banyak percobaan salah.';
        });
        _pw.clear();
        _startCountdown(r.lockFor);
    }
  }

  Future<void> _biometric() async {
    if (_busy || _lockLeft > Duration.zero) return;
    await ref.read(authProvider.notifier).loginWithBiometric();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return m > 0 ? '$m mnt ${s.toString().padLeft(2, '0')} dtk' : '${d.inSeconds} dtk';
  }

  @override
  Widget build(BuildContext context) {
    final locked = _lockLeft > Duration.zero;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const VaulteLogo(size: 88),
                const SizedBox(height: 22),
                Text('Selamat datang', style: AppText.heading(42)),
                const SizedBox(height: 8),
                Text('Masukkan master password untuk membuka Vaulte',
                    textAlign: TextAlign.center,
                    style: AppText.body(14, color: AppColors.champagneMuted)),
                const SizedBox(height: 30),
                PasswordField(
                  controller: _pw,
                  label: 'Master password',
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  child: _error == null && !locked
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  size: 18, color: AppColors.danger),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  locked
                                      ? '${_error ?? 'Login ditunda.'} Coba lagi dalam ${_fmt(_lockLeft)}.'
                                      : _error!,
                                  style: AppText.body(13,
                                      color: AppColors.danger, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: locked ? 'Ditunda ${_fmt(_lockLeft)}' : 'Buka Kunci',
                  icon: Icons.lock_open_rounded,
                  loading: _busy,
                  onPressed: locked ? null : _submit,
                ),
                if (_bioAvailable) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: locked ? null : _biometric,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: const Text('Gunakan biometrik'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
