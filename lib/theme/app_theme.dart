import 'package:flutter/material.dart';

import '../core/utils/routes.dart';
import 'app_colors.dart';

/// Gaya teks. Font diunduh oleh tools/bootstrap.sh (assets/fonts).
/// Font variabel: bobot diatur lewat fontVariations.
class AppText {
  AppText._();

  static const String headingFamily = 'CormorantGaramond';
  static const String bodyFamily = 'Inter';

  static TextStyle heading(double size,
      {bool italic = true, int weight = 600, Color? color}) {
    return TextStyle(
      fontFamily: headingFamily,
      fontSize: size,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontWeight: FontWeight.values[(weight ~/ 100) - 1],
      fontVariations: [FontVariation('wght', weight.toDouble())],
      color: color ?? AppColors.champagne,
      height: 1.1,
    );
  }

  static TextStyle body(double size,
      {int weight = 400, Color? color, double? height}) {
    return TextStyle(
      fontFamily: bodyFamily,
      fontSize: size,
      fontWeight: FontWeight.values[(weight ~/ 100) - 1],
      fontVariations: [FontVariation('wght', weight.toDouble())],
      color: color ?? AppColors.champagne,
      height: height,
    );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.burgundy,
      onPrimary: AppColors.champagne,
      secondary: AppColors.gold,
      onSecondary: AppColors.midnight,
      error: AppColors.danger,
      onError: AppColors.midnight,
      surface: AppColors.espresso,
      onSurface: AppColors.champagne,
      surfaceContainerHighest: AppColors.espresso,
      outline: AppColors.gold,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.midnight,
      fontFamily: AppText.bodyFamily,
      splashFactory: InkRipple.splashFactory,
    );

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: w),
        );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: AppText.bodyFamily,
        bodyColor: AppColors.champagne,
        displayColor: AppColors.champagne,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.espresso,
        foregroundColor: AppColors.champagne,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppText.heading(26),
      ),
      cardTheme: CardThemeData(
        color: AppColors.espresso,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: AppColors.goldBorder()),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.espresso,
        labelStyle: AppText.body(14, color: AppColors.champagneMuted),
        hintStyle: AppText.body(14, color: AppColors.champagneMuted),
        prefixIconColor: AppColors.gold,
        suffixIconColor: AppColors.gold,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: border(AppColors.goldBorder(0.25)),
        enabledBorder: border(AppColors.goldBorder(0.25)),
        focusedBorder: border(AppColors.gold, 1.4),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger, 1.4),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.espresso,
        modalBackgroundColor: AppColors.espresso,
        showDragHandle: true,
        dragHandleColor: AppColors.gold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.espresso,
        titleTextStyle: AppText.heading(26),
        contentTextStyle: AppText.body(14, height: 1.45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.goldBorder()),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.espresso,
        contentTextStyle: AppText.body(14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.goldBorder()),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.champagne
                : AppColors.champagneMuted),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.burgundy
                : AppColors.midnight),
        trackOutlineColor:
            WidgetStateProperty.all(AppColors.goldBorder(0.6)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.gold,
        inactiveTrackColor: AppColors.goldBorder(0.25),
        thumbColor: AppColors.gold,
        overlayColor: AppColors.goldBorder(0.15),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.espresso,
        selectedColor: AppColors.burgundy,
        side: BorderSide(color: AppColors.goldBorder(0.35)),
        labelStyle: AppText.body(13),
        checkmarkColor: AppColors.champagne,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.espresso,
        indicatorColor: AppColors.burgundy,
        height: 70,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              color: s.contains(WidgetState.selected)
                  ? AppColors.champagne
                  : AppColors.gold,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => AppText.body(
              12,
              weight: s.contains(WidgetState.selected) ? 600 : 500,
              color: s.contains(WidgetState.selected)
                  ? AppColors.champagne
                  : AppColors.champagneMuted,
            )),
      ),
      dividerTheme: DividerThemeData(color: AppColors.goldBorder(0.18)),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.gold),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: const BorderSide(color: AppColors.gold),
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: AppColors.gold),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeSlideTransitionsBuilder(),
        TargetPlatform.iOS: FadeSlideTransitionsBuilder(),
      }),
    );
  }
}
