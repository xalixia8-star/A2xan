import 'package:flutter/material.dart';

/// Kurva & durasi animasi terpusat supaya konsisten di seluruh aplikasi.
class Motion {
  Motion._();

  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve out = Curves.easeOutQuart;

  static const Duration page = Duration(milliseconds: 520);
  static const Duration tab = Duration(milliseconds: 400);
  static const Duration dialogIn = Duration(milliseconds: 350);
  static const Duration dialogOut = Duration(milliseconds: 300);
  static const Duration listItem = Duration(milliseconds: 450);

  static const AnimationStyle overlayStyle = AnimationStyle(
    duration: dialogIn,
    reverseDuration: dialogOut,
    curve: smooth,
    reverseCurve: smooth,
  );
}

Widget _fadeSlide(Animation<double> animation, Animation<double> secondary,
    Widget child) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: Motion.out,
    reverseCurve: Motion.smooth,
  );
  final slide = Tween<Offset>(
    begin: const Offset(0.0, 0.04),
    end: Offset.zero,
  ).animate(curved);
  return FadeTransition(
    opacity: curved,
    child: SlideTransition(position: slide, child: child),
  );
}

/// Transisi halaman: fade + slide tipis (450-600 ms).
class FadeSlideRoute<T> extends PageRouteBuilder<T> {
  FadeSlideRoute({required WidgetBuilder builder, super.settings})
      : super(
          transitionDuration: Motion.page,
          reverseTransitionDuration: Motion.page,
          opaque: true,
          pageBuilder: (context, a, b) => builder(context),
          transitionsBuilder: (context, a, b, child) => _fadeSlide(a, b, child),
        );
}

/// Dipakai sebagai default untuk MaterialPageRoute lewat ThemeData.
class FadeSlideTransitionsBuilder extends PageTransitionsBuilder {
  const FadeSlideTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      _fadeSlide(animation, secondaryAnimation, child);
}
