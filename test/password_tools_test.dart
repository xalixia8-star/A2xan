import 'package:flutter_test/flutter_test.dart';
import 'package:vaulte/core/security/attempt_limiter.dart';
import 'package:vaulte/core/utils/password_tools.dart';

void main() {
  group('PasswordGenerator', () {
    test('panjang dibatasi 8-64', () {
      expect(PasswordGenerator.generate(const GeneratorOptions(length: 2)).length, 8);
      expect(PasswordGenerator.generate(const GeneratorOptions(length: 500)).length, 64);
      expect(PasswordGenerator.generate(const GeneratorOptions(length: 24)).length, 24);
    });

    test('memuat semua kelompok karakter yang dipilih', () {
      for (var i = 0; i < 50; i++) {
        final p = PasswordGenerator.generate(const GeneratorOptions(length: 8));
        expect(p, matches(RegExp(r'[A-Z]')));
        expect(p, matches(RegExp(r'[a-z]')));
        expect(p, matches(RegExp(r'[0-9]')));
        expect(p, matches(RegExp(r'[^A-Za-z0-9]')));
      }
    });

    test('hanya angka bila hanya angka dipilih', () {
      final p = PasswordGenerator.generate(const GeneratorOptions(
          length: 20, upper: false, lower: false, symbols: false));
      expect(p, matches(RegExp(r'^[0-9]+$')));
    });
  });

  group('PasswordStrength', () {
    test('kosong', () {
      expect(PasswordStrength.evaluate('').level, StrengthLevel.empty);
    });
    test('pendek/umum = lemah', () {
      expect(PasswordStrength.evaluate('password').level, StrengthLevel.weak);
      expect(PasswordStrength.evaluate('aaaaaaaa').level, StrengthLevel.weak);
    });
    test('panjang acak = sangat kuat', () {
      expect(PasswordStrength.evaluate('Xk9#mQ2\$vL7!pR4&zN8@').level,
          StrengthLevel.excellent);
    });
  });

  group('AttemptLimiter.delayFor', () {
    test('3 percobaan pertama tanpa delay', () {
      expect(AttemptLimiter.delayFor(1), Duration.zero);
      expect(AttemptLimiter.delayFor(2), Duration.zero);
    });
    test('delay bertahap setelah 3x salah', () {
      expect(AttemptLimiter.delayFor(3), const Duration(seconds: 30));
      expect(AttemptLimiter.delayFor(4), const Duration(seconds: 60));
      expect(AttemptLimiter.delayFor(5), const Duration(seconds: 120));
    });
    test('dibatasi maksimum', () {
      expect(AttemptLimiter.delayFor(50),
          const Duration(seconds: AttemptLimiter.maxDelaySeconds));
    });
  });
}
