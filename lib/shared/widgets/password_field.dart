import 'package:flutter/material.dart';

/// Field password dengan tombol tampil/sembunyi.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.onChanged,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.autofocus = false,
    this.extraSuffix,
    this.prefixIcon = Icons.lock_outline_rounded,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  /// Tombol tambahan di sebelah kiri ikon mata (mis. generate).
  final Widget? extraSuffix;
  final IconData prefixIcon;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      autofocus: widget.autofocus,
      enableSuggestions: false,
      autocorrect: false,
      enableIMEPersonalizedLearning: false,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.prefixIcon),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.extraSuffix != null) widget.extraSuffix!,
            IconButton(
              tooltip: _obscure ? 'Tampilkan' : 'Sembunyikan',
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
