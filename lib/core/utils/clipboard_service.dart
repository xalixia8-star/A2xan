import 'dart:async';

import 'package:flutter/services.dart';

/// Menyalin teks lalu membersihkan clipboard otomatis setelah [seconds].
class ClipboardService {
  Timer? _timer;
  String? _pending;

  Future<void> copy(String text, {required int clearAfterSeconds}) async {
    _timer?.cancel();
    await Clipboard.setData(ClipboardData(text: text));
    _pending = text;
    _timer = Timer(Duration(seconds: clearAfterSeconds), clearNow);
  }

  /// Hapus clipboard bila isinya masih hasil salinan kita.
  Future<void> clearNow() async {
    _timer?.cancel();
    final mine = _pending;
    if (mine == null) return;
    _pending = null;
    try {
      final current = await Clipboard.getData(Clipboard.kTextPlain);
      final text = current?.text;
      // Jangan hapus jika pengguna sudah menyalin hal lain.
      // (Pada Android 10+ pembacaan di background bisa null; tetap bersihkan.)
      if (text == null || text == mine) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    } catch (_) {
      await Clipboard.setData(const ClipboardData(text: ''));
    }
  }

  void dispose() => _timer?.cancel();
}
