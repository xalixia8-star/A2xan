import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Operasi kriptografi: PBKDF2-HMAC-SHA256 + AES-256-GCM.
class CryptoService {
  CryptoService({this.iterations = defaultIterations});

  /// Di atas batas minimum 310.000 (rekomendasi OWASP untuk SHA-256: 600.000).
  static const int defaultIterations = 600000;
  static const int saltLength = 16;
  static const int nonceLength = 12;
  static const int macLength = 16;

  final int iterations;
  final AesGcm _aes = AesGcm.with256bits();

  Uint8List randomBytes(int length) {
    final r = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => r.nextInt(256)));
  }

  /// Turunkan kunci 256-bit dari password + salt.
  Future<SecretKey> deriveKey(String password, List<int> salt,
      {int? iterations}) {
    final kdf = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations ?? this.iterations,
      bits: 256,
    );
    return kdf.deriveKeyFromPassword(password: password, nonce: salt);
  }

  SecretKey keyFromBytes(List<int> bytes) => SecretKey(bytes);

  /// Mengembalikan nonce || ciphertext || mac.
  Future<Uint8List> encrypt(List<int> plain, SecretKey key) async {
    final box = await _aes.encrypt(plain, secretKey: key);
    return Uint8List.fromList(box.concatenation());
  }

  /// Melempar [SecretBoxAuthenticationError] bila kunci salah / data diubah.
  Future<Uint8List> decrypt(List<int> data, SecretKey key) async {
    final box = SecretBox.fromConcatenation(
      data,
      nonceLength: nonceLength,
      macLength: macLength,
    );
    final clear = await _aes.decrypt(box, secretKey: key);
    return Uint8List.fromList(clear);
  }
}
