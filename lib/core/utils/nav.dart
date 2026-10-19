import 'package:flutter/material.dart';

/// Navigator global: dipakai untuk menutup semua halaman saat vault terkunci.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Messenger global untuk snackbar dari luar widget.
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();
