import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/routes.dart';
import '../../data/providers.dart';
import '../../shared/widgets/primary_button.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class _Page {
  const _Page(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

const _pages = [
  _Page(
    Icons.shield_moon_rounded,
    'Brankas pribadi Anda',
    'Simpan semua sandi dan akun di satu tempat yang aman. '
        'Seluruh data tersimpan offline di perangkat Anda.',
  ),
  _Page(
    Icons.enhanced_encryption_rounded,
    'Enkripsi tingkat tinggi',
    'Data dilindungi AES-256-GCM dengan kunci turunan master password. '
        'Tanpa analytics, tanpa pelacak, tanpa izin yang tidak perlu.',
  ),
  _Page(
    Icons.auto_awesome_rounded,
    'Pilih, simpan, selesai',
    'Pilih layanan dari ikon yang familiar, buat password kuat dengan '
        'generator, lalu buka kunci cukup dengan biometrik.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    HapticFeedback.selectionClick();
    await ref
        .read(settingsProvider.notifier)
        .update((s) => s.copyWith(onboardingDone: true));
  }

  void _next() {
    if (_index == _pages.length - 1) {
      _finish();
    } else {
      _controller.nextPage(duration: Motion.page, curve: Motion.smooth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                opacity: last ? 0 : 1,
                duration: Motion.tab,
                child: TextButton(
                  onPressed: last ? null : _finish,
                  child: Text('Lewati', style: AppText.body(14, color: AppColors.gold)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.espresso,
                            border: Border.all(color: AppColors.goldBorder(0.5)),
                            boxShadow: AppColors.softShadow,
                          ),
                          child: Icon(p.icon, size: 68, color: AppColors.gold),
                        ),
                        const SizedBox(height: 44),
                        Text(p.title,
                            textAlign: TextAlign.center,
                            style: AppText.heading(38)),
                        const SizedBox(height: 16),
                        Text(
                          p.body,
                          textAlign: TextAlign.center,
                          style: AppText.body(15,
                              color: AppColors.champagneMuted, height: 1.6),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: Motion.tab,
                    curve: Motion.smooth,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: i == _index
                          ? AppColors.gold
                          : AppColors.goldBorder(0.3),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
              child: PrimaryButton(
                label: last ? 'Mulai' : 'Lanjut',
                icon: last ? Icons.check_rounded : Icons.arrow_forward_rounded,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
