import 'dart:math';

/// Opsi generator password.
class GeneratorOptions {
  const GeneratorOptions({
    this.length = 20,
    this.upper = true,
    this.lower = true,
    this.digits = true,
    this.symbols = true,
  });

  final int length;
  final bool upper;
  final bool lower;
  final bool digits;
  final bool symbols;

  GeneratorOptions copyWith({
    int? length,
    bool? upper,
    bool? lower,
    bool? digits,
    bool? symbols,
  }) =>
      GeneratorOptions(
        length: length ?? this.length,
        upper: upper ?? this.upper,
        lower: lower ?? this.lower,
        digits: digits ?? this.digits,
        symbols: symbols ?? this.symbols,
      );

  int get enabledCount =>
      [upper, lower, digits, symbols].where((e) => e).length;
}

class PasswordGenerator {
  PasswordGenerator._();

  static const _upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const _lower = 'abcdefghijkmnopqrstuvwxyz';
  static const _digits = '23456789';
  static const _symbols = r'!@#$%^&*()-_=+[]{};:,.?';

  /// Menghasilkan password acak (CSPRNG) dengan minimal satu karakter dari
  /// tiap kelompok yang dipilih. Panjang dibatasi 8-64.
  static String generate(GeneratorOptions o, {Random? random}) {
    final r = random ?? Random.secure();
    final groups = <String>[
      if (o.upper) _upper,
      if (o.lower) _lower,
      if (o.digits) _digits,
      if (o.symbols) _symbols,
    ];
    if (groups.isEmpty) groups.add(_lower);

    final length = o.length.clamp(8, 64).toInt();
    final pool = groups.join();
    final chars = <String>[
      for (final g in groups) g[r.nextInt(g.length)],
    ];
    while (chars.length < length) {
      chars.add(pool[r.nextInt(pool.length)]);
    }
    // Fisher-Yates shuffle
    for (var i = chars.length - 1; i > 0; i--) {
      final j = r.nextInt(i + 1);
      final t = chars[i];
      chars[i] = chars[j];
      chars[j] = t;
    }
    return chars.join();
  }
}

enum StrengthLevel { empty, weak, fair, strong, excellent }

class PasswordStrength {
  const PasswordStrength(this.level, this.bits);

  final StrengthLevel level;
  final double bits;

  /// 0.0 - 1.0 untuk indikator.
  double get fraction {
    switch (level) {
      case StrengthLevel.empty:
        return 0;
      case StrengthLevel.weak:
        return 0.25;
      case StrengthLevel.fair:
        return 0.5;
      case StrengthLevel.strong:
        return 0.75;
      case StrengthLevel.excellent:
        return 1;
    }
  }

  String get label {
    switch (level) {
      case StrengthLevel.empty:
        return '';
      case StrengthLevel.weak:
        return 'Lemah';
      case StrengthLevel.fair:
        return 'Sedang';
      case StrengthLevel.strong:
        return 'Kuat';
      case StrengthLevel.excellent:
        return 'Sangat kuat';
    }
  }

  static const _common = [
    'password', 'qwerty', '123456', 'admin', 'letmein', 'welcome',
    'iloveyou', 'abc123', 'sandi', 'rahasia', 'indonesia',
  ];

  /// Estimasi entropi sederhana + penalti pola umum / karakter berulang.
  static PasswordStrength evaluate(String p) {
    if (p.isEmpty) return const PasswordStrength(StrengthLevel.empty, 0);

    var pool = 0;
    if (RegExp(r'[a-z]').hasMatch(p)) pool += 26;
    if (RegExp(r'[A-Z]').hasMatch(p)) pool += 26;
    if (RegExp(r'[0-9]').hasMatch(p)) pool += 10;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) pool += 32;

    var bits = p.length * (log(max(pool, 2)) / ln2);

    // Penalti karakter unik sedikit (mis. "aaaaaaaa").
    final unique = p.split('').toSet().length;
    bits *= (unique / p.length).clamp(0.3, 1.0);

    final lower = p.toLowerCase();
    if (_common.any(lower.contains)) bits *= 0.5;

    final level = bits < 36
        ? StrengthLevel.weak
        : bits < 56
            ? StrengthLevel.fair
            : bits < 80
                ? StrengthLevel.strong
                : StrengthLevel.excellent;
    return PasswordStrength(level, bits);
  }
}
