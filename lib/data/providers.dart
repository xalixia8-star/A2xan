import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/crypto/crypto_service.dart';
import '../core/security/attempt_limiter.dart';
import '../core/security/biometric_service.dart';
import '../core/security/secure_store.dart';
import '../core/utils/clipboard_service.dart';
import '../core/utils/nav.dart';
import 'catalog/service_catalog.dart';
import 'models/app_settings.dart';
import 'models/credential.dart';
import 'models/service_def.dart';
import 'repositories/vault_repository.dart';

// ------------------------------------------------------------- infrastruktur

final secureStoreProvider = Provider<SecureStore>((ref) => SecureStore());
final cryptoProvider = Provider<CryptoService>((ref) => CryptoService());
final biometricProvider = Provider<BiometricService>((ref) => BiometricService());

final attemptLimiterProvider =
    Provider<AttemptLimiter>((ref) => AttemptLimiter(ref.watch(secureStoreProvider)));

final vaultRepoProvider = Provider<VaultRepository>((ref) =>
    VaultRepository(ref.watch(secureStoreProvider), ref.watch(cryptoProvider)));

final clipboardProvider = Provider<ClipboardService>((ref) {
  final s = ClipboardService();
  ref.onDispose(s.dispose);
  return s;
});

// ------------------------------------------------------------------ settings

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();

  Future<void> load() async {
    final raw = await ref.read(secureStoreProvider).read(StoreKeys.settings);
    state = AppSettings.decode(raw);
  }

  Future<void> update(AppSettings Function(AppSettings) change) async {
    state = change(state);
    await ref.read(secureStoreProvider).write(StoreKeys.settings, state.encode());
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

// ---------------------------------------------------------------------- auth

enum AuthStatus { booting, noVault, locked, unlocked }

enum LoginOutcome { success, wrong, locked }

class LoginResult {
  const LoginResult(this.outcome, {this.lockFor = Duration.zero, this.failures = 0});
  final LoginOutcome outcome;
  final Duration lockFor;
  final int failures;

  int get attemptsLeft =>
      (AttemptLimiter.freeAttempts - failures).clamp(0, AttemptLimiter.freeAttempts).toInt();
}

class AuthNotifier extends Notifier<AuthStatus> {
  @override
  AuthStatus build() => AuthStatus.booting;

  VaultRepository get _repo => ref.read(vaultRepoProvider);

  Future<void> bootstrap() async {
    await ref.read(settingsProvider.notifier).load();
    state = await _repo.hasVault() ? AuthStatus.locked : AuthStatus.noVault;
  }

  Future<void> createVault(String password, {required bool enableBiometric}) async {
    await _repo.createVault(password);
    if (enableBiometric) {
      await _repo.storeBiometricKey();
      await ref
          .read(settingsProvider.notifier)
          .update((s) => s.copyWith(biometricEnabled: true));
    }
    ref.invalidate(vaultProvider);
    state = AuthStatus.unlocked;
  }

  Future<LoginResult> login(String password) async {
    final limiter = ref.read(attemptLimiterProvider);
    final remaining = await limiter.remaining();
    if (remaining > Duration.zero) {
      return LoginResult(LoginOutcome.locked,
          lockFor: remaining, failures: await limiter.failures());
    }
    final ok = await _repo.unlockWithPassword(password);
    if (ok) {
      await limiter.reset();
      _afterUnlock();
      return const LoginResult(LoginOutcome.success);
    }
    final d = await limiter.registerFailure();
    final failures = await limiter.failures();
    return LoginResult(
      d > Duration.zero ? LoginOutcome.locked : LoginOutcome.wrong,
      lockFor: d,
      failures: failures,
    );
  }

  /// Buka dengan biometrik. Mengembalikan true jika berhasil.
  Future<bool> loginWithBiometric() async {
    final settings = ref.read(settingsProvider);
    if (!settings.biometricEnabled) return false;
    final limiter = ref.read(attemptLimiterProvider);
    if (await limiter.remaining() > Duration.zero) return false;
    final ok = await ref
        .read(biometricProvider)
        .authenticate('Buka Vaulte dengan biometrik');
    if (!ok) return false;
    if (!await _repo.unlockWithBiometricKey()) return false;
    await limiter.reset();
    _afterUnlock();
    return true;
  }

  void _afterUnlock() {
    ref.invalidate(vaultProvider);
    HapticFeedback.mediumImpact();
    state = AuthStatus.unlocked;
  }

  /// Kunci vault, hapus data dari memori, tutup semua halaman.
  void lock() {
    if (state != AuthStatus.unlocked) return;
    _repo.lock();
    ref.read(clipboardProvider).clearNow();
    ref.invalidate(vaultProvider);
    navigatorKey.currentState?.popUntil((r) => r.isFirst);
    state = AuthStatus.locked;
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthStatus>(AuthNotifier.new);

// --------------------------------------------------------------------- vault

class VaultNotifier extends Notifier<VaultData> {
  @override
  VaultData build() => ref.read(vaultRepoProvider).data;

  VaultRepository get _repo => ref.read(vaultRepoProvider);

  Future<void> save(Credential c) async {
    await _repo.upsert(c);
    state = _repo.data;
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    state = _repo.data;
  }

  Future<void> toggleFavorite(Credential c) =>
      save(c.copyWith(favorite: !c.favorite, updatedAt: DateTime.now()));

  Future<void> addCustomService(CustomService s) async {
    await _repo.addCustomService(s);
    state = _repo.data;
  }

  Future<int> importBackup(List<int> bytes, String password) async {
    final n = await _repo.importBackup(bytes, password);
    state = _repo.data;
    return n;
  }
}

final vaultProvider =
    NotifierProvider<VaultNotifier, VaultData>(VaultNotifier.new);

/// Katalog bawaan + layanan kustom pengguna.
final allServicesProvider = Provider<List<ServiceDef>>((ref) {
  final custom = ref.watch(vaultProvider.select((v) => v.customServices));
  return [...kServiceCatalog, ...custom.map((e) => e.toDef())];
});

/// Mengubah serviceId menjadi definisi layanan (dengan fallback inisial).
final serviceResolverProvider =
    Provider<ServiceDef Function(String id, String name)>((ref) {
  final all = ref.watch(allServicesProvider);
  final byId = {for (final s in all) s.id: s};
  return (id, name) => byId[id] ?? ServiceDef.fallback(id, name);
});

// ------------------------------------------------------------ filter & sort

enum VaultSort { az, newest, favorites }

final searchQueryProvider = StateProvider<String>((ref) => '');
final categoryFilterProvider = StateProvider<String?>((ref) => null);
final sortProvider = StateProvider<VaultSort>((ref) => VaultSort.az);

int _byName(Credential a, Credential b) =>
    a.serviceName.toLowerCase().compareTo(b.serviceName.toLowerCase());

final filteredCredentialsProvider = Provider<List<Credential>>((ref) {
  final all = ref.watch(vaultProvider.select((v) => v.credentials));
  final q = ref.watch(searchQueryProvider).trim().toLowerCase();
  final cat = ref.watch(categoryFilterProvider);
  final sort = ref.watch(sortProvider);

  final list = all.where((c) {
    if (cat != null && c.category != cat) return false;
    if (q.isEmpty) return true;
    return c.serviceName.toLowerCase().contains(q) ||
        c.username.toLowerCase().contains(q) ||
        c.url.toLowerCase().contains(q);
  }).toList();

  switch (sort) {
    case VaultSort.az:
      list.sort(_byName);
    case VaultSort.newest:
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case VaultSort.favorites:
      list.sort((a, b) {
        if (a.favorite != b.favorite) return a.favorite ? -1 : 1;
        return _byName(a, b);
      });
  }
  return list;
});

final favoriteCredentialsProvider = Provider<List<Credential>>((ref) {
  final all = ref.watch(vaultProvider.select((v) => v.credentials));
  return all.where((c) => c.favorite).toList()..sort(_byName);
});

/// Satu credential berdasarkan id (untuk halaman detail yang selalu terbaru).
final credentialByIdProvider = Provider.family<Credential?, String>((ref, id) {
  final all = ref.watch(vaultProvider.select((v) => v.credentials));
  for (final c in all) {
    if (c.id == id) return c;
  }
  return null;
});
