import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Logo (lambang) Vaulte: squircle burgundy + gembok emas.
class VaulteLogo extends StatelessWidget {
  const VaulteLogo({super.key, this.size = 104});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        gradient: AppColors.primaryGradient,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(size * 0.44),
          side: BorderSide(color: AppColors.goldBorder(0.7), width: 1.4),
        ),
        shadows: AppColors.softShadow,
      ),
      child: Icon(Icons.lock_rounded, size: size * 0.5, color: AppColors.gold),
    );
  }
}

/// Splash: fade in 900 ms, tahan 600 ms, fade out 800 ms.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2300),
  );

  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(begin: 0, end: 1)
          .chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: 900,
    ),
    TweenSequenceItem(tween: ConstantTween<double>(1), weight: 600),
    TweenSequenceItem(
      tween: Tween<double>(begin: 1, end: 0)
          .chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: 800,
    ),
  ]).animate(_c);

  late final Animation<double> _scale = Tween<double>(begin: 0.94, end: 1.0)
      .chain(CurveTween(curve: Curves.easeOutQuart))
      .animate(_c);

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onFinished();
    });
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) => Opacity(
            opacity: _opacity.value,
            child: Transform.scale(scale: _scale.value, child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const VaulteLogo(),
              const SizedBox(height: 28),
              Text('Vaulte', style: AppText.heading(56)),
              const SizedBox(height: 10),
              Text(
                'Rahasia Anda, tersimpan dengan anggun',
                style: AppText.body(13, color: AppColors.gold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
