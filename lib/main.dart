import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cryptography_flutter/cryptography_flutter.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // PBKDF2/AES-GCM native (Android/iOS) agar derivasi kunci 600.000 iterasi
  // cepat dan tidak membuat UI patah-patah.
  FlutterCryptography.enable();

  // Android: minta refresh rate tertinggi (90/120 Hz).
  // iOS: ProMotion 120 Hz via CADisableMinimumFrameDurationOnPhone di Info.plist.
  if (!kIsWeb && Platform.isAndroid) {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (_) {
      // Perangkat tanpa dukungan: abaikan.
    }
  }

  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.espresso,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: VaulteApp()));
}
