/// Menahan auto-lock sementara saat aplikasi sengaja berpindah ke luar
/// (dialog biometrik, pemilih berkas, share sheet), agar tidak terkunci
/// sendiri ketika event lifecycle `paused` terpicu.
class LockGuard {
  LockGuard._();

  static DateTime _until = DateTime.fromMillisecondsSinceEpoch(0);
  static int _depth = 0;

  static bool get suppressed =>
      _depth > 0 || DateTime.now().isBefore(_until);

  static Future<T> run<T>(Future<T> Function() action) async {
    _depth++;
    try {
      return await action();
    } finally {
      _depth--;
      // Beri jeda karena event resume tiba sedikit setelah aksi selesai.
      _until = DateTime.now().add(const Duration(milliseconds: 1500));
    }
  }
}
