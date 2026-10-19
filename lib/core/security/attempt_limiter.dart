import 'secure_store.dart';

/// Membatasi percobaan login salah: 3x salah, lalu delay bertahap
/// (30 dtk, 60 dtk, 2 mnt, 4 mnt ... maks 15 mnt). Disimpan di secure storage
/// sehingga tidak hilang saat aplikasi ditutup.
class AttemptLimiter {
  AttemptLimiter(this._store);

  final SecureStore _store;

  static const int freeAttempts = 3;
  static const int maxDelaySeconds = 900;

  static Duration delayFor(int failures) {
    if (failures < freeAttempts) return Duration.zero;
    final exp = failures - freeAttempts; // 0,1,2...
    final seconds =
        (30 * (1 << exp.clamp(0, 10).toInt())).clamp(30, maxDelaySeconds).toInt();
    return Duration(seconds: seconds);
  }

  Future<int> failures() async =>
      int.tryParse(await _store.read(StoreKeys.failCount) ?? '') ?? 0;

  /// Sisa waktu kunci (Duration.zero jika tidak terkunci).
  Future<Duration> remaining() async {
    final raw = await _store.read(StoreKeys.lockUntil);
    final ms = int.tryParse(raw ?? '');
    if (ms == null) return Duration.zero;
    final left = DateTime.fromMillisecondsSinceEpoch(ms)
        .difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  /// Catat kegagalan; kembalikan durasi kunci yang berlaku.
  Future<Duration> registerFailure() async {
    final n = (await failures()) + 1;
    await _store.write(StoreKeys.failCount, '$n');
    final d = delayFor(n);
    if (d > Duration.zero) {
      final until = DateTime.now().add(d).millisecondsSinceEpoch;
      await _store.write(StoreKeys.lockUntil, '$until');
    }
    return d;
  }

  Future<void> reset() async {
    await _store.delete(StoreKeys.failCount);
    await _store.delete(StoreKeys.lockUntil);
  }
}
