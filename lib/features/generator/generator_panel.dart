import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/password_tools.dart';
import '../../core/utils/routes.dart';
import '../../shared/widgets/copy_helper.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/strength_meter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Panel generator password; dipakai di halaman Generator dan bottom sheet.
class GeneratorPanel extends ConsumerStatefulWidget {
  const GeneratorPanel({super.key, this.onUse});

  /// Jika diisi, tampil tombol "Gunakan password ini".
  final ValueChanged<String>? onUse;

  @override
  ConsumerState<GeneratorPanel> createState() => _GeneratorPanelState();
}

class _GeneratorPanelState extends ConsumerState<GeneratorPanel> {
  GeneratorOptions _o = const GeneratorOptions();
  late String _password = PasswordGenerator.generate(_o);

  void _regen([GeneratorOptions? next]) {
    HapticFeedback.selectionClick();
    setState(() {
      if (next != null) _o = next;
      _password = PasswordGenerator.generate(_o);
    });
  }

  /// Minimal satu jenis karakter harus aktif.
  void _toggle(GeneratorOptions Function(bool) build, bool value, bool current) {
    final next = build(value);
    if (next.enabledCount == 0) return;
    _regen(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 8, 14),
          decoration: BoxDecoration(
            color: AppColors.espresso,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.goldBorder(0.35)),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: Motion.tab,
                      child: SelectableText(
                        _password,
                        key: ValueKey(_password),
                        style: AppText.body(21, weight: 500).copyWith(
                          letterSpacing: 0.8,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        tooltip: 'Buat ulang',
                        onPressed: _regen,
                        icon: const Icon(Icons.refresh_rounded),
                        color: AppColors.gold,
                      ),
                      IconButton(
                        tooltip: 'Salin',
                        onPressed: () => copyValue(ref, _password, 'Password'),
                        icon: const Icon(Icons.copy_rounded),
                        color: AppColors.gold,
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, top: 4),
                child: StrengthMeter(password: _password),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Text('Panjang', style: AppText.body(15, weight: 500)),
            const Spacer(),
            Text('${_o.length}',
                style: AppText.heading(30, italic: false, color: AppColors.gold)),
          ],
        ),
        Slider(
          value: _o.length.toDouble(),
          min: 8,
          max: 64,
          divisions: 56,
          label: '${_o.length}',
          onChanged: (v) {
            setState(() {
              _o = _o.copyWith(length: v.round());
              _password = PasswordGenerator.generate(_o);
            });
          },
        ),
        _Option(
          title: 'Huruf besar (A-Z)',
          value: _o.upper,
          onChanged: (v) => _toggle((b) => _o.copyWith(upper: b), v, _o.upper),
        ),
        _Option(
          title: 'Huruf kecil (a-z)',
          value: _o.lower,
          onChanged: (v) => _toggle((b) => _o.copyWith(lower: b), v, _o.lower),
        ),
        _Option(
          title: 'Angka (0-9)',
          value: _o.digits,
          onChanged: (v) => _toggle((b) => _o.copyWith(digits: b), v, _o.digits),
        ),
        _Option(
          title: 'Simbol (!@#\$%)',
          value: _o.symbols,
          onChanged: (v) => _toggle((b) => _o.copyWith(symbols: b), v, _o.symbols),
        ),
        if (widget.onUse != null) ...[
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Gunakan password ini',
            icon: Icons.check_rounded,
            onPressed: () => widget.onUse!(_password),
          ),
        ],
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(title, style: AppText.body(14.5)),
      value: value,
      onChanged: onChanged,
    );
  }
}
