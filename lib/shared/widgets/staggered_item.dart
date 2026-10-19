import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/utils/routes.dart';

/// Memunculkan child dengan fade-in + slide-up bertahap berdasarkan [index].
class StaggeredItem extends StatefulWidget {
  const StaggeredItem({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: Motion.listItem);
  late final Animation<double> _curve =
      CurvedAnimation(parent: _c, curve: Motion.out);
  late final Animation<Offset> _slide =
      Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(_curve);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Batasi jeda agar item jauh di bawah tidak menunggu terlalu lama.
    final delay = Duration(milliseconds: 60 * widget.index.clamp(0, 8).toInt());
    _timer = Timer(delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
