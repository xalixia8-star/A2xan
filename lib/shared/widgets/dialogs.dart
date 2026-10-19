import 'package:flutter/material.dart';

import '../../core/utils/nav.dart';
import '../../core/utils/routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Dialog dengan fade in 350 ms / out 300 ms.
Future<T?> showAppDialog<T>(BuildContext context, {required WidgetBuilder builder}) {
  return showDialog<T>(
    context: context,
    animationStyle: Motion.overlayStyle,
    builder: builder,
  );
}

/// Bottom sheet dengan fade in 350 ms / out 300 ms.
Future<T?> showAppSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    sheetAnimationStyle: Motion.overlayStyle,
    builder: builder,
  );
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Ya',
  bool destructive = false,
}) async {
  final res = await showAppDialog<bool>(
    context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Batal', style: AppText.body(14, color: AppColors.champagneMuted)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            confirmLabel,
            style: AppText.body(14,
                weight: 600,
                color: destructive ? AppColors.danger : AppColors.gold),
          ),
        ),
      ],
    ),
  );
  return res ?? false;
}

/// Snackbar singkat.
void showSnack(String message) {
  final m = messengerKey.currentState;
  if (m == null) return;
  m
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
}
