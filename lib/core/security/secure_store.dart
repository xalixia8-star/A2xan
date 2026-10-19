import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Pembungkus Keychain (iOS) / Keystore (Android).
class SecureStore {
  SecureStore([FlutterSecureStorage? storage])
      : _s = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _s;

  Future<String?> read(String key) => _s.read(key: key);
  Future<void> write(String key, String value) =>
      _s.write(key: key, value: value);
  Future<void> delete(String key) => _s.delete(key: key);
}

/// Kunci penyimpanan.
class StoreKeys {
  StoreKeys._();
  static const kdfSalt = 'kdf_salt';
  static const kdfIter = 'kdf_iter';
  static const wrappedDek = 'wrapped_dek';
  static const bioDek = 'bio_dek';
  static const failCount = 'fail_count';
  static const lockUntil = 'lock_until';
  static const settings = 'settings_json';
}
