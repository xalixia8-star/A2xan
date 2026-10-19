import 'package:flutter/material.dart';

import '../../shared/widgets/dialogs.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'generator_panel.dart';

/// Halaman Generator (tab).
class GeneratorScreen extends StatelessWidget {
  const GeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Generator', style: AppText.heading(42)),
            const SizedBox(height: 6),
            Text('Buat password acak yang kuat',
                style: AppText.body(14, color: AppColors.champagneMuted)),
            const SizedBox(height: 22),
            const GeneratorPanel(),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet generator; mengembalikan password yang dipilih.
Future<String?> showGeneratorSheet(BuildContext context) {
  return showAppSheet<String>(
    context,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        4,
        22,
        22 + MediaQuery.of(ctx).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Generate Password', style: AppText.heading(32)),
            const SizedBox(height: 16),
            GeneratorPanel(onUse: (pw) => Navigator.pop(ctx, pw)),
          ],
        ),
      ),
    ),
  );
}
