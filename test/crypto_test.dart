import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaulte/core/crypto/crypto_service.dart';

void main() {
  // Iterasi rendah hanya untuk kecepatan tes; produksi memakai 600.000.
  final crypto = CryptoService(iterations: 1000);

  test('iterasi default memenuhi minimum 310.000', () {
    expect(CryptoService.defaultIterations, greaterThanOrEqualTo(310000));
  });

  test('enkripsi lalu dekripsi mengembalikan data asli', () async {
    final salt = crypto.randomBytes(16);
    final key = await crypto.deriveKey('master-password', salt);
    final enc = await crypto.encrypt(utf8.encode('rahasia'), key);
    expect(utf8.decode(await crypto.decrypt(enc, key)), 'rahasia');
  });

  test('ciphertext berbeda tiap enkripsi (nonce acak)', () async {
    final key = await crypto.deriveKey('pw', crypto.randomBytes(16));
    final a = await crypto.encrypt([1, 2, 3], key);
    final b = await crypto.encrypt([1, 2, 3], key);
    expect(a, isNot(equals(b)));
  });

  test('kunci salah ditolak', () async {
    final salt = crypto.randomBytes(16);
    final k1 = await crypto.deriveKey('benar', salt);
    final k2 = await crypto.deriveKey('salah', salt);
    final enc = await crypto.encrypt([9, 9, 9], k1);
    expect(() => crypto.decrypt(enc, k2),
        throwsA(isA<SecretBoxAuthenticationError>()));
  });

  test('data yang diubah terdeteksi (GCM)', () async {
    final key = await crypto.deriveKey('pw', crypto.randomBytes(16));
    final enc = await crypto.encrypt(utf8.encode('data penting'), key);
    enc[enc.length ~/ 2] ^= 0x01;
    expect(() => crypto.decrypt(enc, key),
        throwsA(isA<SecretBoxAuthenticationError>()));
  });
}
