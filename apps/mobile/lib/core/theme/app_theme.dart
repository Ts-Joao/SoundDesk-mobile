import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens. Spacing/radius live here so widgets never hardcode them.
class Tk {
  static const s4 = 4.0, s8 = 8.0, s12 = 12.0, s16 = 16.0, s24 = 24.0, s32 = 32.0;
  static const rSm = 6.0, rMd = 10.0, rLg = 14.0;
}

class AppTheme {
  static final light = _build(Brightness.light);
  static final dark = _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final d = b == Brightness.dark;
    final bg = d ? const Color(0xFF0F1115) : const Color(0xFFF7F7F5);
    final surface = d ? const Color(0xFF171A20) : Colors.white;
    final elevated = d ? const Color(0xFF1D2128) : Colors.white;
    final text = d ? const Color(0xFFF3F4F6) : const Color(0xFF171717);
    final text2 = d ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final border = d ? const Color(0xFF272B33) : const Color(0xFFE5E7EB);
    final accent = d ? const Color(0xFF5DB1B7) : const Color(0xFF2F7F86);

    final scheme = ColorScheme(
      brightness: b,
      primary: accent,
      onPrimary: d ? const Color(0xFF0F1115) : Colors.white,
      secondary: accent,
      onSecondary: d ? const Color(0xFF0F1115) : Colors.white,
      error: d ? const Color(0xFFE5786F) : const Color(0xFFC0392B),
      onError: Colors.white,
      surface: surface,
      onSurface: text,
      onSurfaceVariant: text2,
      outline: border,
      outlineVariant: border,
      surfaceContainerHighest: elevated,
      surfaceContainerHigh: elevated,
      surfaceContainer: surface,
    );

    final base = ThemeData(brightness: b, useMaterial3: true);
    final tt = GoogleFonts.interTextTheme(base.textTheme).apply(bodyColor: text, displayColor: text).copyWith(
          headlineSmall: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: text),
          titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: text),
          titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: text),
          bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: text),
          bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: text),
          bodySmall: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w400, color: text2),
          labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: tt,
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: bg, surfaceTintColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0,
        titleTextStyle: tt.titleLarge, centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface, indicatorColor: accent.withValues(alpha: 0.14), elevation: 0,
        surfaceTintColor: Colors.transparent, height: 64,
        labelTextStyle: WidgetStatePropertyAll(GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: elevated, surfaceTintColor: Colors.transparent, showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Tk.rLg))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: elevated, surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tk.rLg), side: BorderSide(color: border)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: surface, isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Tk.rMd), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Tk.rMd), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Tk.rMd), borderSide: BorderSide(color: accent, width: 1.5)),
        hintStyle: TextStyle(color: text2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48), textStyle: tt.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tk.rMd)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent, linearTrackColor: border, linearMinHeight: 3),
      sliderTheme: SliderThemeData(
        trackHeight: 3, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: SliderComponentShape.noOverlay, activeTrackColor: accent,
        inactiveTrackColor: border, thumbColor: accent,
      ),
    );
  }
}
