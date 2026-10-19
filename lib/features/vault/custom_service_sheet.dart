import 'package:flutter/material.dart';

import '../../data/models/credential.dart';
import '../../data/models/service_def.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/service_icon.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Bottom sheet untuk membuat layanan kustom (nama + ikon + warna).
class CustomServiceSheet extends StatefulWidget {
  const CustomServiceSheet({super.key});

  @override
  State<CustomServiceSheet> createState() => _CustomServiceSheetState();
}

class _CustomServiceSheetState extends State<CustomServiceSheet> {
  final _name = TextEditingController();
  int _icon = 0;
  int _color = 0;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  ServiceDef get _preview => ServiceDef(
        id: 'preview',
        name: _name.text.isEmpty ? 'Layanan' : _name.text,
        group: 'Lainnya',
        color: kCustomColors[_color].toARGB32(),
        iconIndex: _icon,
        isCustom: true,
      );

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(
      context,
      CustomService(
        id: 'custom-${Credential.newId()}',
        name: name,
        iconIndex: _icon,
        color: kCustomColors[_color].toARGB32(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        4,
        22,
        22 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Layanan baru', style: AppText.heading(32)),
            const SizedBox(height: 16),
            Center(child: ServiceIcon(service: _preview, size: 76)),
            const SizedBox(height: 18),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Nama layanan',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
            ),
            const SizedBox(height: 18),
            Text('Ikon', style: AppText.body(13, color: AppColors.champagneMuted)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < kCustomIcons.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _icon = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: i == _icon ? AppColors.burgundy : AppColors.midnight,
                        border: Border.all(
                          color: i == _icon
                              ? AppColors.gold
                              : AppColors.goldBorder(0.3),
                        ),
                      ),
                      child: Icon(kCustomIcons[i],
                          size: 22,
                          color: i == _icon
                              ? AppColors.champagne
                              : AppColors.gold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Warna', style: AppText.body(13, color: AppColors.champagneMuted)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < kCustomColors.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _color = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kCustomColors[i],
                        border: Border.all(
                          color: i == _color
                              ? AppColors.champagne
                              : AppColors.goldBorder(0.3),
                          width: i == _color ? 2.5 : 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Lanjut',
              icon: Icons.arrow_forward_rounded,
              onPressed: _name.text.trim().isEmpty ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
