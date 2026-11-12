import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ridlers brand palette.
///
/// A playful, cartoonish identity with a soft blue-gray canvas, sunny yellow
/// `#FFF085`, mint `#CBFBF1`, chunky ink borders, and hard sticker shadows.
class AppTheme {
  AppTheme._();

  // ---- Brand ----
  static const Color primary = Color(0xFFFFF085);
  static const Color primaryDark = Color(0xFFF6CF3F);
  static const Color mint = Color(0xFFCBFBF1);
  static const Color mintDark = Color(0xFF8FE8D3);

  // ---- Accents ----
  static const Color coral = Color(0xFFFF9A76);
  static const Color pink = Color(0xFFFFD3E0);
  static const Color periwinkle = Color(0xFFC7C8FF);
  static const Color sky = Color(0xFFC7E7FF);
  static const Color skyAccent = Color(0xFF468EB7);
  static const Color lavender = Color(0xFFE5D9FF);
  static const Color lemon = Color(0xFFEDFFC9);

  // ---- Surfaces ----
  static const Color surface = Color(0xFFFFFEFA);
  static const Color background = Color(0xFFF4F7F8);
  static const Color backgroundShade = Color(0xFFEEF3F5);
  static const Color cardBg = surface;

  // ---- Text ----
  static const Color ink = Color(0xFF22303C);
  static const Color inkSoft = Color(0xFF566572);
  static const Color inkFaint = Color(0xFF596A75);

  // ---- Lines ----
  static const Color outline = Color(0xFF22303C);
  static const Color divider = Color(0xFFD2E4F0);
  static const Color stickerShadowColor = Color(0xFFB4D1E6);

  static const Color error = Color(0xFFDA4F58);
  static const Color success = Color(0xFF237B5D);

  // Chunky cartoon helpers ------------------------------------------------
  static const double borderWidth = 3;
  static const double inputBorderWidth = 2.5;

  /// Hard "sticker" shadow: offset, zero blur.
  static List<BoxShadow> stickerShadow(Color color, {double dy = 5}) => [
    BoxShadow(
      color: color,
      offset: Offset(0, dy),
      blurRadius: 0,
      spreadRadius: 0,
    ),
  ];

  static BoxDecoration sticker({
    Color color = surface,
    Color shadow = stickerShadowColor,
    Color? borderColor,
    double radius = 24,
    double dy = 5,
    EdgeInsets? padding,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? outline,
        width: borderWidth,
      ),
      boxShadow: stickerShadow(shadow, dy: dy),
    );
  }

  static ColorScheme get _colorScheme => ColorScheme.light(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: ink,
    secondary: mint,
    onSecondary: ink,
    error: error,
    onError: Colors.white,
    surface: surface,
    onSurface: ink,
  );

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme,
      // The shared AppBackdrop paints the mist-blue canvas behind every route.
      scaffoldBackgroundColor: Colors.transparent,
      splashFactory: InkSparkle.splashFactory,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: skyAccent,
        selectionColor: Color(0x55468EB7),
        selectionHandleColor: skyAccent,
      ),
    );

    final textTheme = base.textTheme
        .apply(
          displayColor: ink,
          bodyColor: ink,
        )
        .copyWith(
          displayLarge: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: ink,
            letterSpacing: -1,
            height: 1.05,
          ),
          displayMedium: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: ink,
            letterSpacing: -0.5,
          ),
          headlineMedium: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: ink,
            letterSpacing: -0.4,
          ),
          headlineSmall: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
          titleLarge: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          titleMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          titleSmall: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          bodyLarge: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ink,
            height: 1.4,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            height: 1.35,
            color: inkSoft,
          ),
          bodySmall: const TextStyle(
            fontSize: 12,
            height: 1.3,
            color: inkFaint,
          ),
          labelLarge: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          labelMedium: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: ink),
        titleTextStyle: textTheme.headlineSmall,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: ink,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: outline, width: borderWidth),
          ),
          shadowColor: stickerShadowColor,
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: outline, width: borderWidth),
          ),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: outline, width: inputBorderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: outline, width: inputBorderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: skyAccent, width: borderWidth),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: error, width: inputBorderWidth),
        ),
        labelStyle: const TextStyle(color: inkSoft, fontSize: 15),
        floatingLabelStyle: const TextStyle(color: inkSoft, fontSize: 15),
        hintStyle: const TextStyle(color: inkFaint, fontSize: 15),
        prefixIconColor: inkSoft,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: outline, width: borderWidth),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary,
        labelStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: outline, width: 2),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        showDragHandle: true,
        dragHandleColor: inkFaint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: textTheme.bodyLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 2),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primaryDark),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: ink,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: outline, width: borderWidth),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }
}
