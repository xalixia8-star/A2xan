import 'package:vaulte/core/security/secure_store.dart';

/// SecureStore palsu berbasis memori untuk unit test.
class MemoryStore extends SecureStore {
  final Map<String, String> _m = {};

  @override
  Future<String?> read(String key) async => _m[key];

  @override
  Future<void> write(String key, String value) async => _m[key] = value;

  @override
  Future<void> delete(String key) async => _m.remove(key);
}
