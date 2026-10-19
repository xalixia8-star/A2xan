import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/crypto/crypto_service.dart';
import '../../core/security/secure_store.dart';
import '../models/credential.dart';

class WrongPasswordException implements Exception {
  @override
  String toString() => 'Password salah';
}

class InvalidBackupException implements Exception {
  InvalidBackupException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Mengelola vault terenkripsi.
///
/// Skema kunci:
///  * master password --PBKDF2(salt acak)--> KEK
///  * DEK (32 byte acak) dibungkus AES-256-GCM dengan KEK -> `wrapped_dek`
///    disimpan di Keychain/Keystore. Password asli TIDAK pernah disimpan.
///  * Seluruh data (sandi + layanan kustom) dienkripsi AES-256-GCM dengan DEK
///    dan ditulis ke berkas `vault.enc`.
class VaultRepository {
  VaultRepository(this._store, this._crypto, {Directory? directory})
      : _dirOverride = directory;

  final SecureStore _store;
  final CryptoService _crypto;
  final Directory? _dirOverride;

  SecretKey? _dek;
  VaultData _data = const VaultData();

  bool get isUnlocked => _dek != null;
  VaultData get data => _data;

  Future<File> _file() async {
    final dir = _dirOverride ?? await getApplicationSupportDirectory();
    if (!await dir.exists()) await dir.create(recursive: true);
    return File('${dir.path}/vault.enc');
  }

  Future<bool> hasVault() async =>
      (await _store.read(StoreKeys.wrappedDek)) != null;

  // ---------------------------------------------------------------- setup

  Future<void> createVault(String masterPassword) async {
    final salt = _crypto.randomBytes(CryptoService.saltLength);
    final kek = await _crypto.deriveKey(masterPassword, salt);
    final dekBytes = _crypto.randomBytes(32);
    final wrapped = await _crypto.encrypt(dekBytes, kek);

    await _store.write(StoreKeys.kdfSalt, base64Encode(salt));
    await _store.write(StoreKeys.kdfIter, '${_crypto.iterations}');
    await _store.write(StoreKeys.wrappedDek, base64Encode(wrapped));

    _dek = SecretKey(dekBytes);
    _data = const VaultData();
    await _persist();
  }

  // --------------------------------------------------------------- unlock

  Future<SecretKey> _unwrapDek(String password) async {
    final saltB64 = await _store.read(StoreKeys.kdfSalt);
    final wrappedB64 = await _store.read(StoreKeys.wrappedDek);
    final iter = int.tryParse(await _store.read(StoreKeys.kdfIter) ?? '') ??
        _crypto.iterations;
    if (saltB64 == null || wrappedB64 == null) {
      throw StateError('Vault belum dibuat');
    }
    final kek =
        await _crypto.deriveKey(password, base64Decode(saltB64), iterations: iter);
    try {
      final dek = await _crypto.decrypt(base64Decode(wrappedB64), kek);
      return SecretKey(dek);
    } on SecretBoxAuthenticationError {
      throw WrongPasswordException();
    }
  }

  /// Mengembalikan false bila password salah.
  Future<bool> unlockWithPassword(String password) async {
    try {
      _dek = await _unwrapDek(password);
    } on WrongPasswordException {
      return false;
    }
    await _load();
    return true;
  }

  Future<bool> unlockWithBiometricKey() async {
    final b64 = await _store.read(StoreKeys.bioDek);
    if (b64 == null) return false;
    _dek = SecretKey(base64Decode(b64));
    try {
      await _load();
      return true;
    } catch (_) {
      _dek = null;
      return false;
    }
  }

  void lock() {
    _dek = null;
    _data = const VaultData();
  }

  // ------------------------------------------------------------ biometric

  Future<bool> isBiometricKeyStored() async =>
      (await _store.read(StoreKeys.bioDek)) != null;

  Future<void> storeBiometricKey() async {
    final dek = _dek;
    if (dek == null) return;
    final bytes = await dek.extractBytes();
    await _store.write(StoreKeys.bioDek, base64Encode(bytes));
  }

  Future<void> removeBiometricKey() => _store.delete(StoreKeys.bioDek);

  // ------------------------------------------------------ master password

  /// Ganti master password. Data tidak perlu dienkripsi ulang (DEK tetap).
  Future<void> changeMasterPassword(String oldPw, String newPw) async {
    final dek = await _unwrapDek(oldPw); // melempar WrongPasswordException
    final salt = _crypto.randomBytes(CryptoService.saltLength);
    final kek = await _crypto.deriveKey(newPw, salt);
    final wrapped = await _crypto.encrypt(await dek.extractBytes(), kek);
    await _store.write(StoreKeys.kdfSalt, base64Encode(salt));
    await _store.write(StoreKeys.kdfIter, '${_crypto.iterations}');
    await _store.write(StoreKeys.wrappedDek, base64Encode(wrapped));
  }

  // ----------------------------------------------------------------- CRUD

  Future<void> upsert(Credential c) async {
    final list = [..._data.credentials];
    final i = list.indexWhere((e) => e.id == c.id);
    if (i >= 0) {
      list[i] = c;
    } else {
      list.add(c);
    }
    _data = _data.copyWith(credentials: list);
    await _persist();
  }

  Future<void> delete(String id) async {
    _data = _data.copyWith(
      credentials: _data.credentials.where((e) => e.id != id).toList(),
    );
    await _persist();
  }

  Future<void> addCustomService(CustomService s) async {
    _data = _data.copyWith(customServices: [..._data.customServices, s]);
    await _persist();
  }

  // ---------------------------------------------------------- persistence

  Future<void> _persist() async {
    final dek = _dek;
    if (dek == null) throw StateError('Vault terkunci');
    final enc = await _crypto.encrypt(_data.encode(), dek);
    final file = await _file();
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsBytes(enc, flush: true);
    await tmp.rename(file.path); // tulis atomik
  }

  Future<void> _load() async {
    final dek = _dek!;
    final file = await _file();
    if (!await file.exists()) {
      _data = const VaultData();
      return;
    }
    final clear = await _crypto.decrypt(await file.readAsBytes(), dek);
    _data = VaultData.decode(clear);
  }

  // -------------------------------------------------------- backup/restore

  /// Backup terenkripsi (AES-256-GCM, kunci dari [backupPassword]).
  Future<Uint8List> exportBackup(String backupPassword) async {
    if (!isUnlocked) throw StateError('Vault terkunci');
    final salt = _crypto.randomBytes(CryptoService.saltLength);
    final key = await _crypto.deriveKey(backupPassword, salt);
    final enc = await _crypto.encrypt(_data.encode(), key);
    final envelope = jsonEncode({
      'app': 'vaulte',
      'v': 1,
      'iter': _crypto.iterations,
      'salt': base64Encode(salt),
      'data': base64Encode(enc),
    });
    return Uint8List.fromList(utf8.encode(envelope));
  }

  /// Gabungkan isi backup ke vault. Mengembalikan jumlah entri yang ditambah
  /// atau diperbarui (entri dengan id sama diganti jika lebih baru).
  Future<int> importBackup(List<int> bytes, String backupPassword) async {
    if (!isUnlocked) throw StateError('Vault terkunci');
    Map<String, dynamic> env;
    try {
      env = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    } catch (_) {
      throw InvalidBackupException('Berkas bukan backup Vaulte yang valid.');
    }
    if (env['app'] != 'vaulte' || env['salt'] == null || env['data'] == null) {
      throw InvalidBackupException('Berkas bukan backup Vaulte yang valid.');
    }
    final key = await _crypto.deriveKey(
      backupPassword,
      base64Decode(env['salt'] as String),
      iterations: (env['iter'] as num?)?.toInt() ?? _crypto.iterations,
    );
    VaultData incoming;
    try {
      final clear =
          await _crypto.decrypt(base64Decode(env['data'] as String), key);
      incoming = VaultData.decode(clear);
    } on SecretBoxAuthenticationError {
      throw WrongPasswordException();
    }

    final byId = {for (final c in _data.credentials) c.id: c};
    var changed = 0;
    for (final c in incoming.credentials) {
      final existing = byId[c.id];
      if (existing == null || c.updatedAt.isAfter(existing.updatedAt)) {
        byId[c.id] = c;
        changed++;
      }
    }
    final customById = {for (final s in _data.customServices) s.id: s};
    for (final s in incoming.customServices) {
      customById.putIfAbsent(s.id, () => s);
    }
    _data = VaultData(
      credentials: byId.values.toList(),
      customServices: customById.values.toList(),
    );
    await _persist();
    return changed;
  }
}
