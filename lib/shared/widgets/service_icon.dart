import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/models/service_def.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Daftar berkas SVG yang benar-benar ada di bundle (assets/icons/*.svg).
final iconAssetsProvider = FutureProvider<Set<String>>((ref) async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  return manifest
      .listAssets()
      .where((e) => e.startsWith('assets/icons/') && e.endsWith('.svg'))
      .toSet();
});

/// Ikon layanan bergaya iOS: squircle seragam, logo brand, fallback inisial.
class ServiceIcon extends ConsumerWidget {
  const ServiceIcon({
    super.key,
    required this.service,
    this.size = 60,
    this.heroTag,
  });

  final ServiceDef service;
  final double size;
  final Object? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(iconAssetsProvider).valueOrNull ?? const <String>{};

    var base = Color(service.color);
    if (base.computeLuminance() < 0.03) base = AppColors.iconNeutralBase;
    final fg = base.computeLuminance() > 0.5
        ? AppColors.iconOnLight
        : AppColors.iconOnDark;

    final path = service.slug == null ? null : 'assets/icons/${service.slug}.svg';
    final Widget glyph;
    if (service.iconIndex != null) {
      glyph = Icon(kCustomIcons[service.iconIndex!], color: fg, size: size * 0.52);
    } else if (path != null && assets.contains(path)) {
      glyph = SvgPicture.asset(
        path,
        width: size * 0.5,
        height: size * 0.5,
        colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
      );
    } else {
      glyph = Text(
        service.initials.toUpperCase(),
        style: AppText.body(size * 0.34, weight: 700, color: fg),
      );
    }

    final icon = RepaintBoundary(
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: base,
          shape: ContinuousRectangleBorder(
            // radius ≈ 22% ukuran ikon (continuous corner butuh nilai ~2x).
            borderRadius: BorderRadius.circular(size * 0.44),
            side: BorderSide(color: AppColors.goldBorder(0.35)),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: size * 0.2,
              offset: Offset(0, size * 0.08),
            ),
          ],
        ),
        child: SizedBox(width: size, height: size, child: Center(child: glyph)),
      ),
    );

    if (heroTag == null) return icon;
    return Hero(tag: heroTag!, child: icon);
  }
}
