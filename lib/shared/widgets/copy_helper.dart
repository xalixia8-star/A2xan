import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import 'dialogs.dart';

/// Salin teks ke clipboard (dibersihkan otomatis) + haptic + snackbar.
Future<void> copyValue(WidgetRef ref, String text, String label) async {
  final secs = ref.read(settingsProvider).clipboardSeconds;
  await ref.read(clipboardProvider).copy(text, clearAfterSeconds: secs);
  HapticFeedback.lightImpact();
  showSnack('$label disalin • dihapus otomatis dalam $secs detik');
}
