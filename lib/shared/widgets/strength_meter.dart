import 'package:flutter/material.dart';

import '../../core/utils/password_tools.dart';
import '../../core/utils/routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Indikator kekuatan password (bar animasi + label).
class StrengthMeter extends StatelessWidget {
  const StrengthMeter({super.key, required this.password});

  final String password;

  Color _color(StrengthLevel l) {
    switch (l) {
      case StrengthLevel.empty:
        return AppColors.goldBorder(0.2);
      case StrengthLevel.weak:
        return AppColors.danger;
      case StrengthLevel.fair:
        return AppColors.gold;
      case StrengthLevel.strong:
      case StrengthLevel.excellent:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = PasswordStrength.evaluate(password);
    final color = _color(s.level);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(height: 6, color: AppColors.goldBorder(0.15)),
              AnimatedFractionallySizedBox(
                duration: Motion.tab,
                curve: Motion.smooth,
                widthFactor: s.fraction,
                child: AnimatedContainer(
                  duration: Motion.tab,
                  height: 6,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: Motion.tab,
          child: Text(
            s.level == StrengthLevel.empty
                ? ' '
                : 'Kekuatan: ${s.label}',
            key: ValueKey(s.level),
            style: AppText.body(12, color: color == AppColors.goldBorder(0.2)
                ? AppColors.champagneMuted
                : color),
          ),
        ),
      ],
    );
  }
}
