import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vaulte/core/crypto/crypto_service.dart';
import 'package:vaulte/data/models/credential.dart';
import 'package:vaulte/data/repositories/vault_repository.dart';

import 'helpers.dart';

Credential cred(String id, {String pw = 'pw', DateTime? at}) {
  final t = at ?? DateTime(2026, 1, 1);
  return Credential(
    id: id,
    serviceId: 'github',
    serviceName: 'GitHub',
    username: 'me@example.com',
    password: pw,
    createdAt: t,
    updatedAt: t,
  );
}

void main() {
  late Directory dir;
  late MemoryStore store;
  late VaultRepository repo;

  VaultRepository make() => VaultRepository(
        store,
        CryptoService(iterations: 1000),
        directory: dir,
      );

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('vaulte_test');
    store = MemoryStore();
    repo = make();
  });

  tearDown(() => dir.delete(recursive: true));

  test('buat vault, simpan, kunci, buka kembali', () async {
    await repo.createVault('master-pass-123');
    await repo.upsert(cred('1'));
    repo.lock();
    expect(repo.isUnlocked, isFalse);

    final fresh = make();
    expect(await fresh.unlockWithPassword('salah'), isFalse);
    expect(await fresh.unlockWithPassword('master-pass-123'), isTrue);
    expect(fresh.data.credentials.single.username, 'me@example.com');
  });

  test('berkas di disk tidak berisi teks asli', () async {
    await repo.createVault('master-pass-123');
    await repo.upsert(cred('1', pw: 'SANGAT-RAHASIA'));
    final raw = latin1
        .decode(await File('${dir.path}/vault.enc').readAsBytes());
    expect(raw.contains('SANGAT-RAHASIA'), isFalse);
    expect(raw.contains('GitHub'), isFalse);
  });

  test('master password tidak disimpan dalam bentuk asli', () async {
    await repo.createVault('master-pass-123');
    for (final v in [
      await store.read('kdf_salt'),
      await store.read('wrapped_dek'),
    ]) {
      expect(v, isNot(contains('master-pass-123')));
    }
  });

  test('ganti master password tanpa kehilangan data', () async {
    await repo.createVault('lama-lama-123');
    await repo.upsert(cred('1'));
    await repo.changeMasterPassword('lama-lama-123', 'baru-baru-456');
    repo.lock();
    final fresh = make();
    expect(await fresh.unlockWithPassword('lama-lama-123'), isFalse);
    expect(await fresh.unlockWithPassword('baru-baru-456'), isTrue);
    expect(fresh.data.credentials.length, 1);
  });

  test('ganti master password dengan password lama salah ditolak', () async {
    await repo.createVault('lama-lama-123');
    expect(() => repo.changeMasterPassword('salah', 'baru-baru-456'),
        throwsA(isA<WrongPasswordException>()));
  });

  test('backup & restore terenkripsi', () async {
    await repo.createVault('master-pass-123');
    await repo.upsert(cred('1'));
    await repo.upsert(cred('2'));
    final backup = await repo.exportBackup('backup-pass');

    await repo.delete('1');
    await repo.delete('2');
    expect(repo.data.credentials, isEmpty);

    expect(() => repo.importBackup(backup, 'salah'),
        throwsA(isA<WrongPasswordException>()));
    final n = await repo.importBackup(backup, 'backup-pass');
    expect(n, 2);
    expect(repo.data.credentials.length, 2);
  });

  test('restore berkas sembarang ditolak', () async {
    await repo.createVault('master-pass-123');
    expect(() => repo.importBackup([1, 2, 3], 'x'),
        throwsA(isA<InvalidBackupException>()));
  });
}
