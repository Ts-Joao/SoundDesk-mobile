import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens. Spacing/radius and brand gradients live here.
class Tk {
  static const s4 = 4.0, s8 = 8.0, s12 = 12.0, s16 = 16.0, s24 = 24.0, s32 = 32.0;
  static const rSm = 8.0, rMd = 14.0, rLg = 20.0, rFull = 999.0;

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
  );
}

class AppTheme {
  static final light = _build(Brightness.light);
  static final dark = _build(Brightness.dark);

  static TextStyle _display({required double size, required FontWeight w, double? spacing, Color? color}) =>
      GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: w, letterSpacing: spacing ?? -0.2, height: 1.12, color: color);

  static ThemeData _build(Brightness b) {
    final d = b == Brightness.dark;

    // Deep Obsidian / Radiant Neon Violet-Rose Palette
    final bg = d ? const Color(0xFF090A0E) : const Color(0xFFF7F8FC);
    final surface = d ? const Color(0xFF13141C) : Colors.white;
    final elevated = d ? const Color(0xFF1C1D27) : const Color(0xFFF0F2F9);
    final text = d ? const Color(0xFFF9FAFC) : const Color(0xFF0F172A);
    final text2 = d ? const Color(0xFF949BAC) : const Color(0xFF64748B);
    final border = d ? const Color(0xFF282A38) : const Color(0xFFE2E6EF);

    // Electric Iris Violet (primary) & Neon Coral (secondary)
    final accent = d ? const Color(0xFF8B5CF6) : const Color(0xFF7C3AED);
    final secondary = d ? const Color(0xFFFF5E7E) : const Color(0xFFE11D48);
    final press = d ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05);
    final hover = d ? const Color(0xFF8B5CF6).withValues(alpha: 0.08) : const Color(0xFF7C3AED).withValues(alpha: 0.06);

    final scheme = ColorScheme(
      brightness: b,
      primary: accent,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: d ? const Color(0xFFFF4D4D) : const Color(0xFFDC2626),
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
      headlineSmall: _display(size: 26, w: FontWeight.w700, color: text),
      titleLarge: _display(size: 20, w: FontWeight.w700, spacing: -0.2, color: text),
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
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: tt.titleLarge,
        centerTitle: false,
        iconTheme: IconThemeData(color: text),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent.withValues(alpha: 0.18),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tk.rFull)),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        height: 66,
        labelTextStyle: WidgetStateProperty.resolveWith((s) => GoogleFonts.manrope(
            fontSize: 11.5,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? accent : text2)),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? accent : text2,
            size: 24)),
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(border: Border(bottom: BorderSide(color: accent, width: 3))),
        labelColor: accent,
        unselectedLabelColor: text2,
        labelStyle: GoogleFonts.manrope(fontSize: 13.5, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.manrope(fontSize: 13.5, fontWeight: FontWeight.w500),
        overlayColor: WidgetStatePropertyAll(hover),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: elevated,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: text2.withValues(alpha: 0.4),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Tk.rLg))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: elevated,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: tt.titleMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tk.rLg), side: BorderSide(color: border)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Tk.rMd), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Tk.rMd), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Tk.rMd), borderSide: BorderSide(color: accent, width: 1.8)),
        hintStyle: TextStyle(color: text2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(accent),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
          textStyle: WidgetStatePropertyAll(tt.labelLarge),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tk.rMd))),
          overlayColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.pressed) ? press : null),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(text),
          side: WidgetStatePropertyAll(BorderSide(color: border)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tk.rMd))),
          overlayColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.pressed) ? press : null),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(accent),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tk.rSm))),
          overlayColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.pressed) ? press : null),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: text2,
        titleTextStyle: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        subtitleTextStyle: tt.bodySmall,
        selectedTileColor: hover,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent, linearTrackColor: border, linearMinHeight: 3),
      sliderTheme: SliderThemeData(
        trackHeight: 3.5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
        overlayShape: SliderComponentShape.noOverlay,
        activeTrackColor: accent,
        inactiveTrackColor: border,
        thumbColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: accent.withValues(alpha: 0.18),
        side: BorderSide(color: border),
        labelStyle: tt.bodySmall,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tk.rMd)),
      ),
    );
  }
}
