import 'dart:convert';

/// Pengaturan non-rahasia (disimpan di secure storage juga agar sederhana).
class AppSettings {
  const AppSettings({
    this.autoLockSeconds = 60,
    this.clipboardSeconds = 30,
    this.biometricEnabled = false,
    this.onboardingDone = false,
  });

  final int autoLockSeconds;
  final int clipboardSeconds;
  final bool biometricEnabled;
  final bool onboardingDone;

  static const List<int> autoLockOptions = [30, 60, 300];
  static const List<int> clipboardOptions = [15, 30, 60];

  AppSettings copyWith({
    int? autoLockSeconds,
    int? clipboardSeconds,
    bool? biometricEnabled,
    bool? onboardingDone,
  }) =>
      AppSettings(
        autoLockSeconds: autoLockSeconds ?? this.autoLockSeconds,
        clipboardSeconds: clipboardSeconds ?? this.clipboardSeconds,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        onboardingDone: onboardingDone ?? this.onboardingDone,
      );

  String encode() => jsonEncode({
        'autoLockSeconds': autoLockSeconds,
        'clipboardSeconds': clipboardSeconds,
        'biometricEnabled': biometricEnabled,
        'onboardingDone': onboardingDone,
      });

  factory AppSettings.decode(String? raw) {
    if (raw == null) return const AppSettings();
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return AppSettings(
        autoLockSeconds: (j['autoLockSeconds'] as num?)?.toInt() ?? 60,
        clipboardSeconds: (j['clipboardSeconds'] as num?)?.toInt() ?? 30,
        biometricEnabled: (j['biometricEnabled'] as bool?) ?? false,
        onboardingDone: (j['onboardingDone'] as bool?) ?? false,
      );
    } catch (_) {
      return const AppSettings();
    }
  }

  static String durationLabel(int seconds) {
    if (seconds < 60) return '$seconds detik';
    final m = seconds ~/ 60;
    return '$m menit';
  }
}
