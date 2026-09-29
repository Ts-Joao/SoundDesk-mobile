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

  // Display type carries personality on titles and the now-playing title.
  // Body stays on a plain grotesk for maximum legibility at small sizes.
  static TextStyle _display({required double size, required FontWeight w, double? spacing, Color? color}) =>
      GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: w, letterSpacing: spacing ?? -0.2, height: 1.12, color: color);

  static ThemeData _build(Brightness b) {
    final d = b == Brightness.dark;
    final bg = d ? const Color(0xFF0F1115) : const Color(0xFFF7F7F5);
    final surface = d ? const Color(0xFF171A20) : Colors.white;
    final elevated = d ? const Color(0xFF1D2128) : Colors.white;
    final text = d ? const Color(0xFFF3F4F6) : const Color(0xFF171717);
    final text2 = d ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final border = d ? const Color(0xFF272B33) : const Color(0xFFE5E7EB);
    // Slightly warmer, more saturated than the original teal so it reads as
    // a chosen brand color rather than a default Material accent.
    final accent = d ? const Color(0xFF6CC0BE) : const Color(0xFF1F7A76);
    final press = d ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04);
    final hover = d ? Colors.white.withValues(alpha: 0.035) : Colors.black.withValues(alpha: 0.025);

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
    final body = GoogleFonts.manropeTextTheme(base.textTheme).apply(bodyColor: text, displayColor: text);
    final tt = body.copyWith(
      headlineSmall: _display(size: 26, w: FontWeight.w600, color: text),
      titleLarge: _display(size: 19, w: FontWeight.w600, spacing: -0.1, color: text),
      titleMedium: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.1, color: text),
      bodyLarge: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w500, color: text),
      bodyMedium: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w400, color: text),
      bodySmall: GoogleFonts.manrope(fontSize: 12.5, fontWeight: FontWeight.w500, color: text2),
      labelLarge: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.1),
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: tt,
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: bg, surfaceTintColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0,
        titleTextStyle: tt.titleLarge, centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface, indicatorColor: accent.withValues(alpha: 0.16), elevation: 0,
        surfaceTintColor: Colors.transparent, height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((s) => GoogleFonts.manrope(
            fontSize: 11.5, fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? text : text2)),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? text : text2, size: 24)),
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent, indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(border: Border(bottom: BorderSide(color: accent, width: 2.5))),
        labelColor: text, unselectedLabelColor: text2,
        labelStyle: GoogleFonts.manrope(fontSize: 13.5, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.manrope(fontSize: 13.5, fontWeight: FontWeight.w500),
        overlayColor: WidgetStatePropertyAll(hover),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: elevated, surfaceTintColor: Colors.transparent, showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Tk.rLg))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: elevated, surfaceTintColor: Colors.transparent,
        titleTextStyle: tt.titleMedium,
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
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
          textStyle: WidgetStatePropertyAll(tt.labelLarge),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tk.rMd))),
          overlayColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.pressed) ? press : null),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(overlayColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.pressed) ? press : null)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(overlayColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.pressed) ? press : null)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: text2,
        titleTextStyle: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        subtitleTextStyle: tt.bodySmall,
        selectedTileColor: hover,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent, linearTrackColor: border, linearMinHeight: 3),
      sliderTheme: SliderThemeData(
        trackHeight: 3, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: SliderComponentShape.noOverlay, activeTrackColor: accent,
        inactiveTrackColor: border, thumbColor: accent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface, selectedColor: accent.withValues(alpha: 0.16),
        side: BorderSide(color: border), labelStyle: tt.bodySmall,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tk.rMd)),
      ),
    );
  }
}
