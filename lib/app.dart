import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/utils/nav.dart';
import 'core/security/lock_guard.dart';
import 'core/utils/routes.dart';
import 'data/providers.dart';
import 'features/auth/create_master_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/shell_screen.dart';
import 'features/splash/splash_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class VaulteApp extends StatelessWidget {
  const VaulteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vaulte',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const AppRoot(),
    );
  }
}

/// Akar aplikasi: splash -> onboarding -> buat master / login -> shell.
/// Juga menangani auto-lock (idle + background) dan overlay privasi.
class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key});

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> with WidgetsBindingObserver {
  bool _splashDone = false;
  bool _obscured = false; // overlay blur saat app tidak aktif
  Timer? _idle;
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Tunda sampai frame pertama agar tidak mengubah provider saat build.
    Future.microtask(() => ref.read(authProvider.notifier).bootstrap());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _idle?.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------ lifecycle

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final unlocked = ref.read(authProvider) == AuthStatus.unlocked;
    switch (state) {
      case AppLifecycleState.inactive:
        // Pasang overlay sebelum snapshot recent-apps diambil (iOS).
        if (unlocked && !LockGuard.suppressed) setState(() => _obscured = true);
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (unlocked && !LockGuard.suppressed) {
          _backgroundedAt ??= DateTime.now();
          setState(() => _obscured = true);
        }
      case AppLifecycleState.resumed:
        _handleResume();
      case AppLifecycleState.detached:
        break;
    }
  }

  void _handleResume() {
    final at = _backgroundedAt;
    _backgroundedAt = null;
    if (at != null && ref.read(authProvider) == AuthStatus.unlocked) {
      final limit = Duration(seconds: ref.read(settingsProvider).autoLockSeconds);
      if (DateTime.now().difference(at) >= limit) {
        ref.read(authProvider.notifier).lock();
      }
    }
    if (_obscured) setState(() => _obscured = false);
    _resetIdle();
  }

  // ----------------------------------------------------------------- idle

  void _resetIdle() {
    _idle?.cancel();
    if (ref.read(authProvider) != AuthStatus.unlocked) return;
    final secs = ref.read(settingsProvider).autoLockSeconds;
    _idle = Timer(Duration(seconds: secs), () {
      if (!LockGuard.suppressed) ref.read(authProvider.notifier).lock();
    });
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(authProvider);
    final onboardingDone =
        ref.watch(settingsProvider.select((s) => s.onboardingDone));

    ref.listen<AuthStatus>(authProvider, (prev, next) {
      if (next == AuthStatus.unlocked) {
        _resetIdle();
      } else {
        _idle?.cancel();
      }
    });
    ref.listen(settingsProvider.select((s) => s.autoLockSeconds), (_, __) {
      _resetIdle();
    });

    final Widget page;
    if (!_splashDone || status == AuthStatus.booting) {
      page = SplashScreen(
        key: const ValueKey('splash'),
        onFinished: () => setState(() => _splashDone = true),
      );
    } else if (status == AuthStatus.noVault && !onboardingDone) {
      page = const OnboardingScreen(key: ValueKey('onboarding'));
    } else if (status == AuthStatus.noVault) {
      page = const CreateMasterScreen(key: ValueKey('create'));
    } else if (status == AuthStatus.locked) {
      page = const LoginScreen(key: ValueKey('login'));
    } else {
      page = const ShellScreen(key: ValueKey('shell'));
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetIdle(),
      onPointerMove: (_) => _resetIdle(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Perpindahan antar tahap: cross-fade (fade in 350 ms / out 300 ms
          // diperhalus menjadi 600 ms agar transisi splash terasa elegan).
          AnimatedSwitcher(
            duration: Motion.page,
            reverseDuration: Motion.page,
            switchInCurve: Motion.out,
            switchOutCurve: Motion.smooth,
            child: page,
          ),
          IgnorePointer(
            ignoring: !_obscured,
            child: AnimatedOpacity(
              opacity: _obscured ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: const _PrivacyShield(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Menutup konten saat aplikasi berpindah (recent apps / app switcher).
class _PrivacyShield extends StatelessWidget {
  const _PrivacyShield();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: const ColoredBox(color: Color(0xE60D0D0D)),
        ),
        const Center(child: VaulteLogo(size: 96)),
        Positioned(
          left: 0,
          right: 0,
          bottom: 90,
          child: Center(
            child: Text('Vaulte',
                style: AppText.heading(34, color: AppColors.gold)),
          ),
        ),
      ],
    );
  }
}
