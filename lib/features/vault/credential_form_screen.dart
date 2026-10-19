import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/credential.dart';
import '../../data/models/service_def.dart';
import '../../data/providers.dart';
import '../../shared/widgets/dialogs.dart';
import '../../shared/widgets/password_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/service_icon.dart';
import '../../shared/widgets/strength_meter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../generator/generator_screen.dart';

/// Langkah 2 tambah sandi (atau mengedit sandi yang ada).
class CredentialFormScreen extends ConsumerStatefulWidget {
  const CredentialFormScreen({super.key, this.service, this.existing})
      : assert(service != null || existing != null);

  final ServiceDef? service;
  final Credential? existing;

  @override
  ConsumerState<CredentialFormScreen> createState() =>
      _CredentialFormScreenState();
}

class _CredentialFormScreenState extends ConsumerState<CredentialFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _password;
  late final TextEditingController _url;
  late final TextEditingController _notes;
  late String _category;
  late bool _favorite;
  late ServiceDef _service;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _service = ref.read(serviceResolverProvider)(e.serviceId, e.serviceName);
    } else {
      _service = widget.service!;
    }
    _name = TextEditingController(text: e?.serviceName ?? _service.name);
    _username = TextEditingController(text: e?.username ?? '');
    _password = TextEditingController(text: e?.password ?? '');
    _url = TextEditingController(text: e?.url ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    _category = e?.category ?? _service.category;
    _favorite = e?.favorite ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _password.dispose();
    _url.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final pw = await showGeneratorSheet(context);
    if (pw != null) setState(() => _password.text = pw);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final e = widget.existing;
    final cred = Credential(
      id: e?.id ?? Credential.newId(),
      serviceId: e?.serviceId ?? _service.id,
      serviceName: _name.text.trim(),
      username: _username.text.trim(),
      password: _password.text,
      url: _url.text.trim(),
      notes: _notes.text.trim(),
      category: _category,
      favorite: _favorite,
      createdAt: e?.createdAt ?? now,
      updatedAt: now,
    );
    await ref.read(vaultProvider.notifier).save(cred);
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    if (_isEdit) {
      Navigator.of(context).pop();
    } else {
      // Kembali ke Vault (tutup pemilih layanan + form).
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
    showSnack(_isEdit ? 'Perubahan disimpan' : 'Sandi disimpan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit sandi' : 'Detail akun')),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ServiceIcon(
                    service: _service,
                    size: 84,
                    heroTag: _isEdit
                        ? 'cred-${widget.existing!.id}'
                        : 'svc-${_service.id}',
                  ),
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nama layanan',
                    prefixIcon: Icon(Icons.apps_rounded),
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _username,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    labelText: 'Username / Email',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Username atau email wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                PasswordField(
                  controller: _password,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                  validator: (v) =>
                      (v ?? '').isEmpty ? 'Password wajib diisi' : null,
                  extraSuffix: IconButton(
                    tooltip: 'Generate password',
                    onPressed: _generate,
                    icon: const Icon(Icons.auto_fix_high_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                StrengthMeter(password: _password.text),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _generate,
                    icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                    label: const Text('Generate Password'),
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _url,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'URL (opsional)',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notes,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 52),
                      child: Icon(Icons.sticky_note_2_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  dropdownColor: AppColors.espresso,
                  borderRadius: BorderRadius.circular(16),
                  iconEnabledColor: AppColors.gold,
                  style: AppText.body(15),
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.label_outline_rounded),
                  ),
                  items: [
                    for (final c in kCategories)
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                const SizedBox(height: 6),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  value: _favorite,
                  onChanged: (v) => setState(() => _favorite = v),
                  title: Text('Tandai favorit', style: AppText.body(15, weight: 500)),
                  secondary: Icon(
                    _favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: _isEdit ? 'Simpan perubahan' : 'Simpan',
                  icon: Icons.check_rounded,
                  loading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
